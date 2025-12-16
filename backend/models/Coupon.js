const mongoose = require('mongoose');

const couponSchema = new mongoose.Schema({
  code: { type: String, required: true, unique: true },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  gameId: { type: mongoose.Schema.Types.ObjectId, ref: 'LiveGame', required: true },
  winType: { type: String, enum: ['FIRST_LINE', 'SECOND_LINE', 'THIRD_LINE', 'JALDI', 'HOUSIE'], required: true },
  couponValue: { type: Number, default: 0 },
  cardNumber: { type: String },
  status: { type: String, enum: ['PENDING', 'ASSIGNED', 'USED'], default: 'ASSIGNED' },
  wonAt: { type: Date, default: Date.now },
  rewardDetails: {
    brand: String,
    description: String,
    amount: Number
  },
  isUsed: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now },
  expiresAt: { type: Date }
});

module.exports = mongoose.model('Coupon', couponSchema);
