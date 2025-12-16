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

    console.log(`🎬 Game ${gameId}: Starting auto-announcement with 5 second interval`);

    const interval = setInterval(async () => {
      console.log(`\n⏰ [${new Date().toISOString()}] Game ${gameId}: Interval tick - checking game state...`);
      try {
        console.log(`📥 Game ${gameId}: Fetching game from database...`);
        const game = await LiveGame.findById(gameId);
        
        if (!game) {
          console.log(`❌ Game ${gameId}: Game not found in database, stopping interval`);
          clearInterval(interval);
          this.activeGames.delete(gameId);
          return;
        }
        
        console.log(`📊 Game ${gameId}: Status=${game.status}, CurrentIndex=${game.currentIndex}, AnnouncedCount=${game.announcedNumbers.length}`);
        
        if (game.status !== 'LIVE') {
          console.log(`❌ Game ${gameId}: Status is ${game.status}, not LIVE. Stopping interval`);
          clearInterval(interval);
          this.activeGames.delete(gameId);
          return;
        }

        // ✅ CRITICAL FIX: Robust validation for housie winner
        const hasHousieWinner = !!(game.housieWinner?.userId && game.housieWinner?.cardNumber);
        const allNumbersAnnounced = game.currentIndex >= 90;
        
        console.log(`🔍 Game ${gameId}: End conditions check:`);
        console.log(`   - Current Index: ${game.currentIndex}/90`);
        console.log(`   - Announced Count: ${game.announcedNumbers.length}`);
        console.log(`   - Housie Winner exists: ${!!game.housieWinner}`);
        console.log(`   - Housie Winner userId: ${game.housieWinner?.userId || 'NONE'}`);
        console.log(`   - Valid Housie Winner: ${hasHousieWinner}`);
        console.log(`   - All Numbers Announced: ${allNumbersAnnounced}`);
        
        // ✅ PERMANENT FIX: ONLY end game if HOUSIE winner found OR all 90 numbers announced
        if (hasHousieWinner || allNumbersAnnounced) {
          console.log(`🏁 Game ${gameId}: ENDING GAME - HousieWinner=${hasHousieWinner}, AllNumbersAnnounced=${allNumbersAnnounced}`);
          clearInterval(interval);
          this.activeGames.delete(gameId);
          await this.endGame(gameId);
          return;
        }
        
        console.log(`✅ Game ${gameId}: Continuing - no end conditions met`);

        if (!game.generatedNumbers || game.generatedNumbers.length === 0) {
          console.log(`❌ Game ${gameId}: No generated numbers found (length=${game.generatedNumbers?.length})`);
          clearInterval(interval);
          this.activeGames.delete(gameId);
          return;
        }

        console.log(`🎯 Game ${gameId}: Getting number at index ${game.currentIndex} from ${game.generatedNumbers.length} generated numbers`);
        const number = game.generatedNumbers[game.currentIndex];
        console.log(`🔢 Game ${gameId}: Number to announce: ${number}`);
        
        // CRITICAL FIX: Only push if not already in array (prevent duplicates)
        if (!game.announcedNumbers.includes(number)) {
          game.announcedNumbers.push(number);
        }
        game.currentNumber = number;
        game.currentIndex += 1;
        
        console.log(`💾 Game ${gameId}: Saving to database - CurrentNumber=${number}, NewIndex=${game.currentIndex}`);
        await game.save();
        console.log(`✅ Game ${gameId}: Saved successfully`);

        console.log(`📡 Game ${gameId}: Emitting number:announced event to clients`);
        this.io.to(gameId).emit('number:announced', {
          number,
          timestamp: new Date(),
          announcedNumbers: game.announcedNumbers,
          remaining: 90 - game.announcedNumbers.length
        });

        console.log(`🎲 Game ${gameId}: ✅ Successfully announced number ${number} (${game.announcedNumbers.length}/90) - Remaining: ${90 - game.announcedNumbers.length}`);
      } catch (error) {
        console.error(`❌ Auto-announcement error for game ${gameId}:`, error.message);
        console.error(`❌ Stack trace:`, error.stack);
      }
    }, 5000);

    this.activeGames.set(gameId, interval);
    console.log(`✅ Game ${gameId}: Auto-announcement interval created and stored in activeGames Map`);
    console.log(`📋 Game ${gameId}: Active games count: ${this.activeGames.size}`);
  }

  async endGame(gameId) {
    console.log(`\n🏁🏁🏁 Game ${gameId}: endGame() called 🏁🏁🏁`);
    console.log(`Stack trace to see who called endGame:`);
    console.trace();
    
    const interval = this.activeGames.get(gameId);
    if (interval) {
      console.log(`🚫 Game ${gameId}: Clearing announcement interval`);
      clearInterval(interval);
      this.activeGames.delete(gameId);
      console.log(`✅ Game ${gameId}: Interval cleared and removed from activeGames`);
    } else {
      console.log(`⚠️ Game ${gameId}: No active interval found`);
    }

    console.log(`📥 Game ${gameId}: Fetching game from database to validate end conditions`);
    const game = await LiveGame.findById(gameId);
    if (!game) {
      console.log(`❌ Game ${gameId}: Game not found in database`);
      return;
    }
    
    // ✅ CRITICAL FIX: Validate that game should actually end
    const hasHousieWinner = !!(game.housieWinner?.userId && game.housieWinner?.cardNumber);
    const allNumbersAnnounced = game.announcedNumbers.length >= 90 && game.currentIndex >= 90;
    
    console.log(`📊 Game ${gameId}: Final validation before ending:`);
    console.log(`  - Announced: ${game.announcedNumbers.length}/90`);
    console.log(`  - CurrentIndex: ${game.currentIndex}`);
    console.log(`  - Housie Winner: ${hasHousieWinner}`);
    console.log(`  - Housie Winner UserId: ${game.housieWinner?.userId}`);
    console.log(`  - Housie Winner CardNumber: ${game.housieWinner?.cardNumber}`);
    console.log(`  - All Numbers Announced: ${allNumbersAnnounced}`);
    
    if (!hasHousieWinner && !allNumbersAnnounced) {
      console.log(`⚠️⚠️⚠️ Game ${gameId}: REFUSING TO END - No valid end condition met!`);
      console.log(`⚠️ Only ${game.announcedNumbers.length}/90 numbers announced and no valid housie winner`);
      console.log(`Game will NOT be marked as COMPLETED`);
      return;
    }
    
    console.log(`✅ Game ${gameId}: Valid end condition met, proceeding to complete`);
    game.status = 'COMPLETED';
    game.endTime = new Date();
    await game.save();
    console.log(`✅ Game ${gameId}: Marked as COMPLETED at ${game.endTime}`);

    console.log(`📡 Game ${gameId}: Emitting game:ended event to clients`);
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
    console.log(`✅ Game ${gameId}: Game ended successfully`);
  }
}

module.exports = GameEngine;
