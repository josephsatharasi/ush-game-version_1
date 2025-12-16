const mongoose = require('mongoose');

const winnerSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  username: String,
  cardNumber: String,
  wonAt: Date,
  couponCode: String,
  couponValue: Number
}, { _id: false });

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
  generatedNumbers: [{ type: Number }],
  currentIndex: { type: Number, default: 0 },
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

// Log whenever status changes to COMPLETED
liveGameSchema.pre('save', function(next) {
  if (this.isModified('status') && this.status === 'COMPLETED') {
    console.log(`\n🚨🚨🚨 GAME STATUS CHANGED TO COMPLETED 🚨🚨🚨`);
    console.log(`Game ID: ${this._id}`);
    console.log(`Game Code: ${this.gameCode}`);
    console.log(`Current Index: ${this.currentIndex}`);
    console.log(`Announced Numbers: ${this.announcedNumbers.length}`);
    console.log(`Housie Winner: ${this.housieWinner?.userId ? 'YES' : 'NO'}`);
    console.log(`Stack trace:`);
    console.trace();
    console.log(`🚨🚨🚨 END OF STATUS CHANGE LOG 🚨🚨🚨\n`);
  }
  next();
});

module.exports = mongoose.model('LiveGame', liveGameSchema);
