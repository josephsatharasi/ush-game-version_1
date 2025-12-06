import React, { useState } from 'react';
import { Plus, Search, Filter, Eye, Edit, Trash2, Play, Pause } from 'lucide-react';

const Games = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [filterStatus, setFilterStatus] = useState('all');

  const games = [
    { 
      id: 'G001', 
      type: 'Live Game', 
      players: 45, 
      maxPlayers: 100, 
      status: 'Active', 
      timeSlot: '2:30 PM', 
      prizePool: '₹5000',
      created: '2024-01-15'
    },
    { 
      id: 'G002', 
      type: 'FAM-JAM', 
      players: 12, 
      maxPlayers: 20, 
      status: 'Completed', 
      timeSlot: '2:00 PM', 
      prizePool: '₹1200',
      created: '2024-01-15'
    },
    { 
      id: 'G003', 
      type: 'Live Game', 
      players: 67, 
      maxPlayers: 100, 
      status: 'Active', 
      timeSlot: '1:45 PM', 
      prizePool: '₹6700',
      created: '2024-01-15'
    },
    { 
      id: 'G004', 
      type: 'FAM-JAM', 
      players: 8, 
      maxPlayers: 15, 
      status: 'Waiting', 
      timeSlot: '3:00 PM', 
      prizePool: '₹800',
      created: '2024-01-15'
    }
  ];

  const getStatusColor = (status) => {
    switch(status) {
      case 'Active': return 'bg-green-100 text-green-800';
      case 'Completed': return 'bg-blue-100 text-blue-800';
      case 'Waiting': return 'bg-yellow-100 text-yellow-800';
      case 'Cancelled': return 'bg-red-100 text-red-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

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
              {games.map((game) => (
                <tr key={game.id} className="border-b hover:bg-gray-50">
                  <td className="py-3 px-4 font-medium">{game.id}</td>
                  <td className="py-3 px-4">
                    <span className={`px-2 py-1 rounded-full text-xs ${
                      game.type === 'Live Game' ? 'bg-orange-100 text-orange-800' : 'bg-pink-100 text-pink-800'
                    }`}>
                      {game.type}
                    </span>
                  </td>
                  <td className="py-3 px-4">{game.players}/{game.maxPlayers}</td>
                  <td className="py-3 px-4">
                    <span className={`px-2 py-1 rounded-full text-xs ${getStatusColor(game.status)}`}>
                      {game.status}
                    </span>
                  </td>
                  <td className="py-3 px-4">{game.timeSlot}</td>
                  <td className="py-3 px-4 font-medium">{game.prizePool}</td>
                  <td className="py-3 px-4">
                    <div className="flex space-x-2">
                      <button className="p-1 text-blue-600 hover:bg-blue-100 rounded">
                        <Eye size={16} />
                      </button>
                      <button className="p-1 text-green-600 hover:bg-green-100 rounded">
                        <Edit size={16} />
                      </button>
                      {game.status === 'Active' ? (
                        <button className="p-1 text-yellow-600 hover:bg-yellow-100 rounded">
                          <Pause size={16} />
                        </button>
                      ) : (
                        <button className="p-1 text-green-600 hover:bg-green-100 rounded">
                          <Play size={16} />
                        </button>
                      )}
                      <button className="p-1 text-red-600 hover:bg-red-100 rounded">
                        <Trash2 size={16} />
                      </button>
                    </div>
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

export default Games;