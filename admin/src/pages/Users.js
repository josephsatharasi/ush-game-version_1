import React, { useState } from 'react';
import { Search, Filter, Eye, Edit, Ban, UserCheck, MapPin } from 'lucide-react';

const Users = () => {
  const [searchTerm, setSearchTerm] = useState('');

  const users = [
    {
      id: 'U001',
      name: 'Kishore',
      phone: '+91 9876543210',
      location: 'Visakhapatnam, Pendurthi',
      gamesPlayed: 45,
      totalWinnings: '₹12,500',
      status: 'Active',
      joinDate: '2024-01-10',
      lastActive: '2 hours ago'
    },
    {
      id: 'U002',
      name: 'Nandha Kishore',
      phone: '+91 9876543211',
      location: 'Visakhapatnam, MVP',
      gamesPlayed: 32,
      totalWinnings: '₹8,200',
      status: 'Active',
      joinDate: '2024-01-08',
      lastActive: '1 hour ago'
    },
    {
      id: 'U003',
      name: 'Bhaskar Ram',
      phone: '+91 9876543212',
      location: 'Visakhapatnam, Gajuwaka',
      gamesPlayed: 28,
      totalWinnings: '₹6,750',
      status: 'Inactive',
      joinDate: '2024-01-05',
      lastActive: '2 days ago'
    },
    {
      id: 'U004',
      name: 'Neethu',
      phone: '+91 9876543213',
      location: 'Visakhapatnam, Dwaraka',
      gamesPlayed: 15,
      totalWinnings: '₹3,400',
      status: 'Active',
      joinDate: '2024-01-12',
      lastActive: '30 minutes ago'
    }
  ];

  const getStatusColor = (status) => {
    switch(status) {
      case 'Active': return 'bg-green-100 text-green-800';
      case 'Inactive': return 'bg-yellow-100 text-yellow-800';
      case 'Banned': return 'bg-red-100 text-red-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  return (
    <div className="p-6">
      <div className="mb-6">
        <h1 className="text-3xl font-bold text-gray-800">Users Management</h1>
        <p className="text-gray-600">Manage all registered users</p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <div className="bg-white rounded-lg shadow-md p-4">
          <h3 className="text-sm text-gray-500">Total Users</h3>
          <p className="text-2xl font-bold text-gray-800">12,543</p>
        </div>
        <div className="bg-white rounded-lg shadow-md p-4">
          <h3 className="text-sm text-gray-500">Active Users</h3>
          <p className="text-2xl font-bold text-green-600">9,876</p>
        </div>
        <div className="bg-white rounded-lg shadow-md p-4">
          <h3 className="text-sm text-gray-500">New This Month</h3>
          <p className="text-2xl font-bold text-blue-600">1,234</p>
        </div>
        <div className="bg-white rounded-lg shadow-md p-4">
          <h3 className="text-sm text-gray-500">Banned Users</h3>
          <p className="text-2xl font-bold text-red-600">45</p>
        </div>
      </div>

      {/* Filters */}
      <div className="bg-white rounded-lg shadow-md p-4 mb-6">
        <div className="flex flex-col md:flex-row gap-4">
          <div className="flex-1">
            <div className="relative">
              <Search size={20} className="absolute left-3 top-3 text-gray-400" />
              <input
                type="text"
                placeholder="Search users by name, phone, or location..."
                className="w-full pl-10 pr-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
            </div>
          </div>
          <div className="flex gap-2">
            <select className="px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500">
              <option>All Status</option>
              <option>Active</option>
              <option>Inactive</option>
              <option>Banned</option>
            </select>
            <select className="px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500">
              <option>All Locations</option>
              <option>Visakhapatnam</option>
              <option>Hyderabad</option>
              <option>Bangalore</option>
            </select>
            <button className="px-4 py-2 border rounded-lg flex items-center hover:bg-gray-50">
              <Filter size={16} className="mr-2" />
              Filter
            </button>
          </div>
        </div>
      </div>

      {/* Users Table */}
      <div className="bg-white rounded-lg shadow-md overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="text-left py-3 px-4 font-medium text-gray-700">User</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Contact</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Location</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Games</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Winnings</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Status</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Last Active</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Actions</th>
              </tr>
            </thead>
            <tbody>
              {users.map((user) => (
                <tr key={user.id} className="border-b hover:bg-gray-50">
                  <td className="py-3 px-4">
                    <div>
                      <p className="font-medium text-gray-800">{user.name}</p>
                      <p className="text-sm text-gray-500">{user.id}</p>
                    </div>
                  </td>
                  <td className="py-3 px-4">
                    <p className="text-sm">{user.phone}</p>
                  </td>
                  <td className="py-3 px-4">
                    <div className="flex items-center">
                      <MapPin size={14} className="mr-1 text-gray-400" />
                      <span className="text-sm">{user.location}</span>
                    </div>
                  </td>
                  <td className="py-3 px-4 text-center">{user.gamesPlayed}</td>
                  <td className="py-3 px-4 font-medium text-green-600">{user.totalWinnings}</td>
                  <td className="py-3 px-4">
                    <span className={`px-2 py-1 rounded-full text-xs ${getStatusColor(user.status)}`}>
                      {user.status}
                    </span>
                  </td>
                  <td className="py-3 px-4 text-sm text-gray-500">{user.lastActive}</td>
                  <td className="py-3 px-4">
                    <div className="flex space-x-2">
                      <button className="p-1 text-blue-600 hover:bg-blue-100 rounded">
                        <Eye size={16} />
                      </button>
                      <button className="p-1 text-green-600 hover:bg-green-100 rounded">
                        <Edit size={16} />
                      </button>
                      {user.status === 'Active' ? (
                        <button className="p-1 text-red-600 hover:bg-red-100 rounded">
                          <Ban size={16} />
                        </button>
                      ) : (
                        <button className="p-1 text-green-600 hover:bg-green-100 rounded">
                          <UserCheck size={16} />
                        </button>
                      )}
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

export default Users;