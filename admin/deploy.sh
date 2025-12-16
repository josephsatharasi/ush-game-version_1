#!/bin/bash

echo "🚀 Deploying Admin Panel..."

# Install dependencies
echo "📦 Installing dependencies..."
npm install --production

# Build the React app
echo "🔨 Building React app..."
npm run build

# Create logs directory
mkdir -p logs

# Stop existing PM2 process
echo "🛑 Stopping existing process..."
pm2 stop admin-panel 2>/dev/null || true

# Start with PM2
echo "▶️ Starting application..."
pm2 start ecosystem.config.js

# Save PM2 process list
pm2 save

echo "✅ Deployment complete!"
echo "📊 View logs: pm2 logs admin-panel"
echo "📈 Monitor: pm2 monit"
