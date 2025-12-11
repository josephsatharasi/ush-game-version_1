# Ush Game - Environment Configuration

## Quick Setup

### Backend Configuration
Change environment in `backend/.env`:
```bash
# For local development
ENVIRONMENT=local

# For production
ENVIRONMENT=live
```

### Flutter App Configuration
Run with environment flag:
```bash
# Local development
flutter run --dart-define=USE_LOCAL=true

# Production
flutter run --dart-define=USE_LOCAL=false
```

### Admin Panel Configuration
```bash
# Local development
cp admin/.env.local admin/.env

# Production  
cp admin/.env admin/.env
```

## Environment Details

### Local Configuration
- Backend: `http://localhost:5000`
- Database: `mongodb://localhost:27017/ush-game-local`
- Flutter: `http://192.168.0.22:5000`

### Live Configuration  
- Backend: `https://ush-game-version-1.onrender.com`
- Database: MongoDB Atlas
- Flutter: Production URL

## Quick Commands
```bash
# Start local backend
cd backend && ENVIRONMENT=local npm start

# Start live backend  
cd backend && ENVIRONMENT=live npm start

# Flutter local
flutter run --dart-define=USE_LOCAL=true

# Flutter live
flutter run --dart-define=USE_LOCAL=false
```