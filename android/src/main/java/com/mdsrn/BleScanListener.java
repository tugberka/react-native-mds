package com.mdsrn;


import androidx.annotation.NonNull;

public interface BleScanListener {

    void onDeviceFound(@NonNull String name, @NonNull String address);
}
