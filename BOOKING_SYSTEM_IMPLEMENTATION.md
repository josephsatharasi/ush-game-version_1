# Booking System Implementation

## Overview
Complete ticket booking system with date/time slot selection, integrated with admin panel.

## Backend Changes

### 1. Updated Booking Model (`backend/models/Booking.js`)
Added new fields:
- `gameCode`: Game identifier (e.g., "LIVE GAME")
- `gameType`: Type of game ("LIVE" or "FAM-JAM")
- `ticketCount`: Number of tickets (1-6)
- `scheduledDate`: Selected date
- `weekDay`: Selected day of week (Mon, Tue, etc.)
- `timeSlot`: Selected time slot (e.g., "10:00 AM")

### 2. Updated Game Routes (`backend/routes/game.js`)
**Modified `/book` endpoint:**
- Now accepts: `ticketCount`, `scheduledDate`, `weekDay`, `timeSlot`
- Validates ticket count (1-6)
- Checks slot availability
- Reduces available slots by ticket count
- Returns complete booking info

**New endpoints:**
- `GET /api/game/bookings` - Get all bookings (Admin)
- `GET /api/game/my-bookings` - Get user's bookings

## Flutter App Changes

### 1. Updated Backend API Config (`flutter-app/lib/config/backend_api_config.dart`)
**Modified `bookTicket()` method:**
- Added parameters: `ticketCount`, `scheduledDate`, `weekDay`, `timeSlot`
- Sends complete booking data to backend

**New methods:**
- `getAllBookings()` - Fetch all bookings for admin
- `getMyBookings()` - Fetch user's bookings

### 2. Updated Live Game Widget (`flutter-app/lib/app_state/live_gametype1/live_gametype1_widget.dart`)
**Enhanced `_bookTicket()` method:**
- Collects ticket count from model
- Collects selected week day and time slot
- Constructs scheduled date
- Sends all data to backend
- Stores booking details in SharedPreferences

## Admin Panel Changes

### 1. New Bookings Page (`admin/src/pages/Bookings.js`)
Features:
- Displays all bookings in a table
- Shows: Username, Email, Game Code, Game Type, Ticket Count, Schedule (Week Day + Time Slot), Card Number, Status, Booked At
- Real-time data from backend
- Responsive design

### 2. Updated App Routes (`admin/src/App.js`)
- Added `/bookings` route
- Imported Bookings component

### 3. Updated Sidebar (`admin/src/components/Sidebar.js`)
- Added "Bookings" menu item with Calendar icon
- Links to `/bookings` page

## User Flow

1. **User selects game** on Game Selection Screen
2. **Navigates to Live Game Type 1** screen
3. **Selects ticket count** (1, 3, 6, or custom 2-5)
4. **Selects week day** from horizontal selector
5. **Selects time slot** from grid (shows available slots)
6. **Clicks "Order ticket"** button
7. **Backend processes booking:**
   - Validates data
   - Checks slot availability
   - Creates booking record
   - Reduces available slots
   - Returns booking confirmation
8. **User sees success screen**

## Admin Flow

1. **Admin logs into admin panel**
2. **Navigates to "Bookings"** from sidebar
3. **Views all bookings** in table format:
   - User details (username, email)
   - Game information (code, type)
   - Booking details (tickets, schedule, time slot)
   - Card number
   - Status (PENDING/DELIVERED)
   - Booking timestamp
4. **Monitors slot availability** across different time slots

## Data Flow

```
Flutter App → Backend API → MongoDB
     ↓
Admin Panel ← Backend API ← MongoDB
```

## Key Features

✅ Ticket count selection (1-6)
✅ Week day selection with visual feedback
✅ Time slot selection with availability display
✅ Real-time slot reduction
✅ Admin panel integration
✅ Complete booking history
✅ User and admin views
✅ Status tracking (PENDING/DELIVERED)

## API Endpoints

### User Endpoints
- `POST /api/game/book` - Book tickets
- `GET /api/game/my-bookings` - Get user's bookings

### Admin Endpoints
- `GET /api/game/bookings` - Get all bookings

## Database Schema

```javascript
{
  userId: ObjectId,
  gameId: ObjectId,
  gameCode: String,        // "LIVE GAME"
  gameType: String,        // "LIVE" or "FAM-JAM"
  ticketCount: Number,     // 1-6
  scheduledDate: Date,     // Selected date
  weekDay: String,         // "Mon", "Tue", etc.
  timeSlot: String,        // "10:00 AM", etc.
  cardNumber: String,
  ticketNumber: String,
  status: String,          // "PENDING" or "DELIVERED"
  bookedAt: Date,
  deliveredAt: Date
}
```

## Testing

1. **Test booking flow:**
   - Select different ticket counts
   - Choose various time slots
   - Verify slot reduction

2. **Test admin panel:**
   - View all bookings
   - Check data accuracy
   - Verify real-time updates

3. **Test edge cases:**
   - Full slots
   - Invalid ticket counts
   - Missing selections
