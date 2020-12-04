package com.example.fileextractor.utils;


import android.os.Environment;
import android.util.Log;

import com.example.fileextractor.modal.FileInfo;
import com.example.fileextractor.modal.FileType;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;

/**
 * Created by huzongyao on 17-7-13.
 */

public class FileUtils {

    private static final String[] ARCHIVE_ARRAY = {"rar", "zip", "7z", "bz2", "bzip2",
            "tbz2", "tbz", "gz", "gzip", "tgz", "tar", "xz", "txz"};

    public static FileInfo getFileInfoFromPath(String filePath) {
        FileInfo info = new FileInfo();
        File file = new File(filePath);
        info.setFileName(file.getName());
        info.setFilePath(file.getAbsolutePath());
        info.setFileType("fileUnknown");
        if (file.isDirectory()) {
            info.setFolder(true);
            info.setFileType("folderEmpty");
            String[] fileList = file.list();
            if (fileList != null) {
                if (fileList.length > 0) {
                    info.setSubCount(fileList.length);
                    info.setFileType("folderFull");
                }
            }
        } else {
            info.setFileLength(file.length());
            if (isArchive(file)) {
                info.setFileType("fileArchive");
            }
        }
        return info;
    }

    private static boolean isArchive(File file) {
        String fileName = file.getName();
        String suffix = fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase();
        for (String suf : ARCHIVE_ARRAY) {
            if (suffix.equals(suf)) {
                return true;
            }
        }
        return false;
    }

    public static ArrayList<FileInfo> getInfoListFromPath(String path) {

        ArrayList<FileInfo> fileInfos = new ArrayList<>();
        File folder = new File(path);
        if (folder.exists() && folder.isDirectory() && folder.canRead()) {
            File[] fileNames = folder.listFiles();
            if (fileNames != null) {
                Arrays.sort(fileNames, new FileComparator());
                for (File file : fileNames) {
                    fileInfos.add(getFileInfoFromPath(file.getPath()));
                }
            }
        }
        Log.d("root", fileInfos.size() + " is size");
        return fileInfos;
    }

    private static class FileComparator implements Comparator<File> {
        @Override
        public int compare(File o1, File o2) {
            int ret = getFileScore(o2) - getFileScore(o1);
            if (ret == 0) {
                ret = o1.getName().compareToIgnoreCase(o2.getName());
            }
            return ret;
        }
    }

    private static int getFileScore(File file) {
        int score = 0;
        score |= file.isDirectory() ? 0x10 : 0;
        score |= file.isHidden() ? 0 : 0x01;
        return score;
    }

    public static String getParentPath(String path) {
        return path.substring(0, path.lastIndexOf(File.separatorChar));
    }
}
