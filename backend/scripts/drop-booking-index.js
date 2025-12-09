const mongoose = require('mongoose');
require('dotenv').config();

async function dropIndex() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to MongoDB');

    const db = mongoose.connection.db;
    const collection = db.collection('bookings');

    // Drop the old unique index
    await collection.dropIndex('userId_1_gameId_1_scheduledDate_1_timeSlot_1');
    console.log('✅ Successfully dropped old unique index');

    // List remaining indexes
    const indexes = await collection.indexes();
    console.log('\nRemaining indexes:');
    indexes.forEach(index => console.log(index));

    await mongoose.connection.close();
    console.log('\n✅ Done! Restart your backend server.');
  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  }
}

dropIndex();
