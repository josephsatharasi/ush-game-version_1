const dotenv = require('dotenv');
dotenv.config();

const isLive = process.env.ENVIRONMENT === 'live';

const config = {
  PORT: isLive ? (process.env.LIVE_PORT || 5000) : (process.env.LOCAL_PORT || 3001),
  MONGODB_URI: isLive ? process.env.LIVE_MONGODB_URI : process.env.LOCAL_MONGODB_URI,
  JWT_SECRET: isLive ? process.env.LIVE_JWT_SECRET : process.env.LOCAL_JWT_SECRET,
  OTP_EXPIRY: process.env.OTP_EXPIRY,
  TWILIO_ACCOUNT_SID: process.env.TWILIO_ACCOUNT_SID,
  TWILIO_AUTH_TOKEN: process.env.TWILIO_AUTH_TOKEN,
  TWILIO_PHONE_NUMBER: process.env.TWILIO_PHONE_NUMBER
};

console.log(`🔧 Environment: ${isLive ? 'LIVE' : 'LOCAL'}`);
console.log(`🔧 Port: ${config.PORT}`);

module.exports = config;