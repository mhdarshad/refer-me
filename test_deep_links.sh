#!/bin/bash

# Deep Link Testing Script for Refer Me
# This script helps test deep links on Android devices

echo "🔗 Refer Me Deep Link Testing Script"
echo "====================================="

# Check if ADB is available
if ! command -v adb &> /dev/null; then
    echo "❌ ADB not found. Please add Android SDK platform-tools to your PATH:"
    echo "   export PATH=\"\$PATH:/Users/mohammedarshad/Library/Android/sdk/platform-tools\""
    echo "   Or use the full path: /Users/mohammedarshad/Library/Android/sdk/platform-tools/adb"
    exit 1
fi

# Check if device is connected
echo "📱 Checking for connected devices..."
DEVICES=$(adb devices | grep -v "List of devices attached" | grep -v "^$" | wc -l)

if [ $DEVICES -eq 0 ]; then
    echo "❌ No Android devices connected."
    echo "   Please connect your device via USB and enable USB debugging."
    exit 1
fi

echo "✅ Found $DEVICES device(s) connected"
adb devices

echo ""
echo "🧪 Testing Deep Links..."
echo "========================"

# Test different deep link scenarios
echo "1. Testing referral link..."
adb shell am start -W -a android.intent.action.VIEW -d "referme://referral?token=TEST123&source=email&campaign=winter2024"

echo ""
echo "2. Testing campaign link..."
adb shell am start -W -a android.intent.action.VIEW -d "referme://campaign?id=winter2024&source=social&medium=facebook"

echo ""
echo "3. Testing invite link..."
adb shell am start -W -a android.intent.action.VIEW -d "referme://invite?code=INVITE456&inviter=user789&message=Join%20me!"

echo ""
echo "4. Testing share link..."
adb shell am start -W -a android.intent.action.VIEW -d "referme://share?user=user123&message=Check%20out%20this%20app!"

echo ""
echo "5. Testing HTTPS deep link..."
adb shell am start -W -a android.intent.action.VIEW -d "https://yourdomain.com/referral?token=TEST123&source=email"

echo ""
echo "✅ Deep link testing completed!"
echo ""
echo "📝 Notes:"
echo "   - Make sure your app is installed and configured for deep links"
echo "   - Check your app logs for deep link handling"
echo "   - If links don't work, verify your AndroidManifest.xml configuration"
echo ""
echo "🔧 To test with a specific package, use:"
echo "   adb shell am start -W -a android.intent.action.VIEW -d \"referme://referral?token=TEST123\" com.yourapp.package"
