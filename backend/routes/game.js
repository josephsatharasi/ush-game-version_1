const express = require('express');
const LiveGame = require('../models/LiveGame');
const Booking = require('../models/Booking');
const GameSlotConfig = require('../models/GameSlotConfig');
const auth = require('../middleware/auth');
const cardGenerator = require('../services/cardGenerator');
const winValidator = require('../services/winValidator');
const couponGenerator = require('../services/couponGenerator');
const autoCouponGenerator = require('../services/autoCouponGenerator');
const TicketCleanupService = require('../services/ticketCleanup');
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
    const { gameId, ticketCount, scheduledDate, timeSlot } = req.body;
    const userId = req.userId;
    console.log(`\n🎫 BOOK TICKET: Request received`);
    console.log(`👤 User ID: ${userId}`);
    console.log(`🎮 Game ID: ${gameId}`);
    console.log(`🎫 Ticket Count: ${ticketCount}`);
    console.log(`📅 Scheduled Date: ${scheduledDate}`);
    console.log(`⏰ Time Slot: ${timeSlot}`);

    // Validate input
    if (!ticketCount || ticketCount < 1) {
      console.log(`❌ BOOK TICKET: Invalid ticket count`);
      return res.status(400).json({ message: 'Ticket count must be at least 1' });
    }

    // Auto-calculate weekDay from scheduledDate
    const date = new Date(scheduledDate);
    const weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const weekDay = weekDays[date.getDay()];

    // Validate timeSlot
    const validTimeSlots = ['10:00 AM', '11:00 AM', '1:00 PM', '2:00 PM', '3:00 PM', '4:00 PM', '5:00 PM', '6:00 PM'];
    
    if (!validTimeSlots.includes(timeSlot)) {
      return res.status(400).json({ message: 'Invalid time slot' });
    }

    const game = await LiveGame.findOne({ $or: [{ _id: gameId }, { gameCode: gameId }] });
    if (!game) {
      console.log(`❌ BOOK TICKET: Game not found`);
      return res.status(404).json({ message: 'Game not found' });
    }
    console.log(`✅ BOOK TICKET: Game found - ${game.gameCode}, Status: ${game.status}`);

    if (game.bookedSlots + ticketCount > game.totalSlots) {
      return res.status(400).json({ message: 'Not enough slots available' });
    }

    // Check if user already booked this specific time slot on this specific date
    const bookingDate = new Date(scheduledDate);
    bookingDate.setHours(0, 0, 0, 0);
    
    const nextDay = new Date(bookingDate);
    nextDay.setDate(nextDay.getDate() + 1);
    
    const existingBooking = await Booking.findOne({ 
      userId, 
      gameId: game._id,
      scheduledDate: {
        $gte: bookingDate,
        $lt: nextDay
      },
      timeSlot 
    });
    
    if (existingBooking) {
      return res.status(400).json({ 
        message: `You have already booked ${timeSlot} on this date. Please choose a different time slot.` 
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
    console.log(`✅ BOOK TICKET: Booking saved with ID: ${booking._id}`);
    console.log(`🎫 BOOK TICKET: Ticket Numbers: ${ticketNumbers.join(', ')}`);
    console.log(`🃏 BOOK TICKET: Card Numbers: ${cardNumbers.join(', ')}`);

    // Update game booked slots
    game.bookedSlots += ticketCount;
    await game.save();
    console.log(`✅ BOOK TICKET: Game ${game.gameCode} updated - Booked Slots: ${game.bookedSlots}/${game.totalSlots}\n`);

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
    console.log(`❌ BOOK TICKET: Error - ${error.message}\n`);
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

// Get user's bookings (only active ones)
router.get('/my-bookings', auth, async (req, res) => {
  try {
    const userId = req.userId;
    const bookings = await Booking.find({ userId })
      .populate('gameId', 'gameCode status')
      .sort({ bookedAt: -1 });

    // Filter out expired bookings
    const activeBookings = await TicketCleanupService.filterActiveBookings(bookings);

    res.json({ bookings: activeBookings });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get specific booking by ID
router.get('/booking/:bookingId', auth, async (req, res) => {
  try {
    const { bookingId } = req.params;
    const userId = req.userId;

    const booking = await Booking.findOne({ _id: bookingId, userId })
      .populate('gameId', 'gameCode status scheduledTime');

    if (!booking) {
      return res.status(404).json({ message: 'Booking not found' });
    }

    res.json({
      success: true,
      booking: {
        _id: booking._id,
        cardNumbers: booking.cardNumbers,
        ticketNumbers: booking.ticketNumbers,
        generatedNumbers: booking.generatedNumbers,
        gameCode: booking.gameCode,
        ticketCount: booking.ticketCount,
        scheduledDate: booking.scheduledDate,
        weekDay: booking.weekDay,
        timeSlot: booking.timeSlot,
        status: booking.status,
        scheduledTime: booking.gameId?.scheduledTime
      }
    });
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



// Get announced numbers
router.get('/:gameId/announced-numbers', auth, async (req, res) => {
  try {
    const { gameId } = req.params;

    const game = await LiveGame.findById(gameId);
    if (!game) {
      return res.status(404).json({ message: 'Game not found' });
    }

    const gameEngine = req.app.get('gameEngine');
    if (gameEngine && game.status === 'LIVE') {
      await gameEngine.ensureAnnouncementRunning(gameId);
    }

    res.json({
      announcedNumbers: game.announcedNumbers,
      currentNumber: game.currentNumber,
      remaining: 90 - game.announcedNumbers.length
    });
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

    if (game.currentIndex >= 90) {
      return res.status(400).json({ message: 'All numbers announced' });
    }

    const nextNumber = game.generatedNumbers[game.currentIndex];
    game.announcedNumbers.push(nextNumber);
    game.currentNumber = nextNumber;
    game.currentIndex += 1;
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

// Get announced numbers
router.get('/:gameId/announced-numbers', auth, async (req, res) => {
  try {
    const { gameId } = req.params;

    const game = await LiveGame.findById(gameId);
    if (!game) {
      return res.status(404).json({ message: 'Game not found' });
    }

    res.json({
      announcedNumbers: game.announcedNumbers,
      currentNumber: game.currentNumber,
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

    // Ensure announcement is running if game is LIVE
    const gameEngine = req.app.get('gameEngine');
    if (gameEngine && game.status === 'LIVE') {
      await gameEngine.ensureAnnouncementRunning(gameId);
    }

    // Log status for debugging
    console.log(`📊 STATUS API: Game ${gameId} - Status: ${game.status}, Announced: ${game.announcedNumbers.length}/90`);
    console.log(`📊 STATUS API: Housie Winner: ${game.housieWinner?.userId ? 'YES' : 'NO'}`);

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

// Claim win (without coupon generation)
router.post('/:gameId/claim-win', auth, async (req, res) => {
  try {
    const { gameId } = req.params;
    const { winType, cardNumber } = req.body;
    const userId = req.userId;

    console.log(`\n🏆🏆🏆 CLAIM-WIN ENDPOINT CALLED 🏆🏆🏆`);
    console.log(`Timestamp: ${new Date().toISOString()}`);
    console.log(`Game ID: ${gameId}`);
    console.log(`User ID: ${userId}`);
    console.log(`Win Type: ${winType}`);
    console.log(`Card Number: ${cardNumber}`);
    console.log(`User-Agent: ${req.headers['user-agent']}`);
    console.log(`IP: ${req.ip}`);
    console.trace('Call stack:');

    if (!cardNumber) {
      return res.status(400).json({ valid: false, message: 'Card number is required' });
    }

    const validation = await winValidator.validateWin(gameId, userId, winType, cardNumber);
    if (!validation.valid) {
      return res.status(400).json({ valid: false, message: validation.reason });
    }

    const booking = await Booking.findOne({ userId, gameId }).populate('userId', 'username');
    if (!booking) {
      return res.status(400).json({ valid: false, message: 'No booking found' });
    }

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
      console.log(`🎯 Setting ${winnerField} for game ${gameId}`);
      
      // Auto-generate coupon code
      const couponCode = autoCouponGenerator.generateCoupon(winType);
      const couponValue = autoCouponGenerator.getCouponValue(winType);
      
      const username = booking.userId?.username || 'Unknown';
      
      game[winnerField] = {
        userId,
        username: username,
        cardNumber: cardNumber,
        wonAt: new Date(),
        couponCode: couponCode,
        couponValue: couponValue
      };
      console.log(`🎟️ Auto-generated coupon: ${couponCode} (Value: ₹${couponValue})`);
      console.log(`👤 Winner username: ${username}`);
      console.log(`💾 Saving game with winner field: ${winnerField}`);
    }
    await game.save();
    console.log(`✅ Game saved successfully. Status: ${game.status}`);
    console.log(`🏁 END OF CLAIM-WIN PROCESSING\n`);

    console.log(`📤 Sending success response to client\n`);
    res.json({
      valid: true,
      message: 'Congratulations! You won!',
      couponCode: game[winnerField]?.couponCode,
      couponValue: game[winnerField]?.couponValue
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get winners list for a game (Admin)
router.get('/:gameId/winners', auth, async (req, res) => {
  try {
    const { gameId } = req.params;

    const game = await LiveGame.findById(gameId);
    if (!game) {
      return res.status(404).json({ message: 'Game not found' });
    }

    const winners = [];

    const winTypes = [
      { type: 'FIRST_LINE', field: 'firstLineWinner' },
      { type: 'SECOND_LINE', field: 'secondLineWinner' },
      { type: 'THIRD_LINE', field: 'thirdLineWinner' },
      { type: 'JALDI', field: 'jaldiWinner' },
      { type: 'HOUSIE', field: 'housieWinner' }
    ];

    for (const { type, field } of winTypes) {
      if (game[field] && game[field].userId) {
        const booking = await Booking.findOne({ 
          userId: game[field].userId, 
          gameId 
        }).populate('userId', 'username email phone');

        winners.push({
          winType: type,
          userId: game[field].userId,
          username: booking?.userId?.username || 'Unknown',
          email: booking?.userId?.email,
          phone: booking?.userId?.phone,
          cardNumber: game[field].cardNumber,
          wonAt: game[field].wonAt,
          couponCode: game[field].couponCode,
          hasCoupon: !!game[field].couponCode
        });
      }
    }

    res.json({ 
      gameCode: game.gameCode,
      gameStatus: game.status,
      winners 
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Admin assigns coupon code to winner
router.post('/:gameId/assign-coupon', auth, async (req, res) => {
  try {
    const { gameId } = req.params;
    const { winType, couponCode } = req.body;

    if (!winType || !couponCode) {
      return res.status(400).json({ message: 'winType and couponCode are required' });
    }

    const game = await LiveGame.findById(gameId);
    if (!game) {
      return res.status(404).json({ message: 'Game not found' });
    }

    const winTypeMap = {
      'FIRST_LINE': 'firstLineWinner',
      'SECOND_LINE': 'secondLineWinner',
      'THIRD_LINE': 'thirdLineWinner',
      'JALDI': 'jaldiWinner',
      'HOUSIE': 'housieWinner'
    };

    const winnerField = winTypeMap[winType];
    if (!winnerField || !game[winnerField]) {
      return res.status(404).json({ message: 'Winner not found for this win type' });
    }

    game[winnerField].couponCode = couponCode;
    await game.save();

    res.json({ 
      success: true,
      message: 'Coupon code assigned successfully',
      winner: game[winnerField]
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get user's coupon codes
router.get('/my-coupons', auth, async (req, res) => {
  try {
    const userId = req.userId;

    const games = await LiveGame.find({
      $or: [
        { 'firstLineWinner.userId': userId },
        { 'secondLineWinner.userId': userId },
        { 'thirdLineWinner.userId': userId },
        { 'jaldiWinner.userId': userId },
        { 'housieWinner.userId': userId }
      ]
    });

    const coupons = [];

    games.forEach(game => {
      const winTypes = [
        { type: 'FIRST_LINE', field: 'firstLineWinner' },
        { type: 'SECOND_LINE', field: 'secondLineWinner' },
        { type: 'THIRD_LINE', field: 'thirdLineWinner' },
        { type: 'JALDI', field: 'jaldiWinner' },
        { type: 'HOUSIE', field: 'housieWinner' }
      ];

      winTypes.forEach(({ type, field }) => {
        if (game[field] && game[field].userId.toString() === userId.toString()) {
          coupons.push({
            gameCode: game.gameCode,
            gameId: game._id,
            winType: type,
            cardNumber: game[field].cardNumber,
            wonAt: game[field].wonAt,
            couponCode: game[field].couponCode,
            couponValue: game[field].couponValue || 0,
            status: game[field].couponCode ? 'ASSIGNED' : 'PENDING'
          });
        }
      });
    });

    res.json({ coupons });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
