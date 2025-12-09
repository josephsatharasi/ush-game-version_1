const mongoose = require('mongoose');
require('dotenv').config();

const Booking = require('../models/Booking');

async function fixGeneratedNumbers() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to MongoDB');

    const bookings = await Booking.find({});
    let fixed = 0;

    for (const booking of bookings) {
      let needsUpdate = false;
      const updatedNumbers = [];

      for (const genNum of booking.generatedNumbers) {
        if (typeof genNum === 'string') {
          const numbers = genNum.split(',').map(n => parseInt(n.trim()));
          updatedNumbers.push({
            firstLine: numbers.slice(0, 5),
            secondLine: numbers.slice(5, 10),
            thirdLine: numbers.slice(10, 15)
          });
          needsUpdate = true;
        } else {
          updatedNumbers.push(genNum);
        }
      }

      if (needsUpdate) {
        booking.generatedNumbers = updatedNumbers;
        await booking.save();
        fixed++;
        console.log(`Fixed booking ${booking._id}`);
      }
    }

    console.log(`\nMigration complete! Fixed ${fixed} bookings.`);
    process.exit(0);
  } catch (error) {
    console.error('Migration failed:', error);
    process.exit(1);
  }
}

fixGeneratedNumbers();
