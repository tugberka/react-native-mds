import Foundation

/// The main class for using the services from Movesense devices.
/// This class offers a way to enumerate the devices and receive connected/disconnected
/// callbacks when the devices become available
final public class MdsService: NSObject {
    internal var mds : MDSWrapper!
    private var subscriptions = Dictionary<String, Bool>()
    private var devices = Dictionary<String, MovesenseDevice>()
    private var bleController : BleController!
    
    public override init() {
        super.init()
        self.mds = MDSWrapper()
        self.bleController = BleController()
    }
    
    public func shutdown() {
        self.mds!.deactivate();
    }
    
    /// Start looking for Movesense devices
    public func startScan(_ deviceFound : @escaping (MovesenseDevice) -> (),
                          _ scanCompleted: @escaping () -> ()) {
            self.bleController.startScan(deviceFound: { device in
                self.devices[device.serial] = device
                deviceFound(device)
            },scanReady : {
                scanCompleted()
            });
    }
    
    /// Stop looking for Movesense devices
    public func stopScan() {
        self.bleController.stopScan()
    }
    
    /// Establish a connection to the specific Movesense device
    public func connectDevice(_ address : String) {
        let uuid = UUID.init(uuidString: address)
        self.bleController.stopScan();
        self.mds.connectPeripheral(with: uuid!);
    }
    
    /// Disconnect specific Movesense device
    public func disconnectDevice(_ address : String) {
        let uuid = UUID.init(uuidString: address)
        self.mds.disconnectPeripheral(with: uuid!);
    }
    
    /// Subscribe to a specified resource
    public func subscribe(_ uri: String,
                          parameters: Dictionary<String, Any>,
                          onNotify : @escaping (String) -> (),
                          onError : @escaping (String, String) -> ()) {
        
        self.mds!.doSubscribe(uri,
                              contract: parameters,
                              response: { (response) in
                                if response.statusCode < 300 {
                                    self.subscriptions[uri] = true
                                } else {
                                    onError(response.header["Uri"] as! String,
                                            response.header["Reason"] as! String)
                                }
        },
                              onEvent: { (event) in
                                onNotify(self.convertEvent(event))
        })
    }
    
    /// Unsubscribe from a specified resource. Must have been subscribed before.
    public func unsubscribe(_ uri: String) {
        self.mds!.doUnsubscribe(uri)
        self.subscriptions.removeValue(forKey: uri)
    }
    
    public func put(_ uri : String,
                    _ parameters: Dictionary<String, Any>,
                    _ completionCb: @escaping (String) -> (),
                    _ errorCb: @escaping (String) -> ())  {

            self.mds!.doPut(uri,
                            contract: parameters,
                            completion: { (response) in
                                if response.statusCode < 300 {
                                    completionCb(self.convertResponse(response))
                                } else {
                                    errorCb(response.header["Reason"] as! String)
                                }
            });
    }
    
    public func get(_ uri : String,
                    _ parameters: Dictionary<String, Any>,
                    _ completionCb: @escaping (String) -> (),
                    _ errorCb: @escaping (String) -> ())  {
        
        self.mds!.doGet(uri,
                        contract: parameters,
                        completion: { (response) in
                            if response.statusCode < 300 {
                                completionCb(self.convertResponse(response))
                            } else {
                                errorCb(response.header["Reason"] as! String)
                            }
        });
    }
    
    public func post(_ uri : String,
                    _ parameters: Dictionary<String, Any>,
                    _ completionCb: @escaping (String) -> (),
                    _ errorCb: @escaping (String) -> ())  {
        
        self.mds!.doPost(uri,
                        contract: parameters,
                        completion: { (response) in
                            if response.statusCode < 300 {
                                completionCb(self.convertResponse(response))
                            } else {
                                errorCb(response.header["Reason"] as! String)
                            }
        });
    }
    
    public func del(_ uri : String,
                    _ parameters: Dictionary<String, Any>,
                    _ completionCb: @escaping (String) -> (),
                    _ errorCb: @escaping (String) -> ())  {
        
        self.mds!.doDelete(uri,
                        contract: parameters,
                        completion: { (response) in
                            if response.statusCode < 300 {
                                completionCb(self.convertResponse(response))
                            } else {
                                errorCb(response.header["Reason"] as! String)
                            }
        });
    }
    
    
    private func convertResponse(_ response : MDSResponse) -> String {
        do {
            if let json = try JSONSerialization.jsonObject(with: response.bodyData) as? [String: Any] {
                    let jsonData = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                    let jsonString = String(data: jsonData, encoding: .utf8)
                    return jsonString!
                
            }
        } catch {
            return ""
        }
        
        return ""
    }
    
    private func convertEvent(_ event : MDSEvent) -> String {
        do {
            if let json = try JSONSerialization.jsonObject(with: event.bodyData) as? [String: Any] {
                let jsonData = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                let jsonString = String(data: jsonData, encoding: .utf8)
                return jsonString!
            }
        } catch {
            return ""
        }
        
        return ""
    }
}

public struct MovesenseDeviceInfo {
    public var hw: String
    public var sw: String
    public var manufacturerName: String
    public var productName: String
    public var variant: String
    public var serial: String
}

public struct MovesenseDevice {
    public var uuid : UUID
    public var localName : String
    public var serial : String // Must be unique among all devices
    public var bleStatus : Bool
    public var mdsConnected : Bool = false
    public var deviceInfo: MovesenseDeviceInfo?
    
    init(uuid: UUID, localName: String, serial: String,
         info: MovesenseDeviceInfo?, linkStatus: Bool)
    {
        self.uuid = uuid
        self.localName = localName
        self.serial = serial
        self.bleStatus = linkStatus
        self.deviceInfo = info
    }
}
