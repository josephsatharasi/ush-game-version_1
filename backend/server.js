const express = require('express');
const http = require('http');
const https = require('https');
const fs = require('fs');
const socketIO = require('socket.io');
const cors = require('cors');
const path = require('path');
const config = require('./config/environment');
const connectDB = require('./config/db');
const authRoutes = require('./routes/auth');
const unifiedAuthRoutes = require('./routes/unified-auth');
const gameRoutes = require('./routes/game');
const couponRoutes = require('./routes/coupon');
const adminRoutes = require('./routes/admin');
const GameEngine = require('./services/gameEngine');
const { scheduleCleanup } = require('./jobs/cleanupScheduler');
const { scheduleGameStarter } = require('./jobs/gameScheduler');

connectDB().then(async () => {
  // Drop old unique index on startup
  try {
    const mongoose = require('mongoose');
    const db = mongoose.connection.db;
    const collection = db.collection('bookings');
    await collection.dropIndex('userId_1_gameId_1_scheduledDate_1_timeSlot_1');
    console.log('✅ Dropped old unique booking index');
  } catch (e) {
    if (!e.message.includes('not found')) {
      console.log('⚠️ Index drop:', e.message);
    }
  }
});
scheduleCleanup();

const app = express();

// Use HTTP for local, HTTPS for production
let server;
if (config.NODE_ENV === 'production') {
  const sslOptions = {
    key: fs.readFileSync('C:\\ssl\\privkey.pem'),
    cert: fs.readFileSync('C:\\ssl\\fullchain.pem')
  };
  server = https.createServer(sslOptions, app);
} else {
  // Local development - use HTTP
  server = http.createServer(app);
}

const io = socketIO(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST']
  },
  transports: ['websocket', 'polling'],
  secure: config.NODE_ENV === 'production'
});

const gameEngine = new GameEngine(io);

app.use(cors({
  origin: '*',
  credentials: true
}));
app.use(express.json());

// Strict HTTPS enforcement (production only)
if (config.NODE_ENV === 'production') {
  app.use((req, res, next) => {
    res.setHeader('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
    next();
  });
}

const adminAuthRoutes = require('./routes/admin-auth');

app.use('/api/auth', unifiedAuthRoutes);
app.use('/api/auth/legacy', authRoutes);
app.use('/api/admin/auth', adminAuthRoutes);
app.use('/api/game', (req, res, next) => { req.app.set('io', io); next(); }, gameRoutes);
app.use('/api/coupons', couponRoutes);
app.use('/api/admin', adminRoutes);

// Serve admin panel static files
app.use(express.static(path.join(__dirname, '../admin/build')));

app.get('/', (req, res) => {
  res.json({ message: 'Ush Game Backend API - Version 1' });
});

// Catch-all route for React Router (must be after API routes)
app.get('/*', (req, res) => {
  res.sendFile(path.join(__dirname, '../admin/build', 'index.html'));
});

// Socket.IO connection
io.on('connection', (socket) => {
  console.log('Client connected:', socket.id);

  socket.on('game:join', ({ gameId }) => {
    socket.join(gameId);
    console.log(`Client ${socket.id} joined game ${gameId}`);
  });

  socket.on('game:leave', ({ gameId }) => {
    socket.leave(gameId);
    console.log(`Client ${socket.id} left game ${gameId}`);
  });

  socket.on('disconnect', () => {
    console.log('Client disconnected:', socket.id);
  });
});

// Store gameEngine and io globally for routes
app.set('gameEngine', gameEngine);
app.set('io', io);

// Start game auto-scheduler
scheduleGameStarter(gameEngine);

const PORT = config.PORT || 5000;
const HOST = process.env.IPADDRESS || '0.0.0.0';

server.listen(PORT, HOST, () => {
  console.log(`🚀 Server running on ${HOST}:${PORT}`);
});
