# 🚀 Notes Replica Automated Build Script
# This script handles the patching and signing of the Notes app.

$APK_NAME = "Notes_com.mrdarkside.notes_v1.1.0_Final.apk"
$BASE_APK = "D:/Ideas/Antigravity/Notes/patched_base.apk"
$APKSIGNER = "C:/Users/Abhi/AppData/Local/Android/Sdk/build-tools/35.0.0/apksigner.bat"

Write-Host "--- Starting Build Process ---" -ForegroundColor Cyan

# 1. Prepare Base
if (Test-Path "final_notes.apk") { Remove-Item "final_notes.apk" }
Copy-Item $BASE_APK "final_notes.apk"

# 2. Patching (Using Java Patcher)
Write-Host "[*] Injecting patched binaries..." -ForegroundColor Yellow
if (-not (Test-Path "ApkPatcher.java")) {
    # Re-create patcher if missing
    Set-Content -Path "ApkPatcher.java" -Value 'import java.io.*; import java.util.*; import java.util.zip.*; import java.nio.file.*; public class ApkPatcher { public static void main(String[] args) throws Exception { File apkFile = new File("final_notes.apk"); File tempFile = new File("final_notes_temp.apk"); ZipInputStream zin = new ZipInputStream(new FileInputStream(apkFile)); ZipOutputStream zout = new ZipOutputStream(new FileOutputStream(tempFile)); Set<String> replaced = new HashSet<>(); replaced.add("classes.dex"); replaced.add("classes2.dex"); replaced.add("lib/arm64-v8a/libapp.so"); replaced.add("lib/arm64-v8a/libclib.so"); replaced.add("lib/arm64-v8a/libflutter.so"); replaced.add("lib/arm64-v8a/libobjectbox-jni.so"); replaced.add("lib/arm64-v8a/libpbkdf2_native.so"); replaced.add("lib/arm64-v8a/libpolarssl.so"); replaced.add("lib/arm64-v8a/libsecurity.so"); replaced.add("lib/arm64-v8a/libtmlib.so"); ZipEntry entry = zin.getNextEntry(); while (entry != null) { String name = entry.getName(); if (!replaced.contains(name)) { zout.putNextEntry(new ZipEntry(name)); byte[] buf = new byte[1024]; int len; while ((len = zin.read(buf)) > 0) { zout.write(buf, 0, len); } zout.closeEntry(); } entry = zin.getNextEntry(); } zin.close(); addFile(zout, "prebuilt/dex/classes.dex", "classes.dex"); addFile(zout, "prebuilt/dex/classes2.dex", "classes2.dex"); String libBase = "prebuilt/lib/arm64-v8a/"; String[] libs = {"libapp.so", "libclib.so", "libflutter.so", "libobjectbox-jni.so", "libpbkdf2_native.so", "libpolarssl.so", "libsecurity.so", "libtmlib.so"}; for (String lib : libs) { addFile(zout, libBase + lib, "lib/arm64-v8a/" + lib); } zout.close(); apkFile.delete(); tempFile.renameTo(apkFile); } private static void addFile(ZipOutputStream zout, String srcPath, String entryName) throws IOException { zout.putNextEntry(new ZipEntry(entryName)); byte[] buf = Files.readAllBytes(Paths.get(srcPath)); zout.write(buf, 0, buf.length); zout.closeEntry(); } }'
}
javac ApkPatcher.java
java ApkPatcher
Remove-Item ApkPatcher.class

# 3. Signing
Write-Host "[*] Signing APK..." -ForegroundColor Yellow
& $APKSIGNER sign --ks release.jks --ks-pass pass:notes123 --ks-key-alias notes --key-pass pass:notes123 --out $APK_NAME final_notes.apk

Write-Host "--- Build Finished: $APK_NAME ---" -ForegroundColor Green