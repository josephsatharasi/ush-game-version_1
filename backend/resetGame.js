const mongoose = require('mongoose');
require('dotenv').config();

const resetGame = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('✅ Connected to MongoDB');

    const LiveGame = mongoose.model('LiveGame', new mongoose.Schema({}, { strict: false }));
    
    const gameId = '693d6f63714cfb341b0b4820';
    
    // First, check current state
    const game = await LiveGame.findById(gameId);
    console.log('\n📊 Current game state:');
    console.log('  Status:', game.status);
    console.log('  Announced:', game.announcedNumbers?.length || 0, '/90');
    console.log('  CurrentIndex:', game.currentIndex);
    console.log('  HousieWinner:', game.housieWinner);
    
    const result = await LiveGame.updateOne(
      { _id: gameId },
      {
        $set: {
          status: 'SCHEDULED',
          currentIndex: 0,
          announcedNumbers: [],
          currentNumber: null,
          startTime: null,
          endTime: null,
          scheduledTime: new Date(Date.now() + 15000) // 15 seconds from now
        },
        $unset: {
          firstLineWinner: 1,
          secondLineWinner: 1,
          thirdLineWinner: 1,
          jaldiWinner: 1,
          housieWinner: 1
        }
      }
    );

    console.log('\n✅ Game reset successfully:', result);
    console.log('🎮 Game will auto-start in 15 seconds');
    console.log('🔄 Please restart your backend server now!');
    
    await mongoose.disconnect();
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
};

resetGame();
