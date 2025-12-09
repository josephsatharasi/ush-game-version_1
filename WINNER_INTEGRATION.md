# Winner Integration Documentation

## Overview
Complete integration of winner functionality between Flutter app and backend API.

## Backend Endpoints Used

### 1. Claim Win
- **Endpoint**: `POST /api/game/:gameId/claim-win`
- **Purpose**: User claims a win for HOUSIE
- **Payload**: `{ winType: "HOUSIE", cardNumber: "CARD123" }`
- **Response**: `{ valid: true, message: "Congratulations! You won!" }`

### 2. Get Winners
- **Endpoint**: `GET /api/game/:gameId/winners`
- **Purpose**: Fetch all winners for a game
- **Response**: 
```json
{
  "winners": [
    {
      "winType": "HOUSIE",
      "userId": "user123",
      "username": "John Doe",
      "cardNumber": "CARD123",
      "wonAt": "2024-01-01T00:00:00Z",
      "couponCode": null
    }
  ]
}
```

## Flutter Implementation

### Models Created

#### 1. WinType Enum (`lib/models/win_type.dart`)
```dart
enum WinType {
  FIRST_LINE,
  SECOND_LINE,
  THIRD_LINE,
  JALDI,
  HOUSIE
}
```
- Matches backend win type enums exactly
- Provides `apiValue` for API calls
- Provides `displayName` for UI

#### 2. Winner Model (`lib/models/winner.dart`)
- Represents winner data from backend
- Includes: userId, username, cardNumber, wonAt, couponCode, winType

### Services Created

#### WinnerService (`lib/services/winner_service.dart`)
- `claimWin()`: Claims a win for the user
- `getWinners()`: Fetches all winners for a game
- `getHousieWinner()`: Gets specifically the HOUSIE winner

### Updated Files

#### 1. `backend_api_config.dart`
- Added `cardNumber` parameter to `claimWin()`
- Added `getWinners()` endpoint
- Added `getMyCoupons()` endpoint

#### 2. `housi_widget.dart`
- Stops number announcements when HOUSI clicked
- Claims win via API when user clicks HOUSI
- Fetches winner data from backend
- Passes winner data to NextGameScreeniWidget
- Shows real winner username in winner screen

#### 3. `next_winner.dart`
- Accepts `winnerUsername` and `winnerUserId` parameters
- Checks if current user is the winner
- Shows "You Won" screen if user won
- Shows "Winner: [username]" screen if someone else won
- Navigates to scratch reward screen if user won

## Flow

### When User Clicks HOUSI:

1. **Stop Announcements**
   - `GameNumberService().stopGame()` stops number announcements

2. **Claim Win**
   - Calls `WinnerService().claimWin()` with:
     - gameId (from SharedPreferences)
     - winType: HOUSIE
     - cardNumber (from SharedPreferences)

3. **Fetch Winner**
   - Calls `WinnerService().getHousieWinner()` to get winner details

4. **Navigate**
   - Navigates to `NextGameScreeniWidget` with winner data

5. **Display Result**
   - If current user won: Shows "Game Over" → "You Won" → Scratch Reward
   - If someone else won: Shows "Game Over" → "Winner: [username]"

## Win Validation (Backend)

The backend validates wins by checking:
- **FIRST_LINE**: All numbers in first line announced
- **SECOND_LINE**: All numbers in second line announced
- **THIRD_LINE**: All numbers in third line announced
- **JALDI**: Any ONE complete line
- **HOUSIE**: All THREE lines complete

## Data Storage

### SharedPreferences Keys Used:
- `token`: Authentication token
- `userId`: Current user ID
- `gameId`: Current game ID
- `cardNumber`: User's card number for the game

## Error Handling

- Network errors are caught and logged
- Invalid card numbers are rejected by backend
- Already claimed wins are rejected by backend
- Missing authentication shows error

## Future Enhancements

1. Support for other win types (FIRST_LINE, SECOND_LINE, etc.)
2. Real-time winner notifications via WebSocket
3. Coupon code display after win
4. Win history for user
5. Leaderboard integration
