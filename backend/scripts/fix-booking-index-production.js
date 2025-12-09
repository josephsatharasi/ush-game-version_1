const mongoose = require('mongoose');

// Replace with your production MongoDB URI
const MONGODB_URI = process.env.MONGODB_URI || 'YOUR_MONGODB_URI_HERE';

async function fixBookingIndex() {
  try {
    await mongoose.connect(MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    const db = mongoose.connection.db;
    const collection = db.collection('bookings');

    // Get current indexes
    const indexes = await collection.indexes();
    console.log('\n📋 Current indexes:', JSON.stringify(indexes, null, 2));

    // Drop the unique index if it exists
    try {
      await collection.dropIndex('userId_1_gameId_1_scheduledDate_1_timeSlot_1');
      console.log('\n✅ Dropped unique index');
    } catch (e) {
      if (e.message.includes('not found')) {
        console.log('\n✅ Index already dropped or does not exist');
      } else {
        throw e;
      }
    }

    // Create non-unique index
    await collection.createIndex(
      { userId: 1, gameId: 1, scheduledDate: 1, timeSlot: 1 },
      { unique: false, name: 'booking_lookup_index' }
    );
    console.log('✅ Created non-unique index');

    // Verify
    const newIndexes = await collection.indexes();
    console.log('\n📋 New indexes:', JSON.stringify(newIndexes, null, 2));

    await mongoose.connection.close();
    console.log('\n✅ Done! Users can now book multiple slots per day.');
  } catch (error) {
    console.error('❌ Error:', error.message);
    await mongoose.connection.close();
    process.exit(1);
  }
}

fixBookingIndex();
