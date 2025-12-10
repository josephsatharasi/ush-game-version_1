# Coupon System API Documentation

## Overview
The coupon system allows winners to receive coupon codes manually assigned by admins. Winners claim their wins during the game, and admins later assign coupon codes through the admin panel.

---

## Backend Endpoints (Ready for Flutter Integration)

### 1. Get User's Coupons
**Endpoint:** `GET /api/game/my-coupons`  
**Auth Required:** Yes (Bearer Token)  
**Description:** Fetch all coupons for the authenticated user

**Request Headers:**
```json
{
  "Authorization": "Bearer <token>",
  "Content-Type": "application/json"
}
```

**Response (200 OK):**
```json
{
  "coupons": [
    {
      "gameCode": "GAME001",
      "gameId": "507f1f77bcf86cd799439011",
      "winType": "FIRST_LINE",
      "cardNumber": "CARD-1234",
      "wonAt": "2024-01-15T10:30:00.000Z",
      "couponCode": "BURGER50",
      "status": "ASSIGNED"
    },
    {
      "gameCode": "GAME002",
      "gameId": "507f1f77bcf86cd799439012",
      "winType": "HOUSIE",
      "cardNumber": "CARD-5678",
      "wonAt": "2024-01-16T14:20:00.000Z",
      "couponCode": null,
      "status": "PENDING"
    }
  ]
}
```

**Win Types:**
- `FIRST_LINE` - First Line Winner
- `SECOND_LINE` - Second Line Winner
- `THIRD_LINE` - Third Line Winner
- `JALDI` - Jaldi (Quick Five) Winner
- `HOUSIE` - Housie (Full House) Winner

**Status Values:**
- `PENDING` - Coupon not yet assigned by admin
- `ASSIGNED` - Coupon code has been assigned

---

### 2. Claim Win (During Game)
**Endpoint:** `POST /api/game/:gameId/claim-win`  
**Auth Required:** Yes (Bearer Token)  
**Description:** User claims a win during the game

**Request Headers:**
```json
{
  "Authorization": "Bearer <token>",
  "Content-Type": "application/json"
}
```

**Request Body:**
```json
{
  "winType": "FIRST_LINE",
  "cardNumber": "CARD-1234"
}
```

**Response (200 OK):**
```json
{
  "valid": true,
  "message": "Congratulations! You won! Admin will assign your coupon code soon."
}
```

**Response (400 Bad Request):**
```json
{
  "valid": false,
  "message": "This win type has already been claimed"
}
```

---

### 3. Get Winners List (Admin Only)
**Endpoint:** `GET /api/game/:gameId/winners`  
**Auth Required:** Yes (Bearer Token)  
**Description:** Get all winners for a specific game (used by admin)

**Request Headers:**
```json
{
  "Authorization": "Bearer <token>",
  "Content-Type": "application/json"
}
```

**Response (200 OK):**
```json
{
  "gameCode": "GAME001",
  "gameStatus": "COMPLETED",
  "winners": [
    {
      "winType": "FIRST_LINE",
      "userId": "507f1f77bcf86cd799439011",
      "username": "john_doe",
      "email": "john@example.com",
      "phone": "+1234567890",
      "cardNumber": "CARD-1234",
      "wonAt": "2024-01-15T10:30:00.000Z",
      "couponCode": "BURGER50",
      "hasCoupon": true
    },
    {
      "winType": "HOUSIE",
      "userId": "507f1f77bcf86cd799439012",
      "username": "jane_smith",
      "email": "jane@example.com",
      "phone": "+1234567891",
      "cardNumber": "CARD-5678",
      "wonAt": "2024-01-15T11:45:00.000Z",
      "couponCode": null,
      "hasCoupon": false
    }
  ]
}
```

---

### 4. Assign Coupon (Admin Only)
**Endpoint:** `POST /api/game/:gameId/assign-coupon`  
**Auth Required:** Yes (Bearer Token)  
**Description:** Admin assigns a coupon code to a winner

**Request Headers:**
```json
{
  "Authorization": "Bearer <token>",
  "Content-Type": "application/json"
}
```

**Request Body:**
```json
{
  "winType": "FIRST_LINE",
  "couponCode": "BURGER50"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Coupon code assigned successfully",
  "winner": {
    "userId": "507f1f77bcf86cd799439011",
    "cardNumber": "CARD-1234",
    "wonAt": "2024-01-15T10:30:00.000Z",
    "couponCode": "BURGER50"
  }
}
```

**Response (404 Not Found):**
```json
{
  "message": "Winner not found for this win type"
}
```

---

## Flutter Integration Guide

### Step 1: Create Coupon Model
```dart
class Coupon {
  final String gameCode;
  final String gameId;
  final String winType;
  final String cardNumber;
  final DateTime wonAt;
  final String? couponCode;
  final String status;

  Coupon({
    required this.gameCode,
    required this.gameId,
    required this.winType,
    required this.cardNumber,
    required this.wonAt,
    this.couponCode,
    required this.status,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      gameCode: json['gameCode'],
      gameId: json['gameId'],
      winType: json['winType'],
      cardNumber: json['cardNumber'],
      wonAt: DateTime.parse(json['wonAt']),
      couponCode: json['couponCode'],
      status: json['status'],
    );
  }
}
```

### Step 2: Add API Method to BackendApiConfig
```dart
static Future<Map<String, dynamic>> getMyCoupons({
  required String token,
}) async {
  final response = await http.get(
    Uri.parse('$baseUrl/game/my-coupons'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to get coupons');
  }
}
```

### Step 3: Create Coupon Service
```dart
class CouponService {
  Future<List<Coupon>> getMyCoupons() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    final response = await BackendApiConfig.getMyCoupons(token: token!);
    final List<dynamic> couponsJson = response['coupons'] ?? [];
    
    return couponsJson.map((json) => Coupon.fromJson(json)).toList();
  }
}
```

### Step 4: Create Coupons Screen
Display the list of coupons with:
- Game Code
- Win Type (formatted label)
- Card Number
- Won Date
- Coupon Code (if assigned) or "Pending" status
- Visual indicator for assigned vs pending

---

## Admin Panel (Already Implemented)

### Winners Management Page
**Location:** `/admin/src/pages/Winners.js`

**Features:**
✅ Select game from dropdown  
✅ View all winners for selected game  
✅ See winner details (username, email, phone, card number)  
✅ Input field to enter coupon code  
✅ Assign button to send coupon to winner  
✅ Visual indicator showing if coupon is assigned  

**How to Use:**
1. Login to admin panel
2. Navigate to "Winners" page
3. Select a game from dropdown
4. View list of winners
5. For each winner without a coupon:
   - Enter coupon code in the input field
   - Click "Assign" button
6. Coupon is immediately assigned and user can see it in their app

---

## Database Schema

### LiveGame Model (Winner Fields)
```javascript
{
  firstLineWinner: {
    userId: ObjectId,
    cardNumber: String,
    wonAt: Date,
    couponCode: String  // Assigned by admin
  },
  secondLineWinner: { /* same structure */ },
  thirdLineWinner: { /* same structure */ },
  jaldiWinner: { /* same structure */ },
  housieWinner: { /* same structure */ }
}
```

---

## Testing the API

### Test Get My Coupons
```bash
curl -X GET http://localhost:5000/api/game/my-coupons \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json"
```

### Test Assign Coupon (Admin)
```bash
curl -X POST http://localhost:5000/api/game/GAME_ID/assign-coupon \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "winType": "FIRST_LINE",
    "couponCode": "BURGER50"
  }'
```

---

## Notes for Flutter Team

1. **Authentication:** All endpoints require Bearer token in Authorization header
2. **Error Handling:** Handle 401 (Unauthorized), 404 (Not Found), 400 (Bad Request)
3. **Polling:** Consider polling `/api/game/my-coupons` periodically to check for new assigned coupons
4. **Notifications:** When a coupon status changes from PENDING to ASSIGNED, show a notification
5. **UI States:** 
   - Show "Pending" badge for coupons without codes
   - Show coupon code prominently when assigned
   - Allow users to copy coupon code to clipboard
6. **Win Type Labels:** Use friendly labels (First Line, Second Line, etc.) instead of raw values

---

## Status: ✅ READY FOR INTEGRATION

Both backend and admin panel are fully functional and ready for Flutter integration.
