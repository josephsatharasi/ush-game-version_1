# 📮 Postman Testing Guide - Ticket Booking Flow

## 🔧 Setup

### Base URL
```
http://localhost:5000/api
```

### Environment Variables (Optional)
Create these in Postman:
- `baseUrl`: `http://localhost:5000/api`
- `token`: (will be set after login)
- `userId`: (will be set after registration)
- `gameId`: (will be set after creating game)

---

## 📝 Complete Testing Flow

### **Step 1: Register User**

**Endpoint:** `POST {{baseUrl}}/auth/register`

**Headers:**
```json
Content-Type: application/json
```

**Body (raw JSON):**
```json
{
  "username": "testuser123",
  "phone": "+919876543210",
  "password": "Test@1234"
}
```

**Expected Response (200):**
```json
{
  "message": "Registration successful. OTP sent.",
  "userId": "65abc123def456789012345"
}
```

**Save userId for next step!**

---

### **Step 2: Verify OTP**

**Endpoint:** `POST {{baseUrl}}/auth/verify-otp`

**Headers:**
```json
Content-Type: application/json
```

**Body (raw JSON):**
```json
{
  "userId": "65abc123def456789012345",
  "otp": "1234"
}
```

**Note:** Check your backend console for the OTP (it's printed there)

**Expected Response (200):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "65abc123def456789012345",
    "username": "testuser123",
    "phone": "+919876543210"
  }
}
```

**Save the token! You'll need it for all subsequent requests.**

---

### **Step 3: Create a Game (Admin Only)**

First, you need to create an admin account or use existing one.

**Endpoint:** `POST {{baseUrl}}/admin/games/create`

**Headers:**
```json
Content-Type: application/json
Authorization: Bearer YOUR_ADMIN_TOKEN_HERE
```

**Body (raw JSON):**
```json
{
  "gameCode": "GAME001",
  "scheduledTime": "2024-12-31T18:00:00.000Z",
  "totalSlots": 100
}
```

**Expected Response (200):**
```json
{
  "message": "Game created successfully",
  "game": {
    "_id": "65xyz789abc123456789012",
    "gameCode": "GAME001",
    "status": "SCHEDULED",
    "scheduledTime": "2024-12-31T18:00:00.000Z",
    "totalSlots": 100,
    "bookedSlots": 0,
    "announcedNumbers": []
  }
}
```

**Save the game._id for booking!**

---

### **Step 4: Get Live Game**

**Endpoint:** `GET {{baseUrl}}/game/live`

**Headers:**
```json
Content-Type: application/json
```

**No Body Required**

**Expected Response (200):**
```json
{
  "game": {
    "_id": "65xyz789abc123456789012",
    "gameCode": "GAME001",
    "status": "SCHEDULED",
    "scheduledTime": "2024-12-31T18:00:00.000Z",
    "totalSlots": 100,
    "bookedSlots": 0,
    "announcedNumbers": [],
    "currentNumber": null
  }
}
```

---

### **Step 5: Book Ticket** ⭐

**Endpoint:** `POST {{baseUrl}}/game/book`

**Headers:**
```json
Content-Type: application/json
Authorization: Bearer YOUR_USER_TOKEN_HERE
```

**Body (raw JSON):**
```json
{
  "gameId": "65xyz789abc123456789012"
}
```

**Expected Response (200):**
```json
{
  "booking": {
    "_id": "65booking123456789012345",
    "cardNumber": "12345",
    "ticketNumber": "67890",
    "status": "PENDING"
  }
}
```

**Note:** 
- Status will auto-change to "DELIVERED" after 2 seconds
- Save the cardNumber for verification later!

---

### **Step 6: Get Countdown**

**Endpoint:** `GET {{baseUrl}}/game/:gameId/countdown`

Replace `:gameId` with actual game ID

**Headers:**
```json
Content-Type: application/json
Authorization: Bearer YOUR_USER_TOKEN_HERE
```

**Example URL:**
```
GET http://localhost:5000/api/game/65xyz789abc123456789012/countdown
```

**Expected Response (200):**
```json
{
  "timeRemaining": 3600,
  "status": "SCHEDULED",
  "booking": {
    "cardNumber": "12345",
    "status": "DELIVERED"
  }
}
```

---

### **Step 7: Verify Card Number**

**Endpoint:** `POST {{baseUrl}}/game/:gameId/verify-card`

**Headers:**
```json
Content-Type: application/json
Authorization: Bearer YOUR_USER_TOKEN_HERE
```

**Body (raw JSON):**
```json
{
  "cardNumber": "12345"
}
```

**Expected Response (200):**
```json
{
  "valid": true,
  "message": "Card verified"
}
```

**Invalid Card Response (400):**
```json
{
  "valid": false,
  "message": "Invalid card number"
}
```

---

### **Step 8: Start Game (Admin)**

**Endpoint:** `POST {{baseUrl}}/admin/games/:gameId/start`

**Headers:**
```json
Content-Type: application/json
Authorization: Bearer YOUR_ADMIN_TOKEN_HERE
```

**No Body Required**

**Expected Response (200):**
```json
{
  "message": "Game started"
}
```

---

### **Step 9: Get Game Status**

**Endpoint:** `GET {{baseUrl}}/game/:gameId/status`

**Headers:**
```json
Content-Type: application/json
Authorization: Bearer YOUR_USER_TOKEN_HERE
```

**Expected Response (200):**
```json
{
  "status": "LIVE",
  "currentNumber": 42,
  "announcedNumbers": [15, 23, 42],
  "firstLineWinner": null,
  "secondLineWinner": null,
  "thirdLineWinner": null,
  "jaldiWinner": null,
  "housieWinner": null
}
```

---

### **Step 10: Announce Number (Admin)**

**Endpoint:** `POST {{baseUrl}}/admin/games/:gameId/announce`

**Headers:**
```json
Content-Type: application/json
Authorization: Bearer YOUR_ADMIN_TOKEN_HERE
```

**Body (raw JSON):**
```json
{
  "number": 42
}
```

**Expected Response (200):**
```json
{
  "message": "Number announced",
  "game": {
    "_id": "65xyz789abc123456789012",
    "currentNumber": 42,
    "announcedNumbers": [15, 23, 42],
    "status": "LIVE"
  }
}
```

---

### **Step 11: Claim Win**

**Endpoint:** `POST {{baseUrl}}/game/:gameId/claim-win`

**Headers:**
```json
Content-Type: application/json
Authorization: Bearer YOUR_USER_TOKEN_HERE
```

**Body (raw JSON):**
```json
{
  "winType": "FIRST_LINE"
}
```

**Win Types:**
- `FIRST_LINE`
- `SECOND_LINE`
- `THIRD_LINE`
- `JALDI`
- `HOUSIE`

**Expected Response (200):**
```json
{
  "valid": true,
  "couponId": "65coupon123456789012345",
  "message": "Congratulations! You won!"
}
```

**Already Claimed Response (400):**
```json
{
  "valid": false,
  "message": "FIRST_LINE already claimed"
}
```

---

## 🎯 Quick Test Collection

### Test Data Set 1
```json
{
  "user": {
    "username": "player1",
    "phone": "+919876543210",
    "password": "Pass@123"
  },
  "game": {
    "gameCode": "GAME001",
    "scheduledTime": "2024-12-31T18:00:00.000Z",
    "totalSlots": 100
  }
}
```

### Test Data Set 2
```json
{
  "user": {
    "username": "player2",
    "phone": "+919876543211",
    "password": "Pass@456"
  },
  "game": {
    "gameCode": "GAME002",
    "scheduledTime": "2024-12-31T20:00:00.000Z",
    "totalSlots": 50
  }
}
```

---

## 🔍 Common Error Responses

### 401 Unauthorized
```json
{
  "message": "No token provided"
}
```
**Fix:** Add Authorization header with Bearer token

### 404 Not Found
```json
{
  "message": "Game not found"
}
```
**Fix:** Check gameId is correct

### 400 Bad Request
```json
{
  "message": "Already booked"
}
```
**Fix:** User already has a booking for this game

### 400 Game Full
```json
{
  "message": "Game is full"
}
```
**Fix:** All slots are booked

---

## 📊 Postman Collection JSON

Save this as a `.json` file and import into Postman:

```json
{
  "info": {
    "name": "Ush Game API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Auth",
      "item": [
        {
          "name": "Register",
          "request": {
            "method": "POST",
            "header": [{"key": "Content-Type", "value": "application/json"}],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"username\": \"testuser\",\n  \"phone\": \"+919876543210\",\n  \"password\": \"Test@123\"\n}"
            },
            "url": "{{baseUrl}}/auth/register"
          }
        },
        {
          "name": "Verify OTP",
          "request": {
            "method": "POST",
            "header": [{"key": "Content-Type", "value": "application/json"}],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"userId\": \"{{userId}}\",\n  \"otp\": \"1234\"\n}"
            },
            "url": "{{baseUrl}}/auth/verify-otp"
          }
        },
        {
          "name": "Login",
          "request": {
            "method": "POST",
            "header": [{"key": "Content-Type", "value": "application/json"}],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"username\": \"testuser\",\n  \"password\": \"Test@123\"\n}"
            },
            "url": "{{baseUrl}}/auth/login"
          }
        }
      ]
    },
    {
      "name": "Game",
      "item": [
        {
          "name": "Get Live Game",
          "request": {
            "method": "GET",
            "header": [{"key": "Content-Type", "value": "application/json"}],
            "url": "{{baseUrl}}/game/live"
          }
        },
        {
          "name": "Book Ticket",
          "request": {
            "method": "POST",
            "header": [
              {"key": "Content-Type", "value": "application/json"},
              {"key": "Authorization", "value": "Bearer {{token}}"}
            ],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"gameId\": \"{{gameId}}\"\n}"
            },
            "url": "{{baseUrl}}/game/book"
          }
        },
        {
          "name": "Get Countdown",
          "request": {
            "method": "GET",
            "header": [
              {"key": "Content-Type", "value": "application/json"},
              {"key": "Authorization", "value": "Bearer {{token}}"}
            ],
            "url": "{{baseUrl}}/game/{{gameId}}/countdown"
          }
        },
        {
          "name": "Verify Card",
          "request": {
            "method": "POST",
            "header": [
              {"key": "Content-Type", "value": "application/json"},
              {"key": "Authorization", "value": "Bearer {{token}}"}
            ],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"cardNumber\": \"12345\"\n}"
            },
            "url": "{{baseUrl}}/game/{{gameId}}/verify-card"
          }
        },
        {
          "name": "Get Game Status",
          "request": {
            "method": "GET",
            "header": [
              {"key": "Content-Type", "value": "application/json"},
              {"key": "Authorization", "value": "Bearer {{token}}"}
            ],
            "url": "{{baseUrl}}/game/{{gameId}}/status"
          }
        },
        {
          "name": "Claim Win",
          "request": {
            "method": "POST",
            "header": [
              {"key": "Content-Type", "value": "application/json"},
              {"key": "Authorization", "value": "Bearer {{token}}"}
            ],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"winType\": \"FIRST_LINE\"\n}"
            },
            "url": "{{baseUrl}}/game/{{gameId}}/claim-win"
          }
        }
      ]
    }
  ]
}
```

---

## 🚀 Quick Start Commands

### 1. Start Backend
```bash
cd backend
npm install
npm start
```

### 2. Test Connection
```bash
curl http://localhost:5000/api/game/live
```

### 3. Create Admin (if needed)
Check backend documentation for admin creation script.

---

## ✅ Testing Checklist

- [ ] Register user successfully
- [ ] Verify OTP and get token
- [ ] Create game (admin)
- [ ] Get live game
- [ ] Book ticket with valid token
- [ ] Verify card number
- [ ] Get countdown
- [ ] Start game (admin)
- [ ] Get game status
- [ ] Announce numbers (admin)
- [ ] Claim win
- [ ] Test error cases (invalid token, wrong card, etc.)

---

## 💡 Pro Tips

1. **Save Tokens:** Use Postman environment variables to store tokens
2. **Test Scripts:** Add test scripts to auto-save responses
3. **Collections:** Organize requests by feature
4. **Pre-request Scripts:** Auto-generate test data
5. **Monitor:** Use Postman Monitor for continuous testing

---

## 🐛 Troubleshooting

### "No token provided"
- Add `Authorization: Bearer YOUR_TOKEN` header

### "Game not found"
- Create a game first using admin endpoint
- Check gameId is correct MongoDB ObjectId

### "Already booked"
- User can only book once per game
- Use different user or different game

### "Invalid card number"
- Use the cardNumber from booking response
- Card must match the booking

---

**Happy Testing! 🎉**
