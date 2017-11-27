//
//  RNMdsModule.swift
//  RNMds
//
//  Created by Akdogan, Tugberk on 13/10/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

import Foundation

@objc(ReactMds)
public final class ReactMds: RCTEventEmitter {
    let mds = MdsService()
    var subscriptions: Dictionary<String, String>  = [:]

    override init() {
        super.init()
    }
    
    @objc open override func supportedEvents() -> [String] {
        var allEventNames: [String] = ["newScannedDevice", "newNotification", "newNotificationError"]
        return allEventNames
    }
    
    @objc(scan)
    func scan() {
        self.mds.startScan({device in self.handleScannedDevice(device: device)}, {})
    }
    
    @objc(stopScan)
    func stopScan() {
        self.mds.stopScan()
    }
    
    @objc(connect:)
    func connect(address: String) {
        self.mds.connectDevice(address)
    }
    
    @objc(disconnect:)
    func disconnect(address: String) {
        self.mds.disconnectDevice(address)
    }
    
    @objc(get:parameters:successCallback:errorCallback:)
    func get(uri: String,
             parameters: Dictionary<String, Any>,
             callback successCallback: @escaping RCTResponseSenderBlock,
             callback errorCallback: @escaping RCTResponseSenderBlock) {
        self.mds.get(uri, parameters, { response in
            successCallback([NSNull(), response])
        }, { e in
            errorCallback([NSNull(), e])
        })
        
    }
    
    @objc(put:parameters:successCallback:errorCallback:)
    func put(uri: String,
             parameters: Dictionary<String, Any>,
             callback successCallback: @escaping RCTResponseSenderBlock,
             callback errorCallback: @escaping RCTResponseSenderBlock) {
        self.mds.put(uri, parameters, { response in
            successCallback([NSNull(), response])
        }, { e in
            errorCallback([NSNull(), e])
        })
        
    }
    
    @objc(post:parameters:successCallback:errorCallback:)
    func post(uri: String,
             parameters: Dictionary<String, Any>,
             callback successCallback: @escaping RCTResponseSenderBlock,
             callback errorCallback: @escaping RCTResponseSenderBlock) {
        self.mds.post(uri, parameters, { response in
            successCallback([NSNull(), response])
        }, { e in
            errorCallback([NSNull(), e])
        })
        
    }
    
    @objc(del:parameters:successCallback:errorCallback:)
    func del(uri: String,
             parameters: Dictionary<String, Any>,
             callback successCallback: @escaping RCTResponseSenderBlock,
             callback errorCallback: @escaping RCTResponseSenderBlock) {
        self.mds.del(uri, parameters, { response in
            successCallback([NSNull(), response])
        }, { e in
            errorCallback([NSNull(), e])
        })
    }
    
    @objc(subscribe:parameters:key:)
    func subscribe(uri: String,
             parameters: Dictionary<String, Any>,
             key: String) {
        self.mds.subscribe(uri, parameters: parameters, onNotify: { event in
            self.sendNotificationEvent(key: key, event: event);
        }, onError: { uri, reason in
            self.sendNotificationErrorEvent(key: key, uri: uri, reason: reason)
        })
        subscriptions[key] = uri;
    }
    
    @objc(unsubscribe:)
    func unsubscribe(key: String) {
        self.mds.unsubscribe(subscriptions[key]!)
        subscriptions[key] = nil
    }

    private func handleScannedDevice(device: MovesenseDevice) {
        let deviceSend = ["name": device.localName, "address": device.uuid.uuidString] as [String : Any]
        self.sendEvent( withName: "newScannedDevice", body: deviceSend )
    }
    
    private func sendNotificationEvent(key: String, event: String) {
        let eventBody = ["key": key, "notification": event]
        self.sendEvent( withName: "newNotification", body: eventBody )
    }
    
    private func sendNotificationErrorEvent(key: String, uri: String, reason: String) {
        let errorBody = ["key": key, "error": reason]
        self.sendEvent( withName: "newNotificationError", body: errorBody )
    }
}
