const mongoose = require('mongoose');
const config = require('./environment');

const connectDB = async () => {
  try {
    console.log(`🔧 Environment: ${config.ENVIRONMENT}`);
    console.log(`🔗 Connecting to: ${config.MONGODB_URI?.includes('localhost') ? 'Local MongoDB' : 'Live MongoDB'}`);
    await mongoose.connect(config.MONGODB_URI);
    console.log('MongoDB connected');
  } catch (error) {
    console.error('MongoDB connection error:', error);
    process.exit(1);
  }
};

module.exports = connectDB;
