# Notes Replica (com.mrdarkside.notes)

This is an exact replica of the Notes app, with package name changed and premium restrictions removed.

## Project Structure
- `android/`: Modified Android project with the new package name.
- `assets/`: Original assets from the Notes app.
- `lib/`: Flutter placeholder (the actual logic is in `jniLibs`).
- `prebuilt/`: Patched `classes.dex` and native libraries.

## How to Build the Final APK

Since the original logic is in compiled AOT binaries (`libapp.so`) and patched Smali (`classes.dex`), follow these steps to produce the final APK:

1.  **Build the shell APK**:
    ```bash
    flutter build apk --release
    ```
    *Note: This generates the initial structure but uses a placeholder Flutter binary.*

2.  **Patch the APK**:
    Replace the following files in the generated APK (`build/app/outputs/flutter-apk/app-release.apk`) with the ones in `prebuilt/`:
    -   Replace `classes.dex` and `classes2.dex` with `prebuilt/dex/classes.dex` and `classes2.dex`.
    -   Replace the `lib/` directory contents with `prebuilt/lib/`.
    -   Ensure `assets/flutter_assets/` matches the `assets/` folder.

3.  **Re-sign the APK**:
    The APK must be signed before it can be installed. You can use `uber-apk-signer` or `apksigner`.
    ```bash
    java -jar uber-apk-signer.jar --apk app-release.apk
    ```

## Removed Restrictions
- **Play Store License Check**: Disabled in `LicenseClient`.
- **Premium/Pro Features**: All entitlements are forced to "active" in the RevenueCat mapper.
- **Package Name**: Fully rebranded to `com.mrdarkside.notes` throughout the manifest and native binary.
