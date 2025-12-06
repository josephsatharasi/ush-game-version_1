const express = require('express');
const Coupon = require('../models/Coupon');
const auth = require('../middleware/auth');
const router = express.Router();

// Get coupon details
router.get('/:couponId', auth, async (req, res) => {
  try {
    const { couponId } = req.params;
    const userId = req.userId;

    const coupon = await Coupon.findOne({ _id: couponId, userId });
    if (!coupon) {
      return res.status(404).json({ message: 'Coupon not found' });
    }

    res.json({
      coupon: {
        code: coupon.code,
        winType: coupon.winType,
        rewardDetails: coupon.rewardDetails,
        expiresAt: coupon.expiresAt,
        isUsed: coupon.isUsed
      }
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Reveal reward
router.post('/:couponId/reveal', auth, async (req, res) => {
  try {
    const { couponId } = req.params;
    const userId = req.userId;

    const coupon = await Coupon.findOne({ _id: couponId, userId });
    if (!coupon) {
      return res.status(404).json({ message: 'Coupon not found' });
    }

    res.json({
      revealed: true,
      coupon: {
        code: coupon.code,
        rewardDetails: coupon.rewardDetails
      }
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
