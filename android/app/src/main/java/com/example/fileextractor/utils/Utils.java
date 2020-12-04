package com.example.fileextractor.utils;

import java.text.SimpleDateFormat;

public class Utils {
    private static final int INDEX_NOT_FOUND = -1;
    private static final SimpleDateFormat DATE_NO_MINUTES = new SimpleDateFormat("MMM dd, yyyy");
    private static final SimpleDateFormat DATE_WITH_MINUTES = new SimpleDateFormat("MMM dd yyyy | HH:mm");
    private static final String INPUT_INTENT_BLACKLIST_COLON = ";";
    private static final String INPUT_INTENT_BLACKLIST_PIPE = "\\|";
    private static final String INPUT_INTENT_BLACKLIST_AMP = "&&";
    private static final String INPUT_INTENT_BLACKLIST_DOTS = "\\.\\.\\.";
    public static String sanitizeInput(String input) {
        // iterate through input and keep sanitizing until it's fully injection proof
        String sanitizedInput;
        String sanitizedInputTemp = input;

        while (true) {
            sanitizedInput = sanitizeInputOnce(sanitizedInputTemp);
            if (sanitizedInput.equals(sanitizedInputTemp)) break;
            sanitizedInputTemp = sanitizedInput;
        }

        return sanitizedInput;
    }

    private static String sanitizeInputOnce(String input) {
        return input.replaceAll(INPUT_INTENT_BLACKLIST_PIPE, "").
                replaceAll(INPUT_INTENT_BLACKLIST_AMP, "").
                replaceAll(INPUT_INTENT_BLACKLIST_DOTS, "").
                replaceAll(INPUT_INTENT_BLACKLIST_COLON, "");
    }
}
