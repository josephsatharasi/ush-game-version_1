import React from 'react';
import { Users, GamepadIcon, Trophy, DollarSign, TrendingUp, Clock } from 'lucide-react';

const Dashboard = () => {
  const stats = [
    { title: 'Total Users', value: '12,543', icon: Users, color: 'bg-blue-500', change: '+12%' },
    { title: 'Active Games', value: '45', icon: GamepadIcon, color: 'bg-orange-500', change: '+8%' },
    { title: 'Total Revenue', value: '₹2,45,670', icon: DollarSign, color: 'bg-pink-500', change: '+15%' },
    { title: 'Winners Today', value: '234', icon: Trophy, color: 'bg-green-500', change: '+5%' }
  ];

  const recentGames = [
    { id: 'G001', type: 'Live Game', players: 45, status: 'Active', time: '2:30 PM' },
    { id: 'G002', type: 'FAM-JAM', players: 12, status: 'Completed', time: '2:00 PM' },
    { id: 'G003', type: 'Live Game', players: 67, status: 'Active', time: '1:45 PM' },
    { id: 'G004', type: 'FAM-JAM', players: 8, status: 'Waiting', time: '3:00 PM' }
  ];

  return (
    <div className="p-4 lg:p-6">
      <div className="mb-6">
        <h1 className="text-2xl lg:text-3xl font-bold text-gray-800">Dashboard</h1>
        <p className="text-gray-600">Welcome to Ush Admin Panel</p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 lg:gap-6 mb-6 lg:mb-8">
        {stats.map((stat, index) => (
          <div key={index} className="bg-white rounded-xl shadow-lg p-4 lg:p-6 border-l-4 border-blue-500">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-gray-500 text-xs lg:text-sm">{stat.title}</p>
                <p className="text-lg lg:text-2xl font-bold text-gray-800">{stat.value}</p>
                <p className="text-green-500 text-xs lg:text-sm flex items-center">
                  <TrendingUp size={14} className="mr-1" />
                  {stat.change}
                </p>
              </div>
              <div className={`${stat.color} p-2 lg:p-3 rounded-full`}>
                <stat.icon size={20} className="text-white lg:w-6 lg:h-6" />
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Recent Games */}
      <div className="bg-white rounded-xl shadow-lg p-4 lg:p-6">
        <h2 className="text-lg lg:text-xl font-bold text-gray-800 mb-4">Recent Games</h2>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b">
                <th className="text-left py-2 lg:py-3 px-2 lg:px-4 text-sm lg:text-base">Game ID</th>
                <th className="text-left py-2 lg:py-3 px-2 lg:px-4 text-sm lg:text-base">Type</th>
                <th className="text-left py-2 lg:py-3 px-2 lg:px-4 text-sm lg:text-base">Players</th>
                <th className="text-left py-2 lg:py-3 px-2 lg:px-4 text-sm lg:text-base">Status</th>
                <th className="text-left py-2 lg:py-3 px-2 lg:px-4 text-sm lg:text-base">Time</th>
              </tr>
            </thead>
            <tbody>
              {recentGames.map((game) => (
                <tr key={game.id} className="border-b hover:bg-gray-50">
                  <td className="py-2 lg:py-3 px-2 lg:px-4 font-medium text-sm lg:text-base">{game.id}</td>
                  <td className="py-2 lg:py-3 px-2 lg:px-4 text-sm lg:text-base">
                    <span className={`px-2 py-1 rounded-full text-xs ${
                      game.type === 'Live Game' ? 'bg-orange-100 text-orange-800' : 'bg-pink-100 text-pink-800'
                    }`}>
                      {game.type}
                    </span>
                  </td>
                  <td className="py-2 lg:py-3 px-2 lg:px-4 text-sm lg:text-base">{game.players}</td>
                  <td className="py-2 lg:py-3 px-2 lg:px-4">
                    <span className={`px-2 py-1 rounded-full text-xs ${
                      game.status === 'Active' ? 'bg-green-100 text-green-800' :
                      game.status === 'Completed' ? 'bg-blue-100 text-blue-800' :
                      'bg-yellow-100 text-yellow-800'
                    }`}>
                      {game.status}
                    </span>
                  </td>
                  <td className="py-2 lg:py-3 px-2 lg:px-4 flex items-center text-sm lg:text-base">
                    <Clock size={14} className="mr-2 text-gray-400" />
                    {game.time}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;