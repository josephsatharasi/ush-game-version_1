const LiveGame = require('../models/LiveGame');

class WinValidator {
  async validateWin(gameId, userId, winType) {
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

    return { valid: true };
  }
}

module.exports = new WinValidator();
