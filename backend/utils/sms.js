const twilio = require('twilio');

const sendOTP = async (phone, otp) => {
  try {
    if (!process.env.TWILIO_ACCOUNT_SID || !process.env.TWILIO_AUTH_TOKEN) {
      console.log(`OTP for ${phone}: ${otp}`);
      return true;
    }
    
    const client = twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);
    await client.messages.create({
      body: `Your Ush Game OTP is ${otp}. This code is valid for 60 seconds. Do not share this code with anyone.`,
      from: process.env.TWILIO_PHONE_NUMBER,
      to: `+91${phone}`
    });
    return true;
  } catch (error) {
    console.error('SMS Error:', error);
    return false;
  }
};

module.exports = { sendOTP };
