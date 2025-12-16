# QUICK FIX for "Missing parameter name at index 1: *" Error

## The Problem
You're running `npm start` on the server, which starts the React development server. This causes the path-to-regexp error.

## The Solution (On Your Server)

### Step 1: Stop the current process
```bash
# Press Ctrl+C to stop npm start
# OR if running with PM2:
pm2 stop admin-panel
pm2 delete admin-panel
```

### Step 2: Build the production version
```bash
cd /root/ush-game-version_1/admin
npm run build
```

### Step 3: Install Express
```bash
npm install express
```

### Step 4: Start with PM2
```bash
pm2 start ecosystem.config.js
pm2 save
```

### Step 5: Check if it's running
```bash
pm2 status
pm2 logs admin-panel
```

## Access Your Admin Panel
- If using port 3000: `http://your-domain:3000`
- If using Nginx proxy: `http://your-domain`

## Important Notes
- NEVER run `npm start` on production server
- Always use `npm run build` first
- Use PM2 to manage the production server
- The build folder contains optimized static files

## If You Get "express not found" Error
```bash
cd /root/ush-game-version_1/admin
npm install express --save
```

## Alternative: Serve from Backend
If you prefer to serve admin panel from your backend:

1. Build admin panel:
```bash
cd /root/ush-game-version_1/admin
npm run build
```

2. Your backend at `/root/ush-game-version_1/backend/server.js` should already have code to serve it

3. Just restart backend:
```bash
cd /root/ush-game-version_1/backend
pm2 restart ush-game-backend
```

Then access at: `http://your-domain:5000`
