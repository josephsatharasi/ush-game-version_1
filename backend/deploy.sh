#!/bin/bash

# Quick deployment script
echo "🚀 Deploying Ush Game Backend..."

# Install dependencies
echo "📦 Installing dependencies..."
npm install --production

# Create logs directory
mkdir -p logs

# Stop existing PM2 process
echo "🛑 Stopping existing process..."
pm2 stop ush-game-backend 2>/dev/null || true

# Start with PM2
echo "▶️ Starting application..."
pm2 start ecosystem.config.js

# Save PM2 process list
pm2 save

echo "✅ Deployment complete!"
echo "📊 View logs: pm2 logs ush-game-backend"
echo "📈 Monitor: pm2 monit"
