import React, { useState, useEffect } from 'react';
import { Play, Square, Send, Trophy, Gamepad2, Dices, Volume2, Zap, Award, Target } from 'lucide-react';

const GameControl = () => {
  const [games, setGames] = useState([]);
  const [selectedGame, setSelectedGame] = useState(null);
  const [numberInput, setNumberInput] = useState('');
  const [announcedNumbers, setAnnouncedNumbers] = useState([]);
  const [winners, setWinners] = useState({});
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchGames();
  }, []);

  const fetchGames = async () => {
    try {
      const token = localStorage.getItem('token');
      const response = await fetch(`${process.env.REACT_APP_API_URL || 'http://localhost:5000'}/api/admin/games/all`, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });
      const data = await response.json();
      if (response.ok && data.games) {
        setGames(data.games.filter(g => g.status === 'SCHEDULED' || g.status === 'LIVE'));
      }
    } catch (error) {
      console.error('Error fetching games:', error);
    } finally {
      setLoading(false);
    }
  };

  const startGame = async (gameId) => {
    try {
      const token = localStorage.getItem('token');
      const response = await fetch(`${process.env.REACT_APP_API_URL || 'http://localhost:5000'}/api/admin/games/${gameId}/start`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });
      const data = await response.json();
      alert(data.message);
      setSelectedGame(gameId);
    } catch (error) {
      alert('Error starting game');
    }
  };

  const announceNumber = async () => {
    const number = parseInt(numberInput);
    if (!number || number < 1 || number > 90) {
      alert('Enter valid number (1-90)');
      return;
    }

    try {
      const token = localStorage.getItem('token');
      const response = await fetch(`${process.env.REACT_APP_API_URL || 'http://localhost:5000'}/api/admin/games/${selectedGame}/announce`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ number })
      });
      const data = await response.json();
      if (response.ok) {
        setAnnouncedNumbers(data.game.announcedNumbers);
        setWinners({
          firstLine: data.game.firstLineWinner,
          secondLine: data.game.secondLineWinner,
          thirdLine: data.game.thirdLineWinner,
          jaldi: data.game.jaldiWinner,
          housie: data.game.housieWinner
        });
        setNumberInput('');
      } else {
        alert(data.message);
      }
    } catch (error) {
      alert('Error announcing number');
    }
  };

  const endGame = async () => {
    try {
      const token = localStorage.getItem('token');
      const response = await fetch(`${process.env.REACT_APP_API_URL || 'http://localhost:5000'}/api/admin/games/${selectedGame}/end`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });
      const data = await response.json();
      alert(data.message);
      setSelectedGame(null);
      setAnnouncedNumbers([]);
    } catch (error) {
      alert('Error ending game');
    }
  };

  return (
    <div className="p-6">
      <h1 className="text-3xl font-bold text-gray-800 mb-6">Game Control Panel</h1>

      {!selectedGame ? (
        <div className="bg-white rounded-lg shadow-md p-6">
          <h2 className="text-xl font-bold mb-4">Select Game to Control</h2>
          {loading ? (
            <p className="text-gray-500 text-center py-8">Loading games...</p>
          ) : games.length === 0 ? (
            <p className="text-gray-500 text-center py-8">No games available</p>
          ) : (
            <div className="space-y-3">
              {games.map(game => (
                <div key={game._id} className="flex justify-between items-center p-4 border rounded">
                  <div>
                    <span className="font-medium">{game.gameCode}</span>
                    <p className="text-sm text-gray-500">Status: {game.status}</p>
                  </div>
                  <button 
                    onClick={() => startGame(game._id)}
                    className="bg-green-600 text-white px-4 py-2 rounded flex items-center hover:bg-green-700"
                    disabled={game.status === 'LIVE'}
                  >
                    <Play size={16} className="mr-2" />
                    {game.status === 'LIVE' ? 'Running' : 'Start Game'}
                  </button>
                </div>
              ))}
            </div>
          )}
        </div>
      ) : (
        <div className="space-y-6">
          {/* Game Header */}
          <div className="bg-gradient-to-r from-blue-600 to-purple-600 rounded-2xl shadow-xl p-6 text-white">
            <div className="flex justify-between items-center mb-6">
              <div className="flex items-center">
                <Gamepad2 size={32} className="mr-3" />
                <div>
                  <h2 className="text-2xl font-bold">{games.find(g => g._id === selectedGame)?.gameCode || selectedGame}</h2>
                  <p className="text-blue-100 text-sm mt-1">Live Game Control</p>
                </div>
              </div>
              <button 
                onClick={endGame}
                className="bg-red-500 text-white px-6 py-3 rounded-full flex items-center hover:bg-red-600 shadow-lg transition"
              >
                <Square size={18} className="mr-2" />
                End Game
              </button>
            </div>

            {/* Number Input Section */}
            <div className="bg-white/10 backdrop-blur-sm rounded-xl p-6">
              <div className="flex gap-3">
                <input
                  type="number"
                  min="1"
                  max="90"
                  value={numberInput}
                  onChange={(e) => setNumberInput(e.target.value)}
                  onKeyPress={(e) => e.key === 'Enter' && announceNumber()}
                  placeholder="Enter number (1-90)"
                  className="flex-1 px-6 py-4 text-2xl font-bold text-gray-800 rounded-xl focus:outline-none focus:ring-4 focus:ring-yellow-400 text-center"
                />
                <button 
                  onClick={announceNumber}
                  className="bg-gradient-to-r from-yellow-400 to-orange-500 text-white px-8 py-4 rounded-xl flex items-center hover:from-yellow-500 hover:to-orange-600 shadow-lg transition font-bold text-lg"
                >
                  <Send size={20} className="mr-2" />
                  Announce
                </button>
              </div>
              <div className="mt-4 text-center">
                <span className="bg-white/20 px-4 py-2 rounded-full text-sm font-semibold flex items-center justify-center">
                  <Volume2 size={16} className="mr-2" />
                  Announced: {announcedNumbers.length} / 90
                </span>
              </div>
            </div>
          </div>

          {/* Announced Numbers */}
          <div className="bg-white rounded-2xl shadow-xl p-6">
            <h3 className="text-xl font-bold mb-4 text-gray-800 flex items-center">
              <span className="bg-blue-100 p-2 rounded-lg mr-3">
                <Dices size={20} className="text-blue-600" />
              </span>
              Announced Numbers
            </h3>
            <div className="grid grid-cols-9 gap-3">
              {announcedNumbers.map((num, idx) => (
                <div 
                  key={idx} 
                  className="bg-gradient-to-br from-blue-500 to-blue-600 text-white p-3 rounded-xl text-center font-bold text-lg shadow-md hover:scale-105 transition"
                >
                  {num}
                </div>
              ))}
            </div>
            {announcedNumbers.length === 0 && (
              <p className="text-gray-400 text-center py-8">No numbers announced yet</p>
            )}
          </div>

          {/* Winners */}
          <div className="bg-white rounded-2xl shadow-xl p-6">
            <h3 className="text-xl font-bold mb-4 text-gray-800 flex items-center">
              <Trophy className="text-yellow-500 mr-3" size={24} />
              Winners Board
            </h3>
            <div className="space-y-3">
              {winners.firstLine && (
                <div className="flex justify-between items-center p-4 bg-gradient-to-r from-blue-50 to-blue-100 rounded-xl border-l-4 border-blue-500">
                  <div className="flex items-center">
                    <div className="bg-blue-500 p-2 rounded-lg mr-3">
                      <Award size={20} className="text-white" />
                    </div>
                    <span className="font-bold text-gray-800">First Line</span>
                  </div>
                  <span className="bg-blue-500 text-white px-4 py-2 rounded-full font-bold">#{winners.firstLine.cardNumber}</span>
                </div>
              )}
              {winners.secondLine && (
                <div className="flex justify-between items-center p-4 bg-gradient-to-r from-red-50 to-red-100 rounded-xl border-l-4 border-red-500">
                  <div className="flex items-center">
                    <div className="bg-red-500 p-2 rounded-lg mr-3">
                      <Award size={20} className="text-white" />
                    </div>
                    <span className="font-bold text-gray-800">Second Line</span>
                  </div>
                  <span className="bg-red-500 text-white px-4 py-2 rounded-full font-bold">#{winners.secondLine.cardNumber}</span>
                </div>
              )}
              {winners.thirdLine && (
                <div className="flex justify-between items-center p-4 bg-gradient-to-r from-green-50 to-green-100 rounded-xl border-l-4 border-green-500">
                  <div className="flex items-center">
                    <div className="bg-green-500 p-2 rounded-lg mr-3">
                      <Award size={20} className="text-white" />
                    </div>
                    <span className="font-bold text-gray-800">Third Line</span>
                  </div>
                  <span className="bg-green-500 text-white px-4 py-2 rounded-full font-bold">#{winners.thirdLine.cardNumber}</span>
                </div>
              )}
              {winners.jaldi && (
                <div className="flex justify-between items-center p-4 bg-gradient-to-r from-yellow-50 to-yellow-100 rounded-xl border-l-4 border-yellow-500">
                  <div className="flex items-center">
                    <div className="bg-yellow-500 p-2 rounded-lg mr-3">
                      <Zap size={20} className="text-white" />
                    </div>
                    <span className="font-bold text-gray-800">Jaldi</span>
                  </div>
                  <span className="bg-yellow-500 text-white px-4 py-2 rounded-full font-bold">#{winners.jaldi.cardNumber}</span>
                </div>
              )}
              {winners.housie && (
                <div className="flex justify-between items-center p-4 bg-gradient-to-r from-purple-50 to-purple-100 rounded-xl border-l-4 border-purple-500">
                  <div className="flex items-center">
                    <div className="bg-purple-500 p-2 rounded-lg mr-3">
                      <Trophy size={20} className="text-white" />
                    </div>
                    <span className="font-bold text-gray-800">Housie (Full House)</span>
                  </div>
                  <span className="bg-purple-500 text-white px-4 py-2 rounded-full font-bold">#{winners.housie.cardNumber}</span>
                </div>
              )}
              {!winners.firstLine && !winners.secondLine && !winners.thirdLine && !winners.jaldi && !winners.housie && (
                <div className="text-center py-8">
                  <Target size={64} className="text-gray-300 mx-auto mb-3" />
                  <p className="text-gray-400 font-medium">No winners yet - Keep playing!</p>
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default GameControl;
