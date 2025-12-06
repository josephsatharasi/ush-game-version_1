const mongoose = require('mongoose');

const gameSlotConfigSchema = new mongoose.Schema({
  gameId: { type: mongoose.Schema.Types.ObjectId, ref: 'LiveGame', required: true },
  gameCode: { type: String, required: true },
  maxTicketsPerUser: { type: Number, default: 6, min: 1, max: 6 },
  availableWeekDays: [{
    type: String,
    enum: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
  }],
  availableTimeSlots: [{
    time: { type: String, required: true },
    totalSlots: { type: Number, required: true, min: 1 },
    bookedSlots: { type: Number, default: 0 },
    badge: { type: String, enum: ['Best time', 'Good time', 'Low Time'], default: null }
  }],
  scheduledDate: { type: Date, required: true },
  isActive: { type: Boolean, default: true },
  createdAt: { type: Date, default: Date.now }
});

gameSlotConfigSchema.index({ gameId: 1 }, { unique: true });

module.exports = mongoose.model('GameSlotConfig', gameSlotConfigSchema);