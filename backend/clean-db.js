const mongoose = require('mongoose');
const config = require('./config/environment');

async function cleanDatabase() {
  try {
    await mongoose.connect(config.MONGODB_URI);
    console.log('✅ Connected to MongoDB');
    
    const db = mongoose.connection.db;
    
    // Delete all games
    const gamesResult = await db.collection('livegames').deleteMany({});
    console.log(`🗑️  Deleted ${gamesResult.deletedCount} games`);
    
    // Delete all bookings
    const bookingsResult = await db.collection('bookings').deleteMany({});
    console.log(`🗑️  Deleted ${bookingsResult.deletedCount} bookings`);
    
    // Delete all game slot configs
    const configsResult = await db.collection('gameslotconfigs').deleteMany({});
    console.log(`🗑️  Deleted ${configsResult.deletedCount} game slot configs`);
    
    console.log('✅ Database cleaned successfully');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

cleanDatabase();
