const express = require('express');
const Booking = require('../models/Booking');
const Account = require('../models/Account');
const LiveGame = require('../models/LiveGame');
const Ticket = require('../models/Ticket');
const GameSlotConfig = require('../models/GameSlotConfig');
const { requireRole } = require('../middleware/roleAuth');
const cardGenerator = require('../services/cardGenerator');
const router = express.Router();

let gameEngine;

router.get('/bookings', requireRole(['admin']), async (req, res) => {
  try {
    const bookings = await Booking.find()
      .populate('userId', 'username phone')
      .populate('gameId', 'name scheduledTime')
      .sort({ bookedAt: -1 });

    const formattedBookings = bookings.map(booking => ({
      id: booking._id,
      ticketNumber: booking.ticketNumber,
      cardNumber: booking.cardNumber,
      username: booking.userId?.username || 'Unknown',
      phone: booking.userId?.phone || 'N/A',
      gameName: booking.gameId?.name || 'Unknown Game',
      timeSlot: booking.gameId?.scheduledTime || null,
      status: booking.status,
      bookedAt: booking.bookedAt,
      deliveredAt: booking.deliveredAt
    }));

    res.json({ bookings: formattedBookings });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get('/stats', requireRole(['admin']), async (req, res) => {
  try {
    const totalBookings = await Booking.countDocuments();
    const activeBookings = await Booking.countDocuments({ status: 'DELIVERED' });
    const totalUsers = await Account.countDocuments({ role: 'user' });
    const totalGames = await LiveGame.countDocuments();

    res.json({
      totalBookings,
      activeBookings,
      totalUsers,
      totalGames
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post('/games/:gameId/start', requireRole(['admin']), async (req, res) => {
  try {
    console.log(`\n🚀 START GAME: Request received for game ${req.params.gameId}`);
    if (!gameEngine) gameEngine = req.app.get('gameEngine');
    await gameEngine.startGame(req.params.gameId);
    console.log(`✅ START GAME: Game ${req.params.gameId} started successfully\n`);
    res.json({ message: 'Game started and auto-announcement activated' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});



router.post('/games/:gameId/announce', requireRole(['admin']), async (req, res) => {
  try {
    const { gameId } = req.params;

    const game = await LiveGame.findById(gameId);
    if (!game) {
      return res.status(404).json({ message: 'Game not found' });
    }

    if (game.status !== 'LIVE') {
      return res.status(400).json({ message: 'Game is not live' });
    }

    if (!gameEngine) gameEngine = req.app.get('gameEngine');
    gameEngine.startAutoAnnouncement(gameId);

    res.json({ 
      message: 'Auto-announcement started. Numbers will be announced every 5 seconds until all 90 numbers are announced or housie is won.',
      game: {
        announcedNumbers: game.announcedNumbers,
        currentNumber: game.currentNumber,
        remaining: 90 - game.announcedNumbers.length,
        status: game.status
      }
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post('/games/:gameId/end', requireRole(['admin']), async (req, res) => {
  try {
    if (!gameEngine) gameEngine = req.app.get('gameEngine');
    await gameEngine.endGame(req.params.gameId);
    res.json({ message: 'Game ended' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post('/games/create', requireRole(['admin']), async (req, res) => {
  try {
    const { gameCode, scheduledTime, totalSlots } = req.body;
    console.log(`\n🎮 CREATE GAME: Request received`);
    console.log(`📝 Game Code: ${gameCode}`);
    console.log(`⏰ Scheduled Time: ${scheduledTime}`);
    console.log(`🎫 Total Slots: ${totalSlots || 100}`);
    
    const existingGame = await LiveGame.findOne({ gameCode });
    if (existingGame) {
      console.log(`❌ CREATE GAME: Game code ${gameCode} already exists`);
      return res.status(400).json({ message: 'Game code already exists' });
    }

    // Generate shuffled 1-90 numbers
    const numbers = Array.from({ length: 90 }, (_, i) => i + 1);
    for (let i = numbers.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [numbers[i], numbers[j]] = [numbers[j], numbers[i]];
    }

    const game = new LiveGame({
      gameCode,
      scheduledTime: new Date(scheduledTime),
      totalSlots: totalSlots || 100,
      bookedSlots: 0,
      status: 'SCHEDULED',
      generatedNumbers: numbers,
      currentIndex: 0,
      announcedNumbers: [],
      currentNumber: null
      // Don't set winner fields - let them be undefined
    });

    await game.save();
    console.log(`✅ CREATE GAME: Game ${gameCode} created successfully with ID: ${game._id}`);
    console.log(`📊 CREATE GAME: Status=${game.status}, Numbers=${game.generatedNumbers.length}\n`);

    res.json({ 
      message: `Game created successfully with ${totalSlots || 100} slots`, 
      game
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get('/games/all', async (req, res) => {
  try {
    const games = await LiveGame.find().sort({ scheduledTime: -1 });
    res.json({ games });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get('/games/admin-all', requireRole(['admin']), async (req, res) => {
  try {
    const games = await LiveGame.find().sort({ scheduledTime: -1 });
    res.json({ games });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Configure game slots
router.post('/games/:gameId/configure-slots', requireRole(['admin']), async (req, res) => {
  try {
    const { gameId } = req.params;
    const { maxTicketsPerUser, availableTickets, availableTimeSlots, scheduledDate, selectedWeekDays } = req.body;
    console.log(`\n⚙️ CONFIGURE SLOTS: Game ${gameId}`);
    console.log(`👥 Max Tickets Per User: ${maxTicketsPerUser}`);
    console.log(`🎫 Available Tickets: ${JSON.stringify(availableTickets)}`);
    console.log(`⏰ Time Slots: ${JSON.stringify(availableTimeSlots)}`);
    console.log(`📅 Scheduled Date: ${scheduledDate}`);
    console.log(`📆 Selected Week Days: ${JSON.stringify(selectedWeekDays)}`);

    const game = await LiveGame.findById(gameId);
    if (!game) {
      return res.status(404).json({ message: 'Game not found' });
    }

    // Convert full day names to short format
    const dayMap = {
      'Sunday': 'Sun',
      'Monday': 'Mon',
      'Tuesday': 'Tue',
      'Wednesday': 'Wed',
      'Thursday': 'Thu',
      'Friday': 'Fri',
      'Saturday': 'Sat'
    };
    
    const weekDays = selectedWeekDays && selectedWeekDays.length > 0
      ? selectedWeekDays.map(day => dayMap[day] || day)
      : [dayMap[new Date(scheduledDate).toLocaleDateString('en-US', { weekday: 'long' })]];

    const existingConfig = await GameSlotConfig.findOne({ gameId });
    if (existingConfig) {
      existingConfig.maxTicketsPerUser = maxTicketsPerUser;
      existingConfig.availableTickets = availableTickets || [1, 3, 6];
      existingConfig.availableWeekDays = weekDays;
      existingConfig.availableTimeSlots = availableTimeSlots;
      existingConfig.scheduledDate = new Date(scheduledDate);
      await existingConfig.save();
      return res.json({ message: 'Game slots updated successfully', config: existingConfig });
    }

    const config = new GameSlotConfig({
      gameId,
      gameCode: game.gameCode,
      maxTicketsPerUser,
      availableTickets: availableTickets || [1, 3, 6],
      availableWeekDays: weekDays,
      availableTimeSlots,
      scheduledDate: new Date(scheduledDate)
    });

    await config.save();
    console.log(`✅ CONFIGURE SLOTS: Configuration saved for game ${gameId}\n`);
    res.json({ message: 'Game slots configured successfully', config });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get game slot configuration
router.get('/games/:gameId/slot-config', requireRole(['admin']), async (req, res) => {
  try {
    const config = await GameSlotConfig.findOne({ gameId: req.params.gameId });
    if (!config) {
      return res.status(404).json({ message: 'No slot configuration found' });
    }
    res.json({ config });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Update game slots - Add additional slots to existing game
router.patch('/games/:gameId/update-slots', requireRole(['admin']), async (req, res) => {
  try {
    const { gameId } = req.params;
    const { additionalSlots } = req.body;
    
    console.log(`\n📝 UPDATE SLOTS: Game ${gameId}`);
    console.log(`➕ Additional Slots: ${additionalSlots}`);

    if (!additionalSlots || additionalSlots < 1) {
      return res.status(400).json({ message: 'Additional slots must be at least 1' });
    }

    const game = await LiveGame.findById(gameId);
    if (!game) {
      return res.status(404).json({ message: 'Game not found' });
    }

    const oldTotal = game.totalSlots;
    game.totalSlots += parseInt(additionalSlots);
    await game.save();

    console.log(`✅ UPDATE SLOTS: Updated from ${oldTotal} to ${game.totalSlots} slots\n`);

    res.json({ 
      success: true,
      message: `Successfully added ${additionalSlots} slots`,
      game: {
        gameCode: game.gameCode,
        oldTotal,
        newTotal: game.totalSlots,
        bookedSlots: game.bookedSlots,
        availableSlots: game.totalSlots - game.bookedSlots
      }
    });
  } catch (error) {
    console.error('❌ UPDATE SLOTS ERROR:', error);
    res.status(500).json({ message: error.message });
  }
});

// Add new time slots to existing game configuration
router.post('/games/:gameId/add-time-slots', requireRole(['admin']), async (req, res) => {
  try {
    const { gameId } = req.params;
    const { newTimeSlots } = req.body;
    
    console.log(`\n⏰ ADD TIME SLOTS: Game ${gameId}`);
    console.log(`🕐 New Time Slots: ${JSON.stringify(newTimeSlots)}`);

    if (!newTimeSlots || newTimeSlots.length === 0) {
      return res.status(400).json({ message: 'At least one time slot is required' });
    }

    const config = await GameSlotConfig.findOne({ gameId });
    if (!config) {
      return res.status(404).json({ message: 'Game configuration not found' });
    }

    // Add new time slots, avoiding duplicates
    newTimeSlots.forEach(slot => {
      const exists = config.availableTimeSlots.find(s => s.time === slot.time);
      if (!exists) {
        config.availableTimeSlots.push({
          time: slot.time,
          totalSlots: slot.totalSlots || 20,
          bookedSlots: 0,
          badge: slot.badge || null
        });
      }
    });

    await config.save();
    console.log(`✅ ADD TIME SLOTS: Added ${newTimeSlots.length} new time slots\n`);

    res.json({ 
      success: true,
      message: 'Time slots added successfully',
      config
    });
  } catch (error) {
    console.error('❌ ADD TIME SLOTS ERROR:', error);
    res.status(500).json({ message: error.message });
  }
});

// Remove time slot from game configuration
router.delete('/games/:gameId/time-slots/:timeSlot', requireRole(['admin']), async (req, res) => {
  try {
    const { gameId, timeSlot } = req.params;
    
    console.log(`\n🗑️ REMOVE TIME SLOT: Game ${gameId}, Time: ${timeSlot}`);

    const config = await GameSlotConfig.findOne({ gameId });
    if (!config) {
      return res.status(404).json({ message: 'Game configuration not found' });
    }

    config.availableTimeSlots = config.availableTimeSlots.filter(s => s.time !== decodeURIComponent(timeSlot));
    await config.save();

    console.log(`✅ REMOVE TIME SLOT: Removed time slot ${timeSlot}\n`);

    res.json({ 
      success: true,
      message: 'Time slot removed successfully',
      config
    });
  } catch (error) {
    console.error('❌ REMOVE TIME SLOT ERROR:', error);
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
