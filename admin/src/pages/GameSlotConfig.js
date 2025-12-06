import React, { useState, useEffect } from 'react';
import { Settings, Calendar, Clock, Users, Save } from 'lucide-react';

const GameSlotConfig = () => {
  const [games, setGames] = useState([]);
  const [selectedGame, setSelectedGame] = useState('');
  const [config, setConfig] = useState({
    maxTicketsPerUser: 6,
    availableWeekDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
    availableTimeSlots: [
      { time: '10:00 AM', totalSlots: 20, badge: 'Best time' },
      { time: '11:00 AM', totalSlots: 20, badge: null },
      { time: '1:00 PM', totalSlots: 20, badge: 'Low Time' },
      { time: '2:00 PM', totalSlots: 20, badge: null },
      { time: '3:00 PM', totalSlots: 20, badge: 'Good time' },
      { time: '4:00 PM', totalSlots: 20, badge: null },
      { time: '5:00 PM', totalSlots: 20, badge: null },
      { time: '6:00 PM', totalSlots: 20, badge: 'Best time' }
    ],
    scheduledDate: new Date().toISOString().split('T')[0]
  });
  const [loading, setLoading] = useState(false);

  const weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  const badges = ['Best time', 'Good time', 'Low Time'];

  useEffect(() => {
    fetchGames();
  }, []);

  const fetchGames = async () => {
    try {
      const token = localStorage.getItem('token');
      const response = await fetch(`${process.env.REACT_APP_API_URL || 'https://ush-game-version-1.onrender.com'}/api/admin/games/all`, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });
      const data = await response.json();
      if (response.ok) {
        setGames(data.games);
      }
    } catch (error) {
      console.error('Error fetching games:', error);
    }
  };

  const loadGameConfig = async (gameId) => {
    try {
      const token = localStorage.getItem('token');
      const response = await fetch(`${process.env.REACT_APP_API_URL || 'https://ush-game-version-1.onrender.com'}/api/admin/games/${gameId}/slot-config`, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });
      if (response.ok) {
        const data = await response.json();
        setConfig({
          ...data.config,
          scheduledDate: new Date(data.config.scheduledDate).toISOString().split('T')[0]
        });
      }
    } catch (error) {
      console.log('No existing config found, using defaults');
    }
  };

  const handleGameSelect = (gameId) => {
    setSelectedGame(gameId);
    if (gameId) {
      loadGameConfig(gameId);
    }
  };

  const updateTimeSlot = (index, field, value) => {
    const newSlots = [...config.availableTimeSlots];
    newSlots[index] = { ...newSlots[index], [field]: value };
    setConfig({ ...config, availableTimeSlots: newSlots });
  };

  const toggleWeekDay = (day) => {
    const newDays = config.availableWeekDays.includes(day)
      ? config.availableWeekDays.filter(d => d !== day)
      : [...config.availableWeekDays, day];
    setConfig({ ...config, availableWeekDays: newDays });
  };

  const saveConfiguration = async () => {
    if (!selectedGame) {
      alert('Please select a game first');
      return;
    }

    setLoading(true);
    try {
      const token = localStorage.getItem('token');
      const response = await fetch(`${process.env.REACT_APP_API_URL || 'https://ush-game-version-1.onrender.com'}/api/admin/games/${selectedGame}/configure-slots`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(config)
      });

      const data = await response.json();
      if (response.ok) {
        alert('Configuration saved successfully!');
      } else {
        alert(data.message || 'Failed to save configuration');
      }
    } catch (error) {
      alert('Error saving configuration');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="p-6">
      <h1 className="text-3xl font-bold text-gray-800 mb-6 flex items-center">
        <Settings className="mr-3" />
        Game Slot Configuration
      </h1>

      {/* Game Selection */}
      <div className="bg-white rounded-lg shadow-md p-6 mb-6">
        <h2 className="text-xl font-bold mb-4">Select Game</h2>
        <select
          value={selectedGame}
          onChange={(e) => handleGameSelect(e.target.value)}
          className="w-full p-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
        >
          <option value="">Choose a game...</option>
          {games.map(game => (
            <option key={game._id} value={game._id}>
              {game.gameCode} - {game.status}
            </option>
          ))}
        </select>
      </div>

      {selectedGame && (
        <div className="space-y-6">
          {/* Basic Settings */}
          <div className="bg-white rounded-lg shadow-md p-6">
            <h3 className="text-lg font-bold mb-4 flex items-center">
              <Users className="mr-2" />
              Basic Settings
            </h3>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium mb-2">Max Tickets Per User</label>
                <input
                  type="number"
                  min="1"
                  max="6"
                  value={config.maxTicketsPerUser}
                  onChange={(e) => setConfig({ ...config, maxTicketsPerUser: parseInt(e.target.value) })}
                  className="w-full p-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">Scheduled Date</label>
                <input
                  type="date"
                  value={config.scheduledDate}
                  onChange={(e) => setConfig({ ...config, scheduledDate: e.target.value })}
                  className="w-full p-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
            </div>
          </div>

          {/* Week Days */}
          <div className="bg-white rounded-lg shadow-md p-6">
            <h3 className="text-lg font-bold mb-4 flex items-center">
              <Calendar className="mr-2" />
              Available Week Days
            </h3>
            <div className="flex flex-wrap gap-3">
              {weekDays.map(day => (
                <button
                  key={day}
                  onClick={() => toggleWeekDay(day)}
                  className={`px-4 py-2 rounded-lg font-medium ${
                    config.availableWeekDays.includes(day)
                      ? 'bg-blue-600 text-white'
                      : 'bg-gray-200 text-gray-700'
                  }`}
                >
                  {day}
                </button>
              ))}
            </div>
          </div>

          {/* Time Slots */}
          <div className="bg-white rounded-lg shadow-md p-6">
            <h3 className="text-lg font-bold mb-4 flex items-center">
              <Clock className="mr-2" />
              Time Slots Configuration
            </h3>
            <div className="space-y-4">
              {config.availableTimeSlots.map((slot, index) => (
                <div key={index} className="grid grid-cols-4 gap-4 p-4 border rounded-lg">
                  <div>
                    <label className="block text-sm font-medium mb-1">Time</label>
                    <input
                      type="text"
                      value={slot.time}
                      onChange={(e) => updateTimeSlot(index, 'time', e.target.value)}
                      className="w-full p-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium mb-1">Total Slots</label>
                    <input
                      type="number"
                      min="1"
                      value={slot.totalSlots}
                      onChange={(e) => updateTimeSlot(index, 'totalSlots', parseInt(e.target.value))}
                      className="w-full p-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium mb-1">Badge</label>
                    <select
                      value={slot.badge || ''}
                      onChange={(e) => updateTimeSlot(index, 'badge', e.target.value || null)}
                      className="w-full p-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
                    >
                      <option value="">No Badge</option>
                      {badges.map(badge => (
                        <option key={badge} value={badge}>{badge}</option>
                      ))}
                    </select>
                  </div>
                  <div className="flex items-end">
                    <button
                      onClick={() => {
                        const newSlots = config.availableTimeSlots.filter((_, i) => i !== index);
                        setConfig({ ...config, availableTimeSlots: newSlots });
                      }}
                      className="px-3 py-2 bg-red-500 text-white rounded hover:bg-red-600"
                    >
                      Remove
                    </button>
                  </div>
                </div>
              ))}
              <button
                onClick={() => {
                  const newSlots = [...config.availableTimeSlots, { time: '7:00 PM', totalSlots: 20, badge: null }];
                  setConfig({ ...config, availableTimeSlots: newSlots });
                }}
                className="px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600"
              >
                Add Time Slot
              </button>
            </div>
          </div>

          {/* Save Button */}
          <div className="flex justify-end">
            <button
              onClick={saveConfiguration}
              disabled={loading}
              className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 flex items-center disabled:opacity-50"
            >
              <Save className="mr-2" size={20} />
              {loading ? 'Saving...' : 'Save Configuration'}
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

export default GameSlotConfig;