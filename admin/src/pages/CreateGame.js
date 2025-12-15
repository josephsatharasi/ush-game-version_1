import React, { useState } from 'react';
import { Calendar, Users, Code, Plus, Clock, Ticket } from 'lucide-react';

const CreateGame = () => {
  const [formData, setFormData] = useState({
    gameCode: '',
    scheduledDate: '',
    totalSlots: 100,
    availableTickets: [1, 3, 6],
    maxTicketsPerUser: 6,
    availableTimeSlots: [],
    selectedWeekDays: []
  });
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState('');

  const ticketOptions = [1, 2, 3, 4, 5, 6];
  const weekDays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  const timeSlots = [
    { time: '10:00 AM', badge: 'Best time' },
    { time: '11:00 AM', badge: null },
    { time: '1:00 PM', badge: 'Low Time' },
    { time: '2:00 PM', badge: null },
    { time: '3:00 PM', badge: 'Good time' },
    { time: '4:00 PM', badge: null },
    { time: '5:00 PM', badge: null },
    { time: '6:00 PM', badge: 'Best time' }
  ];

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
    setMessage('');
  };

  const toggleTicket = (ticket) => {
    const tickets = formData.availableTickets.includes(ticket)
      ? formData.availableTickets.filter(t => t !== ticket)
      : [...formData.availableTickets, ticket].sort((a, b) => a - b);
    setFormData({ ...formData, availableTickets: tickets });
  };

  const toggleWeekDay = (day) => {
    const days = formData.selectedWeekDays.includes(day)
      ? formData.selectedWeekDays.filter(d => d !== day)
      : [...formData.selectedWeekDays, day];
    setFormData({ ...formData, selectedWeekDays: days });
  };



  const toggleTimeSlot = (slot) => {
    const exists = formData.availableTimeSlots.find(s => s.time === slot.time);
    const slots = exists
      ? formData.availableTimeSlots.filter(s => s.time !== slot.time)
      : [...formData.availableTimeSlots, { ...slot, totalSlots: 20, bookedSlots: 0 }];
    setFormData({ ...formData, availableTimeSlots: slots });
  };

  const updateSlotCount = (time, count) => {
    const slots = formData.availableTimeSlots.map(s => 
      s.time === time ? { ...s, totalSlots: parseInt(count) || 0 } : s
    );
    setFormData({ ...formData, availableTimeSlots: slots });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setMessage('');

    try {
      const token = localStorage.getItem('token');
      console.log('Using token:', token);
      console.log('API URL:', process.env.REACT_APP_API_URL);
      
      if (!token) {
        setMessage('❌ No authentication token found. Please login again.');
        setLoading(false);
        return;
      }
      
      // Create game first
      const gameResponse = await fetch(`${process.env.REACT_APP_API_URL}/api/admin/games/create`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          gameCode: formData.gameCode,
          scheduledTime: new Date(formData.scheduledDate).toISOString(),
          totalSlots: formData.totalSlots
        })
      });

      const gameData = await gameResponse.json();
      
      if (!gameResponse.ok) {
        setMessage('❌ ' + gameData.message);
        setLoading(false);
        return;
      }

      // Configure slots
      const configResponse = await fetch(`${process.env.REACT_APP_API_URL}/api/admin/games/${gameData.game._id}/configure-slots`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          maxTicketsPerUser: formData.maxTicketsPerUser,
          availableTickets: formData.availableTickets,
          availableTimeSlots: formData.availableTimeSlots,
          scheduledDate: formData.scheduledDate,
          selectedWeekDays: formData.selectedWeekDays
        })
      });

      const configData = await configResponse.json();
      
      if (configResponse.ok) {
        setMessage('✅ Game created and configured successfully!');
        setFormData({
          gameCode: '',
          scheduledDate: '',
          totalSlots: 100,
          availableTickets: [1, 3, 6],
          maxTicketsPerUser: 6,
          availableTimeSlots: [],
          selectedWeekDays: []
        });
      } else {
        setMessage('⚠️ Game created but configuration failed: ' + configData.message);
      }
    } catch (error) {
      setMessage('❌ Error creating game: ' + error.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="p-6 max-w-6xl mx-auto">
      <div className="mb-6">
        <h1 className="text-3xl font-bold text-gray-800">Create New Game</h1>
        <p className="text-gray-600">Configure game settings, tickets, days, and time slots</p>
      </div>

      <form onSubmit={handleSubmit} className="space-y-6">
        {/* Basic Info */}
        <div className="bg-white rounded-2xl shadow-xl p-6">
          <h2 className="text-xl font-bold text-gray-800 mb-4">Basic Information</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
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
                className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500"
                required
              />
            </div>
            <div>
              <label className="flex items-center text-sm font-semibold text-gray-700 mb-2">
                <Calendar size={18} className="mr-2 text-green-600" />
                Scheduled Date
              </label>
              <input
                type="datetime-local"
                name="scheduledDate"
                value={formData.scheduledDate}
                onChange={handleChange}
                className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-green-500"
                required
              />
            </div>
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
                className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-purple-500"
                required
              />
            </div>
            <div>
              <label className="flex items-center text-sm font-semibold text-gray-700 mb-2">
                <Ticket size={18} className="mr-2 text-orange-600" />
                Max Tickets Per User
              </label>
              <input
                type="number"
                name="maxTicketsPerUser"
                value={formData.maxTicketsPerUser}
                onChange={handleChange}
                min="1"
                max="10"
                className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-orange-500"
                required
              />
            </div>
          </div>
        </div>

        {/* Available Tickets */}
        <div className="bg-white rounded-2xl shadow-xl p-6">
          <h2 className="text-xl font-bold text-gray-800 mb-4">Available Ticket Options</h2>
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-3">
            {ticketOptions.map(ticket => (
              <button
                key={ticket}
                type="button"
                onClick={() => toggleTicket(ticket)}
                className={`py-3 px-4 rounded-xl font-semibold transition ${
                  formData.availableTickets.includes(ticket)
                    ? 'bg-blue-600 text-white shadow-lg'
                    : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                }`}
              >
                {ticket} Ticket{ticket > 1 ? 's' : ''}
              </button>
            ))}
          </div>
        </div>

        {/* Week Days Selection */}
        <div className="bg-white rounded-2xl shadow-xl p-6">
          <h2 className="text-xl font-bold text-gray-800 mb-4">Available Week Days</h2>
          <p className="text-sm text-gray-600 mb-4">Select the days when this game can be played</p>
          <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-7 gap-3">
            {weekDays.map(day => (
              <button
                key={day}
                type="button"
                onClick={() => toggleWeekDay(day)}
                className={`py-3 px-4 rounded-xl font-semibold transition ${
                  formData.selectedWeekDays.includes(day)
                    ? 'bg-green-600 text-white shadow-lg'
                    : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                }`}
              >
                {day.substring(0, 3)}
              </button>
            ))}
          </div>
        </div>



        {/* Time Slots */}
        <div className="bg-white rounded-2xl shadow-xl p-6">
          <h2 className="text-xl font-bold text-gray-800 mb-4">Available Time Slots</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            {timeSlots.map(slot => {
              const selected = formData.availableTimeSlots.find(s => s.time === slot.time);
              return (
                <div key={slot.time} className="border-2 border-gray-200 rounded-xl p-4">
                  <div className="flex items-center justify-between mb-2">
                    <button
                      type="button"
                      onClick={() => toggleTimeSlot(slot)}
                      className={`flex-1 py-2 px-3 rounded-lg font-semibold transition ${
                        selected
                          ? 'bg-blue-600 text-white'
                          : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                      }`}
                    >
                      {slot.time}
                    </button>
                  </div>
                  {slot.badge && (
                    <span className={`text-xs px-2 py-1 rounded-full ${
                      slot.badge === 'Best time' ? 'bg-green-100 text-green-700' :
                      slot.badge === 'Good time' ? 'bg-orange-100 text-orange-700' :
                      'bg-red-100 text-red-700'
                    }`}>
                      {slot.badge}
                    </span>
                  )}
                  {selected && (
                    <div className="mt-2">
                      <label className="text-xs text-gray-600">Slots:</label>
                      <input
                        type="number"
                        value={selected.totalSlots}
                        onChange={(e) => updateSlotCount(slot.time, e.target.value)}
                        min="1"
                        max="100"
                        className="w-full px-2 py-1 border border-gray-300 rounded text-sm"
                      />
                    </div>
                  )}
                </div>
              );
            })}
          </div>
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
  );
};

export default CreateGame;
