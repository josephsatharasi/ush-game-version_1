import React, { useState, useEffect } from 'react';
import { Plus, Search, Filter, Eye, Edit, Trash2, Play, Pause, X, Clock } from 'lucide-react';
import axios from 'axios';

const Games = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [filterStatus, setFilterStatus] = useState('all');
  const [games, setGames] = useState([]);
  const [loading, setLoading] = useState(true);
  const [editModal, setEditModal] = useState(null);
  const [newSlots, setNewSlots] = useState(0);
  const [timeSlotModal, setTimeSlotModal] = useState(null);
  const [newTimeSlots, setNewTimeSlots] = useState([]);
  const [selectedTime, setSelectedTime] = useState('');
  const [slotCount, setSlotCount] = useState(20);

  const availableTimeSlots = [
    { time: '10:00 AM', badge: 'Best time' },
    { time: '11:00 AM', badge: null },
    { time: '1:00 PM', badge: 'Low Time' },
    { time: '2:00 PM', badge: null },
    { time: '3:00 PM', badge: 'Good time' },
    { time: '4:00 PM', badge: null },
    { time: '5:00 PM', badge: null },
    { time: '6:00 PM', badge: 'Best time' }
  ];

  useEffect(() => {
    fetchGames();
  }, []);

  const fetchGames = async () => {
    try {
      const token = localStorage.getItem('token');
      const res = await axios.get(`${process.env.REACT_APP_API_URL || 'https://ush-game-version-1.onrender.com'}/api/admin/games/admin-all`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      setGames(res.data.games);
    } catch (err) {
      console.error('Failed to fetch games:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleEditSlots = (game) => {
    setEditModal(game);
    setNewSlots(0);
  };

  const handleUpdateSlots = async () => {
    try {
      const token = localStorage.getItem('token');
      await axios.patch(
        `${process.env.REACT_APP_API_URL || 'https://ush-game-version-1.onrender.com'}/api/admin/games/${editModal._id}/update-slots`,
        { additionalSlots: parseInt(newSlots) },
        { headers: { Authorization: `Bearer ${token}` } }
      );
      setEditModal(null);
      fetchGames();
    } catch (err) {
      console.error('Failed to update slots:', err);
    }
  };

  const handleManageTimeSlots = async (game) => {
    try {
      const token = localStorage.getItem('token');
      const res = await axios.get(
        `${process.env.REACT_APP_API_URL || 'https://ush-game-version-1.onrender.com'}/api/admin/games/${game._id}/slot-config`,
        { headers: { Authorization: `Bearer ${token}` } }
      );
      setTimeSlotModal({ game, config: res.data.config });
      setNewTimeSlots([]);
    } catch (err) {
      console.error('Failed to load time slots:', err);
    }
  };

  const addTimeSlot = () => {
    if (!selectedTime) return;
    const slot = availableTimeSlots.find(s => s.time === selectedTime);
    setNewTimeSlots([...newTimeSlots, { ...slot, totalSlots: slotCount }]);
    setSelectedTime('');
    setSlotCount(20);
  };

  const removeNewTimeSlot = (index) => {
    setNewTimeSlots(newTimeSlots.filter((_, i) => i !== index));
  };

  const handleSaveTimeSlots = async () => {
    try {
      const token = localStorage.getItem('token');
      await axios.post(
        `${process.env.REACT_APP_API_URL || 'https://ush-game-version-1.onrender.com'}/api/admin/games/${timeSlotModal.game._id}/add-time-slots`,
        { newTimeSlots },
        { headers: { Authorization: `Bearer ${token}` } }
      );
      setTimeSlotModal(null);
      setNewTimeSlots([]);
    } catch (err) {
      console.error('Failed to add time slots:', err);
    }
  };

  const handleRemoveExistingSlot = async (timeSlot) => {
    if (!window.confirm(`Remove time slot ${timeSlot}?`)) return;
    try {
      const token = localStorage.getItem('token');
      await axios.delete(
        `${process.env.REACT_APP_API_URL || 'https://ush-game-version-1.onrender.com'}/api/admin/games/${timeSlotModal.game._id}/time-slots/${encodeURIComponent(timeSlot)}`,
        { headers: { Authorization: `Bearer ${token}` } }
      );
      handleManageTimeSlots(timeSlotModal.game);
    } catch (err) {
      console.error('Failed to remove time slot:', err);
    }
  };

  const getStatusColor = (status) => {
    switch(status) {
      case 'LIVE': return 'bg-green-100 text-green-800';
      case 'COMPLETED': return 'bg-blue-100 text-blue-800';
      case 'SCHEDULED': return 'bg-yellow-100 text-yellow-800';
      case 'COUNTDOWN': return 'bg-orange-100 text-orange-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const displayGames = games.map(g => ({
    id: g._id,
    gameCode: g.gameCode,
    players: g.bookedSlots,
    maxPlayers: g.totalSlots,
    status: g.status,
    scheduledTime: new Date(g.scheduledTime).toLocaleString(),
    created: new Date(g.createdAt).toLocaleDateString()
  }));

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-3xl font-bold text-gray-800">Games Management</h1>
          <p className="text-gray-600">Manage all Tambola games</p>
        </div>
        <button className="bg-purple-600 text-white px-4 py-2 rounded-lg flex items-center hover:bg-purple-700">
          <Plus size={20} className="mr-2" />
          Create Game
        </button>
      </div>

      {/* Filters */}
      <div className="bg-white rounded-lg shadow-md p-4 mb-6">
        <div className="flex flex-col md:flex-row gap-4">
          <div className="flex-1">
            <div className="relative">
              <Search size={20} className="absolute left-3 top-3 text-gray-400" />
              <input
                type="text"
                placeholder="Search games..."
                className="w-full pl-10 pr-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
            </div>
          </div>
          <div className="flex gap-2">
            <select 
              className="px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500"
              value={filterStatus}
              onChange={(e) => setFilterStatus(e.target.value)}
            >
              <option value="all">All Status</option>
              <option value="active">Active</option>
              <option value="waiting">Waiting</option>
              <option value="completed">Completed</option>
            </select>
            <button className="px-4 py-2 border rounded-lg flex items-center hover:bg-gray-50">
              <Filter size={16} className="mr-2" />
              Filter
            </button>
          </div>
        </div>
      </div>

      {/* Games Table */}
      <div className="bg-white rounded-lg shadow-md overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Game ID</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Type</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Players</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Status</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Time Slot</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Prize Pool</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Actions</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr><td colSpan="7" className="text-center py-4">Loading...</td></tr>
              ) : displayGames.length === 0 ? (
                <tr><td colSpan="7" className="text-center py-8 text-gray-500">No games found</td></tr>
              ) : displayGames.map((game) => (
                <tr key={game.id} className="border-b hover:bg-gray-50">
                  <td className="py-3 px-4 font-medium">{game.gameCode}</td>
                  <td className="py-3 px-4">
                    <span className="px-2 py-1 rounded-full text-xs bg-orange-100 text-orange-800">
                      Live Game
                    </span>
                  </td>
                  <td className="py-3 px-4">{game.players}/{game.maxPlayers}</td>
                  <td className="py-3 px-4">
                    <span className={`px-2 py-1 rounded-full text-xs ${getStatusColor(game.status)}`}>
                      {game.status}
                    </span>
                  </td>
                  <td className="py-3 px-4">{game.scheduledTime}</td>
                  <td className="py-3 px-4 font-medium">-</td>
                  <td className="py-3 px-4">
                    <div className="flex space-x-2">
                      <button 
                        onClick={() => handleEditSlots(games.find(g => g._id === game.id))}
                        className="p-1 text-green-600 hover:bg-green-100 rounded"
                        title="Edit Slots"
                      >
                        <Edit size={16} />
                      </button>
                      <button 
                        onClick={() => handleManageTimeSlots(games.find(g => g._id === game.id))}
                        className="p-1 text-blue-600 hover:bg-blue-100 rounded"
                        title="Manage Time Slots"
                      >
                        <Clock size={16} />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Edit Slots Modal */}
      {editModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-2xl shadow-2xl p-6 max-w-md w-full mx-4">
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-2xl font-bold text-gray-800">Edit Game Slots</h2>
              <button onClick={() => setEditModal(null)} className="text-gray-500 hover:text-gray-700">
                <X size={24} />
              </button>
            </div>
            
            <div className="space-y-4">
              <div>
                <p className="text-sm text-gray-600">Game Code</p>
                <p className="text-lg font-bold text-gray-800">{editModal.gameCode}</p>
              </div>
              
              <div>
                <p className="text-sm text-gray-600">Current Slots</p>
                <p className="text-lg font-bold text-blue-600">{editModal.bookedSlots} / {editModal.totalSlots}</p>
              </div>
              
              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Add Additional Slots
                </label>
                <input
                  type="number"
                  value={newSlots}
                  onChange={(e) => setNewSlots(e.target.value)}
                  min="1"
                  max="500"
                  placeholder="Enter number of slots to add"
                  className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
              
              {newSlots > 0 && (
                <div className="bg-blue-50 p-3 rounded-lg">
                  <p className="text-sm text-blue-800">
                    New Total: <span className="font-bold">{editModal.totalSlots + parseInt(newSlots || 0)}</span> slots
                  </p>
                </div>
              )}
              
              <div className="flex gap-3 mt-6">
                <button
                  onClick={() => setEditModal(null)}
                  className="flex-1 px-4 py-3 border-2 border-gray-300 text-gray-700 rounded-xl font-semibold hover:bg-gray-50"
                >
                  Cancel
                </button>
                <button
                  onClick={handleUpdateSlots}
                  disabled={!newSlots || newSlots <= 0}
                  className="flex-1 px-4 py-3 bg-blue-600 text-white rounded-xl font-semibold hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Update Slots
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Manage Time Slots Modal */}
      {timeSlotModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-2xl shadow-2xl p-6 max-w-2xl w-full mx-4 max-h-[90vh] overflow-y-auto">
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-2xl font-bold text-gray-800">Manage Time Slots</h2>
              <button onClick={() => setTimeSlotModal(null)} className="text-gray-500 hover:text-gray-700">
                <X size={24} />
              </button>
            </div>
            
            <div className="space-y-6">
              <div>
                <p className="text-sm text-gray-600">Game Code</p>
                <p className="text-lg font-bold text-gray-800">{timeSlotModal.game.gameCode}</p>
              </div>
              
              {/* Existing Time Slots */}
              <div>
                <h3 className="text-lg font-semibold text-gray-800 mb-3">Current Time Slots</h3>
                {timeSlotModal.config?.availableTimeSlots?.length > 0 ? (
                  <div className="space-y-2">
                    {timeSlotModal.config.availableTimeSlots.map((slot, idx) => (
                      <div key={idx} className="flex items-center justify-between bg-blue-50 p-3 rounded-lg">
                        <div>
                          <span className="font-semibold text-blue-900">{slot.time}</span>
                          <span className="text-sm text-blue-700 ml-3">({slot.bookedSlots}/{slot.totalSlots} booked)</span>
                          {slot.badge && (
                            <span className="ml-2 text-xs px-2 py-1 bg-green-100 text-green-700 rounded-full">
                              {slot.badge}
                            </span>
                          )}
                        </div>
                        <button
                          onClick={() => handleRemoveExistingSlot(slot.time)}
                          className="text-red-600 hover:bg-red-100 p-1 rounded"
                        >
                          <X size={16} />
                        </button>
                      </div>
                    ))}
                  </div>
                ) : (
                  <p className="text-gray-500 text-sm">No time slots configured yet</p>
                )}
              </div>
              
              {/* Add New Time Slots */}
              <div>
                <h3 className="text-lg font-semibold text-gray-800 mb-3">Add New Time Slots</h3>
                <div className="flex gap-2 mb-3">
                  <select
                    value={selectedTime}
                    onChange={(e) => setSelectedTime(e.target.value)}
                    className="flex-1 px-3 py-2 border-2 border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  >
                    <option value="">Select time...</option>
                    {availableTimeSlots.map(slot => (
                      <option key={slot.time} value={slot.time}>{slot.time}</option>
                    ))}
                  </select>
                  <input
                    type="number"
                    value={slotCount}
                    onChange={(e) => setSlotCount(e.target.value)}
                    min="1"
                    max="100"
                    placeholder="Slots"
                    className="w-24 px-3 py-2 border-2 border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                  <button
                    onClick={addTimeSlot}
                    disabled={!selectedTime}
                    className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
                  >
                    <Plus size={20} />
                  </button>
                </div>
                
                {newTimeSlots.length > 0 && (
                  <div className="space-y-2">
                    {newTimeSlots.map((slot, idx) => (
                      <div key={idx} className="flex items-center justify-between bg-green-50 p-3 rounded-lg">
                        <div>
                          <span className="font-semibold text-green-900">{slot.time}</span>
                          <span className="text-sm text-green-700 ml-3">({slot.totalSlots} slots)</span>
                          {slot.badge && (
                            <span className="ml-2 text-xs px-2 py-1 bg-green-200 text-green-800 rounded-full">
                              {slot.badge}
                            </span>
                          )}
                        </div>
                        <button
                          onClick={() => removeNewTimeSlot(idx)}
                          className="text-red-600 hover:bg-red-100 p-1 rounded"
                        >
                          <X size={16} />
                        </button>
                      </div>
                    ))}
                  </div>
                )}
              </div>
              
              <div className="flex gap-3 mt-6">
                <button
                  onClick={() => setTimeSlotModal(null)}
                  className="flex-1 px-4 py-3 border-2 border-gray-300 text-gray-700 rounded-xl font-semibold hover:bg-gray-50"
                >
                  Cancel
                </button>
                <button
                  onClick={handleSaveTimeSlots}
                  disabled={newTimeSlots.length === 0}
                  className="flex-1 px-4 py-3 bg-blue-600 text-white rounded-xl font-semibold hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Save Time Slots
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default Games;