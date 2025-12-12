const LiveGame = require('../models/LiveGame');

class GameEngine {
  constructor(io) {
    this.io = io;
    this.activeGames = new Map();
  }

  async startGame(gameId) {
    console.log(`🚀 Starting game ${gameId}`);
    const game = await LiveGame.findById(gameId);
    if (!game) throw new Error('Game not found');

    // Generate shuffled 1-90 numbers if not already generated
    if (!game.generatedNumbers || game.generatedNumbers.length === 0) {
      console.log(`🎲 Generating 90 random numbers for game ${gameId}`);
      const numbers = Array.from({ length: 90 }, (_, i) => i + 1);
      for (let i = numbers.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [numbers[i], numbers[j]] = [numbers[j], numbers[i]];
      }
      game.generatedNumbers = numbers;
      game.currentIndex = 0;
      console.log(`✅ Generated numbers: ${numbers.slice(0, 5).join(', ')}...`);
    } else {
      console.log(`✅ Game ${gameId} already has ${game.generatedNumbers.length} generated numbers`);
    }

    game.status = 'LIVE';
    game.startTime = new Date();
    await game.save();
    console.log(`✅ Game ${gameId} status set to LIVE`);

    this.io.to(gameId).emit('game:started', { gameId, startTime: game.startTime });
    console.log(`📡 Emitted game:started event for game ${gameId}`);
    
    this.startAutoAnnouncement(gameId);
  }

  async ensureAnnouncementRunning(gameId) {
    const game = await LiveGame.findById(gameId);
    if (game && game.status === 'LIVE' && !this.activeGames.has(gameId)) {
      console.log(`🔄 Restarting announcement for game ${gameId} after server restart`);
      this.startAutoAnnouncement(gameId);
    }
  }

  startAutoAnnouncement(gameId) {
    if (this.activeGames.has(gameId)) {
      console.log(`⚠️ Game ${gameId}: Auto-announcement already running`);
      return;
    }

    console.log(`🎬 Game ${gameId}: Starting auto-announcement`);

    const interval = setInterval(async () => {
      try {
        const game = await LiveGame.findById(gameId);
        if (!game || game.status !== 'LIVE') {
          console.log(`❌ Game ${gameId}: Not found or not LIVE, stopping`);
          clearInterval(interval);
          this.activeGames.delete(gameId);
          return;
        }

        if (game.housieWinner || game.currentIndex >= 90) {
          console.log(`🏁 Game ${gameId}: Game ended (housie winner or all numbers announced)`);
          clearInterval(interval);
          this.activeGames.delete(gameId);
          await this.endGame(gameId);
          return;
        }

        if (!game.generatedNumbers || game.generatedNumbers.length === 0) {
          console.log(`❌ Game ${gameId}: No generated numbers found`);
          clearInterval(interval);
          this.activeGames.delete(gameId);
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
        console.error(`❌ Auto-announcement error for game ${gameId}:`, error);
      }
    }, 5000);

    this.activeGames.set(gameId, interval);
    console.log(`✅ Game ${gameId}: Auto-announcement interval set`);
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
