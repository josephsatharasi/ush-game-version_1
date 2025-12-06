const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const accountSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  phone: { type: String, required: true },
  password: { type: String, required: true },
  role: { type: String, enum: ['user', 'admin'], default: 'user' },
  otp: { type: String },
  otpExpiry: { type: Date },
  isVerified: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now },
  lastLogin: { type: Date }
});

accountSchema.index({ username: 1 }, { unique: true });

accountSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 10);
  next();
});

accountSchema.methods.comparePassword = async function(password) {
  return await bcrypt.compare(password, this.password);
};

const Account = mongoose.model('Account', accountSchema);

Account.collection.dropIndex('phone_1').catch(() => {});

module.exports = Account;
