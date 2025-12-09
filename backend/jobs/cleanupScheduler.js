const cron = require('node-cron');
const TicketCleanupService = require('../services/ticketCleanup');

// Run cleanup every hour
const scheduleCleanup = () => {
  cron.schedule('0 * * * *', async () => {
    console.log('Running ticket cleanup job...');
    try {
      await TicketCleanupService.markExpiredBookings();
      console.log('Ticket cleanup completed');
    } catch (error) {
      console.error('Cleanup job error:', error);
    }
  });
};

module.exports = { scheduleCleanup };
