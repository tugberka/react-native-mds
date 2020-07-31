import { DeviceEventEmitter, NativeEventEmitter, Platform } from 'react-native';

import ReactMds from './RNMds'

const URI_PREFIX = "suunto://"

function MDSImpl() {
	var self = this;
	self.subsKey = 0;
	self.subsKeys = [];
	self.subsSuccessCbs = [];
	self.subsErrorCbs = [];
	self.mdsEmitter = null;
	var subscribedToConnectedDevices = false;
	var connectedDevicesSubscription = -1;

	var getIdxFromKey = function(key) {
		var idx = -1;
		for (var i = 0; i < self.subsKeys.length; i++) {
			if (self.subsKeys[i] == key) {
				idx = i;
				break;
			}
		}
		return idx;
	}

	 this.subscribeToConnectedDevices = function() {
		subscribedToConnectedDevices = true;
		connectedDevicesSubscription = self.subscribe("", "MDS/ConnectedDevices",
    {}, (notification) => {
			var data = JSON.parse(notification);
      if (data["Method"] == "POST") {
				if (data.hasOwnProperty("Body")) {
					if(data["Body"].hasOwnProperty("DeviceInfo")) {
						if (data["Body"]["DeviceInfo"].hasOwnProperty("Serial")) {
							self.onDeviceConnected(data["Body"]["DeviceInfo"]["Serial"])
						}
					} else if(data["Body"].hasOwnProperty("Serial")){
						self.onDeviceConnected(data["Body"]["Serial"])
				}
			}
		} else if (data["Method"] == "DEL") {
			if(data["Body"].hasOwnProperty("Serial")){
				self.onDeviceDisonnected(data["Body"]["Serial"])
			}
		}
	},
      (error) => {
        console.log("MDS subscribe error")
				self.unsubscribe(connectedDevicesSubscription);
				subscribedToConnectedDevices = false;
      });

	}

	this.initMdsEmitter = function () {
		if (this.mdsEmitter) {
			return;
		}

		if (Platform.OS === 'android'){
			DeviceEventEmitter.addListener('newScannedDevice', this.handleNewScannedDevice);
			DeviceEventEmitter.addListener('newNotification', this.handleNewNotification);
			DeviceEventEmitter.addListener('newNotificationError', this.handleNewNotificationError);
			this.mdsEmitter = true;
		} else {
			const mdsEmitter = new NativeEventEmitter(ReactMds);

			scanSubscription = mdsEmitter.addListener('newScannedDevice', this.handleNewScannedDevice);
			newNotificationSubscription = mdsEmitter.addListener('newNotification', this.handleNewNotification);
			newNotificationErrorSubscription = mdsEmitter.addListener('newNotificationError', this.handleNewNotificationError);
			this.mdsEmitter = mdsEmitter;
		}
	}

	this.handleNewScannedDevice = function(e: Event) {
		self.onNewScannedDevice(e.name, e.address);
	}

	this.handleNewNotification = function(e: Event) {
		self.subsSuccessCbs[getIdxFromKey(e.key)](e.notification);
	}

	this.handleNewNotificationError = function(e: Event) {
		self.subsErrorCbs[getIdxFromKey(e.key)](e.error);
	}

	this.scan = function(scanHandler) {
		self.onNewScannedDevice = function (a, b) {scanHandler(a, b);}
		this.initMdsEmitter();
		ReactMds.scan();
	}

	this.stopScan = function() {
		ReactMds.stopScan();
	}

	this.setHandlers = function(deviceConnected, deviceDisconnected) {
		self.onDeviceConnected = deviceConnected;
		self.onDeviceDisonnected = deviceDisconnected;
		if (!subscribedToConnectedDevices) {
			subscribedToConnectedDevices = true;
			self.subscribeToConnectedDevices();
		}
	}

	this.connect = function(address) {
		this.initMdsEmitter();
		ReactMds.connect(address);
	}

	this.disconnect = function(address) {
		ReactMds.disconnect(address);
	}

	this.get = function(serial, uri, contract, responseCb, errorCb) {
		if (serial == undefined ||
            uri == undefined ||
            contract == undefined ||
            responseCb == undefined ||
            errorCb == undefined) {
			console.log("MDS get() missing argument(s).")
			return false;
		}
        if (Platform.OS === 'android'){
          ReactMds.get(URI_PREFIX + serial + uri, JSON.stringify(contract), responseCb, errorCb);
        }
        else {
          ReactMds.get(URI_PREFIX + serial + uri, contract, (err,r) => responseCb(r), (err,r) => errorCb(r));
        }
		return true;
	}

	this.put = function(serial, uri, contract, responseCb, errorCb) {
		if (serial == undefined ||
            uri == undefined ||
            contract == undefined ||
            responseCb == undefined ||
            errorCb == undefined) {
			console.log("MDS put() missing argument(s).")
			return false;
		}

		if (Platform.OS === 'android'){
          ReactMds.put(URI_PREFIX + serial + uri, JSON.stringify(contract), (err,r) => responseCb(r), (err,r) => errorCb(r));
        }
        else {
          ReactMds.put(URI_PREFIX + serial + uri, contract, responseCb, errorCb);
        }
	}

	this.post = function(serial, uri, contract, responseCb, errorCb) {
		if (serial == undefined ||
            uri == undefined ||
            contract == undefined ||
            responseCb == undefined ||
            errorCb == undefined) {
			console.log("MDS post() missing argument(s).")
			return false;
		}

		if (Platform.OS === 'android'){
          ReactMds.post(URI_PREFIX + serial + uri, JSON.stringify(contract), responseCb, errorCb);
        }
        else {
          ReactMds.post(URI_PREFIX + serial + uri, contract, responseCb, errorCb);
        }
	}

	this.delete = function(serial, uri, contract, responseCb, errorCb) {
		if (serial == undefined ||
            uri == undefined ||
            contract == undefined ||
            responseCb == undefined ||
            errorCb == undefined) {
			console.log("MDS delete() missing argument(s).")
			return false;
		}

		if (Platform.OS === 'android'){
          ReactMds.delete(URI_PREFIX + serial + uri, JSON.stringify(contract), responseCb, errorCb);
        }
        else {
          ReactMds.delete(URI_PREFIX + serial + uri, contract, responseCb, errorCb);
        }
	}

	this.subscribe = function(serial, uri, contract, responseCb, errorCb) {
		if (serial == undefined ||
            uri == undefined ||
            contract == undefined ||
            responseCb == undefined ||
            errorCb == undefined) {
			console.log("MDS subscribe() missing argument(s).")
			return -1;
		}

		self.subsKey++;
		var subsKeyStr = self.subsKey.toString();
		self.subsKeys.push(self.subsKey);
		self.subsSuccessCbs.push(responseCb);
		self.subsErrorCbs.push(errorCb);
        if (Platform.OS === 'android'){
          contract["Uri"] =  serial + uri;
          ReactMds.subscribe("suunto://MDS/EventListener", JSON.stringify(contract), subsKeyStr);
        }
        else {
          ReactMds.subscribe(URI_PREFIX + serial + uri, contract, subsKeyStr);
        }

		return self.subsKey;
	}

	this.unsubscribe = function(key) {
		var idx = self.subsKeys.indexOf(key);
		if (idx == -1) {
			return false;
		}

		ReactMds.unsubscribe(key.toString());
		self.subsKeys.splice(idx, 0);
		self.subsSuccessCbs.splice(idx, 0);
		self.subsErrorCbs.splice(idx, 0);
		return true;
	}
}

export default new MDSImpl();
