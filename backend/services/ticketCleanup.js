const Booking = require('../models/Booking');
const LiveGame = require('../models/LiveGame');

class TicketCleanupService {
  // Filter out expired bookings from user view
  static async filterActiveBookings(bookings) {
    const now = new Date();
    
    return bookings.filter(booking => {
      // Remove if game is completed
      if (booking.gameId?.status === 'COMPLETED') {
        return false;
      }
      
      // Parse time slot to get end time
      const scheduledDate = new Date(booking.scheduledDate);
      const timeSlotHour = this.parseTimeSlot(booking.timeSlot);
      scheduledDate.setHours(timeSlotHour, 0, 0, 0);
      
      // Remove if time slot has passed (add 1 hour buffer for game duration)
      const slotEndTime = new Date(scheduledDate.getTime() + 60 * 60 * 1000);
      if (now > slotEndTime) {
        return false;
      }
      
      // Remove if scheduled date has passed
      const endOfDay = new Date(booking.scheduledDate);
      endOfDay.setHours(23, 59, 59, 999);
      if (now > endOfDay) {
        return false;
      }
      
      return true;
    });
  }
  
  // Parse time slot string to hour (24-hour format)
  static parseTimeSlot(timeSlot) {
    const timeMap = {
      '10:00 AM': 10,
      '11:00 AM': 11,
      '1:00 PM': 13,
      '2:00 PM': 14,
      '3:00 PM': 15,
      '4:00 PM': 16,
      '5:00 PM': 17,
      '6:00 PM': 18
    };
    return timeMap[timeSlot] || 10;
  }
  
  // Mark expired bookings (for admin tracking)
  static async markExpiredBookings() {
    const now = new Date();
    
    const bookings = await Booking.find({ status: 'DELIVERED' })
      .populate('gameId', 'status');
    
    for (const booking of bookings) {
      let shouldExpire = false;
      
      // Check if game is completed
      if (booking.gameId?.status === 'COMPLETED') {
        shouldExpire = true;
      }
      
      // Check if time slot has passed
      const scheduledDate = new Date(booking.scheduledDate);
      const timeSlotHour = this.parseTimeSlot(booking.timeSlot);
      scheduledDate.setHours(timeSlotHour, 0, 0, 0);
      const slotEndTime = new Date(scheduledDate.getTime() + 60 * 60 * 1000);
      
      if (now > slotEndTime) {
        shouldExpire = true;
      }
      
      // Check if day has passed
      const endOfDay = new Date(booking.scheduledDate);
      endOfDay.setHours(23, 59, 59, 999);
      if (now > endOfDay) {
        shouldExpire = true;
      }
      
      if (shouldExpire && booking.status !== 'EXPIRED') {
        booking.status = 'EXPIRED';
        await booking.save();
      }
    }
  }
}

module.exports = TicketCleanupService;
