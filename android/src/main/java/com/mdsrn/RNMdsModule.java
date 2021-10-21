
package com.mdsrn;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.movesense.mds.Logger;
import com.movesense.mds.Mds;
import com.movesense.mds.MdsConnectionListener;
import com.movesense.mds.MdsException;
import com.movesense.mds.MdsNotificationListener;
import com.movesense.mds.MdsResponseListener;
import com.movesense.mds.MdsSubscription;

import java.util.HashMap;
import java.util.Map;

public class RNMdsModule extends ReactContextBaseJavaModule {

    private final String LOG_TAG = RNMdsModule.class.getSimpleName();

    private ReactApplicationContext mContext;
    private Mds mds;
    private BleScanner scanner;

    private Map<String, MdsSubscription> subscriptionMap;

    public RNMdsModule(ReactApplicationContext reactContext) {
        super(reactContext);
        mContext = reactContext;
        mds = Mds.builder().build(reactContext);
        Logger.setPipeToOSLoggingEnabled(true);
        subscriptionMap = new HashMap<>();
        scanner = new BleScanner(reactContext, new BleScanListener() {
            @Override
            public void onDeviceFound(@NonNull String name, @NonNull String address) {
                handleScanResult(name, address);
            }
        });
    }

    @Override
    public String getName() {
        return "ReactMds";
    }

    @ReactMethod
    public void scan() {
        scanner.scan();
    }

    @ReactMethod
    public void stopScan() {
        scanner.stopScan();
    }

    @ReactMethod
    public void connect(String address) {
        mds.connect(address, new MdsConnectionListener() {
            @Override
            public void onConnect(String s) {

            }

            @Override
            public void onConnectionComplete(String s, String s1) {

            }

            @Override
            public void onError(MdsException e) {

            }

            @Override
            public void onDisconnect(String s) {

            }
        });
    }

    @ReactMethod
    public void disconnect(String address) {
        mds.disconnect(address);
    }

    @ReactMethod
    public void get(@NonNull String uri, String contract, final Callback responseCb, final Callback errorCb) {
        mds.get(uri, contract, new MdsResponseListener() {
            @Override
            public void onSuccess(String s) {
                responseCb.invoke(s);
            }

            @Override
            public void onError(MdsException e) {
                errorCb.invoke(e.getMessage());
            }
        });
    }

    @ReactMethod
    public void put(@NonNull String uri, String contract, final Callback responseCb, final Callback errorCb) {
        mds.put(uri, contract, new MdsResponseListener() {
            @Override
            public void onSuccess(String s) {
                responseCb.invoke(s);
            }

            @Override
            public void onError(MdsException e) {
                errorCb.invoke(e.getMessage());
            }
        });
    }

    @ReactMethod
    public void post(@NonNull String uri, String contract, final Callback responseCb, final Callback errorCb) {
        mds.post(uri, contract, new MdsResponseListener() {
            @Override
            public void onSuccess(String s) {
                responseCb.invoke(s);
            }

            @Override
            public void onError(MdsException e) {
                errorCb.invoke(e.getMessage());
            }
        });
    }

    @ReactMethod
    public void delete(@NonNull String uri, String contract, final Callback responseCb, final Callback errorCb) {
        mds.delete(uri, contract, new MdsResponseListener() {
            @Override
            public void onSuccess(String s) {
                responseCb.invoke(s);
            }

            @Override
            public void onError(MdsException e) {
                errorCb.invoke(e.getMessage());
            }
        });
    }

    @ReactMethod
    public void subscribe(@NonNull String uri, String contract, final String key) {
        MdsSubscription subscription = mds.subscribe(uri, contract, new MdsNotificationListener() {
            @Override
            public void onNotification(String s) {
                sendNotificationEvent(key, s);
            }

            @Override
            public void onError(MdsException e) {
                sendNotificationErrorEvent(key, e.getMessage());
            }
        });
        subscriptionMap.put(key, subscription);
    }

    @ReactMethod
    public void unsubscribe(String key) {
        MdsSubscription subscription = subscriptionMap.get(key);

        subscription.unsubscribe();
        subscriptionMap.remove(key);
    }

    private void sendNotificationEvent(String key, String notification) {
        WritableMap params = Arguments.createMap();

        params.putString("key", key);
        params.putString("notification", notification);

        sendEvent("newNotification", params);
    }

    private void sendNotificationErrorEvent(String key, String error) {
        WritableMap params = Arguments.createMap();

        params.putString("key", key);
        params.putString("error", error);

        sendEvent("newNotificationError", params);
    }


    private void handleScanResult(String name, String address) {

        WritableMap params = Arguments.createMap();

        params.putString("name", name);
        params.putString("address", address);

        sendEvent("newScannedDevice", params);
    }

    private void sendEvent(String eventName,
                           @Nullable WritableMap params) {
        mContext
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(eventName, params);
    }
}
