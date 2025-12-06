# 🎮 Ush Game Backend API Documentation

**Version:** 1.0  
**Base URL:** `https://your-render-url.onrender.com/api`  
**Local URL:** `http://localhost:5000/api`

---

## 📋 Table of Contents

1. [Authentication](#authentication)
2. [Game Management](#game-management)
3. [Booking System](#booking-system)
4. [Gameplay](#gameplay)
5. [Real-time Events (Socket.IO)](#real-time-events)
6. [Error Handling](#error-handling)
7. [Data Models](#data-models)

---

## 🔐 Authentication

### 1.1 Register User

**Endpoint:** `POST /auth/register`

**Description:** Register a new user and receive OTP via SMS

**Request Body:**
```json
{
  "username": "john_doe",
  "phone": "9876543210",
  "password": "SecurePass@123",
  "role": "user"
}
```

**Response (200):**
```json
{
  "message": "Registration successful. OTP sent.",
  "userId": "507f1f77bcf86cd799439011",
  "adminId": "507f1f77bcf86cd799439011"
}
```

**Response (500):**
```json
{
  "message": "User already exists"
}
```

**Notes:**
- OTP is 4 digits
- OTP expires in 5 minutes
- Phone number should be 10 digits
- Password must be strong (8+ chars, uppercase, lowercase, number, special char)

---

### 1.2 Verify OTP

**Endpoint:** `POST /auth/verify-otp`

**Description:** Verify OTP and complete registration

**Request Body:**
```json
{
  "userId": "507f1f77bcf86cd799439011",
  "otp": "1234"
}
```

**Response (200):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "507f1f77bcf86cd799439011",
    "username": "john_doe",
    "phone": "9876543210",
    "role": "user"
  }
}
```

**Response (400):**
```json
{
  "message": "Invalid OTP"
}
```

**Notes:**
- Store the JWT token in SharedPreferences
- Token expires in 7 days
- Use token in Authorization header for protected routes

---

### 1.3 Login

**Endpoint:** `POST /auth/login`

**Description:** Login with username and password

**Request Body:**
```json
{
  "username": "john_doe",
  "password": "SecurePass@123"
}
```

**Response (200):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "507f1f77bcf86cd799439011",
    "username": "john_doe",
    "phone": "9876543210",
    "role": "user"
  }
}
```

**Response (401):**
```json
{
  "message": "Invalid credentials"
}
```

---

### 1.4 Resend OTP

**Endpoint:** `POST /auth/resend-otp`

**Description:** Resend OTP to user's phone

**Request Body:**
```json
{
  "userId": "507f1f77bcf86cd799439011"
}
```

**Response (200):**
```json
{
  "message": "OTP resent"
}
```

**Response (404):**
```json
{
  "message": "User not found"
}
```

---

## 🎮 Game Management

### 2.1 Get Live Game

**Endpoint:** `GET /game/live`

**Description:** Get the next scheduled or live game

**Headers:**
```
Content-Type: application/json
```

**Response (200):**
```json
{
  "game": {
    "_id": "507f1f77bcf86cd799439011",
    "gameCode": "GAME001",
    "status": "SCHEDULED",
    "scheduledTime": "2024-01-20T14:30:00.000Z",
    "totalSlots": 100,
    "bookedSlots": 45,
    "announcedNumbers": [],
    "currentNumber": null
  }
}
```

**Response (404):**
```json
{
  "message": "No upcoming games"
}
```

**Game Status Values:**
- `SCHEDULED` - Game is scheduled but not started
- `COUNTDOWN` - Countdown phase before game starts
- `LIVE` - Game is currently running
- `COMPLETED` - Game has ended

---

### 2.2 Get Game Status

**Endpoint:** `GET /game/:gameId/status`

**Description:** Get current game status and announced numbers

**Headers:**
```
Authorization: Bearer <token>
Content-Type: application/json
```

**Response (200):**
```json
{
  "status": "LIVE",
  "currentNumber": 42,
  "announcedNumbers": [15, 23, 8, 42, 67, 31],
  "oneLineWinner": {
    "userId": "507f1f77bcf86cd799439011",
    "cardNumber": "12345",
    "wonAt": "2024-01-20T14:35:00.000Z",
    "couponCode": "ABC12345"
  },
  "jaldiWinner": null
}
```

**Response (404):**
```json
{
  "message": "Game not found"
}
```

---

### 2.3 Get Countdown

**Endpoint:** `GET /game/:gameId/countdown`

**Description:** Get countdown timer and booking status

**Headers:**
```
Authorization: Bearer <token>
Content-Type: application/json
```

**Response (200):**
```json
{
  "timeRemaining": 120,
  "status": "COUNTDOWN",
  "booking": {
    "cardNumber": "12345",
    "status": "DELIVERED"
  }
}
```

**Notes:**
- `timeRemaining` is in seconds
- `booking` is null if user hasn't booked

---

## 🎫 Booking System

### 3.1 Book Ticket

**Endpoint:** `POST /game/book`

**Description:** Book a ticket for a game

**Headers:**
```
Authorization: Bearer <token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "gameId": "507f1f77bcf86cd799439011"
}
```

**Response (200):**
```json
{
  "booking": {
    "_id": "507f1f77bcf86cd799439012",
    "cardNumber": "12345",
    "ticketNumber": "67890",
    "status": "PENDING"
  }
}
```

**Response (400):**
```json
{
  "message": "Already booked"
}
```

**Response (400):**
```json
{
  "message": "Game is full"
}
```

**Notes:**
- Card number is 5 digits (e.g., "12345")
- Ticket number is 5 digits (e.g., "67890")
- Status changes to "DELIVERED" after 2 seconds automatically
- Store cardNumber in SharedPreferences for game entry

---

### 3.2 Verify Card Number

**Endpoint:** `POST /game/:gameId/verify-card`

**Description:** Verify user's card number before starting game

**Headers:**
```
Authorization: Bearer <token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "cardNumber": "12345"
}
```

**Response (200):**
```json
{
  "valid": true,
  "message": "Card verified"
}
```

**Response (400):**
```json
{
  "valid": false,
  "message": "Invalid card number"
}
```

**Notes:**
- Call this endpoint when user enters card number in game countdown screen
- Only proceed to game if valid is true

---

## 🏆 Gameplay

### 4.1 Claim Win

**Endpoint:** `POST /game/:gameId/claim-win`

**Description:** Claim a win (One Line, Jaldi, etc.)

**Headers:**
```
Authorization: Bearer <token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "winType": "ONE_LINE"
}
```

**Win Types:**
- `ONE_LINE` - First line completed
- `JALDI` - First to complete any line (fast win)

**Response (200):**
```json
{
  "valid": true,
  "couponId": "507f1f77bcf86cd799439013",
  "message": "Congratulations! You won!"
}
```

**Response (400):**
```json
{
  "valid": false,
  "message": "One Line already claimed"
}
```

**Response (400):**
```json
{
  "valid": false,
  "message": "No booking found"
}
```

**Notes:**
- Backend validates if user actually won
- Each win type can only be claimed once per game
- Coupon is automatically generated on successful win

---

## 🔴 Real-time Events (Socket.IO)

### 5.1 Connection

**URL:** `wss://your-render-url.onrender.com` or `ws://localhost:5000`

**Connect:**
```dart
import 'package:socket_io_client/socket_io_client.dart' as IO;

IO.Socket socket = IO.io('https://your-render-url.onrender.com', <String, dynamic>{
  'transports': ['websocket'],
  'autoConnect': false,
});

socket.connect();
```

---

### 5.2 Join Game Room

**Event:** `game:join`

**Emit:**
```dart
socket.emit('game:join', {
  'gameId': '507f1f77bcf86cd799439011'
});
```

**Notes:**
- Join game room to receive real-time updates
- Call this after booking ticket

---

### 5.3 Leave Game Room

**Event:** `game:leave`

**Emit:**
```dart
socket.emit('game:leave', {
  'gameId': '507f1f77bcf86cd799439011'
});
```

---

### 5.4 Listen to Number Announcements

**Event:** `number:announced`

**Listen:**
```dart
socket.on('number:announced', (data) {
  print('New number: ${data['number']}');
  print('All numbers: ${data['announcedNumbers']}');
  print('Timestamp: ${data['timestamp']}');
});
```

**Data Structure:**
```json
{
  "number": 42,
  "timestamp": "2024-01-20T14:35:00.000Z",
  "announcedNumbers": [15, 23, 8, 42, 67, 31]
}
```

**Notes:**
- Numbers are announced every 4 seconds
- Update UI with new number
- Check if user has won after each number

---

### 5.5 Listen to Game Started

**Event:** `game:started`

**Listen:**
```dart
socket.on('game:started', (data) {
  print('Game started: ${data['gameId']}');
  print('Start time: ${data['startTime']}');
});
```

---

### 5.6 Listen to Game Ended

**Event:** `game:ended`

**Listen:**
```dart
socket.on('game:ended', (data) {
  print('Game ended: ${data['gameId']}');
  print('Winners: ${data['winners']}');
});
```

**Data Structure:**
```json
{
  "gameId": "507f1f77bcf86cd799439011",
  "winners": {
    "oneLine": {
      "userId": "507f1f77bcf86cd799439011",
      "cardNumber": "12345",
      "wonAt": "2024-01-20T14:35:00.000Z",
      "couponCode": "ABC12345"
    },
    "jaldi": null
  }
}
```

---

## ⚠️ Error Handling

### Common HTTP Status Codes

| Code | Meaning | Action |
|------|---------|--------|
| 200 | Success | Process response data |
| 400 | Bad Request | Show error message to user |
| 401 | Unauthorized | Redirect to login |
| 404 | Not Found | Show "not found" message |
| 500 | Server Error | Show "try again" message |

### Error Response Format

```json
{
  "message": "Error description here"
}
```

### Handling Errors in Flutter

```dart
try {
  final response = await http.post(
    Uri.parse('$baseUrl/game/book'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    },
    body: jsonEncode({'gameId': gameId}),
  );
  
  if (response.statusCode == 200) {
    // Success
    final data = jsonDecode(response.body);
  } else {
    // Error
    final error = jsonDecode(response.body);
    throw Exception(error['message']);
  }
} catch (e) {
  // Show error to user
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e.toString())),
  );
}
```

---

## 📊 Data Models

### User Model
```json
{
  "_id": "507f1f77bcf86cd799439011",
  "username": "john_doe",
  "phone": "9876543210",
  "role": "user",
  "isVerified": true,
  "createdAt": "2024-01-20T10:00:00.000Z",
  "lastLogin": "2024-01-20T14:00:00.000Z"
}
```

### Game Model
```json
{
  "_id": "507f1f77bcf86cd799439011",
  "gameCode": "GAME001",
  "status": "LIVE",
  "scheduledTime": "2024-01-20T14:30:00.000Z",
  "startTime": "2024-01-20T14:30:00.000Z",
  "endTime": null,
  "announcedNumbers": [15, 23, 8, 42],
  "currentNumber": 42,
  "totalSlots": 100,
  "bookedSlots": 45,
  "oneLineWinner": null,
  "jaldiWinner": null,
  "createdAt": "2024-01-20T10:00:00.000Z"
}
```

### Booking Model
```json
{
  "_id": "507f1f77bcf86cd799439012",
  "userId": "507f1f77bcf86cd799439011",
  "gameId": "507f1f77bcf86cd799439011",
  "cardNumber": "12345",
  "ticketNumber": "67890",
  "status": "DELIVERED",
  "bookedAt": "2024-01-20T14:00:00.000Z",
  "deliveredAt": "2024-01-20T14:00:02.000Z"
}
```

### Coupon Model
```json
{
  "_id": "507f1f77bcf86cd799439013",
  "code": "ABC12345",
  "userId": "507f1f77bcf86cd799439011",
  "gameId": "507f1f77bcf86cd799439011",
  "winType": "ONE_LINE",
  "rewardDetails": {
    "brand": "BigBasket",
    "description": "Gift Card",
    "amount": 500
  },
  "isUsed": false,
  "createdAt": "2024-01-20T14:35:00.000Z",
  "expiresAt": "2024-02-20T14:35:00.000Z"
}
```

---

## 🚀 Integration Flow

### Complete User Journey

```
1. User Registration
   ↓
   POST /auth/register
   ↓
   Receive OTP via SMS
   ↓
   POST /auth/verify-otp
   ↓
   Store JWT token

2. Get Live Game
   ↓
   GET /game/live
   ↓
   Display game info

3. Book Ticket
   ↓
   POST /game/book
   ↓
   Store cardNumber & ticketNumber
   ↓
   Show ticket to user

4. Game Countdown
   ↓
   GET /game/:gameId/countdown
   ↓
   Show countdown timer
   ↓
   User enters cardNumber
   ↓
   POST /game/:gameId/verify-card
   ↓
   If valid, proceed to game

5. Connect to Socket.IO
   ↓
   socket.connect()
   ↓
   socket.emit('game:join', {gameId})
   ↓
   socket.on('number:announced')
   ↓
   Update UI with new numbers

6. Claim Win
   ↓
   User clicks win button
   ↓
   POST /game/:gameId/claim-win
   ↓
   Show coupon if won

7. Game End
   ↓
   socket.on('game:ended')
   ↓
   Show winners
   ↓
   socket.emit('game:leave', {gameId})
```

---

## 📝 Important Notes

1. **Authentication:**
   - Always include JWT token in Authorization header for protected routes
   - Token format: `Bearer <token>`
   - Store token securely in SharedPreferences

2. **Card Numbers:**
   - All card/ticket numbers are 5 digits
   - Format: "12345" (string, not number)
   - Validate format before sending to backend

3. **Real-time Updates:**
   - Use Socket.IO for real-time number announcements
   - Don't poll the API repeatedly
   - Join game room after booking ticket

4. **Error Handling:**
   - Always handle errors gracefully
   - Show user-friendly error messages
   - Log errors for debugging

5. **Testing:**
   - Test with local backend first (http://localhost:5000)
   - Then test with production URL
   - Test all error scenarios

---

## 🔗 Production URLs

**Backend API:** `https://your-app.onrender.com/api`  
**Socket.IO:** `wss://your-app.onrender.com`  
**Admin Panel:** `https://your-admin.onrender.com`

---

## 📞 Support

For any issues or questions, contact the backend team.

**Backend Developer:** [Your Name]  
**Email:** [Your Email]  
**Last Updated:** January 2024

---

**End of Documentation** 🎉
