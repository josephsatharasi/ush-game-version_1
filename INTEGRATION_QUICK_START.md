# 🚀 Backend Integration Quick Start

## What Was Integrated

### ✅ New API Endpoints
1. **Game Status** - Real-time game state, numbers, winners
2. **Win Claiming** - Submit and validate win claims
3. **Card Verification** - Verify card numbers before game start

### ✅ New Services
1. **GameService** - Polls backend every 2s for updates
2. **WinClaimService** - Handles win claim logic

### ✅ Updated Screens
1. **Home** - Checks for live games on startup
2. **Countdown** - Syncs with backend timer, verifies cards
3. **Live Game** - Shows game status badge, real-time updates

## 🎯 Key Features

### Real-time Game Updates
```dart
// Automatically polls every 2 seconds
GameService().startPolling();

// Listen to updates
GameService().gameStatusStream.listen((status) {
  print('Game Status: ${status['status']}');
  print('Current Number: ${status['currentNumber']}');
  print('Announced: ${status['announcedNumbers']}');
});
```

### Card Verification
```dart
// Verifies card before entering game
await BackendApiConfig.verifyCard(
  token: token,
  gameId: gameId,
  cardNumber: '12345',
);
```

### Win Claiming
```dart
// Claim a win
final result = await WinClaimService().claimWin('FIRST_LINE');
print('Coupon: ${result['couponId']}');

// Check if win type is available
final canClaim = await WinClaimService().canClaimWin('HOUSIE');
```

## 📱 User Flow

1. **Login** → Token stored in SharedPreferences
2. **Book Ticket** → Card number + gameId stored
3. **Countdown** → Backend syncs timer
4. **Enter Card** → Verified with backend
5. **Game Live** → Status updates every 2s
6. **Claim Win** → Validated and coupon generated

## 🔧 Configuration

### Backend URL
Edit `lib/config/backend_api_config.dart`:
```dart
static const String baseUrl = 'http://YOUR_IP:5000/api';
```

### Polling Interval
Edit `lib/services/game_service.dart`:
```dart
Timer.periodic(Duration(seconds: 2), ...); // Change 2 to desired seconds
```

## 🎮 Game Status Values

- `SCHEDULED` - Game scheduled, not started
- `COUNTDOWN` - Countdown in progress
- `LIVE` - Game is live, numbers being announced
- `COMPLETED` - Game finished

## 🏆 Win Types

| Display | Backend | Description |
|---------|---------|-------------|
| FIRST LINE | FIRST_LINE | First row complete |
| SECOND LINE | SECOND_LINE | Second row complete |
| THIRD LINE | THIRD_LINE | Third row complete |
| JALDHI | JALDI | Quick 5 numbers |
| HOUSI | HOUSIE | Full card |

## 🔄 Offline Fallback

All features work offline with mock data:
- Mock countdown (5 seconds)
- Mock card numbers accepted
- Local game state maintained

## 📊 Data Flow

```
User Action → Flutter App → Backend API → Database
                    ↓
            GameService (polling)
                    ↓
            UI Updates (Stream)
```

## 🐛 Debugging

### Check Backend Connection
```dart
try {
  final game = await BackendApiConfig.getLiveGame();
  print('Connected: ${game['game']['_id']}');
} catch (e) {
  print('Backend offline: $e');
}
```

### Check Stored Data
```dart
final prefs = await SharedPreferences.getInstance();
print('Token: ${prefs.getString('token')}');
print('GameId: ${prefs.getString('gameId')}');
print('CardNumber: ${prefs.getString('cardNumber')}');
```

## ✨ No Breaking Changes

All existing functionality preserved:
- Offline mode still works
- Mock data as fallback
- UI unchanged
- Navigation unchanged

## 🎉 Ready to Use!

The integration is complete and backward compatible. The app will:
- Use backend when available
- Fall back to mock data when offline
- Provide seamless experience in both modes
