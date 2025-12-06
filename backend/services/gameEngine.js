const LiveGame = require('../models/LiveGame');

class GameEngine {
  constructor(io) {
    this.io = io;
    this.activeGames = new Map();
  }

  async startGame(gameId) {
    const game = await LiveGame.findById(gameId);
    if (!game) throw new Error('Game not found');

    game.status = 'LIVE';
    game.startTime = new Date();
    await game.save();

    this.io.to(gameId).emit('game:started', { gameId, startTime: game.startTime });
  }



  async endGame(gameId) {
    const game = await LiveGame.findById(gameId);
    if (game) {
      game.status = 'COMPLETED';
      game.endTime = new Date();
      await game.save();

      this.io.to(gameId).emit('game:ended', {
        gameId,
        winners: {
          firstLine: game.firstLineWinner,
          secondLine: game.secondLineWinner,
          thirdLine: game.thirdLineWinner,
          jaldi: game.jaldiWinner,
          housie: game.housieWinner
        }
      });
    }
  }
}

module.exports = GameEngine;
