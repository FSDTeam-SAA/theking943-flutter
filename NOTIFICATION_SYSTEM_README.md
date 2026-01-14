# Local Polling Notification System

This document explains how to use the Local Polling Notification System implemented in your Flutter app without Firebase Push Notifications.

## Overview

The system consists of:
1. **Backend API endpoint** (`/api/notifications`) - Node.js/MongoDB
2. **NotificationPoller service** - Flutter background polling every 30 seconds
3. **NotificationProvider** - State management for unread count
4. **Local notifications** - Shows system notifications using `flutter_local_notifications`

## Files Created/Modified

### Backend
- `backend/api/notifications.js` - API endpoint for fetching user notifications

### Flutter
- `lib/services/notification_poller.dart` - Main polling service
- `lib/providers/notification_provider.dart` - State management
- `lib/models/notification_model.dart` - Updated with fromJson/toJson
- `lib/main.dart` - Initialized on app startup
- `lib/screens/auth/sign_in_screen.dart` - Starts polling on login
- `lib/app.dart` - Stops polling on logout
- `lib/screens/patient/navigation/patient_main_navigation.dart` - Shows unread badge

## Features

✅ **Automatic polling** every 30 seconds  
✅ **Duplicate prevention** using SharedPreferences  
✅ **System notifications** for new messages  
✅ **Unread count tracking** with ValueNotifier  
✅ **Lifecycle management** (starts on login, stops on logout)  
✅ **Badge indicator** on navigation bar  

## Usage

### 1. Backend Setup

Add this route to your Node.js Express app:

```javascript
const notificationsRouter = require('./api/notifications');
app.use('/api', notificationsRouter);
```

### 2. Starting Polling

**Automatic (recommended):** Already implemented in sign-in flow
```dart
// In sign_in_screen.dart - after successful login
if (_notificationProvider != null) {
  await _notificationProvider!.startPolling();
}
```

**Manual:**
```dart
final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
await notificationProvider.startPolling();
```

### 3. Stopping Polling

**Automatic (recommended):** Already implemented in logout
```dart
// In app.dart - during logout
notificationProvider.stopPolling();
await notificationProvider.clearNotifications();
```

**Manual:**
```dart
final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
notificationProvider.stopPolling();
```

### 4. Displaying Unread Count Badge

**In Navigation Bar:**
```dart
Consumer<NotificationProvider>(
  builder: (context, notificationProvider, child) {
    final unreadCount = notificationProvider.unreadCount;
    return Stack(
      children: [
        Icon(Icons.message),
        if (unreadCount > 0)
          Positioned(
            right: -8, top: -8,
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
      ],
    );
  },
)
```

**In Any Widget:**
```dart
Consumer<NotificationProvider>(
  builder: (context, notificationProvider, child) {
    return Text('Unread: ${notificationProvider.unreadCount}');
  },
)
```

### 5. Mark Notifications as Read

**Single notification:**
```dart
await notificationProvider.markAsRead('notification_id');
```

**All notifications:**
```dart
await notificationProvider.markAllAsRead();
```

### 6. Manual Refresh

```dart
await notificationProvider.refreshNotifications();
```

## Configuration

### Polling Interval

Edit `lib/services/notification_poller.dart`:
```dart
static const Duration _pollingInterval = Duration(seconds: 30); // Change as needed
```

### Notification Channel

The system creates a notification channel named `'docmobi_notifications'` with:
- Importance: High
- Priority: High
- Vibration: Enabled
- Sound: Enabled

## Data Flow

1. **Login** → NotificationPoller starts
2. **Every 30 seconds** → Calls `/api/notifications` 
3. **Compares** latest notification ID with stored ID
4. **If new** → Shows local notification + updates unread count
5. **Logout** → Stops polling and clears stored data

## API Endpoint Details

### GET /api/notifications

**Response format:**
```json
{
  "success": true,
  "data": [
    {
      "id": "notification_id",
      "title": "New message",
      "message": "You have a new message from Dr. Smith",
      "time": "5 min ago",
      "type": "message",
      "isRead": false
    }
  ],
  "total": 10
}
```

## Notification Types

The system handles these notification types:
- `"message"` - Chat messages
- `"appointment"` - Appointment reminders
- `"general"` - General notifications
- Custom types as defined by your backend

## Error Handling

- Network errors are logged but don't crash the app
- Invalid responses are gracefully handled
- Polling continues automatically after errors
- Token expiration triggers automatic logout

## Security Considerations

✅ All API calls include authentication token  
✅ No sensitive data stored in SharedPreferences (only notification IDs)  
✅ Network timeouts prevent hanging requests  
✅ Proper cleanup on app lifecycle events  

## Performance

- **Low battery impact**: 30-second polling is efficient
- **Minimal data usage**: Only fetches new notifications
- **Memory efficient**: Keeps only current notification ID
- **Background friendly**: Works when app is in background (iOS/Android limitations apply)

## Troubleshooting

### Notifications not showing:
1. Check notification permissions in device settings
2. Verify API endpoint returns correct format
3. Check console logs for errors
4. Ensure user is authenticated

### Polling not starting:
1. Verify user is logged in successfully
2. Check that `startPolling()` is called after login
3. Look for initialization errors in logs

### Badge not updating:
1. Ensure `Consumer<NotificationProvider>` is used in UI
2. Check that `notifyListeners()` is called
3. Verify unread count is being calculated correctly

## Customization

### Add new notification type handling:
```dart
// In notification_poller.dart - _handleNotificationTap method
void _handleNotificationTap(String? id, String? type) {
  switch (type) {
    case 'appointment':
      // Navigate to appointment screen
      break;
    case 'message':
      // Navigate to chat screen
      break;
    default:
      // Default behavior
  }
}
```

### Customize notification appearance:
```dart
// In notification_poller.dart - _showLocalNotification method
const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
  'docmobi_notifications',
  'DocMobi Notifications',
  channelDescription: 'Notifications from DocMobi app',
  importance: Importance.high,
  priority: Priority.high,
  color: Color(0xFF1664CD), // Your app's color
  enableVibration: true,
  playSound: true,
);
```

This system provides a complete, production-ready local notification solution without relying on Firebase Cloud Messaging!