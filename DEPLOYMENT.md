# Production Deployment Guide

## Prerequisites on New Server
- ✅ PM2 installed
- ✅ Node.js installed
- ✅ MongoDB installed/accessible
- ✅ Domain pointed to server (api.vspaze.com)

## Step 1: Commit & Push Code

```bash
git add .
git commit -m "Configure HTTPS-only server"
git push origin main
```

## Step 2: Clone on Production Server

```bash
# SSH into your server
ssh user@your-server-ip

# Clone repository
git clone https://github.com/your-username/your-repo.git
cd your-repo/backend

# Install dependencies
npm install
```

## Step 3: Setup SSL Certificates (Let's Encrypt)

```bash
# Install Certbot
sudo apt update
sudo apt install certbot

# Get SSL certificate
sudo certbot certonly --standalone -d api.vspaze.com

# Certificates will be at:
# /etc/letsencrypt/live/api.vspaze.com/privkey.pem
# /etc/letsencrypt/live/api.vspaze.com/fullchain.pem
```

## Step 4: Configure Environment

```bash
# Create .env file
nano .env
```

Add:
```env
NODE_ENV=production
PORT=443
MONGODB_URI=your_mongodb_connection_string
JWT_SECRET=your_jwt_secret
```

## Step 5: Start with PM2

```bash
# Create logs directory
mkdir logs

# Start application using ecosystem file
sudo pm2 start ecosystem.config.js

# Save PM2 configuration
sudo pm2 save

# Setup auto-restart on reboot
sudo pm2 startup

# Check status
sudo pm2 status
sudo pm2 logs ush-game
```

## Step 6: Firewall Configuration

```bash
# Allow HTTPS only
sudo ufw allow 443/tcp
sudo ufw enable
```

## Important Notes:

- Server runs on port **443** (HTTPS default)
- No port 80 (HTTP) needed - HTTPS only
- PM2 must run with `sudo` to bind to port 443
- SSL certificates auto-renew with certbot

## Useful PM2 Commands:

```bash
sudo pm2 restart ush-game    # Restart app
sudo pm2 stop ush-game       # Stop app
sudo pm2 logs ush-game       # View logs
sudo pm2 monit               # Monitor resources
```

## SSL Certificate Renewal:

Certbot auto-renews. To manually renew:
```bash
sudo certbot renew
sudo pm2 restart ush-game
```
