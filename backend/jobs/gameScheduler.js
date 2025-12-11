const cron = require('node-cron');
const LiveGame = require('../models/LiveGame');

let gameEngine;

const checkAndStartGames = async () => {
  try {
    const now = new Date();
    const games = await LiveGame.find({
      status: 'SCHEDULED',
      scheduledTime: { $lte: now }
    });

    for (const game of games) {
      if (gameEngine) {
        await gameEngine.startGame(game._id.toString());
        console.log(`✅ Auto-started game: ${game.gameCode}`);
      }
    }
  } catch (error) {
    console.error('❌ Game scheduler error:', error.message);
  }
};

const scheduleGameStarter = (engine) => {
  gameEngine = engine;
  cron.schedule('* * * * *', checkAndStartGames);
  console.log('✅ Game auto-start scheduler initialized');
};

module.exports = { scheduleGameStarter };
