const express = require('express');
const LiveGame = require('../models/LiveGame');
const Booking = require('../models/Booking');
const GameSlotConfig = require('../models/GameSlotConfig');
const auth = require('../middleware/auth');
const cardGenerator = require('../services/cardGenerator');
const winValidator = require('../services/winValidator');
const couponGenerator = require('../services/couponGenerator');
const router = express.Router();

// Get next live game
router.get('/live', async (req, res) => {
  try {
    const game = await LiveGame.findOne({
      status: { $in: ['SCHEDULED', 'COUNTDOWN'] }
    }).sort({ scheduledTime: 1 });

    if (!game) {
      return res.status(404).json({ message: 'No upcoming games' });
    }

    res.json({ game });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get available games for users
router.get('/available', async (req, res) => {
  try {
    const games = await LiveGame.find({
      status: { $in: ['SCHEDULED', 'LIVE'] }
    }).sort({ scheduledTime: 1 });
    
    res.json({ games });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get game slot configuration
router.get('/:gameId/slot-config', async (req, res) => {
  try {
    const config = await GameSlotConfig.findOne({ gameId: req.params.gameId, isActive: true });
    if (!config) {
      return res.status(404).json({ message: 'No slot configuration found' });
    }
    res.json({ config });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Book ticket
router.post('/book', auth, async (req, res) => {
  try {
    const { gameId, ticketCount, scheduledDate, weekDay, timeSlot } = req.body;
    const userId = req.userId;

    // Validate input
    if (!ticketCount || ticketCount < 1) {
      return res.status(400).json({ message: 'Ticket count must be at least 1' });
    }

    // Validate weekDay and timeSlot
    const validWeekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const validTimeSlots = ['10:00 AM', '11:00 AM', '1:00 PM', '2:00 PM', '3:00 PM', '4:00 PM', '5:00 PM', '6:00 PM'];
    
    if (!validWeekDays.includes(weekDay)) {
      return res.status(400).json({ message: 'Invalid week day' });
    }
    
    if (!validTimeSlots.includes(timeSlot)) {
      return res.status(400).json({ message: 'Invalid time slot' });
    }

    const game = await LiveGame.findOne({ $or: [{ _id: gameId }, { gameCode: gameId }] });
    if (!game) {
      return res.status(404).json({ message: 'Game not found' });
    }

    if (game.bookedSlots + ticketCount > game.totalSlots) {
      return res.status(400).json({ message: 'Not enough slots available' });
    }

    // Check if user already has a booking for this specific ticket count, weekDay, and timeSlot
    const existingBooking = await Booking.findOne({ 
      userId, 
      gameId: game._id,
      ticketCount,
      weekDay, 
      timeSlot 
    });
    
    if (existingBooking) {
      return res.status(400).json({ 
        message: `You have already booked ${ticketCount} ticket(s) for ${weekDay} at ${timeSlot}. Please choose a different ticket count or time slot.` 
      });
    }

    // Generate multiple card numbers, ticket numbers, and random numbers for the booking
    const cardNumbers = [];
    const ticketNumbers = [];
    const generatedNumbers = [];
    
    for (let i = 0; i < ticketCount; i++) {
      cardNumbers.push(cardGenerator.generateCardNumber());
      ticketNumbers.push(`${game.gameCode}-${String(game.bookedSlots + i + 1).padStart(4, '0')}`);
      generatedNumbers.push(cardGenerator.generateTicketNumbers());
    }

    const booking = new Booking({
      userId,
      gameId: game._id,
      gameCode: game.gameCode,
      gameType: 'LIVE',
      ticketCount,
      scheduledDate: new Date(scheduledDate),
      weekDay,
      timeSlot,
      cardNumbers,
      ticketNumbers,
      generatedNumbers,
      status: 'DELIVERED'
    });

    await booking.save();

    // Update game booked slots
    game.bookedSlots += ticketCount;
    await game.save();

    res.json({ 
      success: true,
      booking: { 
        _id: booking._id, 
        cardNumbers, 
        ticketNumbers,
        generatedNumbers,
        gameCode: game.gameCode,
        ticketCount,
        scheduledDate,
        weekDay,
        timeSlot,
        status: 'DELIVERED',
        scheduledTime: game.scheduledTime
      } 
    });
  } catch (error) {
    if (error.code === 11000) {
      return res.status(400).json({ 
        message: 'You have already booked this time slot for this day. Please choose a different time slot.' 
      });
    }
    res.status(500).json({ message: error.message });
  }
});

// Get all bookings (Admin)
router.get('/bookings', auth, async (req, res) => {
  try {
    const bookings = await Booking.find()
      .populate('userId', 'username email')
      .populate('gameId', 'gameCode status')
      .sort({ bookedAt: -1 });

    const formattedBookings = bookings.map(b => ({
      _id: b._id,
      username: b.userId?.username || 'Unknown',
      email: b.userId?.email,
      phone: b.userId?.phone,
      gameCode: b.gameCode,
      gameType: b.gameType,
      ticketCount: b.ticketCount,
      scheduledDate: b.scheduledDate,
      weekDay: b.weekDay,
      timeSlot: b.timeSlot,
      cardNumbers: b.cardNumbers,
      ticketNumbers: b.ticketNumbers,
      generatedNumbers: b.generatedNumbers,
      status: b.status,
      bookedAt: b.bookedAt
    }));

    res.json({ bookings: formattedBookings });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get user's bookings
router.get('/my-bookings', auth, async (req, res) => {
  try {
    const userId = req.userId;
    const bookings = await Booking.find({ userId })
      .populate('gameId', 'gameCode status')
      .sort({ bookedAt: -1 });

    res.json({ bookings });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get countdown
router.get('/:gameId/countdown', auth, async (req, res) => {
  try {
    const { gameId } = req.params;
    const userId = req.userId;

    const game = await LiveGame.findById(gameId);
    if (!game) {
      return res.status(404).json({ message: 'Game not found' });
    }

    const booking = await Booking.findOne({ userId, gameId });
    const timeRemaining = Math.max(0, Math.floor((game.scheduledTime - Date.now()) / 1000));

    res.json({
      timeRemaining,
      status: game.status,
      booking: booking ? { 
        cardNumbers: booking.cardNumbers, 
        ticketCount: booking.ticketCount,
        status: booking.status 
      } : null
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Verify card number
router.post('/:gameId/verify-card', auth, async (req, res) => {
  try {
    const { gameId } = req.params;
    const { cardNumber } = req.body;
    const userId = req.userId;

    const booking = await Booking.findOne({ 
      userId, 
      gameId, 
      cardNumbers: { $in: [cardNumber] } 
    });

    if (!booking) {
      return res.status(400).json({ valid: false, message: 'Invalid card number' });
    }

    res.json({ valid: true, message: 'Card verified' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});



// Auto-generate next number
router.post('/:gameId/next-number', auth, async (req, res) => {
  try {
    const { gameId } = req.params;

    const game = await LiveGame.findById(gameId);
    if (!game) {
      return res.status(404).json({ message: 'Game not found' });
    }

    if (game.status !== 'LIVE') {
      return res.status(400).json({ message: 'Game is not live' });
    }

    if (game.announcedNumbers.length >= 90) {
      return res.status(400).json({ message: 'All numbers announced' });
    }

    const availableNumbers = [];
    for (let i = 1; i <= 90; i++) {
      if (!game.announcedNumbers.includes(i)) {
        availableNumbers.push(i);
      }
    }

    const randomIndex = Math.floor(Math.random() * availableNumbers.length);
    const nextNumber = availableNumbers[randomIndex];

    game.announcedNumbers.push(nextNumber);
    game.currentNumber = nextNumber;
    await game.save();

    const io = req.app.get('io');
    if (io) {
      io.to(gameId).emit('number:announced', {
        number: nextNumber,
        timestamp: new Date(),
        announcedNumbers: game.announcedNumbers
      });
    }

    res.json({
      number: nextNumber,
      announcedNumbers: game.announcedNumbers,
      remaining: 90 - game.announcedNumbers.length
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get game status
router.get('/:gameId/status', auth, async (req, res) => {
  try {
    const { gameId } = req.params;

    const game = await LiveGame.findById(gameId);
    if (!game) {
      return res.status(404).json({ message: 'Game not found' });
    }

    res.json({
      status: game.status,
      currentNumber: game.currentNumber,
      announcedNumbers: game.announcedNumbers,
      firstLineWinner: game.firstLineWinner,
      secondLineWinner: game.secondLineWinner,
      thirdLineWinner: game.thirdLineWinner,
      jaldiWinner: game.jaldiWinner,
      housieWinner: game.housieWinner
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Claim win
router.post('/:gameId/claim-win', auth, async (req, res) => {
  try {
    const { gameId } = req.params;
    const { winType } = req.body;
    const userId = req.userId;

    const validation = await winValidator.validateWin(gameId, userId, winType);
    if (!validation.valid) {
      return res.status(400).json({ valid: false, message: validation.reason });
    }

    const booking = await Booking.findOne({ userId, gameId });
    if (!booking) {
      return res.status(400).json({ valid: false, message: 'No booking found' });
    }

    const coupon = await couponGenerator.createCoupon(userId, gameId, winType);

    const game = await LiveGame.findById(gameId);
    const winTypeMap = {
      'FIRST_LINE': 'firstLineWinner',
      'SECOND_LINE': 'secondLineWinner',
      'THIRD_LINE': 'thirdLineWinner',
      'JALDI': 'jaldiWinner',
      'HOUSIE': 'housieWinner'
    };

    const winnerField = winTypeMap[winType];
    if (winnerField) {
      game[winnerField] = {
        userId,
        cardNumber: booking.cardNumbers[0], // Use first card number for winner display
        wonAt: new Date(),
        couponCode: coupon.code
      };
    }
    await game.save();

    res.json({
      valid: true,
      couponId: coupon._id,
      message: 'Congratulations! You won!'
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
