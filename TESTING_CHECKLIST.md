# 🧪 Testing Checklist

## Backend Integration Testing

### ✅ Pre-requisites
- [ ] Backend server running on `http://localhost:5000`
- [ ] MongoDB connected
- [ ] Admin account created
- [ ] Test user account created

### 📱 Flutter App Testing

#### 1. Authentication Flow
- [ ] Register new user
- [ ] Verify OTP
- [ ] Login with credentials
- [ ] Token stored in SharedPreferences

#### 2. Game Booking
- [ ] Navigate to Live Game screen
- [ ] See available game slots
- [ ] Select ticket count (1, 3, 6, custom)
- [ ] Select time slot
- [ ] Book ticket successfully
- [ ] Card number stored
- [ ] GameId stored

#### 3. Countdown Screen
- [ ] Navigate to countdown screen
- [ ] Countdown syncs with backend
- [ ] Shows correct time remaining
- [ ] Countdown reaches zero
- [ ] "Game Started" UI appears

#### 4. Card Verification
- [ ] Enter 5-digit card number
- [ ] Valid card → Navigate to game
- [ ] Invalid card → Show error
- [ ] Card number obscured (xxxxx)

#### 5. Game Status Updates
- [ ] Game status badge shows "SCHEDULED"
- [ ] Status changes to "COUNTDOWN"
- [ ] Status changes to "LIVE"
- [ ] Status updates every 2 seconds

#### 6. Win Type Selection
- [ ] Select FIRST LINE
- [ ] Select SECOND LINE
- [ ] Select THIRD LINE
- [ ] Select JALDHI
- [ ] Select HOUSI
- [ ] Selection stored for claim

#### 7. Offline Mode
- [ ] Stop backend server
- [ ] App continues to work
- [ ] Mock countdown (5 seconds)
- [ ] Mock card accepted
- [ ] No crashes or errors

### 🎮 Backend Admin Testing

#### 1. Game Creation
```bash
POST /api/admin/games/create
{
  "gameCode": "GAME001",
  "scheduledTime": "2024-01-20T18:00:00Z",
  "totalSlots": 100
}
```
- [ ] Game created successfully
- [ ] Appears in Flutter app

#### 2. Game Control
```bash
POST /api/admin/games/:gameId/start
```
- [ ] Game status changes to LIVE
- [ ] Flutter app shows LIVE badge

```bash
POST /api/admin/games/:gameId/announce
{
  "number": 42
}
```
- [ ] Number announced
- [ ] Flutter app receives update

```bash
POST /api/admin/games/:gameId/end
```
- [ ] Game status changes to COMPLETED
- [ ] Winners recorded

#### 3. Statistics
```bash
GET /api/admin/stats
```
- [ ] Returns total bookings
- [ ] Returns active bookings
- [ ] Returns total users
- [ ] Returns total games

### 🔄 Real-time Updates Testing

#### 1. Game Status Polling
- [ ] Open Flutter app
- [ ] Start game from admin panel
- [ ] Flutter app shows LIVE within 2 seconds
- [ ] Announce number from admin
- [ ] Flutter app receives number within 2 seconds

#### 2. Multiple Devices
- [ ] Open app on 2 devices
- [ ] Book tickets on both
- [ ] Start game from admin
- [ ] Both devices update simultaneously
- [ ] Announce numbers
- [ ] Both devices receive updates

### 🏆 Win Claiming Testing

#### 1. Valid Win Claim
- [ ] User completes FIRST LINE
- [ ] Claim win via button
- [ ] Backend validates
- [ ] Coupon generated
- [ ] Win recorded in game

#### 2. Invalid Win Claim
- [ ] Try to claim already claimed win
- [ ] Error message shown
- [ ] No coupon generated

#### 3. Win Type Availability
- [ ] Check if FIRST LINE available
- [ ] Claim FIRST LINE
- [ ] Check again - should be unavailable
- [ ] Other win types still available

### 🔐 Security Testing

#### 1. Authentication
- [ ] Access game endpoints without token → 401
- [ ] Access with invalid token → 401
- [ ] Access with valid token → 200

#### 2. Authorization
- [ ] User tries admin endpoint → 403
- [ ] Admin accesses admin endpoint → 200

#### 3. Data Validation
- [ ] Book with invalid gameId → 404
- [ ] Verify with wrong card → 400
- [ ] Announce invalid number (>90) → 400
- [ ] Announce duplicate number → 400

### 📊 Performance Testing

#### 1. Polling Performance
- [ ] Monitor network requests
- [ ] Verify 2-second interval
- [ ] Check battery usage
- [ ] No memory leaks

#### 2. Multiple Users
- [ ] 10 users book tickets
- [ ] All receive updates
- [ ] No lag or delays
- [ ] Server handles load

### 🐛 Error Handling

#### 1. Network Errors
- [ ] Disconnect WiFi during booking
- [ ] Graceful error message
- [ ] Reconnect → Resume functionality

#### 2. Backend Errors
- [ ] Backend returns 500
- [ ] App shows user-friendly error
- [ ] App doesn't crash

#### 3. Invalid Data
- [ ] Backend returns unexpected format
- [ ] App handles gracefully
- [ ] Falls back to mock data

### ✨ User Experience

#### 1. Loading States
- [ ] Booking shows loading indicator
- [ ] Countdown shows loading
- [ ] Win claim shows loading

#### 2. Success Messages
- [ ] Booking success → Snackbar
- [ ] Card verified → Navigate
- [ ] Win claimed → Congratulations

#### 3. Error Messages
- [ ] Clear error messages
- [ ] Actionable (e.g., "Try again")
- [ ] Not technical jargon

### 📱 Device Testing

- [ ] Android Emulator
- [ ] iOS Simulator
- [ ] Physical Android Device
- [ ] Physical iOS Device
- [ ] Different screen sizes
- [ ] Different OS versions

### 🎯 Final Checks

- [ ] No console errors
- [ ] No memory leaks
- [ ] Smooth animations
- [ ] Fast response times
- [ ] Intuitive UI
- [ ] All features working
- [ ] Backend integration complete
- [ ] Offline mode functional

## 🚀 Ready for Production

Once all items checked:
- [ ] Code reviewed
- [ ] Documentation complete
- [ ] Backend deployed
- [ ] Flutter app built
- [ ] Beta testing done
- [ ] Production deployment

---

## 📝 Notes

Record any issues found during testing:

1. Issue: _______________
   Fix: _______________

2. Issue: _______________
   Fix: _______________

3. Issue: _______________
   Fix: _______________
