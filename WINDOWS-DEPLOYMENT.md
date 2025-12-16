# Windows Server Deployment Guide

## Your Setup
- **Backend API:** api.vspaze.com (port 443)
- **Admin Panel:** admin.vspaze.com (port 443, same server)
- **Server IP:** 68.178.174.186

---

## STEP 1: Configure DNS (Do this first)

Go to your domain registrar and add these A Records:

```
Type: A Record
Host: api
Value: 68.178.174.186
TTL: 3600

Type: A Record  
Host: admin
Value: 68.178.174.186
TTL: 3600
```

Wait 5-10 minutes for DNS propagation.

---

## STEP 2: Push Code to GitHub (Local Machine)

```bash
cd c:\Users\hp\Desktop\Ush-Game-Version-1\Ush-Game-Version-1-main
git add .
git commit -m "Windows HTTPS deployment ready"
git push origin main
```

---

## STEP 3: Connect to Server

Use Remote Desktop (RDP):
- IP: 68.178.174.186
- Username: Administrator
- Password: (your password)

---

## STEP 4: Install OpenSSL (On Server)

Open PowerShell as Administrator:

```powershell
# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install OpenSSL
choco install openssl -y

# Refresh environment
refreshenv
```

---

## STEP 5: Clone Repository

```powershell
cd C:\
mkdir projects
cd projects

# Replace with your actual GitHub URL
git clone https://github.com/YOUR-USERNAME/YOUR-REPO.git

# Navigate to backend
cd YOUR-REPO\Ush-Game-Version-1-main\backend
```

---

## STEP 6: Generate SSL Certificate

```powershell
# Create SSL directory
mkdir C:\ssl
cd C:\ssl

# Generate certificate for both domains
openssl req -x509 -newkey rsa:4096 -keyout privkey.pem -out fullchain.pem -days 365 -nodes -subj "/CN=*.vspaze.com"

# Verify files
dir C:\ssl
```

You should see: privkey.pem and fullchain.pem

---

## STEP 7: Install Dependencies

```powershell
cd C:\projects\YOUR-REPO\Ush-Game-Version-1-main\backend
npm install
```

---

## STEP 8: Create .env File

```powershell
notepad .env
```

Add:
```env
NODE_ENV=production
PORT=443
MONGODB_URI=mongodb://localhost:27017/ush-game
JWT_SECRET=your-random-secret-key-here
ADMIN_JWT_SECRET=your-admin-secret-key-here
```

Save and close.

---

## STEP 9: Create Logs Directory

```powershell
mkdir logs
```

---

## STEP 10: Configure Firewall

```powershell
New-NetFirewallRule -DisplayName "HTTPS-443" -Direction Inbound -LocalPort 443 -Protocol TCP -Action Allow
```

---

## STEP 11: Test Server

```powershell
node server.js
```

Should see: `🚀 Server running on 0.0.0.0:443`

Press Ctrl+C to stop.

---

## STEP 12: Start with PM2

```powershell
pm2 start ecosystem.config.js
pm2 status
pm2 logs ush-game
```

---

## STEP 13: Save PM2 Configuration

```powershell
pm2 save
npm install -g pm2-windows-startup
pm2-startup install
```

---

## STEP 14: Test Your Deployment

Open browser:
- Backend API: https://api.vspaze.com
- Admin Panel: https://admin.vspaze.com

Note: You'll see security warning (self-signed cert). Click "Advanced" → "Proceed".

---

## Troubleshooting Commands

```powershell
# View PM2 status
pm2 status

# View logs
pm2 logs ush-game --lines 50

# Restart
pm2 restart ush-game

# Stop
pm2 stop ush-game

# Check port 443
netstat -ano | findstr :443

# Check SSL files
dir C:\ssl
```

---

## Domain Structure Explained

Both api.vspaze.com and admin.vspaze.com point to the same server (68.178.174.186).

The Node.js server:
- Serves API routes at /api/* (accessible from both domains)
- Serves admin panel static files at /* (React app)

This works because:
- SSL certificate uses wildcard (*.vspaze.com)
- Both domains resolve to same IP
- Express serves both API and static files
