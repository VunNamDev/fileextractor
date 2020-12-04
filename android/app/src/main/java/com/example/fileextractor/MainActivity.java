package com.example.fileextractor;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.util.Log;


import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;

//import com.hzy.libp7zip.ExitCode;
//import com.hzy.libp7zip.P7ZipApi;

import com.example.fileextractor.command.Command;
import com.example.fileextractor.utils.FileUtils;
import com.example.fileextractor.utils.SharedPrefsUtils;
import com.example.fileextractor.utils.Utils;
import com.google.gson.Gson;
import com.hzy.libp7zip.ExitCode;
import com.hzy.libp7zip.P7ZipApi;

import java.io.File;
import java.io.FileInputStream;
import java.util.Date;
import java.util.Enumeration;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;
import java.util.zip.ZipInputStream;

import dmax.dialog.SpotsDialog;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.reactivex.Observable;
import io.reactivex.ObservableEmitter;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.functions.Consumer;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.reactivex.schedulers.Schedulers;
import io.reactivex.android.schedulers.AndroidSchedulers;

import android.app.AlertDialog;
import android.webkit.MimeTypeMap;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "samples.flutter.dev";
    Result myResult;
    String[] arrPermistion = {Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.READ_EXTERNAL_STORAGE};
    public static int NORMARL_PERMISTION_CODE = 100;
    String title;
    String content;
    String errorText;
    String finishText;
    private AlertDialog mDialog;

    void setup() {
        title = "Extracting";
        content = "Please wait until the process is completed";
        errorText = "Error when extract file";
        finishText = "File was saved";
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == NORMARL_PERMISTION_CODE) {
            boolean check = true;
            for (int i = 0; i < grantResults.length; i++) {
                if (grantResults[i] != PackageManager.PERMISSION_GRANTED) {
                    check = false;
                    break;
                }
            }
            if (!check) {
                getPermistion();
            }
        }
    }

    public String getMimeType(String url) {
        String type = null;
        String extension = MimeTypeMap.getFileExtensionFromUrl(url);
        if (extension != null) {
            type = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension);
        }
        return type;
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        File f = new File("/storage/0/emulated/sample.rar");
        String t = getMimeType(f.getAbsolutePath());
        Log.d("ssss", t);
        setup();
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            myResult = result;
                            switch (call.method) {
                                case "getRootPath":
                                    result.success(Environment.getExternalStorageDirectory().getAbsolutePath());
                                    break;
                                case "extract":
                                    onExtractFile(call.argument("path"), call.argument("outPath"), call.argument("password"), result);
                                    break;
                                case "loadPathInfo":
                                    loadPathInfo(call.argument("path"), result);
                                    break;
                                case "extractFromUri":
                                    extractFromUri();
                                    result.success(zippath);
                                    break;
                                case "dismissProgressDialog":
                                    dismissProgressDialog();
                                    break;

                            }
                        }
                );

    }

    boolean haveAllPermiston() {
        boolean have = true;
        for (int i = 0; i < arrPermistion.length; i++) {
            if (ActivityCompat.checkSelfPermission(this, arrPermistion[i]) != PackageManager.PERMISSION_GRANTED) {
                have = false;
                break;
            }
        }
        return have;
    }

    private void loadPathInfo(String path, Result result) {

        if (path.compareTo("root") == 0) {
            path = Environment.getExternalStorageDirectory().getAbsolutePath();
        }
        Gson gson = new Gson();
        result.success(gson.toJson(FileUtils.getInfoListFromPath(path)));
    }

    private void onExtractFile(final String path, String outPath, String password, Result result) {
        File folder = new File(outPath);
        if (!folder.exists()) {
            folder.mkdirs();
        }

        String cmd = Command.getExtractCmd(path,
                outPath, password);
        Log.d("command", cmd);
        runCommand(cmd, result);
    }

    private void runCommand(final String cmd, Result result) {
        showProgressDialog();
        Observable.create(new ObservableOnSubscribe<Integer>() {
            @Override
            public void subscribe(ObservableEmitter<Integer> e) throws Exception {
                int ret = P7ZipApi.executeCommand(cmd);
                e.onNext(ret);
            }
        }).subscribeOn(Schedulers.io()).observeOn(AndroidSchedulers.mainThread())
                .subscribe(new Consumer<Integer>() {
                    @Override
                    public void accept(Integer integer) throws Exception {
                        showResult(integer, result);

                    }
                });
    }

    private void showResult(int result, Result flutterResult) {

        switch (result) {
            case ExitCode.EXIT_OK:
                flutterResult.success("EXIT_OK");
                //Success
                break;
            case ExitCode.EXIT_WARNING:
                flutterResult.success("EXIT_WARNING");
                //Warning (Non fatal error(s))
                break;
            case ExitCode.EXIT_FATAL:
                flutterResult.success("EXIT_FATAL");
                //Fatal error
                break;
            case ExitCode.EXIT_CMD_ERROR:
                flutterResult.success("EXIT_CMD_ERROR");
                //Command line error
                break;
            case ExitCode.EXIT_MEMORY_ERROR:
                flutterResult.success("EXIT_MEMORY_ERROR");
                //Not enough memory for operation
                break;
            case ExitCode.EXIT_NOT_SUPPORT:
                flutterResult.success("EXIT_NOT_SUPPORT");
                // User stopped the process
                break;
            default:
                break;
        }

    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getPermistion();
    }

    boolean openzip = false;
    String zippath = "";

    void extractFromUri() {
        if (haveAllPermiston()) {
            Intent intent = getIntent();
            String actionIntent = intent.getAction();
            if (actionIntent.equals(Intent.ACTION_VIEW)) {
                {
                    // zip viewer intent
                    Uri uri = intent.getData();
                    openzip = true;
                    File file = new File(uri.getPath());//create path from uri
                    final String[] split = file.getPath().split(":");//split the path.
                    zippath = split[1];
                }


            } else openzip = false;
        }
    }

    private void getPermistion() {
        ActivityCompat.requestPermissions(this, arrPermistion, NORMARL_PERMISTION_CODE);
    }

 

    private void showProgressDialog() {
        if (mDialog == null) {
            mDialog = new SpotsDialog.Builder().setContext(this).build();
            mDialog.setCancelable(false);
            mDialog.setMessage(title);
            mDialog.setTitle(title);
            Log.d("proooo", title);
//      dialog = new ProgressDialog(MainActivity.this);
//      dialog.setTitle(title);
//      dialog.setMessage(content);
//      dialog.setCancelable(false);
        }
        mDialog.show();
    }

    private void dismissProgressDialog() {
        if (mDialog != null && mDialog.isShowing()) {
            mDialog.dismiss();
        }
    }


}
