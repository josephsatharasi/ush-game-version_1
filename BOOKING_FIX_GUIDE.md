# Booking System Fix - Multiple Bookings Per User

## Changes Made

### 1. Backend Model (`backend/models/Booking.js`)
**Changed Index:**
- **Old:** `{ gameId: 1, cardNumber: 1 }` - Prevented same card number per game
- **New:** `{ userId: 1, gameId: 1, weekDay: 1, timeSlot: 1 }` - Prevents duplicate bookings for same user, game, day, and time slot

### 2. Backend Route (`backend/routes/game.js`)
**Updated Validation:**
```javascript
// Old check - blocked all bookings for same user and game
const existingBooking = await Booking.findOne({ userId, gameId: game._id });

// New check - only blocks same day and time slot
const existingBooking = await Booking.findOne({ 
  userId, 
  gameId: game._id, 
  weekDay, 
  timeSlot 
});
```

**New Error Message:**
- Changed from: "Already booked"
- Changed to: "You have already booked this time slot for this day"

## What Users Can Now Do

✅ **Allowed:**
- Book multiple tickets for different time slots on the same day
- Book multiple tickets for the same time slot on different days
- Book multiple tickets for different days and different time slots
- Book as many different combinations as they want

❌ **Not Allowed:**
- Book the same time slot on the same day twice
- Example: Cannot book "Tue 10:00 AM" twice

## Examples

### ✅ Valid Multiple Bookings:
```json
// Booking 1
{
  "weekDay": "Mon",
  "timeSlot": "10:00 AM",
  "ticketCount": 3
}

// Booking 2 - Different time, same day
{
  "weekDay": "Mon",
  "timeSlot": "2:00 PM",
  "ticketCount": 2
}

// Booking 3 - Same time, different day
{
  "weekDay": "Tue",
  "timeSlot": "10:00 AM",
  "ticketCount": 1
}
```

### ❌ Invalid Duplicate Booking:
```json
// Booking 1
{
  "weekDay": "Mon",
  "timeSlot": "10:00 AM",
  "ticketCount": 3
}

// Booking 2 - DUPLICATE (same day + same time)
{
  "weekDay": "Mon",
  "timeSlot": "10:00 AM",
  "ticketCount": 2
}
// Error: "You have already booked this time slot for this day"
```

## Database Migration

Run this command to update the database index:
```bash
cd backend
node scripts/update-booking-index.js
```

This will:
1. Drop the old index `gameId_1_cardNumber_1`
2. Create new index `userId_1_gameId_1_weekDay_1_timeSlot_1`

## Testing

### Test Case 1: Book Different Time Slots
```bash
# First booking
curl -X POST https://ush-game-version-1.onrender.com/api/game/book \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "gameId": "GAME_ID",
    "ticketCount": 3,
    "scheduledDate": "2024-12-02T00:00:00.000Z",
    "weekDay": "Mon",
    "timeSlot": "10:00 AM"
  }'

# Second booking - Should succeed
curl -X POST https://ush-game-version-1.onrender.com/api/game/book \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "gameId": "GAME_ID",
    "ticketCount": 2,
    "scheduledDate": "2024-12-02T00:00:00.000Z",
    "weekDay": "Mon",
    "timeSlot": "2:00 PM"
  }'
```

### Test Case 2: Book Same Slot (Should Fail)
```bash
# First booking
curl -X POST https://ush-game-version-1.onrender.com/api/game/book \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "gameId": "GAME_ID",
    "ticketCount": 3,
    "scheduledDate": "2024-12-02T00:00:00.000Z",
    "weekDay": "Mon",
    "timeSlot": "10:00 AM"
  }'

# Second booking - Should fail with error
curl -X POST https://ush-game-version-1.onrender.com/api/game/book \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "gameId": "GAME_ID",
    "ticketCount": 2,
    "scheduledDate": "2024-12-02T00:00:00.000Z",
    "weekDay": "Mon",
    "timeSlot": "10:00 AM"
  }'
# Expected: "You have already booked this time slot for this day"
```

## Deployment Steps

1. **Update code on server:**
   ```bash
   git add .
   git commit -m "Fix: Allow multiple bookings per user for different slots"
   git push
   ```

2. **Run migration:**
   ```bash
   node backend/scripts/update-booking-index.js
   ```

3. **Restart backend server**

4. **Test the changes**

## No Flutter Changes Required

The Flutter app already sends `weekDay` and `timeSlot` in the booking request, so no changes are needed on the frontend.
