#!/bin/bash
# build-apk.sh — manual APK build for CineJoy (Gradle can't run in this sandbox,
# so this drives the official SDK build-tools directly: aapt2 -> javac -> d8 -> zipalign -> apksigner)
set -e

VERSION_CODE=127
VERSION_NAME="1.2.7"

SDK="$HOME/android-sdk"
BT="$SDK/build-tools/34.0.0"
PLATFORM="$SDK/platforms/android-34/android.jar"
export JAVA_HOME="${JAVA_HOME:-$HOME/jdk}"
export PATH="$JAVA_HOME/bin:$PATH"

PROJ="$HOME/workspace/cinejoy-app"
APP="$PROJ/app"
SRC="$APP/src/main"
OUT="$APP/build/manual"
APK_OUT="$APP/build/outputs/apk/debug"
KEYSTORE="$PROJ/debug.keystore"

mkdir -p "$OUT/gen" "$OUT/classes" "$OUT/dex" "$APK_OUT"

echo "==> debug keystore"
if [ ! -f "$KEYSTORE" ]; then
  keytool -genkeypair -keystore "$KEYSTORE" -alias androiddebugkey \
    -storepass android -keypass android -keyalg RSA -keysize 2048 -validity 10950 \
    -dname "CN=Android Debug,O=Android,C=US"
fi

echo "==> aapt2 compile (resources)"
"$BT/aapt2" compile --dir "$SRC/res" -o "$OUT/compiled_res.zip"

echo "==> aapt2 link"
LINK_ARGS=(-o "$OUT/base.apk"
  --manifest "$SRC/AndroidManifest.xml"
  -I "$PLATFORM"
  --java "$OUT/gen"
  --min-sdk-version 24 --target-sdk-version 34
  --version-code "$VERSION_CODE" --version-name "$VERSION_NAME")
[ -d "$SRC/assets" ] && LINK_ARGS+=(-A "$SRC/assets")
"$BT/aapt2" link "${LINK_ARGS[@]}" "$OUT/compiled_res.zip"

echo "==> javac"
find "$SRC/java" "$OUT/gen" -name "*.java" > "$OUT/sources.txt"
javac -source 17 -target 17 -cp "$PLATFORM" -d "$OUT/classes" @"$OUT/sources.txt" 2>&1 | grep -v "bootstrap class path" || true

echo "==> d8 (dex)"
"$BT/d8" --lib "$PLATFORM" --min-api 24 --output "$OUT/dex" $(find "$OUT/classes" -name "*.class")

echo "==> insert classes.dex"
cp "$OUT/base.apk" "$OUT/app-unsigned.apk"
python3 - "$OUT/app-unsigned.apk" "$OUT/dex/classes.dex" <<'EOF'
import sys, zipfile
apk_path, dex_path = sys.argv[1], sys.argv[2]
with zipfile.ZipFile(apk_path, 'a', zipfile.ZIP_STORED) as z:
    z.write(dex_path, 'classes.dex')
EOF

echo "==> zipalign + apksigner"
"$BT/zipalign" -f 4 "$OUT/app-unsigned.apk" "$OUT/app-aligned.apk"
"$BT/apksigner" sign --ks "$KEYSTORE" --ks-pass pass:android --key-pass pass:android \
  --out "$OUT/app-debug.apk" "$OUT/app-aligned.apk"

echo "==> verify"
"$BT/apksigner" verify "$OUT/app-debug.apk" && echo "SIGNATURE OK"
"$BT/aapt2" dump badging "$OUT/app-debug.apk" | head -6

cp "$OUT/app-debug.apk" "$APK_OUT/app-debug.apk"
echo "APK ready: $APK_OUT/app-debug.apk"
ls -la "$APK_OUT/app-debug.apk"
