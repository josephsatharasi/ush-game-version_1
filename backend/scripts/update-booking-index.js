const mongoose = require('mongoose');
require('dotenv').config();

async function updateIndex() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to MongoDB');

    const db = mongoose.connection.db;
    const collection = db.collection('bookings');

    // Drop old index
    try {
      await collection.dropIndex('gameId_1_cardNumber_1');
      console.log('Old index dropped');
    } catch (err) {
      console.log('Old index not found or already dropped');
    }

    // Create new index
    await collection.createIndex(
      { userId: 1, gameId: 1, weekDay: 1, timeSlot: 1 },
      { unique: true }
    );
    console.log('New index created successfully');

    await mongoose.disconnect();
    console.log('Migration completed');
  } catch (error) {
    console.error('Migration failed:', error);
    process.exit(1);
  }
}

updateIndex();
