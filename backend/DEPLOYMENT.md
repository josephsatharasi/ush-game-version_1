# Backend Deployment Guide

## Server Details
- **IP**: 200.69.21.209
- **Domain**: server.iscraap.com
- **OS**: AlmaLinux 9.5
- **RAM**: 1024 MB
- **CPU**: 1 Core
- **Storage**: 25 GB

## Prerequisites on Server
```bash
# Update system
sudo dnf update -y

# Install Node.js 18.x (AlmaLinux uses dnf, not apt)
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo dnf install -y nodejs

# Install PM2 globally
sudo npm install -g pm2

# Install Nginx (optional, for reverse proxy)
sudo apt install -y nginx
```

## Deployment Steps

### 1. Upload Backend Files
```bash
# On your local machine, zip the backend folder (exclude node_modules)
cd Ush-Game-Version-1-main
zip -r backend.zip backend -x "backend/node_modules/*" "backend/logs/*"

# Upload to server using SCP
scp backend.zip root@200.69.21.209:/root/

# On server, extract
cd /root
unzip backend.zip
cd backend
```

### 2. Configure Environment
```bash
# Edit .env file with production values
nano .env
```

Update these values:
- Keep your MongoDB URI
- Keep JWT_SECRET secure
- Update Twilio credentials if needed
- Set PORT (default 5000)

### 3. Install Dependencies & Start
```bash
# Install dependencies
npm install --production

# Create logs directory
mkdir -p logs

# Start with PM2
pm2 start ecosystem.config.js

# Save PM2 process list
pm2 save

# Setup PM2 to start on boot
pm2 startup
# Follow the command it outputs
```

### 4. Configure Nginx (Recommended)
```bash
sudo nano /etc/nginx/conf.d/ush-game-backend.conf
```

Add this configuration:
```nginx
server {
    listen 80;
    server_name server.iscraap.com 200.69.21.209;

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # WebSocket support for Socket.IO
    location /socket.io/ {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
    }
}
```

Test and restart Nginx:
```bash
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx
```

### 5. Configure Firewall
```bash
# AlmaLinux uses firewalld
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-port=5000/tcp
sudo firewall-cmd --reload
```

### 6. SSL Certificate (Optional but Recommended)
```bash
# Install Certbot
sudo dnf install -y certbot python3-certbot-nginx

# Get SSL certificate
sudo certbot --nginx -d server.iscraap.com
```

## PM2 Commands

```bash
# View logs
pm2 logs ush-game-backend

# Restart app
pm2 restart ush-game-backend

# Stop app
pm2 stop ush-game-backend

# Monitor
pm2 monit

# View status
pm2 status
```

## Testing Deployment

```bash
# Test API endpoint
curl http://200.69.21.209:5000/

# Or with domain
curl http://server.iscraap.com/
```

## Updating Backend

```bash
# On server
cd /root/backend
pm2 stop ush-game-backend
git pull  # if using git
# or upload new files
npm install --production
pm2 restart ush-game-backend
```

## Troubleshooting

```bash
# Check PM2 logs
pm2 logs --lines 100

# Check Nginx logs
sudo tail -f /var/log/nginx/error.log

# Check if port is in use
sudo netstat -tulpn | grep 5000

# Restart everything
pm2 restart all
sudo systemctl restart nginx
```
