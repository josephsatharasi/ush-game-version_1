const mongoose = require('mongoose');
const dotenv = require('dotenv');
const User = require('./models/User');
const Admin = require('./models/Admin');
const Account = require('./models/Account');

dotenv.config();

const migrateToUnifiedAuth = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('Connected to MongoDB');

    const users = await User.find({});
    const admins = await Admin.find({});

    console.log(`Found ${users.length} users and ${admins.length} admins`);

    for (const user of users) {
      const existingAccount = await Account.findOne({ 
        $or: [{ phone: user.phone }, { username: user.username }] 
      });
      
      if (!existingAccount) {
        await Account.create({
          username: user.username,
          phone: user.phone,
          password: user.password,
          role: 'user',
          isVerified: user.isVerified,
          createdAt: user.createdAt,
          lastLogin: user.lastLogin
        });
        console.log(`Migrated user: ${user.username}`);
      }
    }

    for (const admin of admins) {
      const existingAccount = await Account.findOne({ 
        $or: [{ phone: admin.phone }, { username: admin.username }] 
      });
      
      if (!existingAccount) {
        await Account.create({
          username: admin.username,
          phone: admin.phone,
          password: admin.password,
          role: 'admin',
          isVerified: true,
          createdAt: admin.createdAt
        });
        console.log(`Migrated admin: ${admin.username}`);
      }
    }

    console.log('Migration completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('Migration failed:', error);
    process.exit(1);
  }
};

migrateToUnifiedAuth();
