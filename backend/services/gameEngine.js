const LiveGame = require('../models/LiveGame');

class GameEngine {
  constructor(io) {
    this.io = io;
    this.activeGames = new Map();
  }

  async startGame(gameId) {
    const game = await LiveGame.findById(gameId);
    if (!game) throw new Error('Game not found');

    // Generate shuffled 1-90 numbers if not already generated
    if (!game.generatedNumbers || game.generatedNumbers.length === 0) {
      const numbers = Array.from({ length: 90 }, (_, i) => i + 1);
      for (let i = numbers.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [numbers[i], numbers[j]] = [numbers[j], numbers[i]];
      }
      game.generatedNumbers = numbers;
      game.currentIndex = 0;
    }

    game.status = 'LIVE';
    game.startTime = new Date();
    await game.save();

    this.io.to(gameId).emit('game:started', { gameId, startTime: game.startTime });
    
    this.startAutoAnnouncement(gameId);
  }

  startAutoAnnouncement(gameId) {
    if (this.activeGames.has(gameId)) return;

    const interval = setInterval(async () => {
      try {
        const game = await LiveGame.findById(gameId);
        if (!game || game.status !== 'LIVE') {
          clearInterval(interval);
          this.activeGames.delete(gameId);
          return;
        }

        if (game.housieWinner || game.currentIndex >= 90) {
          clearInterval(interval);
          this.activeGames.delete(gameId);
          await this.endGame(gameId);
          return;
        }

        const number = game.generatedNumbers[game.currentIndex];
        game.announcedNumbers.push(number);
        game.currentNumber = number;
        game.currentIndex += 1;
        await game.save();

        this.io.to(gameId).emit('number:announced', {
          number,
          timestamp: new Date(),
          announcedNumbers: game.announcedNumbers,
          remaining: 90 - game.announcedNumbers.length
        });

        console.log(`🎲 Game ${gameId}: Announced number ${number} (${game.announcedNumbers.length}/90)`);
      } catch (error) {
        console.error('Auto-announcement error:', error);
      }
    }, 5000);

    this.activeGames.set(gameId, interval);
  }

  async endGame(gameId) {
    const interval = this.activeGames.get(gameId);
    if (interval) {
      clearInterval(interval);
      this.activeGames.delete(gameId);
    }

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
