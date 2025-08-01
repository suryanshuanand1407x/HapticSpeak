//
//  HomeView.swift
//  HapticSpeech
//
//  Created by Suryanshu on 31/07/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack {
            Image(systemName: "waveform")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("HapticSpeech")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Speech to Haptic Feedback Converter")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 20)
            
            Button(action: {
                print("🚨 BUTTON TAPPED!")
                viewModel.toggleRecording()
            }) {
                Text(viewModel.isRecording ? "Stop Recording" : "Start Recording")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(viewModel.isRecording ? Color.red : Color.blue)
                    .cornerRadius(10)
            }
            .padding()
            
            if viewModel.isProcessing {
                ProgressView("Processing speech...")
                    .padding()
            }
            
            if !viewModel.recognizedText.isEmpty {
                Text("Recognized Text:")
                    .font(.headline)
                    .padding(.top)
                
                Text(viewModel.recognizedText)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            
            Spacer()
            
            HStack {
                Button(action: {
                    // Navigate to settings
                }) {
                    Image(systemName: "gear")
                        .font(.title2)
                }
                
                Spacer()
                
                Button(action: {
                    // Navigate to analytics
                }) {
                    Image(systemName: "chart.bar")
                        .font(.title2)
                }
            }
            .padding()
        }
        .padding()
    }
}