import React, { useState, useEffect } from 'react';
import axios from 'axios';

const API_URL = process.env.REACT_APP_API_URL ? `${process.env.REACT_APP_API_URL}/api` : 'http://localhost:5000/api';

const Winners = () => {
  const [games, setGames] = useState([]);
  const [selectedGame, setSelectedGame] = useState('');
  const [winners, setWinners] = useState([]);
  const [loading, setLoading] = useState(false);
  const [couponInputs, setCouponInputs] = useState({});

  useEffect(() => {
    fetchGames();
  }, []);
  
  useEffect(() => {
    let pollingInterval;
    if (selectedGame) {
      pollingInterval = setInterval(() => {
        fetchWinners(selectedGame);
      }, 2000);
    }
    return () => {
      if (pollingInterval) clearInterval(pollingInterval);
    };
  }, [selectedGame]);

  const fetchGames = async () => {
    try {
      const response = await axios.get(`${API_URL}/game/available`);
      setGames(response.data.games || []);
    } catch (error) {
      console.error('Error fetching games:', error);
      alert('Failed to load games. Please check if backend is running.');
    }
  };

  const fetchWinners = async (gameId) => {
    try {
      const token = localStorage.getItem('token');
      const response = await axios.get(`${API_URL}/game/${gameId}/winners`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      setWinners(response.data.winners || []);
      setLoading(false);
    } catch (error) {
      console.error('Error fetching winners:', error);
      setLoading(false);
    }
  };

  const handleGameSelect = (gameId) => {
    setSelectedGame(gameId);
    if (gameId) {
      fetchWinners(gameId);
    } else {
      setWinners([]);
    }
  };

  const handleCouponInput = (winType, value) => {
    setCouponInputs({ ...couponInputs, [winType]: value });
  };

  const assignCoupon = async (winType) => {
    const couponCode = couponInputs[winType];
    if (!couponCode || !couponCode.trim()) {
      alert('Please enter a coupon code');
      return;
    }

    if (!window.confirm(`Assign coupon "${couponCode.trim()}" to ${getWinTypeLabel(winType)} winner?`)) {
      return;
    }

    try {
      const token = localStorage.getItem('token');
      const response = await axios.post(
        `${API_URL}/game/${selectedGame}/assign-coupon`,
        { winType, couponCode: couponCode.trim() },
        { headers: { Authorization: `Bearer ${token}` } }
      );
      alert('✅ Coupon assigned successfully!');
      fetchWinners(selectedGame);
      setCouponInputs({ ...couponInputs, [winType]: '' });
    } catch (error) {
      console.error('Error assigning coupon:', error);
      alert('❌ ' + (error.response?.data?.message || 'Error assigning coupon'));
    }
  };

  const getWinTypeLabel = (type) => {
    const labels = {
      FIRST_LINE: 'First Line',
      SECOND_LINE: 'Second Line',
      THIRD_LINE: 'Third Line',
      JALDI: 'Jaldi (Quick Five)',
      HOUSIE: 'Housie (Full House)'
    };
    return labels[type] || type;
  };

  return (
    <div className="p-6">
      <h1 className="text-3xl font-bold mb-6">Winners Management</h1>

      {/* Game Selection */}
      <div className="bg-white rounded-lg shadow p-6 mb-6">
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Select Game ({games.length} games available)
        </label>
        <select
          value={selectedGame}
          onChange={(e) => handleGameSelect(e.target.value)}
          className="w-full md:w-96 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
        >
          <option value="">-- Select a Game --</option>
          {games.map((game) => (
            <option key={game._id} value={game._id}>
              {game.gameCode} - {game.status} - {new Date(game.scheduledTime).toLocaleString()}
            </option>
          ))}
        </select>
        {games.length === 0 && (
          <p className="text-sm text-gray-500 mt-2">No games found. Create a game first.</p>
        )}
      </div>

      {/* Winners List */}
      {loading ? (
        <div className="text-center py-8">Loading winners...</div>
      ) : winners.length > 0 ? (
        <div className="bg-white rounded-lg shadow overflow-hidden">
          <div className="px-6 py-4 border-b border-gray-200">
            <h2 className="text-xl font-semibold">Winners List</h2>
          </div>
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Win Type</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Username</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Email</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Phone</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Card Number</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Won At</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Coupon Code</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Action</th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {winners.map((winner, index) => (
                  <tr key={index}>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className="px-2 py-1 text-xs font-semibold rounded-full bg-blue-100 text-blue-800">
                        {getWinTypeLabel(winner.winType)}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">{winner.username}</td>
                    <td className="px-6 py-4 whitespace-nowrap">{winner.email}</td>
                    <td className="px-6 py-4 whitespace-nowrap">{winner.phone}</td>
                    <td className="px-6 py-4 whitespace-nowrap font-mono">{winner.cardNumber}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {new Date(winner.wonAt).toLocaleString()}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      {winner.hasCoupon ? (
                        <span className="px-3 py-1 text-sm font-semibold rounded bg-green-100 text-green-800">
                          {winner.couponCode}
                        </span>
                      ) : (
                        <span className="text-gray-400 text-sm">Not assigned</span>
                      )}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      {!winner.hasCoupon ? (
                        <div className="flex gap-2">
                          <input
                            type="text"
                            placeholder="Enter coupon code"
                            value={couponInputs[winner.winType] || ''}
                            onChange={(e) => handleCouponInput(winner.winType, e.target.value)}
                            className="px-3 py-1 border border-gray-300 rounded text-sm focus:ring-2 focus:ring-blue-500"
                          />
                          <button
                            onClick={() => assignCoupon(winner.winType)}
                            className="px-4 py-1 bg-blue-600 text-white rounded text-sm hover:bg-blue-700"
                          >
                            Assign
                          </button>
                        </div>
                      ) : (
                        <span className="text-green-600 text-sm font-medium">✓ Assigned</span>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      ) : selectedGame ? (
        <div className="bg-white rounded-lg shadow p-8 text-center text-gray-500">
          No winners yet for this game
        </div>
      ) : null}
    </div>
  );
};

export default Winners;
