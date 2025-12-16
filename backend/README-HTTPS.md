# HTTPS-Only Configuration Guide

## 🔒 Your server now runs ONLY on HTTPS (no HTTP)

### For Local Development:

1. **Generate SSL certificates:**
   ```bash
   node generate-ssl.js
   ```
   
   Or manually with OpenSSL:
   ```bash
   mkdir ssl
   openssl req -x509 -newkey rsa:4096 -keyout ssl/localhost-key.pem -out ssl/localhost.pem -days 365 -nodes -subj "/CN=localhost"
   ```

2. **Access your server:**
   - Backend: `https://localhost:5000`
   - Admin Panel: `https://localhost:5000`

3. **Browser Warning:**
   - You'll see "Your connection is not private" warning
   - Click "Advanced" → "Proceed to localhost (unsafe)"
   - This is normal for self-signed certificates

### For Production:

- Server automatically uses Let's Encrypt certificates
- Location: `/etc/letsencrypt/live/api.vspaze.com/`
- Access: `https://api.vspaze.com`

### Security Features Enabled:

✅ HTTPS-only (no HTTP support)
✅ Strict-Transport-Security header (HSTS)
✅ Secure WebSocket connections
✅ All admin routes protected
✅ All backend API routes protected

### Important Notes:

- **No HTTP fallback** - server will NOT respond to http:// requests
- Update all frontend URLs to use `https://`
- Update Socket.IO client to use `https://` and `wss://`
- Mobile apps must use HTTPS endpoints only
