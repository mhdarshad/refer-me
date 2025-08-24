# Referral Client Example

This example demonstrates how to use the `referral_client` package in a Flutter app.

## Features Demonstrated

- **Initialization**: How to set up the referral client on app startup
- **Link Generation**: Creating referral links for users
- **Manual Confirmation**: Testing referral confirmation with tokens
- **UI Integration**: Complete UI example with error handling

## How to Run

1. **Navigate to the example directory**:
   ```bash
   cd example
   ```

2. **Get dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

## What the Example Shows

### 1. App Initialization (`main.dart`)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the referral client
  referral = ReferralClient(
    backendBaseUrl: 'https://api.yourdomain.com', // Replace with your backend URL
    androidPackage: 'com.example.referral_app',
    appStoreId: '1234567890',
  );

  // Start listening for in-app deep links
  referral.startLinkListener();

  // Try confirming via Android Install Referrer
  await referral.confirmInstallIfPossible();

  runApp(const MyApp());
}
```

### 2. Generate Referral Links

The example shows how to:
- Input a user ID
- Generate a referral link
- Display the generated link
- Copy/share the link

### 3. Manual Confirmation

The example demonstrates:
- Manual token input
- Confirmation testing
- Result display

### 4. Error Handling

The example includes proper error handling for:
- Network failures
- Invalid responses
- User input validation

## Backend Setup

To test this example, you'll need a backend that implements the expected API:

### POST /create-referral
```json
{
  "referrerId": "USER123"
}
```

**Response:**
```json
{
  "shortLink": "https://go.yourapp.com/aB12xY"
}
```

### POST /confirm-install
```json
{
  "referrerToken": "token123",
  "deviceId": "device456"
}
```

**Response:**
```json
{
  "success": true,
  "referralCode": "USER123"
}
```

## Testing

1. **Link Generation**: Enter a user ID and tap "Generate Referral Link"
2. **Manual Confirmation**: Enter a token and tap "Confirm"
3. **Deep Links**: Test with URLs like `yourapp://?uid=token123`

## Customization

- Update `backendBaseUrl` to point to your backend
- Modify `androidPackage` and `appStoreId` for your app
- Add your own UI styling and branding
- Implement proper sharing functionality

## Next Steps

1. Set up your backend API
2. Configure Universal Links for iOS
3. Set up Play Store Install Referrer for Android
4. Test with real devices
5. Add analytics and tracking
