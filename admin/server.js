const express = require('express');
const https = require('https');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// SSL Configuration
const sslOptions = {
  key: fs.readFileSync('/etc/letsencrypt/live/admin.vspaze.com/privkey.pem'),
  cert: fs.readFileSync('/etc/letsencrypt/live/admin.vspaze.com/fullchain.pem')
};

// Serve static files from the build directory
app.use(express.static(path.join(__dirname, 'build'), {
  index: 'index.html',
  fallthrough: true
}));

// Handle React routing - return index.html for all routes
app.use((req, res) => {
  res.sendFile(path.join(__dirname, 'build', 'index.html'));
});

https.createServer(sslOptions, app).listen(PORT, '0.0.0.0', () => {
  console.log(`✅ Admin panel HTTPS server running on port ${PORT}`);
});
