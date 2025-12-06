import React, { useState } from 'react';
import { Trophy, Medal, Award, TrendingUp, Crown } from 'lucide-react';

const Leaderboard = () => {
  const [viewMode, setViewMode] = useState('global');

  const globalLeaders = [
    { rank: 1, name: 'Kishore', location: 'Visakhapatnam', coins: 15420, gamesWon: 45, winRate: '78%', avatar: 'K' },
    { rank: 2, name: 'Nandha Kishore', location: 'Visakhapatnam', coins: 12350, gamesWon: 38, winRate: '72%', avatar: 'N' },
    { rank: 3, name: 'Bhaskar Ram', location: 'Visakhapatnam', coins: 9870, gamesWon: 32, winRate: '68%', avatar: 'B' },
    { rank: 4, name: 'Neethu', location: 'Visakhapatnam', coins: 8450, gamesWon: 28, winRate: '65%', avatar: 'N' },
    { rank: 5, name: 'Rajesh Kumar', location: 'Hyderabad', coins: 7890, gamesWon: 25, winRate: '62%', avatar: 'R' },
    { rank: 6, name: 'Priya Sharma', location: 'Bangalore', coins: 7234, gamesWon: 23, winRate: '60%', avatar: 'P' },
    { rank: 7, name: 'Amit Singh', location: 'Delhi', coins: 6789, gamesWon: 21, winRate: '58%', avatar: 'A' },
    { rank: 8, name: 'Sneha Reddy', location: 'Chennai', coins: 6234, gamesWon: 19, winRate: '55%', avatar: 'S' }
  ];

  const areaLeaders = [
    { rank: 1, name: 'Kishore', area: 'Pendurthi', coins: 15420, gamesWon: 45, avatar: 'K' },
    { rank: 2, name: 'Nandha Kishore', area: 'MVP Colony', coins: 12350, gamesWon: 38, avatar: 'N' },
    { rank: 3, name: 'Bhaskar Ram', area: 'Gajuwaka', coins: 9870, gamesWon: 32, avatar: 'B' },
    { rank: 4, name: 'Neethu', area: 'Dwaraka Nagar', coins: 8450, gamesWon: 28, avatar: 'N' }
  ];

  const getRankIcon = (rank) => {
    switch(rank) {
      case 1: return <Crown className="text-yellow-500" size={24} />;
      case 2: return <Medal className="text-gray-400" size={24} />;
      case 3: return <Award className="text-orange-500" size={24} />;
      default: return <span className="text-lg font-bold text-gray-600">#{rank}</span>;
    }
  };

  const getRankBg = (rank) => {
    switch(rank) {
      case 1: return 'bg-gradient-to-r from-yellow-400 to-yellow-600';
      case 2: return 'bg-gradient-to-r from-gray-300 to-gray-500';
      case 3: return 'bg-gradient-to-r from-orange-400 to-orange-600';
      default: return 'bg-white';
    }
  };

  return (
    <div className="p-6">
      <div className="mb-6">
        <h1 className="text-3xl font-bold text-gray-800">Leaderboard</h1>
        <p className="text-gray-600">Top performers and winners</p>
      </div>

      {/* View Toggle */}
      <div className="mb-6">
        <div className="flex space-x-4">
          <button
            onClick={() => setViewMode('global')}
            className={`px-6 py-2 rounded-lg font-medium ${
              viewMode === 'global' 
                ? 'bg-purple-600 text-white' 
                : 'bg-white text-gray-600 border'
            }`}
          >
            Global Rankings
          </button>
          <button
            onClick={() => setViewMode('area')}
            className={`px-6 py-2 rounded-lg font-medium ${
              viewMode === 'area' 
                ? 'bg-purple-600 text-white' 
                : 'bg-white text-gray-600 border'
            }`}
          >
            Area Rankings
          </button>
        </div>
      </div>

      {/* Top 3 Podium */}
      <div className="mb-8">
        <div className="flex justify-center items-end space-x-4 mb-6">
          {/* 2nd Place */}
          <div className="text-center">
            <div className={`${getRankBg(2)} text-white p-6 rounded-lg shadow-lg transform -rotate-2`}>
              <div className="w-16 h-16 bg-white rounded-full flex items-center justify-center mx-auto mb-2">
                <span className="text-2xl font-bold text-gray-800">{globalLeaders[1].avatar}</span>
              </div>
              <Medal className="text-gray-200 mx-auto mb-2" size={32} />
              <h3 className="font-bold">{globalLeaders[1].name}</h3>
              <p className="text-sm opacity-90">{globalLeaders[1].coins} coins</p>
            </div>
          </div>

          {/* 1st Place */}
          <div className="text-center">
            <div className={`${getRankBg(1)} text-white p-8 rounded-lg shadow-xl transform scale-110`}>
              <div className="w-20 h-20 bg-white rounded-full flex items-center justify-center mx-auto mb-2">
                <span className="text-3xl font-bold text-gray-800">{globalLeaders[0].avatar}</span>
              </div>
              <Crown className="text-yellow-200 mx-auto mb-2" size={40} />
              <h3 className="font-bold text-lg">{globalLeaders[0].name}</h3>
              <p className="opacity-90">{globalLeaders[0].coins} coins</p>
            </div>
          </div>

          {/* 3rd Place */}
          <div className="text-center">
            <div className={`${getRankBg(3)} text-white p-6 rounded-lg shadow-lg transform rotate-2`}>
              <div className="w-16 h-16 bg-white rounded-full flex items-center justify-center mx-auto mb-2">
                <span className="text-2xl font-bold text-gray-800">{globalLeaders[2].avatar}</span>
              </div>
              <Award className="text-orange-200 mx-auto mb-2" size={32} />
              <h3 className="font-bold">{globalLeaders[2].name}</h3>
              <p className="text-sm opacity-90">{globalLeaders[2].coins} coins</p>
            </div>
          </div>
        </div>
      </div>

      {/* Leaderboard Table */}
      <div className="bg-white rounded-lg shadow-md overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Rank</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Player</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">
                  {viewMode === 'global' ? 'Location' : 'Area'}
                </th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Coins</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Games Won</th>
                {viewMode === 'global' && (
                  <th className="text-left py-3 px-4 font-medium text-gray-700">Win Rate</th>
                )}
              </tr>
            </thead>
            <tbody>
              {(viewMode === 'global' ? globalLeaders : areaLeaders).map((player) => (
                <tr key={player.rank} className={`border-b hover:bg-gray-50 ${
                  player.rank <= 3 ? 'bg-gradient-to-r from-yellow-50 to-transparent' : ''
                }`}>
                  <td className="py-3 px-4">
                    <div className="flex items-center">
                      {getRankIcon(player.rank)}
                    </div>
                  </td>
                  <td className="py-3 px-4">
                    <div className="flex items-center">
                      <div className="w-10 h-10 bg-purple-500 rounded-full flex items-center justify-center mr-3">
                        <span className="text-white font-bold">{player.avatar}</span>
                      </div>
                      <div>
                        <p className="font-medium text-gray-800">{player.name}</p>
                      </div>
                    </div>
                  </td>
                  <td className="py-3 px-4 text-gray-600">
                    {viewMode === 'global' ? player.location : player.area}
                  </td>
                  <td className="py-3 px-4">
                    <div className="flex items-center">
                      <Trophy className="text-yellow-500 mr-1" size={16} />
                      <span className="font-bold text-purple-600">{player.coins}</span>
                    </div>
                  </td>
                  <td className="py-3 px-4 text-center font-medium">{player.gamesWon}</td>
                  {viewMode === 'global' && (
                    <td className="py-3 px-4">
                      <div className="flex items-center">
                        <TrendingUp className="text-green-500 mr-1" size={16} />
                        <span className="text-green-600 font-medium">{player.winRate}</span>
                      </div>
                    </td>
                  )}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default Leaderboard;