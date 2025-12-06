const express = require('express');
const LiveGame = require('../models/LiveGame');
const Booking = require('../models/Booking');
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

// Book ticket
router.post('/book', auth, async (req, res) => {
  try {
    const { gameId } = req.body;
    const userId = req.userId;

    const game = await LiveGame.findOne({ $or: [{ _id: gameId }, { gameCode: gameId }] });
    if (!game) {
      return res.status(404).json({ message: 'Game not found' });
    }

    if (game.bookedSlots >= game.totalSlots) {
      return res.status(400).json({ message: 'Game is full' });
    }

    const existingBooking = await Booking.findOne({ userId, gameId: game._id });
    if (existingBooking) {
      return res.status(400).json({ message: 'Already booked' });
    }

    const cardNumber = cardGenerator.generateCardNumber();
    const ticketNumber = cardGenerator.generateCardNumber();

    const booking = new Booking({
      userId,
      gameId: game._id,
      cardNumber,
      ticketNumber,
      status: 'PENDING'
    });

    await booking.save();

    game.bookedSlots += 1;
    await game.save();

    // Auto-deliver after 2 seconds
    setTimeout(async () => {
      booking.status = 'DELIVERED';
      booking.deliveredAt = new Date();
      await booking.save();
    }, 2000);

    res.json({ booking: { _id: booking._id, cardNumber, ticketNumber, status: 'PENDING' } });
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
      booking: booking ? { cardNumber: booking.cardNumber, status: booking.status } : null
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

    const booking = await Booking.findOne({ userId, gameId, cardNumber });

    if (!booking) {
      return res.status(400).json({ valid: false, message: 'Invalid card number' });
    }

    res.json({ valid: true, message: 'Card verified' });
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
        cardNumber: booking.cardNumber,
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
