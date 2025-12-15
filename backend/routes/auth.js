const express = require('express');
const jwt = require('jsonwebtoken');
const config = require('../config/environment');
const User = require('../models/User');
const { sendOTP } = require('../utils/sms');
const router = express.Router();

router.post('/register', async (req, res) => {
  try {
    const { username, phone, password } = req.body;
    
    let user = await User.findOne({ username });
    if (user) {
      await User.deleteOne({ _id: user._id });
    }

    const otp = Math.floor(1000 + Math.random() * 9000).toString();
    const otpExpiry = new Date(Date.now() + (parseInt(process.env.OTP_EXPIRY) || 300000));

    user = new User({ username, phone, password, otp, otpExpiry });
    await user.save();

    await sendOTP(phone, otp);
    console.log(`OTP sent to ${phone}: ${otp}`);
    
    res.json({ message: 'Registration successful. OTP sent.', userId: user._id });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post('/verify-otp', async (req, res) => {
  try {
    const { userId, otp } = req.body;
    
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    if (user.otpExpiry < new Date()) {
      return res.status(400).json({ message: 'OTP expired' });
    }

    if (user.otp !== otp) {
      return res.status(400).json({ message: 'Invalid OTP' });
    }

    user.otp = undefined;
    user.otpExpiry = undefined;
    user.isVerified = true;
    user.lastLogin = new Date();
    await user.save();

    const token = jwt.sign({ id: user._id }, config.JWT_SECRET, { expiresIn: '7d' });
    
    res.json({ token, user: { id: user._id, username: user.username, phone: user.phone } });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post('/login', async (req, res) => {
  try {
    const { username, password } = req.body;
    
    const user = await User.findOne({ username });
    if (!user) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    user.lastLogin = new Date();
    await user.save();

    const token = jwt.sign({ id: user._id }, config.JWT_SECRET, { expiresIn: '7d' });
    
    res.json({ token, user: { id: user._id, username: user.username, phone: user.phone } });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post('/resend-otp', async (req, res) => {
  try {
    const { userId } = req.body;
    
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const otp = Math.floor(1000 + Math.random() * 9000).toString();
    const otpExpiry = new Date(Date.now() + (parseInt(process.env.OTP_EXPIRY) || 300000));

    user.otp = otp;
    user.otpExpiry = otpExpiry;
    await user.save();

    await sendOTP(user.phone, otp);
    console.log(`OTP resent to ${user.phone}: ${otp}`);
    
    res.json({ message: 'OTP resent' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
