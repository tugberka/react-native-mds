package com.mdsrn;


import android.support.annotation.NonNull;

public interface BleScanListener {

    void onDeviceFound(@NonNull String name, @NonNull String address);
}
