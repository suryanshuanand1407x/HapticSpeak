//
//  BLEManager.swift
//  HapticSpeech
//
//  Created by Suryanshu on 31/07/25.
//

import Foundation
import CoreBluetooth
import Combine

enum ConnectionState {
    case disconnected
    case scanning
    case connecting
    case connected
}

class BLEManager: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var isScanning = false
    @Published var discoveredPeripherals: [HapticPeripheral] = []
    @Published var connectedPeripheral: HapticPeripheral?
    @Published var isBluetoothEnabled = false
    @Published var connectionState: ConnectionState = .disconnected
    
    // MARK: - Private Properties
    private var centralManager: CBCentralManager!
    private let hapticServiceUUID = CBUUID(string: "1815") // Standard BLE Service for Haptic Feedback
    private let hapticCharacteristicUUID = CBUUID(string: "2A4D") // Custom characteristic for haptic patterns
    
    // MARK: - Initialization
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - Public Methods
    func startScanning() {
        guard centralManager.state == .poweredOn else {
            print("Bluetooth is not powered on")
            return
        }
        
        isScanning = true
        connectionState = .scanning
        discoveredPeripherals.removeAll()
        
        // Scan for peripherals that advertise the haptic service
        centralManager.scanForPeripherals(withServices: [hapticServiceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        
        // Stop scanning after 10 seconds to conserve battery
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { [weak self] in
            self?.stopScanning()
        }
    }
    
    func stopScanning() {
        centralManager.stopScan()
        isScanning = false
        if connectionState == .scanning {
            connectionState = .disconnected
        }
    }
    
    func connect(to peripheral: HapticPeripheral) {
        stopScanning()
        connectionState = .connecting
        centralManager.connect(peripheral.peripheral, options: nil)
    }
    
    func disconnect() {
        guard let peripheral = connectedPeripheral else { return }
        connectionState = .disconnected
        centralManager.cancelPeripheralConnection(peripheral.peripheral)
    }
    
    func sendHapticPatterns(_ patterns: [VibePattern]) {
        guard let peripheral = connectedPeripheral else {
            print("No peripheral connected")
            return
        }
        
        for pattern in patterns {
            let data = pattern.toData()
            peripheral.sendVibePattern(data)
            
            // Add small delay between patterns
            Thread.sleep(forTimeInterval: pattern.duration + pattern.delay)
        }
    }
}

// MARK: - CBCentralManagerDelegate
extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            isBluetoothEnabled = true
            print("Bluetooth is powered on")
        case .poweredOff:
            isBluetoothEnabled = false
            print("Bluetooth is powered off")
        case .resetting:
            print("Bluetooth is resetting")
        case .unauthorized:
            print("Bluetooth is unauthorized")
        case .unsupported:
            print("Bluetooth is unsupported")
        case .unknown:
            print("Bluetooth state is unknown")
        @unknown default:
            print("Unknown Bluetooth state")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let hapticPeripheral = HapticPeripheral(peripheral: peripheral, rssi: RSSI.intValue)
        
        // Check if we already discovered this peripheral
        if !discoveredPeripherals.contains(where: { $0.id == hapticPeripheral.id }) {
            discoveredPeripherals.append(hapticPeripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "Unknown")")
        connectionState = .connected
        
        // Find the HapticPeripheral object that matches this peripheral
        if let index = discoveredPeripherals.firstIndex(where: { $0.peripheral.identifier == peripheral.identifier }) {
            let hapticPeripheral = discoveredPeripherals[index]
            hapticPeripheral.peripheral.delegate = self
            hapticPeripheral.peripheral.discoverServices([hapticServiceUUID])
            connectedPeripheral = hapticPeripheral
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral.name ?? "Unknown"): \(error?.localizedDescription ?? "Unknown error")")
        connectionState = .disconnected
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            print("Disconnected from \(peripheral.name ?? "Unknown") with error: \(error.localizedDescription)")
        } else {
            print("Disconnected from \(peripheral.name ?? "Unknown")")
        }
        
        connectionState = .disconnected
        connectedPeripheral = nil
    }
}

// MARK: - CBPeripheralDelegate
extension BLEManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else { return }
        
        for service in services {
            if service.uuid == hapticServiceUUID {
                peripheral.discoverCharacteristics([hapticCharacteristicUUID], for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            if characteristic.uuid == hapticCharacteristicUUID {
                // Store the characteristic in the HapticPeripheral object
                connectedPeripheral?.hapticCharacteristic = characteristic
                print("Found haptic characteristic")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error writing value to characteristic: \(error.localizedDescription)")
        } else {
            print("Successfully wrote value to characteristic")
        }
    }
}