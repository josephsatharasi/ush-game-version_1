# Winner Flow Changes - Summary

## Problem
- Winners (HOUSIE and line winners) were not seeing proper winner screens
- No navigation to scratch card screen after winning
- Direct navigation to home screen without showing rewards

## Solution Implemented

### 1. Game Play Screen (fam_playground_widget.dart)
**Changed:** All win types now navigate to winner screen
- FIRST LINE, SECOND LINE, THIRD LINE, JALDI, and HOUSIE all follow same flow
- After claiming win, user sees success message for 2 seconds
- Then navigates to `/winner` screen with win type argument

### 2. Winner Screen (winner_screen.dart)
**Changed:** Improved winner detection logic
- Checks if user has won by looking for `wonCouponCode` in SharedPreferences
- If user has coupon → Shows "You Won" screen → Navigates to scratch card
- If user has no coupon → Fetches game status → Shows HOUSIE winner card number → Navigates to home
- Removed unused constructor parameters

**Flow for Winners:**
1. Game Over screen (1 second)
2. You Won screen (2 seconds)
3. Navigate to Scratch Reward Screen

**Flow for Non-Winners:**
1. Game Over screen (1 second)
2. Winner announcement with card number (3 seconds)
3. Navigate to Home

### 3. Scratch Reward Screen (scratch_reward_screen.dart)
**Changed:** Better coupon validation and cleanup
- Validates coupon value > 0 to confirm real win
- Shows congratulations screen for winners
- Shows better luck screen for non-winners (edge case)
- Clears coupon data after showing result (4 seconds)
- Then navigates to home screen

**Scratch Flow:**
1. Loading screen while fetching coupon
2. Scratch card with hidden reward
3. User scratches to reveal
4. Shows congratulations/better luck overlay
5. Auto-navigates to home after 4 seconds

## Winner Flow Summary

### For Line Winners (FIRST_LINE, SECOND_LINE, THIRD_LINE, JALDI):
```
Claim Win → Success Message (2s) → Winner Screen → You Won (2s) → Scratch Card → Scratch → Congratulations (4s) → Home
```

### For HOUSIE Winner:
```
Claim Win → Success Message (2s) → Winner Screen → You Won (2s) → Scratch Card → Scratch → Congratulations (4s) → Home
```

### For Non-Winners (when HOUSIE ends):
```
Game Ends → Winner Screen → Game Over (1s) → Winner Card Display (3s) → Home
```

## Technical Details

### Data Flow:
1. **Claim Win API** returns `couponCode` and `couponValue`
2. Saved to SharedPreferences as `wonCouponCode` and `wonCouponValue`
3. Winner Screen checks for these values to determine if user won
4. Scratch Screen fetches and displays these values
5. After display, values are cleared from SharedPreferences

### Key Files Modified:
- `/flutter-app/lib/app_state/fam_playground/fam_playground_widget.dart`
- `/flutter-app/lib/app_state/game_tilt/winner_screen.dart`
- `/flutter-app/lib/app_state/game_tilt/scratch_reward_screen.dart`

## Testing Checklist
- [ ] Win FIRST LINE → See winner screen → Scratch card → Home
- [ ] Win SECOND LINE → See winner screen → Scratch card → Home
- [ ] Win THIRD LINE → See winner screen → Scratch card → Home
- [ ] Win JALDI → See winner screen → Scratch card → Home
- [ ] Win HOUSIE → See winner screen → Scratch card → Home
- [ ] Lose game → See winner announcement → Home
- [ ] Scratch card shows correct coupon code and value
- [ ] Coupon data cleared after viewing
