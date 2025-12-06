# 🚀 Render Deployment Guide

## Prerequisites
- GitHub account
- Render account (https://render.com)
- MongoDB Atlas account

---

## Step 1: Prepare Backend for Deployment

### 1.1 Update package.json

Ensure you have a start script:
```json
{
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  }
}
```

### 1.2 Update .env for Production

Create production environment variables (don't commit .env file):
```env
PORT=5000
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/ush-game
JWT_SECRET=your-super-secret-jwt-key-change-this
OTP_EXPIRY=300000

TWILIO_ACCOUNT_SID=your-twilio-sid
TWILIO_AUTH_TOKEN=your-twilio-token
TWILIO_PHONE_NUMBER=+1234567890
```

### 1.3 Update CORS in server.js

```javascript
app.use(cors({
  origin: [
    'https://your-admin-panel.onrender.com',
    'http://localhost:3000'
  ],
  credentials: true
}));
```

---

## Step 2: Deploy Backend to Render

### 2.1 Push Code to GitHub

```bash
cd backend
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/yourusername/ush-game-backend.git
git push -u origin main
```

### 2.2 Create Web Service on Render

1. Go to https://dashboard.render.com
2. Click "New +" → "Web Service"
3. Connect your GitHub repository
4. Configure:
   - **Name:** `ush-game-backend`
   - **Environment:** `Node`
   - **Build Command:** `npm install`
   - **Start Command:** `npm start`
   - **Plan:** Free (or paid for better performance)

### 2.3 Add Environment Variables

In Render dashboard, add these environment variables:
- `MONGODB_URI`
- `JWT_SECRET`
- `OTP_EXPIRY`
- `TWILIO_ACCOUNT_SID`
- `TWILIO_AUTH_TOKEN`
- `TWILIO_PHONE_NUMBER`

### 2.4 Deploy

Click "Create Web Service" and wait for deployment (5-10 minutes)

Your backend URL will be: `https://ush-game-backend.onrender.com`

---

## Step 3: Deploy Admin Panel to Render

### 3.1 Update Admin .env

```env
REACT_APP_API_URL=https://ush-game-backend.onrender.com
```

### 3.2 Push Admin to GitHub

```bash
cd admin
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/yourusername/ush-game-admin.git
git push -u origin main
```

### 3.3 Create Static Site on Render

1. Go to Render dashboard
2. Click "New +" → "Static Site"
3. Connect your GitHub repository
4. Configure:
   - **Name:** `ush-game-admin`
   - **Build Command:** `npm install && npm run build`
   - **Publish Directory:** `build`

### 3.4 Add Environment Variable

- `REACT_APP_API_URL` = `https://ush-game-backend.onrender.com`

### 3.5 Deploy

Click "Create Static Site"

Your admin URL will be: `https://ush-game-admin.onrender.com`

---

## Step 4: Update Flutter App

### 4.1 Update backend_api_config.dart

```dart
class BackendApiConfig {
  static const String baseUrl = 'https://ush-game-backend.onrender.com/api';
  
  // ... rest of the code
}
```

### 4.2 Update Socket.IO URL

```dart
IO.Socket socket = IO.io('https://ush-game-backend.onrender.com', {
  'transports': ['websocket'],
  'autoConnect': false,
});
```

---

## Step 5: Test Production Deployment

### 5.1 Test Backend APIs

```bash
# Test health check
curl https://ush-game-backend.onrender.com/

# Test registration
curl -X POST https://ush-game-backend.onrender.com/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test","phone":"9876543210","password":"Test@123"}'
```

### 5.2 Test Admin Panel

1. Open `https://ush-game-admin.onrender.com`
2. Try to register/login
3. Check if data loads

### 5.3 Test Flutter App

1. Build APK with production URLs
2. Install on device
3. Test registration, booking, gameplay

---

## Step 6: Monitor & Maintain

### 6.1 Check Logs

- Go to Render dashboard
- Click on your service
- View "Logs" tab

### 6.2 Monitor Performance

- Check response times
- Monitor error rates
- Watch database connections

### 6.3 Set Up Alerts

- Configure email alerts for downtime
- Set up error tracking (Sentry)

---

## Important Notes

### Free Tier Limitations (Render)

- Backend spins down after 15 minutes of inactivity
- First request after spin-down takes 30-60 seconds
- 750 hours/month free (enough for 1 service)

### Upgrade to Paid Plan For:

- No spin-down (always active)
- Better performance
- More resources
- Custom domains

### MongoDB Atlas Free Tier

- 512 MB storage
- Shared cluster
- Good for development/testing
- Upgrade for production

---

## Production URLs

After deployment, share these URLs with Flutter team:

**Backend API:**
```
https://ush-game-backend.onrender.com/api
```

**Socket.IO:**
```
wss://ush-game-backend.onrender.com
```

**Admin Panel:**
```
https://ush-game-admin.onrender.com
```

---

## Troubleshooting

### Backend Not Starting

1. Check logs in Render dashboard
2. Verify environment variables
3. Check MongoDB connection string
4. Ensure all dependencies are in package.json

### CORS Errors

1. Update CORS origin in server.js
2. Add admin panel URL to allowed origins
3. Redeploy backend

### Socket.IO Not Connecting

1. Use `wss://` (not `ws://`) for production
2. Check firewall settings
3. Verify Socket.IO configuration

### Database Connection Failed

1. Check MongoDB Atlas IP whitelist (allow 0.0.0.0/0)
2. Verify connection string
3. Check database user permissions

---

## Security Checklist

- [ ] Strong JWT_SECRET (random, 32+ characters)
- [ ] MongoDB Atlas IP whitelist configured
- [ ] Environment variables set (not hardcoded)
- [ ] CORS properly configured
- [ ] HTTPS enabled (automatic on Render)
- [ ] Rate limiting implemented (optional)
- [ ] Input validation on all endpoints

---

## Post-Deployment

1. ✅ Share API documentation with Flutter team
2. ✅ Share production URLs
3. ✅ Test all endpoints
4. ✅ Monitor logs for errors
5. ✅ Set up error tracking
6. ✅ Create backup strategy for database

---

**Deployment Complete!** 🎉

Your backend is now live and ready for Flutter team integration.
