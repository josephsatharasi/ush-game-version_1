const mongoose = require('mongoose');
const config = require('./config/environment');
const LiveGame = require('./models/LiveGame');

async function checkGame() {
  try {
    await mongoose.connect(config.MONGODB_URI);
    console.log('✅ Connected to MongoDB');
    
    const games = await LiveGame.find().sort({ createdAt: -1 }).limit(5);
    
    console.log(`\n📊 Found ${games.length} games:\n`);
    
    games.forEach((game, index) => {
      console.log(`\n--- Game ${index + 1} ---`);
      console.log(`ID: ${game._id}`);
      console.log(`Code: ${game.gameCode}`);
      console.log(`Status: ${game.status}`);
      console.log(`Current Index: ${game.currentIndex}`);
      console.log(`Announced Numbers: ${game.announcedNumbers.length}`);
      console.log(`Generated Numbers: ${game.generatedNumbers?.length || 0}`);
      console.log(`\nWinners:`);
      console.log(`  First Line: ${JSON.stringify(game.firstLineWinner)}`);
      console.log(`  Second Line: ${JSON.stringify(game.secondLineWinner)}`);
      console.log(`  Third Line: ${JSON.stringify(game.thirdLineWinner)}`);
      console.log(`  Jaldi: ${JSON.stringify(game.jaldiWinner)}`);
      console.log(`  Housie: ${JSON.stringify(game.housieWinner)}`);
      console.log(`\nHousie Winner Check:`);
      console.log(`  Exists: ${!!game.housieWinner}`);
      console.log(`  Has userId: ${!!(game.housieWinner && game.housieWinner.userId)}`);
      console.log(`  Type: ${typeof game.housieWinner}`);
    });
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

checkGame();
