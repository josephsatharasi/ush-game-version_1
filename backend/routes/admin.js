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
    if (!gameEngine) gameEngine = req.app.get('gameEngine');
    await gameEngine.startGame(req.params.gameId);
    res.json({ message: 'Game started' });
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
    
    const existingGame = await LiveGame.findOne({ gameCode });
    if (existingGame) {
      return res.status(400).json({ message: 'Game code already exists' });
    }

    const game = new LiveGame({
      gameCode,
      scheduledTime: new Date(scheduledTime),
      totalSlots: totalSlots || 100,
      bookedSlots: 0,
      status: 'SCHEDULED'
    });

    await game.save();

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
    const { maxTicketsPerUser, availableTickets, availableWeekDays, availableTimeSlots, scheduledDate } = req.body;

    const game = await LiveGame.findById(gameId);
    if (!game) {
      return res.status(404).json({ message: 'Game not found' });
    }

    const existingConfig = await GameSlotConfig.findOne({ gameId });
    if (existingConfig) {
      existingConfig.maxTicketsPerUser = maxTicketsPerUser;
      existingConfig.availableTickets = availableTickets || [1, 3, 6];
      existingConfig.availableWeekDays = availableWeekDays;
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
      availableWeekDays,
      availableTimeSlots,
      scheduledDate: new Date(scheduledDate)
    });

    await config.save();
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

module.exports = router;
