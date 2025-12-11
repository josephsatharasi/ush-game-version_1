const LiveGame = require('../models/LiveGame');
const Booking = require('../models/Booking');

class WinValidator {
  async validateWin(gameId, userId, winType, cardNumber) {
    const game = await LiveGame.findById(gameId);
    if (!game) throw new Error('Game not found');

    if (game.status !== 'LIVE') {
      return { valid: false, reason: 'Game is not live' };
    }

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

    const booking = await Booking.findOne({ userId, gameId });
    if (!booking) {
      return { valid: false, reason: 'No booking found' };
    }

    const ticketIndex = booking.cardNumbers.indexOf(cardNumber);
    if (ticketIndex === -1) {
      return { valid: false, reason: 'Invalid card number' };
    }

    const ticketNumbers = booking.generatedNumbers[ticketIndex];
    const announcedNumbers = game.announcedNumbers;

    if (!announcedNumbers || announcedNumbers.length === 0) {
      return { valid: false, reason: 'No numbers announced yet' };
    }

    let isValid = false;
    
    if (winType === 'FIRST_LINE') {
      isValid = ticketNumbers.firstLine.every(num => announcedNumbers.includes(num));
      if (!isValid) return { valid: false, reason: 'First line not complete' };
    } else if (winType === 'SECOND_LINE') {
      if (!game.firstLineWinner) {
        return { valid: false, reason: 'First line must be claimed before second line' };
      }
      isValid = ticketNumbers.secondLine.every(num => announcedNumbers.includes(num));
      if (!isValid) return { valid: false, reason: 'Second line not complete' };
    } else if (winType === 'THIRD_LINE') {
      if (!game.secondLineWinner) {
        return { valid: false, reason: 'Second line must be claimed before third line' };
      }
      isValid = ticketNumbers.thirdLine.every(num => announcedNumbers.includes(num));
      if (!isValid) return { valid: false, reason: 'Third line not complete' };
    } else if (winType === 'JALDI') {
      const firstComplete = ticketNumbers.firstLine.every(num => announcedNumbers.includes(num));
      const secondComplete = ticketNumbers.secondLine.every(num => announcedNumbers.includes(num));
      const thirdComplete = ticketNumbers.thirdLine.every(num => announcedNumbers.includes(num));
      isValid = firstComplete || secondComplete || thirdComplete;
      if (!isValid) return { valid: false, reason: 'No complete line found for Jaldi' };
    } else if (winType === 'HOUSIE') {
      const allComplete = ticketNumbers.firstLine.every(num => announcedNumbers.includes(num)) &&
                          ticketNumbers.secondLine.every(num => announcedNumbers.includes(num)) &&
                          ticketNumbers.thirdLine.every(num => announcedNumbers.includes(num));
      isValid = allComplete;
      if (!isValid) return { valid: false, reason: 'All three lines must be complete for Housie' };
    }

    return { valid: true };
  }
}

module.exports = new WinValidator();
