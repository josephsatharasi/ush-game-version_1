const LiveGame = require('../models/LiveGame');
const Booking = require('../models/Booking');

class WinValidator {
  async validateWin(gameId, userId, winType, cardNumber) {
    const game = await LiveGame.findById(gameId);
    if (!game) throw new Error('Game not found');

    const winTypeMap = {
      'FIRST_LINE': 'firstLineWinner',
      'SECOND_LINE': 'secondLineWinner',
      'THIRD_LINE': 'thirdLineWinner',
      'JALDI': 'jaldiWinner',
      'HOUSIE': 'housieWinner'
    };

    const winnerField = winTypeMap[winType];
    if (!winnerField) {
      return { valid: false, reason: 'Invalid win type' };
    }

    if (game[winnerField] && game[winnerField].userId) {
      return { valid: false, reason: `${winType} already claimed` };
    }

    // Get user's booking and verify numbers
    const booking = await Booking.findOne({ userId, gameId });
    if (!booking) {
      return { valid: false, reason: 'No booking found' };
    }

    // Find the ticket index for the cardNumber
    const ticketIndex = booking.cardNumbers.indexOf(cardNumber);
    if (ticketIndex === -1) {
      return { valid: false, reason: 'Invalid card number' };
    }

    const ticketNumbers = booking.generatedNumbers[ticketIndex];
    const announcedNumbers = game.announcedNumbers;

    // Validate based on win type
    let isValid = false;
    
    if (winType === 'FIRST_LINE') {
      isValid = ticketNumbers.firstLine.every(num => announcedNumbers.includes(num));
    } else if (winType === 'SECOND_LINE') {
      isValid = ticketNumbers.secondLine.every(num => announcedNumbers.includes(num));
    } else if (winType === 'THIRD_LINE') {
      isValid = ticketNumbers.thirdLine.every(num => announcedNumbers.includes(num));
    } else if (winType === 'JALDI') {
      // Jaldi: Any one complete line
      isValid = ticketNumbers.firstLine.every(num => announcedNumbers.includes(num)) ||
                ticketNumbers.secondLine.every(num => announcedNumbers.includes(num)) ||
                ticketNumbers.thirdLine.every(num => announcedNumbers.includes(num));
    } else if (winType === 'HOUSIE') {
      // Housie: All three lines complete
      isValid = ticketNumbers.firstLine.every(num => announcedNumbers.includes(num)) &&
                ticketNumbers.secondLine.every(num => announcedNumbers.includes(num)) &&
                ticketNumbers.thirdLine.every(num => announcedNumbers.includes(num));
    }

    if (!isValid) {
      return { valid: false, reason: 'Numbers do not match announced numbers' };
    }

    return { valid: true };
  }
}

module.exports = new WinValidator();
