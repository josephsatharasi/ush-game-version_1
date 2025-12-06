const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'Account', required: true },
  gameId: { type: mongoose.Schema.Types.ObjectId, ref: 'LiveGame', required: true },
  gameCode: { type: String, required: true },
  gameType: { type: String, default: 'LIVE' },
  ticketCount: { type: Number, required: true, min: 1, max: 6 },
  scheduledDate: { type: Date, required: true },
  weekDay: { type: String, required: true, enum: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'] },
  timeSlot: { type: String, required: true, enum: ['10:00 AM', '11:00 AM', '1:00 PM', '2:00 PM', '3:00 PM', '4:00 PM', '5:00 PM', '6:00 PM'] },
  cardNumbers: [{ type: String, required: true }],
  ticketNumbers: [{ type: String, required: true }],
  status: { type: String, enum: ['PENDING', 'DELIVERED'], default: 'PENDING' },
  bookedAt: { type: Date, default: Date.now },
  deliveredAt: { type: Date }
});

// Create compound index to prevent duplicate bookings for same user, game, weekDay, and timeSlot
bookingSchema.index({ userId: 1, gameId: 1, weekDay: 1, timeSlot: 1 }, { unique: true });

module.exports = mongoose.model('Booking', bookingSchema);
