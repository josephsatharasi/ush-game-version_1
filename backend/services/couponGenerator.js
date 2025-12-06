const Coupon = require('../models/Coupon');

class CouponGenerator {
  generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let code = '';
    for (let i = 0; i < 8; i++) {
      code += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return code;
  }

  getRewardDetails(winType) {
    const rewards = {
      ONE_LINE: [
        { brand: 'BigBasket', description: 'Gift Card', amount: 500 },
        { brand: 'Amazon', description: 'Voucher', amount: 300 },
        { brand: 'Flipkart', description: 'Gift Card', amount: 400 }
      ],
      JALDI: [
        { brand: 'Nescafe', description: 'Coffee Voucher', amount: 200 },
        { brand: 'Starbucks', description: 'Gift Card', amount: 250 },
        { brand: 'CCD', description: 'Voucher', amount: 150 }
      ]
    };

    const rewardList = rewards[winType] || rewards.JALDI;
    return rewardList[Math.floor(Math.random() * rewardList.length)];
  }

  async createCoupon(userId, gameId, winType) {
    const code = this.generateCode();
    const rewardDetails = this.getRewardDetails(winType);
    const expiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000); // 30 days

    const coupon = new Coupon({
      code,
      userId,
      gameId,
      winType,
      rewardDetails,
      expiresAt
    });

    await coupon.save();
    return coupon;
  }
}

module.exports = new CouponGenerator();
