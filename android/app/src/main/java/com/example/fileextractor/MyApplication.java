package com.example.fileextractor;

import android.Manifest;

import com.blankj.utilcode.util.Utils;

public class MyApplication extends io.flutter.app.FlutterApplication {
    @Override
    public void onCreate() {
        super.onCreate();
        Utils.init(this);
    }

}