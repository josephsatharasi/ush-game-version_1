const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const sslDir = path.join(__dirname, 'ssl');

// Create ssl directory if it doesn't exist
if (!fs.existsSync(sslDir)) {
  fs.mkdirSync(sslDir);
  console.log('✅ Created ssl directory');
}

// Generate self-signed certificate for localhost
try {
  execSync(`openssl req -x509 -newkey rsa:4096 -keyout "${path.join(sslDir, 'localhost-key.pem')}" -out "${path.join(sslDir, 'localhost.pem')}" -days 365 -nodes -subj "/CN=localhost"`, {
    stdio: 'inherit'
  });
  console.log('✅ SSL certificates generated successfully');
  console.log('📁 Location:', sslDir);
} catch (error) {
  console.error('❌ Error generating certificates:', error.message);
  console.log('\n💡 Manual generation:');
  console.log('Run this command in your terminal:');
  console.log(`openssl req -x509 -newkey rsa:4096 -keyout ssl/localhost-key.pem -out ssl/localhost.pem -days 365 -nodes -subj "/CN=localhost"`);
}
