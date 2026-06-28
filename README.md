# 👁️ Ocular — Smart Monospace Screenshot Indexer

Ocular is a developer-focused, high-contrast, terminal-themed mobile utility that lets you index, search, and recall text from your local screenshots instantly. Powered by local, on-device machine learning (OCR), your screenshots never leave your physical device.

```
 ocular@localhost:~//sys/overview
 ────────────────────────────────────────────────────────
 [STATUS]    : ACTIVE // STABLE
 [ENGINE]    : GOOGLE_MLKIT_TEXT_RECOGNITION
 [PRIVACY]   : 100% LOCAL // ZERO_NETWORK_UPLOADS
 [PERM_GATE] : ENABLED // PLAY_STORE_COMPLIANT
 ────────────────────────────────────────────────────────
```

---

## ⚡ Key Features

*   **🔍 On-Device OCR Search Engine:** Uses **Google ML Kit Text Recognition** locally to analyze pixels. No internet required, no cloud APIs called, and zero background data usage.
*   **🎯 Normalized Search Matching:** Built-in string parser strips spacing, punctuation, and casing differences. Searching `"idcard"` instantly matches screenshots containing `"ID CARD"`, `"ID-CARD"`, or `"Student ID Card"`.
*   **🖼️ Strict Screenshots-Only Filter:** Auto-detects device screenshots albums (like `DCIM/Screenshots`). Performs fallback filename matching to filter out camera uploads, Whatsapp media, and downloads.
*   **🛡️ Google Play Policy Compliant:**
    *   **Prominent Disclosure Modal:** Built-in `privacy.sh` terminal panel explaining read-only data scopes and local storage access.
    *   **Pre-Permission Rationale Popup:** Custom in-app warning dialogue (**`SECURE_SHELL://AUTH_REQUEST`**) that shows on boot before launching the native system dialogue. It offers an easy exit option (`./exit_app.sh`) or allow flow (`./sudo_allow.sh`).
*   **📟 Monospace Terminal UI:** A dark developer theme styled with Matrix neon green accents (`#00FF41`), alert reds, JetBrains Mono typography, and macOS-style console header buttons.
*   **⚙️ Blinking Console Placeholders:** When search or filter ranges return 0 results, the system displays animated console dialog panels (`SECURE_SHELL://QUERY_EXCEPTION`) outlining spellchecks, filters, and a clickable `./clear_search_query.sh` reset button.
*   **💫 Animated Boot Loader:** Beautiful boot-up `SplashScreen` presenting dynamic line initialization logs (loading storage, mounting image sectors, linking ML engines) and an ASCII block loader (`[██████░░░░] 60%`).
*   **🔎 Zoom & Pan Viewer:** Fullscreen screenshot inspector wrapped inside a multi-touch `InteractiveViewer` supporting pinch-to-zoom and pan.

---

## 🛠️ Technology Stack

*   **Frontend:** Flutter / Dart
*   **Media Pipeline:** `photo_manager` (supports granular storage reads)
*   **Text Recognition:** `google_mlkit_text_recognition` (Latin script build)
*   **Build System:** Gradle (Kotlin DSL) / Proguard (R8)

---

## 🚀 Getting Started

### Prerequisites
*   Flutter SDK (3.10+ recommended)
*   Android SDK / iOS Xcode Development Command Line Tools
*   A physical test device or emulator

### 1. Installation
Clone the repository and fetch dependencies:
```bash
git clone https://github.com/HarshVerma007/Ocular.git
cd Ocular
flutter pub get
```

### 2. Running in Development
Start your Android emulator or connect a test device, then execute:
```bash
flutter run
```

---

## 📦 Building for Production (Google Play Store)

Ocular is pre-configured to build a minified, optimized, and secure bundle.

### 1. Configure Code-Signing
To prepare a signed bundle, create a file named `key.properties` inside the `android/` folder:
```properties
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=upload
storeFile=/Users/harsh_verma/upload-keystore.jks
```
*(If no `key.properties` is found, the build system automatically falls back to your local debug key so compilation still works).*

### 2. Generate the App Bundle (.aab)
To generate the final App Bundle for uploading to the Play Console:
```bash
flutter build appbundle --release
```

### 3. Minification (R8 / Proguard)
Since Ocular only compiles the **Latin script** for OCR text recognition, the R8 compiler tree-shakes optional unused scripts (Chinese, Devanagari, Japanese, Korean). 
Ocular includes a pre-configured [proguard-rules.pro](android/app/proguard-rules.pro) file linked inside [build.gradle.kts](android/app/build.gradle.kts) that suppresses missing class warning errors for these tree-shaken resources:
```proguard
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
```

---

## 🔒 Security & Privacy Statement

Ocular operates on a strict **Zero-Trust Client** security model. 
*   All images are processed locally within the application sandbox.
*   No screenshots, recognized text contents, or device metadata are compiled, stored, or transmitted to any cloud servers or third-party tracking APIs.
*   Permission access is strictly **read-only**.
