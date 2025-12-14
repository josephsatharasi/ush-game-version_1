// Auto-generate coupons based on win type
class AutoCouponGenerator {
  generateCoupon(winType) {
    const prefix = this.getCouponPrefix(winType);
    const randomPart = Math.random().toString(36).substring(2, 8).toUpperCase();
    const timestamp = Date.now().toString(36).toUpperCase();
    return `${prefix}-${randomPart}-${timestamp}`;
  }

  getCouponPrefix(winType) {
    const prefixes = {
      'HOUSIE': 'GRAND',
      'JALDI': 'FAST',
      'FIRST_LINE': 'LINE1',
      'SECOND_LINE': 'LINE2',
      'THIRD_LINE': 'LINE3'
    };
    return prefixes[winType] || 'WIN';
  }

  getCouponValue(winType) {
    const values = {
      'HOUSIE': 500,      // Best prize
      'JALDI': 200,       // Fast winner
      'FIRST_LINE': 100,  // Line winners
      'SECOND_LINE': 100,
      'THIRD_LINE': 100
    };
    return values[winType] || 50;
  }
}

module.exports = new AutoCouponGenerator();
