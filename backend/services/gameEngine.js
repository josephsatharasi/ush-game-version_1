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

        if (game.housieWinner || game.announcedNumbers.length >= 90) {
          clearInterval(interval);
          this.activeGames.delete(gameId);
          await this.endGame(gameId);
          return;
        }

        const availableNumbers = [];
        for (let i = 1; i <= 90; i++) {
          if (!game.announcedNumbers.includes(i)) {
            availableNumbers.push(i);
          }
        }

        if (availableNumbers.length === 0) {
          clearInterval(interval);
          this.activeGames.delete(gameId);
          await this.endGame(gameId);
          return;
        }

        const randomIndex = Math.floor(Math.random() * availableNumbers.length);
        const number = availableNumbers[randomIndex];

        game.announcedNumbers.push(number);
        game.currentNumber = number;
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
