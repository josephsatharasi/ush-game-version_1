const dotenv = require('dotenv');
dotenv.config();

const isLocal = process.env.ENVIRONMENT === 'local';

const config = {
  PORT: isLocal ? process.env.LOCAL_PORT : process.env.LIVE_PORT,
  MONGODB_URI: isLocal ? process.env.LOCAL_MONGODB_URI : process.env.LIVE_MONGODB_URI,
  JWT_SECRET: isLocal ? process.env.LOCAL_JWT_SECRET : process.env.LIVE_JWT_SECRET,
  OTP_EXPIRY: process.env.OTP_EXPIRY,
  TWILIO_ACCOUNT_SID: process.env.TWILIO_ACCOUNT_SID,
  TWILIO_AUTH_TOKEN: process.env.TWILIO_AUTH_TOKEN,
  TWILIO_PHONE_NUMBER: process.env.TWILIO_PHONE_NUMBER,
  ENVIRONMENT: process.env.ENVIRONMENT || 'live'
};

module.exports = config;