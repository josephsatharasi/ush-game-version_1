const mongoose = require('mongoose');

const couponSchema = new mongoose.Schema({
  code: { type: String, required: true, unique: true },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  gameId: { type: mongoose.Schema.Types.ObjectId, ref: 'LiveGame', required: true },
  winType: { type: String, enum: ['ONE_LINE', 'JALDI'], required: true },
  rewardDetails: {
    brand: String,
    description: String,
    amount: Number
  },
  isUsed: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now },
  expiresAt: { type: Date, required: true }
});

module.exports = mongoose.model('Coupon', couponSchema);
