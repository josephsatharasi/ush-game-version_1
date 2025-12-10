const mongoose = require('mongoose');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '..', '.env') });

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
    if (error.message.includes('ns not found')) {
      console.log('✅ Index already dropped or does not exist');
    } else {
      console.error('Error:', error.message);
    }
    await mongoose.connection.close();
    process.exit(error.message.includes('ns not found') ? 0 : 1);
  }
}

dropIndex();
