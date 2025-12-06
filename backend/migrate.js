const mongoose = require('mongoose');
require('dotenv').config();

mongoose.connect(process.env.MONGODB_URI);

const Admin = mongoose.model('Admin', new mongoose.Schema({}, { strict: false }));

async function migrate() {
  const admins = await Admin.find({});
  
  for (const admin of admins) {
    if (!admin.username && admin.name) {
      admin.username = admin.name.toLowerCase().replace(/\s+/g, '');
      admin.name = undefined;
      await admin.save();
      console.log(`Migrated: ${admin.username}`);
    }
  }
  
  console.log('Migration complete');
  process.exit(0);
}

migrate().catch(err => {
  console.error(err);
  process.exit(1);
});
