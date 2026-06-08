package com.swp391.servlet;

import java.security.MessageDigest;
import java.nio.charset.StandardCharsets;

/**
 * Simple password hashing utility for demo purposes.
 * Uses MD5 (built-in, no external dependencies).
 * Note: MD5 is NOT recommended for production; use bcrypt/scrypt for real systems.
 */
public final class PasswordUtil {

    private PasswordUtil() {}

    public static String hash(String raw) {
        if (raw == null) return null;
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] hash = md.digest(raw.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : hash) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            throw new IllegalStateException("MD5 algorithm not available", e);
        }
    }

    public static boolean check(String raw, String hashed) {
        if (raw == null || hashed == null) return false;
        return hash(raw).equals(hashed);
    }
}

