const mongoose = require('mongoose');

const ticketSchema = new mongoose.Schema({
  gameId: { type: mongoose.Schema.Types.ObjectId, ref: 'LiveGame', required: true },
  cardNumber: { type: String, required: true },
  ticketNumber: { type: String, required: true, unique: true },
  status: { type: String, enum: ['AVAILABLE', 'BOOKED'], default: 'AVAILABLE' },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'Account' },
  bookedAt: { type: Date },
  createdAt: { type: Date, default: Date.now }
});

ticketSchema.index({ gameId: 1, status: 1 });

module.exports = mongoose.model('Ticket', ticketSchema);
