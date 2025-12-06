const express = require('express');
const http = require('http');
const socketIO = require('socket.io');
const cors = require('cors');
const dotenv = require('dotenv');
const connectDB = require('./config/db');
const authRoutes = require('./routes/auth');
const unifiedAuthRoutes = require('./routes/unified-auth');
const gameRoutes = require('./routes/game');
const couponRoutes = require('./routes/coupon');
const adminRoutes = require('./routes/admin');
const GameEngine = require('./services/gameEngine');

dotenv.config();
connectDB();

const app = express();
const server = http.createServer(app);
const io = socketIO(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST']
  }
});

const gameEngine = new GameEngine(io);

app.use(cors({
  origin: '*',
  credentials: true
}));
app.use(express.json());

const adminAuthRoutes = require('./routes/admin-auth');

app.use('/api/auth', unifiedAuthRoutes);
app.use('/api/auth/legacy', authRoutes);
app.use('/api/admin/auth', adminAuthRoutes);
app.use('/api/game', gameRoutes);
app.use('/api/coupons', couponRoutes);
app.use('/api/admin', adminRoutes);

app.get('/', (req, res) => {
  res.json({ message: 'Ush Game Backend API - Version 1' });
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

// Store gameEngine globally for routes
app.set('gameEngine', gameEngine);

const PORT = process.env.PORT || 5000;
const HOST = process.env.IPADDRESS || '0.0.0.0';

server.listen(PORT, HOST, () => {
  console.log(`Server running on ${HOST}:${PORT}`);
});
