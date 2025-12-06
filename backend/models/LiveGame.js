const mongoose = require('mongoose');

const winnerSchema = {
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  cardNumber: String,
  wonAt: Date,
  couponCode: String
};

const liveGameSchema = new mongoose.Schema({
  gameCode: { type: String, required: true, unique: true },
  status: { 
    type: String, 
    enum: ['SCHEDULED', 'COUNTDOWN', 'LIVE', 'COMPLETED'], 
    default: 'SCHEDULED' 
  },
  scheduledTime: { type: Date, required: true },
  startTime: { type: Date },
  endTime: { type: Date },
  announcedNumbers: [{ type: Number }],
  currentNumber: { type: Number },
  firstLineWinner: winnerSchema,
  secondLineWinner: winnerSchema,
  thirdLineWinner: winnerSchema,
  jaldiWinner: winnerSchema,
  housieWinner: winnerSchema,
  totalSlots: { type: Number, default: 100 },
  bookedSlots: { type: Number, default: 0 },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('LiveGame', liveGameSchema);
