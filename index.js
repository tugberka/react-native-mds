import { DeviceEventEmitter, NativeEventEmitter, Platform } from 'react-native';

import MDSImpl from './src/MDSImpl'

function MDS() {
	this.scan = function(scanHandler) {
		MDSImpl.scan(scanHandler)
	}

	this.stopScan = function() {
		MDSImpl.stopScan();
	}

	this.setHandlers = function(deviceConnected, deviceDisconnected) {
		MDSImpl.setHandlers(deviceConnected, deviceDisconnected)
	}

	this.connect = function(address) {
		MDSImpl.connect(address);
	}

	this.disconnect = function(address) {
		MDSImpl.disconnect(address);
	}

	this.get = function(serial, uri, contract, onResponse, onError) {
		return MDSImpl.get(serial, uri, contract, onResponse, onError)
	}

	this.put = function(serial, uri, contract, onResponse, onError) {
		return MDSImpl.put(serial, uri, contract, onResponse, onError)
	}

	this.post = function(serial, uri, contract, onResponse, onError) {
		return MDSImpl.post(serial, uri, contract, onResponse, onError)
	}

	this.delete = function(serial, uri, contract, onResponse, onError) {
		return MDSImpl.delete(serial, uri, contract, onResponse, onError)
	}

	this.subscribe = function(serial, uri, contract, onResponse, onError) {
		return MDSImpl.subscribe(serial, uri, contract, onResponse, onError)
	}

	this.unsubscribe = function(subscriptionId) {
		return MDSImpl.unsubscribe(subscriptionId)
	}
}

export default new MDS();
