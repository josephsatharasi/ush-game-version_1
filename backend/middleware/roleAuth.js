const jwt = require('jsonwebtoken');
const config = require('../config/environment');

const requireRole = (roles) => {
  return (req, res, next) => {
    try {
      const token = req.header('Authorization')?.replace('Bearer ', '');
      console.log('🔐 Token received:', token?.substring(0, 20) + '...');
      console.log('🔑 Using JWT_SECRET:', config.JWT_SECRET);
      
      if (!token) {
        console.log('❌ No token provided');
        return res.status(401).json({ message: 'No token provided' });
      }

      const decoded = jwt.verify(token, config.JWT_SECRET);
      console.log('✅ Token decoded:', decoded);
      
      if (!roles.includes(decoded.role)) {
        console.log('❌ Role mismatch. Required:', roles, 'Got:', decoded.role);
        return res.status(403).json({ message: 'Access denied' });
      }

      req.user = decoded;
      next();
    } catch (error) {
      console.log('❌ Token verification error:', error.message);
      res.status(401).json({ message: 'Invalid token' });
    }
  };
};

module.exports = { requireRole };
