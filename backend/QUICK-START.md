# Quick Deployment to 200.69.21.209

## Step 1: Connect to Server
```bash
ssh root@200.69.21.209
```

## Step 2: Setup Server (One-time)
```bash
# Update system
sudo dnf update -y

# Install Node.js
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo dnf install -y nodejs

# Install PM2
sudo npm install -g pm2

# Install Nginx
sudo dnf install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# Configure firewall
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-port=5000/tcp
sudo firewall-cmd --reload
```

## Step 3: Upload Backend (From Your PC)
```bash
# Zip backend (exclude node_modules)
cd Ush-Game-Version-1-main
tar -czf backend.tar.gz backend --exclude=backend/node_modules --exclude=backend/logs

# Upload to server
scp backend.tar.gz root@200.69.21.209:/root/

# Or use WinSCP/FileZilla if on Windows
```

## Step 4: Deploy on Server
```bash
# SSH into server
ssh root@200.69.21.209

# Extract
cd /root
tar -xzf backend.tar.gz
cd backend

# Install dependencies
npm install --production

# Start with PM2
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

## Step 5: Access Your API
- Direct: http://200.69.21.209:5000
- Domain: http://server.iscraap.com:5000

## Quick Commands
```bash
# View logs
pm2 logs

# Restart
pm2 restart ush-game-backend

# Status
pm2 status
```
