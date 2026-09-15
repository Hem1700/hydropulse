# 🚀 Step-by-Step App Store Publishing Guide for HydroPulse

Follow these clear, step-by-step instructions to take HydroPulse from your Mac to TestFlight and the live Apple App Store.

---

## Prerequisites
1. **Apple Developer Account:** Active membership ($99/year) at [developer.apple.com](https://developer.apple.com).
2. **Xcode:** Installed on your Mac.
3. **GitHub Repository:** Already created at `https://github.com/Hem1700/hydropulse`.

---

## Step 1: Enable Your Free Privacy Policy via GitHub Pages (1 minute)
Apple strictly requires a live Privacy Policy URL before allowing an app to be submitted.
1. Open your repository on GitHub: **`https://github.com/Hem1700/hydropulse`**.
2. Click **Settings** (tab at the top) -> **Pages** (in the left sidebar).
3. Under **Build and deployment**:
   * **Source:** `Deploy from a branch`
   * **Branch:** `main`
   * **Folder:** `/docs`
4. Click **Save**.
5. Within ~60 seconds, your privacy policy will be live at:  
   **`https://hem1700.github.io/hydropulse/`**

---

## Step 2: Open Project in Xcode and Configure Signing (3 minutes)
1. In Terminal on your Mac, open the iOS workspace:
   ```bash
   cd /Users/hemparekh/hydropulse/ios
   open Runner.xcworkspace
   ```
2. In the left Xcode project navigator, select the top-level **Runner** project.
3. In the center pane, select the **Runner** target, and click the **Signing & Capabilities** tab.
4. Check **Automatically manage signing**.
5. In the **Team** dropdown, select your Apple Developer Team.
6. Verify the **Bundle Identifier** is set to:  
   `com.hemparekh.hydropulse` (or match your registered App ID).
7. Under **Capabilities**, verify that **Background Modes** (Audio) is present.

---

## Step 3: Create the App in App Store Connect (3 minutes)
1. Go to [App Store Connect](https://appstoreconnect.apple.com) and click **Apps** -> **+ (New App)**.
2. Fill out the dialog:
   * **Platforms:** iOS
   * **Name:** `HydroPulse: Focus & Hydrate`
   * **Primary Language:** English (U.S.)
   * **Bundle ID:** Select `com.hemparekh.hydropulse`
   * **SKU:** `HYDROPULSE_01`
   * **User Access:** Full Access
3. Click **Create**.
4. In the app listing, fill in the fields from **`APP_STORE_METADATA.md`**:
   * Description, Keywords, Support URL, and Privacy Policy URL (`https://hem1700.github.io/hydropulse/`).

---

## Step 4: Build & Upload the Release Archive to App Store Connect
You can build and upload directly from the command line or via Xcode:

### Option A: Via Command Line (Recommended)
In the project directory, run:
```bash
arch -arm64 /Users/hemparekh/FlutterDev/flutter/bin/flutter build ipa --release
```
When finished, Xcode Organizer will open automatically, or you will find the `.ipa` in `build/ios/ipa/`. Click **Distribute App** -> **App Store Connect** -> **Upload**.

### Option B: Via Xcode UI
1. In Xcode, in the top device menu, select **Any iOS Device (arm64)** (not a simulator).
2. Go to the menu: **Product** -> **Archive**.
3. Once the build completes, the Xcode Organizer window will appear.
4. Select your build and click **Distribute App**.
5. Choose **App Store Connect** -> **Upload**.
6. Follow the default prompts and click **Upload**.

---

## Step 5: Test on TestFlight
1. Within 5–10 minutes of uploading, the build will finish processing in App Store Connect.
2. Go to the **TestFlight** tab in App Store Connect.
3. Under **Internal Testing**, add yourself.
4. Open the **TestFlight app** on your iPhone and install HydroPulse to test it live on your device!

---

## Step 6: Submit for App Store Review
1. Once satisfied with the TestFlight build, go back to the **App Store** tab in App Store Connect.
2. Scroll to the **Build** section and select your uploaded build.
3. Provide your screenshots (take 3–4 screenshots on your iPhone while using the app, or in the simulator, and drag them into the 6.7" iPhone section).
4. Under **App Review Information**, paste the notes from `APP_STORE_METADATA.md`.
5. Click **Submit for Review**!
6. Apple review typically takes between **12 to 24 hours**. Once approved, your app will automatically be live worldwide on the App Store!
