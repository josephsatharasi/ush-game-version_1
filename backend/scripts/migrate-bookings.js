const mongoose = require('mongoose');
require('dotenv').config();

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/ush-game', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const migrationSchema = new mongoose.Schema({}, { strict: false });
const Booking = mongoose.model('Booking', migrationSchema);

async function migrateBookings() {
  try {
    console.log('Starting booking migration...');
    
    // Find all bookings that need migration (have cardNumber instead of cardNumbers)
    const bookingsToMigrate = await Booking.find({
      cardNumber: { $exists: true },
      cardNumbers: { $exists: false }
    });

    console.log(`Found ${bookingsToMigrate.length} bookings to migrate`);

    for (const booking of bookingsToMigrate) {
      const updateData = {
        cardNumbers: [booking.cardNumber],
        ticketNumbers: [booking.ticketNumber],
        ticketCount: booking.ticketCount || 1,
        gameCode: booking.gameCode || 'UNKNOWN',
        gameType: booking.gameType || 'LIVE',
        scheduledDate: booking.scheduledDate || booking.bookedAt,
        weekDay: booking.weekDay || 'Mon',
        timeSlot: booking.timeSlot || '10:00 AM'
      };

      // Remove old fields
      await Booking.updateOne(
        { _id: booking._id },
        { 
          $set: updateData,
          $unset: { 
            cardNumber: 1, 
            ticketNumber: 1 
          }
        }
      );

      console.log(`Migrated booking ${booking._id}`);
    }

    console.log('Migration completed successfully!');
  } catch (error) {
    console.error('Migration failed:', error);
  } finally {
    mongoose.connection.close();
  }
}

// Run migration
migrateBookings();