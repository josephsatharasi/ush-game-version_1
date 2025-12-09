const mongoose = require('mongoose');
require('dotenv').config();

async function fixIndexes() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to MongoDB');

    const db = mongoose.connection.db;
    const collection = db.collection('bookings');

    // Drop the problematic unique indexes
    try {
      await collection.dropIndex('userId_1_gameId_1_weekDay_1_timeSlot_1');
      console.log('✅ Dropped: userId_1_gameId_1_weekDay_1_timeSlot_1');
    } catch (e) {
      console.log('Index not found or already dropped');
    }

    try {
      await collection.dropIndex('userId_1_gameId_1_ticketCount_1_weekDay_1_timeSlot_1');
      console.log('✅ Dropped: userId_1_gameId_1_ticketCount_1_weekDay_1_timeSlot_1');
    } catch (e) {
      console.log('Index not found or already dropped');
    }

    // List remaining indexes
    const indexes = await collection.indexes();
    console.log('\n📋 Remaining indexes:');
    indexes.forEach(index => console.log(index));

    await mongoose.connection.close();
    console.log('\n✅ Done! Now users can book multiple time slots per day.');
  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  }
}

fixIndexes();
