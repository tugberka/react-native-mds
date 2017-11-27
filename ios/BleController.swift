import Foundation
import UIKit

final class BleController: NSObject, CBCentralManagerDelegate {
    static let SCAN_TIMEOUT = 15.0
    let MOVESENSE_SERVICES = [CBUUID(string: "61353090-8231-49cc-b57a-886370740041")]
    
    private var centralManager : CBCentralManager?
    private var scanTimer = Timer() //!< When timer triggers, scanning is stopped
    private var knownDevices = Dictionary<UUID, String>() //!< Map UUID to Serial
    private var knownDevicesFetched : Optional<() -> ()>
    var bleOnOff : ((Bool) -> ())?
    private var addDeviceCallback : (MovesenseDevice) -> () = { (device) in }
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil, options:nil)
    }
    
    private func isKnown(uuid: UUID) -> Bool {
        return self.knownDevices.contains { elem in
            elem.key == uuid
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let state = central.state
        
        switch state {
        case CBManagerState.poweredOff:
            self.bleOnOff?(false)
        case CBManagerState.poweredOn:
            self.bleOnOff?(true)
            self.retrieveFromSystem()
        default:
            () // Nothing to do
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber)
    {
        print("didDiscoverPeripheral: \(peripheral)")
        
        let uuid = peripheral.identifier
        if (advertisementData.contains { key, _ in key == CBAdvertisementDataLocalNameKey})
        {
            let localName = advertisementData[CBAdvertisementDataLocalNameKey] as! String
            
            if !localName.isEmpty && isMovesense(localName) {
                // Show only Movesense devices as the others are not able to connect with the attached lib
                let serial = self.parseSerial(localName)
                self.knownDevices[uuid as UUID] = serial
                let device = MovesenseDevice(uuid: uuid as UUID, localName: localName, serial: serial, info: nil, linkStatus: false)
                self.addDeviceCallback(device)
            }
        }
    }
    
    func startScan(deviceFound: @escaping (MovesenseDevice) -> (), scanReady: @escaping () -> ()) {
        if (self.centralManager?.isScanning)! {
            return
        }
        
        self.addDeviceCallback = deviceFound
        
        self.centralManager?.scanForPeripherals(withServices: MOVESENSE_SERVICES, options:
            [CBCentralManagerScanOptionAllowDuplicatesKey: true]);
        
        self.scanTimer.invalidate()
        
        Timer.scheduledTimer(withTimeInterval: BleController.SCAN_TIMEOUT, repeats: true, block: { _ in
            self.stopScan()
            scanReady()
        })
        
        self.retrieveFromSystem()
    }
    
    func stopScan() {
        self.scanTimer.invalidate()
        
        if !(self.centralManager?.isScanning)! {
            return
        }
        
        if self.centralManager?.state == .poweredOn {
            self.centralManager?.stopScan()
        }
    }
    
    private func isMovesense(_ localName: String) -> Bool {
        let index = localName.characters.index(of: " ") ?? localName.endIndex
        return localName[localName.startIndex..<index] == "Movesense"
    }
    
    private func parseSerial(_ localName: String) -> String {
        let idx = localName.index(localName.endIndex, offsetBy: -12)
        return localName.substring(from: idx)
    }
    
    func retrieveFromSystem()
    {
        // Fetch the peripherals already known to the system
        let connected = self.centralManager!.retrieveConnectedPeripherals(withServices: MOVESENSE_SERVICES)
        for peripheral in connected
        {
            print("Found known device: \(peripheral)")
            let uuid = peripheral.identifier
            let localName = peripheral.name!
            
            if isMovesense(localName) {
                // Show only Movesense devices as the others are not able to connect with the attached lib
                let serial = self.parseSerial(localName)
                let device = MovesenseDevice(uuid: uuid as UUID,
                                             localName: localName,
                                             serial: serial,
                                             info: nil,
                                             linkStatus: true)
                
                self.addDeviceCallback(device)
                
                self.knownDevices[uuid as UUID] = serial
            }
        }
        //self.knownDevicesFetched!()
    }
}
