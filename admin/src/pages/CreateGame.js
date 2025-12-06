import React, { useState } from 'react';
import { Calendar, Users, Code, Plus } from 'lucide-react';

const CreateGame = () => {
  const [formData, setFormData] = useState({
    gameCode: '',
    scheduledTime: '',
    totalSlots: 100
  });
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState('');

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
    setMessage('');
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setMessage('');

    try {
      const token = localStorage.getItem('token');
      const response = await fetch(`${process.env.REACT_APP_API_URL || 'https://ush-game-version-1.onrender.com'}/api/admin/games/create`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(formData)
      });

      const data = await response.json();
      
      if (response.ok) {
        setMessage('✅ Game created successfully!');
        setFormData({ gameCode: '', scheduledTime: '', totalSlots: 100 });
      } else {
        setMessage('❌ ' + data.message);
      }
    } catch (error) {
      setMessage('❌ Error creating game');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="p-6">
      <div className="mb-6">
        <h1 className="text-3xl font-bold text-gray-800">Create New Game</h1>
        <p className="text-gray-600">Schedule a new Tambola game for users</p>
      </div>

      <div className="bg-white rounded-2xl shadow-xl p-8 max-w-2xl">
        <form onSubmit={handleSubmit} className="space-y-6">
          {/* Game Code */}
          <div>
            <label className="flex items-center text-sm font-semibold text-gray-700 mb-2">
              <Code size={18} className="mr-2 text-blue-600" />
              Game Code
            </label>
            <input
              type="text"
              name="gameCode"
              value={formData.gameCode}
              onChange={handleChange}
              placeholder="e.g., GAME001"
              className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              required
            />
            <p className="text-xs text-gray-500 mt-1">Unique identifier for the game</p>
          </div>

          {/* Scheduled Time */}
          <div>
            <label className="flex items-center text-sm font-semibold text-gray-700 mb-2">
              <Calendar size={18} className="mr-2 text-green-600" />
              Scheduled Time
            </label>
            <input
              type="datetime-local"
              name="scheduledTime"
              value={formData.scheduledTime}
              onChange={handleChange}
              className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent"
              required
            />
            <p className="text-xs text-gray-500 mt-1">When the game will start</p>
          </div>

          {/* Total Slots */}
          <div>
            <label className="flex items-center text-sm font-semibold text-gray-700 mb-2">
              <Users size={18} className="mr-2 text-purple-600" />
              Total Slots
            </label>
            <input
              type="number"
              name="totalSlots"
              value={formData.totalSlots}
              onChange={handleChange}
              min="10"
              max="500"
              className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
              required
            />
            <p className="text-xs text-gray-500 mt-1">Maximum number of players (10-500)</p>
          </div>

          {/* Message */}
          {message && (
            <div className={`p-4 rounded-xl ${message.includes('✅') ? 'bg-green-50 text-green-700' : 'bg-red-50 text-red-700'}`}>
              {message}
            </div>
          )}

          {/* Submit Button */}
          <button
            type="submit"
            disabled={loading}
            className="w-full bg-gradient-to-r from-blue-600 to-purple-600 text-white py-4 rounded-xl font-bold text-lg flex items-center justify-center hover:from-blue-700 hover:to-purple-700 transition disabled:opacity-50 shadow-lg"
          >
            <Plus size={20} className="mr-2" />
            {loading ? 'Creating Game...' : 'Create Game'}
          </button>
        </form>
      </div>

      {/* Info Box */}
      <div className="mt-6 bg-blue-50 border-l-4 border-blue-500 p-4 rounded-lg max-w-2xl">
        <h3 className="font-bold text-blue-900 mb-2">📋 Quick Guide:</h3>
        <ul className="text-sm text-blue-800 space-y-1">
          <li>• Game Code must be unique (e.g., GAME001, GAME002)</li>
          <li>• Schedule time should be in the future</li>
          <li>• Users will see this game in their app</li>
          <li>• Game status will be "SCHEDULED" until you start it</li>
        </ul>
      </div>
    </div>
  );
};

export default CreateGame;
