# Admin Panel Deployment Guide

## Quick Deployment Steps

### 1. Build the Admin Panel Locally
```bash
cd admin
npm install
npm run build
```

### 2. Upload to Server
```bash
# Zip the admin folder (including build directory)
zip -r admin.zip admin

# Upload to server
scp admin.zip root@200.69.21.209:/root/

# On server, extract
cd /root
unzip admin.zip
cd admin
```

### 3. Install Express (if not already installed)
```bash
npm install express --save
```

### 4. Deploy with PM2
```bash
# Make deploy script executable
chmod +x deploy.sh

# Run deployment
./deploy.sh
```

## Alternative: Serve from Backend

If you want to serve the admin panel from your backend server instead:

### 1. Build the admin panel
```bash
cd admin
npm run build
```

### 2. The backend will automatically serve it
The backend `server.js` already has code to serve static files from `../admin/build`

### 3. Just restart your backend
```bash
cd /root/backend
pm2 restart ush-game-backend
```

## PM2 Commands

```bash
# View logs
pm2 logs admin-panel

# Restart
pm2 restart admin-panel

# Stop
pm2 stop admin-panel

# Status
pm2 status
```

## Nginx Configuration (Optional)

If you want to serve admin panel on a subdomain or different port:

```nginx
server {
    listen 80;
    server_name admin.iscraap.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

## Troubleshooting

### Error: "Missing parameter name at index 1: *"
This means you're running `npm start` instead of building and serving the production build.

**Solution:**
1. Stop the dev server: `pm2 stop admin-panel` or `Ctrl+C`
2. Build the app: `npm run build`
3. Start with PM2: `pm2 start ecosystem.config.js`

### Port Already in Use
```bash
# Find process using port 3000
lsof -i :3000

# Kill it
kill -9 <PID>
```
