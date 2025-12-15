const mongoose = require('mongoose');
require('dotenv').config();

const checkGame = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('✅ Connected to MongoDB\n');

    const LiveGame = mongoose.model('LiveGame', new mongoose.Schema({}, { strict: false }));
    
    const gameId = '693d6f63714cfb341b0b4820';
    const game = await LiveGame.findById(gameId);
    
    if (!game) {
      console.log('❌ Game not found');
      await mongoose.disconnect();
      return;
    }

    console.log('📊 GAME STATUS REPORT');
    console.log('='.repeat(50));
    console.log('Game ID:', game._id);
    console.log('Game Code:', game.gameCode);
    console.log('Status:', game.status);
    console.log('Scheduled Time:', game.scheduledTime);
    console.log('Start Time:', game.startTime || 'Not started');
    console.log('End Time:', game.endTime || 'Not ended');
    console.log('\n📢 ANNOUNCEMENT PROGRESS');
    console.log('='.repeat(50));
    console.log('Current Index:', game.currentIndex);
    console.log('Announced Numbers:', game.announcedNumbers?.length || 0, '/ 90');
    console.log('Current Number:', game.currentNumber || 'None');
    console.log('Progress:', ((game.announcedNumbers?.length || 0) / 90 * 100).toFixed(1) + '%');
    
    console.log('\n🏆 WINNERS');
    console.log('='.repeat(50));
    console.log('First Line:', game.firstLineWinner ? '✅ Won' : '❌ Not won');
    console.log('Second Line:', game.secondLineWinner ? '✅ Won' : '❌ Not won');
    console.log('Third Line:', game.thirdLineWinner ? '✅ Won' : '❌ Not won');
    console.log('Jaldi:', game.jaldiWinner ? '✅ Won' : '❌ Not won');
    console.log('Housie:', game.housieWinner ? '✅ Won' : '❌ Not won');
    
    if (game.housieWinner) {
      console.log('\n🎯 Housie Winner Details:');
      console.log('  User ID:', game.housieWinner.userId);
      console.log('  Card Number:', game.housieWinner.cardNumber);
      console.log('  Won At:', game.housieWinner.wonAt);
    }
    
    console.log('\n🔍 VALIDATION CHECKS');
    console.log('='.repeat(50));
    const hasHousieWinner = !!(game.housieWinner?.userId && game.housieWinner?.cardNumber);
    const allNumbersAnnounced = game.announcedNumbers?.length >= 90 && game.currentIndex >= 90;
    console.log('Has Valid Housie Winner:', hasHousieWinner ? '✅ YES' : '❌ NO');
    console.log('All Numbers Announced:', allNumbersAnnounced ? '✅ YES' : '❌ NO');
    console.log('Should Game End:', (hasHousieWinner || allNumbersAnnounced) ? '✅ YES' : '❌ NO');
    
    if (game.status === 'COMPLETED' && !hasHousieWinner && !allNumbersAnnounced) {
      console.log('\n⚠️⚠️⚠️ WARNING: Game marked COMPLETED but end conditions not met!');
      console.log('This is the bug! Run resetGame.js to fix.');
    }
    
    console.log('\n' + '='.repeat(50));
    
    await mongoose.disconnect();
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
};

checkGame();
