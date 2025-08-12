from __future__ import annotations

from pathlib import Path
import argparse
import json

import torch
import torch.nn as nn
from torch.utils.data import DataLoader

from scripts.utils.phoneme_dataset import PhonemeJsonDataset, PHONES_39_WITH_BLANK, phoneme_collate_fn
from scripts.models.ctc_baseline import CTCBaseline


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument('--manifest', type=Path, default=Path('data/processed/manifests/train_librispeech_39.json'))
    p.add_argument('--batch-size', type=int, default=4)
    p.add_argument('--epochs', type=int, default=1)
    p.add_argument('--steps', type=int, default=200)
    p.add_argument('--lr', type=float, default=1e-3)
    p.add_argument('--max-frames', type=int, default=1600)
    p.add_argument('--num-workers', type=int, default=2)
    p.add_argument('--amp', action='store_true')
    p.add_argument('--device', type=str, default='cuda')
    p.add_argument('--sanity-steps', type=int, default=10)
    return p.parse_args()


def train_one_epoch(model, loader, optimizer, scaler, criterion, device, use_amp: bool, max_steps: int):
    model.train()
    step = 0
    for batch in loader:
        mels = batch['mels'].to(device)               # (B, 80, T)
        phone_seqs = batch['phones']                  # list of tensors (var-length)
        mel_lens = batch['mel_lens'].to(device)
        phone_lens = batch['phone_lens'].to(device)

        # Pack targets for CTC
        targets = torch.cat(phone_seqs).to(device)
        logits, time_lens = model(mels)
        log_probs = logits.log_softmax(dim=-1).transpose(0, 1)  # (T, B, C)

        optimizer.zero_grad(set_to_none=True)
        if use_amp:
            # Use autocast in half precision and scale/backward before stepping
            with torch.autocast(device_type='cuda', dtype=torch.float16):
                loss = criterion(log_probs, targets, time_lens, phone_lens)
            scaler.scale(loss).backward()
            scaler.step(optimizer)
            scaler.update()
        else:
            loss = criterion(log_probs, targets, time_lens, phone_lens)
            loss.backward()
            optimizer.step()

        if step % 10 == 0:
            print(f"step {step} loss {loss.item():.4f}")
        step += 1
        if max_steps and step >= max_steps:
            break


def main():
    args = parse_args()
    device = 'cuda' if args.device == 'cuda' and torch.cuda.is_available() else 'cpu'

    ds = PhonemeJsonDataset(args.manifest, max_frames=args.max_frames)
    loader = DataLoader(
        ds,
        batch_size=args.batch_size,
        shuffle=True,
        num_workers=args.num_workers,
        collate_fn=phoneme_collate_fn,
        pin_memory=(device == 'cuda'),
    )

    num_classes = len(PHONES_39_WITH_BLANK)
    model = CTCBaseline(num_mels=80, num_classes=num_classes).to(device)

    optimizer = torch.optim.AdamW(model.parameters(), lr=args.lr)
    criterion = nn.CTCLoss(blank=num_classes - 1, zero_infinity=True)

    use_amp = args.amp and device == 'cuda'
    try:
        scaler = torch.amp.GradScaler('cuda', enabled=use_amp)
    except Exception:
        # Fallback for older torch
        scaler = torch.cuda.amp.GradScaler(enabled=use_amp)

    print(f"Device: {device}, AMP: {use_amp}, Steps: {args.steps}")
    train_one_epoch(model, loader, optimizer, scaler, criterion, device, use_amp, max_steps=args.steps)

    # Save a small checkpoint
    ckpt_path = Path('data/processed/checkpoints/ctc_baseline.pt')
    ckpt_path.parent.mkdir(parents=True, exist_ok=True)
    torch.save({'model_state_dict': model.state_dict()}, ckpt_path)
    print(f"Saved checkpoint to {ckpt_path}")


if __name__ == '__main__':
    main()
