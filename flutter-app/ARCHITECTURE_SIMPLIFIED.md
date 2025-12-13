# Simplified Game Architecture

## Overview
The game architecture has been simplified to use only 3 core files instead of multiple separate screens for each button.

## Core Files

### 1. `game_tilt_widget.dart` (Main Game Screen)
**Purpose**: Single screen that handles:
- Number announcements (jar animation + coin pop)
- All 5 game buttons (First Line, Second Line, Third Line, Jaldhi, Housi)
- Line completion checking
- Win claiming
- Navigation to ticket view and numbers grid

**Key Features**:
- When user clicks any button (First Line, Second Line, etc.), it checks if that line is completed
- If completed, it calls the backend API to claim the win
- Button turns grey with checkmark after successful claim
- No navigation to separate screens - everything happens in place
- Continues announcing numbers in background

### 2. `game_tilt_model.dart` (Game State)
**Purpose**: Manages all game state:
- Current number and announced numbers
- User's ticket numbers (first line, second line, third line)
- Line completion status (firstLineCompleted, secondLineCompleted, etc.)
- Winner information

**Key Methods**:
- `loadTicketNumbers()` - Loads user's ticket from backend
- `checkLineCompletion()` - Checks if a specific line is completed
- `checkJaldhiCompletion()` - Checks if 5 numbers from first line are announced
- `checkHousiCompletion()` - Checks if all ticket numbers are announced

### 3. `game_number_service.dart` (Number Broadcasting)
**Purpose**: Simplified service that only broadcasts current number to other screens
- Used by the numbers grid screen to highlight announced numbers
- No audio/TTS (handled by main game widget)
- No game logic (handled by model)

## Flow

### Game Start
1. User enters game → `game_tilt_widget.dart` loads
2. Widget loads user's ticket numbers from backend
3. Widget starts polling backend every 1 second for new numbers
4. When new number announced → shows coin animation + plays audio/TTS
5. Broadcasts number to `GameNumberService` for other screens

### Button Click (e.g., "First Line")
1. User clicks "FIRST LINE" button
2. Widget calls `_handleLineButtonTap('FIRST LINE')`
3. Model checks if all first line numbers are in announced numbers
4. If YES:
   - Calls backend API to claim win
   - Updates button to grey with checkmark
   - Shows success message
   - If it's a winning claim, navigates to winner screen
5. If NO:
   - Shows "First Line not completed yet!" message
   - User continues playing

### Removed Complexity
- ❌ No separate screens for each button (`first_button_widget.dart`, etc.)
- ❌ No `live_gametype1_widget.dart` (booking screen is separate)
- ❌ No complex state management across multiple screens
- ❌ No navigation back and forth between button screens
- ✅ Everything happens in one place
- ✅ Simple, linear flow
- ✅ Easy to understand and maintain

## API Endpoints Used

1. **GET** `/api/game/:gameId/announced-numbers` - Get current number and all announced numbers
2. **GET** `/api/game/:gameId/status` - Get game status (LIVE, COMPLETED, etc.)
3. **GET** `/api/game/my-bookings` - Get user's ticket numbers
4. **POST** `/api/game/:gameId/claim-win` - Claim a win (First Line, Second Line, etc.)

## Benefits

1. **Simpler Code**: 3 files instead of 10+
2. **Better UX**: No navigation delays, instant feedback
3. **Easier Debugging**: All logic in one place
4. **Better Performance**: No screen transitions, less memory usage
5. **Maintainable**: Easy to add new features or fix bugs
