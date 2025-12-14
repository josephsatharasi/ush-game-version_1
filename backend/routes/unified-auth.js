const express = require('express');
const jwt = require('jsonwebtoken');
const Account = require('../models/Account');
const { sendOTP } = require('../utils/sms');
const router = express.Router();

router.post('/register', async (req, res) => {
  try {
    const { username, phone, password, role = 'user' } = req.body;
    
    let account = await Account.findOne({ username });
    if (account) {
      await Account.deleteOne({ _id: account._id });
    }

    const otp = Math.floor(1000 + Math.random() * 9000).toString();
    const otpExpiry = new Date(Date.now() + (parseInt(process.env.OTP_EXPIRY) || 300000));

    account = new Account({ username, phone, password, role, otp, otpExpiry });
    await account.save();

    await sendOTP(phone, otp);
    console.log(`OTP sent to ${phone}: ${otp}`);
    
    res.json({ message: 'Registration successful. OTP sent.', userId: account._id, adminId: account._id });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post('/verify-otp', async (req, res) => {
  try {
    const { userId, adminId, otp } = req.body;
    const id = userId || adminId;
    
    const account = await Account.findById(id);
    if (!account) {
      return res.status(404).json({ message: 'Account not found' });
    }

    if (account.otpExpiry < new Date()) {
      return res.status(400).json({ message: 'OTP expired' });
    }

    if (account.otp !== otp) {
      return res.status(400).json({ message: 'Invalid OTP' });
    }

    account.otp = undefined;
    account.otpExpiry = undefined;
    account.isVerified = true;
    account.lastLogin = new Date();
    await account.save();

    const token = jwt.sign({ id: account._id, role: account.role }, process.env.JWT_SECRET, { expiresIn: '7d' });
    
    res.json({ 
      token, 
      user: { id: account._id, username: account.username, phone: account.phone, role: account.role },
      admin: { id: account._id, username: account.username, phone: account.phone, role: account.role }
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post('/login', async (req, res) => {
  try {
    const { username, password } = req.body;
    
    const account = await Account.findOne({ username });
    if (!account) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const isMatch = await account.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    account.lastLogin = new Date();
    await account.save();

    const token = jwt.sign({ id: account._id, role: account.role }, process.env.JWT_SECRET, { expiresIn: '7d' });
    
    res.json({ 
      token, 
      user: { id: account._id, username: account.username, phone: account.phone, role: account.role },
      admin: { id: account._id, username: account.username, phone: account.phone, role: account.role }
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post('/resend-otp', async (req, res) => {
  try {
    const { userId, adminId } = req.body;
    const id = userId || adminId;
    
    const account = await Account.findById(id);
    if (!account) {
      return res.status(404).json({ message: 'Account not found' });
    }

    const otp = Math.floor(1000 + Math.random() * 9000).toString();
    const otpExpiry = new Date(Date.now() + (parseInt(process.env.OTP_EXPIRY) || 300000));

    account.otp = otp;
    account.otpExpiry = otpExpiry;
    await account.save();

    await sendOTP(account.phone, otp);
    console.log(`OTP resent to ${account.phone}: ${otp}`);
    
    res.json({ message: 'OTP resent' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
