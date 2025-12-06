# 📱 Flutter Integration Guide

## Quick Start for Flutter Team

This guide will help you integrate the Ush Game backend APIs into your Flutter app.

---

## 📚 Documentation Files

1. **API_DOCUMENTATION.md** - Complete API reference with all endpoints
2. **DEPLOYMENT_GUIDE.md** - Backend deployment instructions
3. **This file** - Quick integration guide

---

## 🔗 Production URLs

**Backend API:** `https://your-app.onrender.com/api`  
**Socket.IO:** `wss://your-app.onrender.com`

*(Replace with actual URLs after deployment)*

---

## 🚀 Quick Integration Steps

### Step 1: Update Backend URL

In `lib/config/backend_api_config.dart`:

```dart
class BackendApiConfig {
  static const String baseUrl = 'https://your-app.onrender.com/api';
  
  // Keep all existing methods
}
```

### Step 2: Add Socket.IO Package

In `pubspec.yaml`:

```yaml
dependencies:
  socket_io_client: ^2.0.3+1
```

Run: `flutter pub get`

### Step 3: Implement Missing API Calls

#### 3.1 Book Ticket (Already exists, just call it)

```dart
// When user clicks "Book Ticket"
try {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final gameId = 'get-from-live-game-api';
  
  final result = await BackendApiConfig.bookTicket(
    token: token!,
    gameId: gameId,
  );
  
  // Store card number
  await prefs.setString('cardNumber', result['booking']['cardNumber']);
  await prefs.setString('ticketNumber', result['booking']['ticketNumber']);
  
  // Show success message
  print('Ticket booked! Card: ${result['booking']['cardNumber']}');
} catch (e) {
  print('Booking failed: $e');
}
```

#### 3.2 Verify Card (Already exists, just call it)

```dart
// When user enters card number in game countdown screen
try {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final gameId = 'current-game-id';
  final cardNumber = _cardNumberController.text; // User input
  
  final result = await BackendApiConfig.verifyCard(
    token: token!,
    gameId: gameId,
    cardNumber: cardNumber,
  );
  
  if (result['valid']) {
    // Navigate to game screen
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => GameTiltWidget()
    ));
  } else {
    // Show error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Invalid card number'))
    );
  }
} catch (e) {
  print('Verification failed: $e');
}
```

#### 3.3 Connect to Socket.IO

Create `lib/services/socket_service.dart`:

```dart
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  late IO.Socket socket;
  Function(int)? onNumberAnnounced;

  void connect() {
    socket = IO.io('https://your-app.onrender.com', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.on('connect', (_) {
      print('Connected to Socket.IO');
    });

    socket.on('number:announced', (data) {
      print('New number: ${data['number']}');
      if (onNumberAnnounced != null) {
        onNumberAnnounced!(data['number']);
      }
    });

    socket.on('disconnect', (_) {
      print('Disconnected from Socket.IO');
    });
  }

  void joinGame(String gameId) {
    socket.emit('game:join', {'gameId': gameId});
  }

  void leaveGame(String gameId) {
    socket.emit('game:leave', {'gameId': gameId});
  }

  void disconnect() {
    socket.disconnect();
  }
}
```

#### 3.4 Use Socket.IO in Game Screen

In `game_tilt_widget.dart`:

```dart
class _GameTiltWidgetState extends State<GameTiltWidget> {
  final SocketService _socketService = SocketService();
  
  @override
  void initState() {
    super.initState();
    
    // Connect to Socket.IO
    _socketService.connect();
    _socketService.joinGame('current-game-id');
    
    // Listen to numbers
    _socketService.onNumberAnnounced = (number) {
      setState(() {
        _currentNumber = number;
        // Update UI with new number
      });
    };
  }
  
  @override
  void dispose() {
    _socketService.leaveGame('current-game-id');
    _socketService.disconnect();
    super.dispose();
  }
}
```

#### 3.5 Claim Win

Add to `backend_api_config.dart`:

```dart
static Future<Map<String, dynamic>> claimWin({
  required String token,
  required String gameId,
  required String winType, // "ONE_LINE" or "JALDI"
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/game/$gameId/claim-win'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({'winType': winType}),
  );
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception(jsonDecode(response.body)['message'] ?? 'Claim failed');
  }
}
```

Call it when user clicks win button:

```dart
// When user clicks "FIRST LINE" button
try {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final gameId = 'current-game-id';
  
  final result = await BackendApiConfig.claimWin(
    token: token!,
    gameId: gameId,
    winType: 'ONE_LINE',
  );
  
  if (result['valid']) {
    // Show coupon
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Congratulations!'),
        content: Text('You won! Coupon ID: ${result['couponId']}'),
      ),
    );
  }
} catch (e) {
  print('Claim failed: $e');
}
```

---

## ✅ Integration Checklist

- [ ] Update backend URL in `backend_api_config.dart`
- [ ] Add `socket_io_client` package
- [ ] Implement Socket.IO service
- [ ] Call `bookTicket()` when user books
- [ ] Call `verifyCard()` before game starts
- [ ] Connect to Socket.IO in game screen
- [ ] Listen to `number:announced` events
- [ ] Implement `claimWin()` method
- [ ] Call `claimWin()` when user clicks win buttons
- [ ] Test all flows end-to-end

---

## 🧪 Testing

### Test Locally First

1. Run backend locally: `npm start` (in backend folder)
2. Update Flutter app to use `http://10.0.2.2:5000/api`
3. Test all features
4. Fix any issues

### Test with Production

1. Deploy backend to Render
2. Update Flutter app with production URL
3. Build APK: `flutter build apk --release`
4. Install on device and test

---

## 🐛 Common Issues

### Issue: "Connection refused"
**Solution:** Check if backend URL is correct and backend is running

### Issue: "Invalid token"
**Solution:** User needs to login again, token might be expired

### Issue: "Socket.IO not connecting"
**Solution:** 
- Use `wss://` for production (not `ws://`)
- Check if backend is running
- Verify Socket.IO URL

### Issue: "Card number invalid"
**Solution:** 
- Ensure card number is 5 digits
- Check if user has booked ticket
- Verify gameId is correct

---

## 📞 Need Help?

If you encounter any issues:

1. Check API_DOCUMENTATION.md for endpoint details
2. Check backend logs on Render dashboard
3. Contact backend developer

---

## 🎯 Expected Result

After integration:

1. ✅ User can register and login
2. ✅ User can book tickets
3. ✅ User receives card number
4. ✅ User can verify card number
5. ✅ User sees real-time number announcements
6. ✅ User can claim wins
7. ✅ User receives coupons
8. ✅ Admin can see all bookings

---

**Happy Coding!** 🚀
