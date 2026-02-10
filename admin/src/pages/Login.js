import React, { useState } from 'react';
import axios from 'axios';

const Login = ({ onSuccess, onSwitchToRegister }) => {
  const [formData, setFormData] = useState({ username: '', password: '' });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
    setError('');
  };

  const handleLogin = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      const res = await axios.post(`${process.env.REACT_APP_API_URL || 'https://ush-game-version-1.onrender.com'}/admin/auth/login`, formData);
      localStorage.setItem('token', res.data.token);
      localStorage.setItem('admin', JSON.stringify(res.data.admin));
      onSuccess();
    } catch (err) {
      setError(err.response?.data?.message || 'Login failed');
    }
    setLoading(false);
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-600 via-blue-500 to-blue-400 p-4">
      <div className="absolute top-0 left-0 w-full h-full overflow-hidden pointer-events-none">
        <div className="absolute top-20 left-10 w-32 h-32 bg-yellow-400 rounded-full opacity-80"></div>
        <div className="absolute top-40 right-20 w-24 h-24 bg-white opacity-30 rounded-lg transform rotate-45"></div>
        <div className="absolute bottom-32 left-1/4 w-20 h-20 bg-yellow-300 rounded-full opacity-70"></div>
      </div>

      <div className="bg-white rounded-3xl shadow-2xl p-8 w-full max-w-md relative z-10">
        <div className="flex justify-between items-center mb-8">
          <button
            onClick={onSwitchToRegister}
            className="px-6 py-2 bg-white border-2 border-blue-600 text-blue-600 rounded-full font-semibold hover:bg-blue-50 transition"
          >
            Register
          </button>
          <h2 className="text-3xl font-bold text-gray-800">Skip the wait.</h2>
        </div>

        <p className="text-blue-600 text-xl font-semibold mb-2">Get your ticket.</p>
        <p className="text-gray-500 text-sm mb-6">Login to your Account</p>

        <form onSubmit={handleLogin}>
          <div className="mb-4">
            <label className="text-sm text-gray-600 mb-2 block">Username</label>
            <input
              type="text"
              name="username"
              value={formData.username}
              onChange={handleChange}
              placeholder="Enter Username"
              className="w-full px-4 py-3 bg-gray-100 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              required
            />
          </div>

          <div className="mb-6">
            <label className="text-sm text-gray-600 mb-2 block">Password</label>
            <input
              type="password"
              name="password"
              value={formData.password}
              onChange={handleChange}
              placeholder="Enter Password"
              className="w-full px-4 py-3 bg-gray-100 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              required
            />
          </div>

          {error && <p className="text-red-500 text-sm mb-4">{error}</p>}

          <button
            type="submit"
            disabled={loading}
            className="w-full bg-blue-600 text-white py-3 rounded-full font-semibold hover:bg-blue-700 transition disabled:opacity-50"
          >
            {loading ? 'Processing...' : 'Login'}
          </button>
        </form>
      </div>
    </div>
  );
};

export default Login;
