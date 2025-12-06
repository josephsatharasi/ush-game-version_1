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

  async announceNumber(gameId, number) {
    const game = await LiveGame.findById(gameId);
    if (!game) throw new Error('Game not found');
    if (game.status !== 'LIVE') throw new Error('Game is not live');
    if (game.announcedNumbers.includes(number)) throw new Error('Number already announced');
    if (number < 1 || number > 90) throw new Error('Invalid number');

    game.announcedNumbers.push(number);
    game.currentNumber = number;
    await game.save();

    this.io.to(gameId).emit('number:announced', {
      number,
      timestamp: new Date(),
      announcedNumbers: game.announcedNumbers
    });

    return game;
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
