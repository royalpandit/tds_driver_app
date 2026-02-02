# Firebase Setup Instructions

## ✅ Firebase Project Status
Your Firebase project is configured with:
- **Sender ID**: 456204258662
- **Android Package**: com.traveldesk.driver
- **iOS Bundle ID**: com.traveldesk.driver
- **FCM API V1**: ✅ Enabled (Recommended)

## 1. Download Configuration Files

### Android Configuration
1. In Firebase Console, go to Project Settings → General tab
2. Scroll down to "Your apps" section
3. Click on the Android app (com.traveldesk.driver)
4. Click "Download google-services.json"
5. Replace the placeholder file at `android/app/google-services.json` with your downloaded file

### iOS Configuration
1. In Firebase Console, go to Project Settings → General tab
2. Scroll down to "Your apps" section
3. Click on the iOS app (com.traveldesk.driver)
4. Click "Download GoogleService-Info.plist"
5. Replace the placeholder file at `ios/Runner/GoogleService-Info.plist` with your downloaded file

## 2. APNs Configuration for iOS (Important!)

Since you have iOS app configured, you need to set up APNs certificates/keys:

### Option 1: APNs Authentication Key (Recommended)
1. Go to [Apple Developer Console](https://developer.apple.com/account/)
2. Navigate to Certificates, Identifiers & Profiles → Keys
3. Create a new key with "Apple Push Notifications service (APNs)" enabled
4. Download the .p8 file
5. In Firebase Console → Project Settings → Cloud Messaging
6. Upload the APNs auth key (.p8 file)
7. Enter the Key ID and Team ID

### Option 2: APNs Certificates (Legacy)
1. Create APNs certificates from Apple Developer Console
2. Download development and production certificates
3. Upload them in Firebase Console

## 3. Test Your Setup

### Test Notifications from Firebase Console
1. Go to Cloud Messaging in Firebase Console
2. Click "Send your first message"
3. Enter test notification details
4. Select your app as target
5. Send test notification

### Verify Token Generation
1. Run the app on a device/emulator
2. Check console logs for FCM token
3. Verify token is sent during registration

## 4. Server Integration

Your server can now send notifications using:
- **FCM Server Key**: Available in Firebase Console → Project Settings → Cloud Messaging
- **FCM Tokens**: Automatically collected during driver registration

## 5. Notification Payload Structure

When sending notifications from your server, use this payload structure:

```json
{
  "message": {
    "token": "driver_fcm_token_here",
    "notification": {
      "title": "New Ride Request",
      "body": "You have a new ride request from customer"
    },
    "data": {
      "type": "ride_request",
      "ride_id": "123",
      "customer_name": "John Doe"
    }
  }
}
```

## 6. Supported Notification Types

The app handles these notification types:
- `ride_request`: New ride request notifications
- `trip_update`: Trip status updates  
- `payment`: Payment-related notifications

## 7. Troubleshooting

### Common Issues:
1. **Notifications not received on iOS**: Check APNs certificates/keys
2. **Android notifications not working**: Verify google-services.json is correct
3. **Token not generated**: Check Firebase initialization logs

### Debug Steps:
1. Check device logs for Firebase initialization messages
2. Verify FCM token is generated and sent to server
3. Test with Firebase Console notification composer
4. Check notification permissions on device

## Important Notes

- ✅ Replace placeholder configuration files with actual Firebase files
- ✅ Set up APNs for iOS notifications to work
- ✅ Test notifications on both Android and iOS devices
- ✅ Ensure your server uses FCM v1 API (not legacy API)
- ✅ Handle notification permissions appropriately in your app flow