const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'Account', required: true },
  gameId: { type: mongoose.Schema.Types.ObjectId, ref: 'LiveGame', required: true },
  cardNumber: { type: String, required: true },
  ticketNumber: { type: String, required: true },
  status: { type: String, enum: ['PENDING', 'DELIVERED'], default: 'PENDING' },
  bookedAt: { type: Date, default: Date.now },
  deliveredAt: { type: Date }
});

bookingSchema.index({ gameId: 1, cardNumber: 1 }, { unique: true });

module.exports = mongoose.model('Booking', bookingSchema);
