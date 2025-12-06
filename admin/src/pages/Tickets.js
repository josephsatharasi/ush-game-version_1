import React, { useState, useEffect } from 'react';
import { Search, Filter, Eye, Download, CheckCircle, XCircle } from 'lucide-react';
import axios from 'axios';

const Tickets = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [tickets, setTickets] = useState([]);
  const [loading, setLoading] = useState(true);
  const [stats, setStats] = useState({ totalBookings: 0, activeBookings: 0 });

  useEffect(() => {
    fetchBookings();
    fetchStats();
  }, []);

  const fetchBookings = async () => {
    try {
      const token = localStorage.getItem('token');
      const res = await axios.get(`${process.env.REACT_APP_API_URL || 'https://ush-game-version-1.onrender.com'}/api/admin/bookings`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      setTickets(res.data.bookings);
    } catch (err) {
      console.error('Failed to fetch bookings:', err);
    } finally {
      setLoading(false);
    }
  };

  const fetchStats = async () => {
    try {
      const token = localStorage.getItem('token');
      const res = await axios.get(`${process.env.REACT_APP_API_URL || 'https://ush-game-version-1.onrender.com'}/api/admin/stats`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      setStats(res.data);
    } catch (err) {
      console.error('Failed to fetch stats:', err);
    }
  };

  const displayTickets = tickets.map(t => ({
    id: t.id,
    ticketNumber: t.ticketNumber,
    cardNumber: t.cardNumber,
    userName: t.username,
    phone: t.phone,
    gameType: t.gameName || 'Live Game',
    timeSlot: t.timeSlot ? new Date(t.timeSlot).toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' }) : 'N/A',
    status: t.status === 'DELIVERED' ? 'Active' : 'Pending',
    purchaseDate: new Date(t.bookedAt).toLocaleDateString()
  }));

  const getStatusColor = (status) => {
    switch(status) {
      case 'Active': return 'bg-blue-100 text-blue-800';
      case 'Won': return 'bg-green-100 text-green-800';
      case 'Lost': return 'bg-red-100 text-red-800';
      case 'Pending': return 'bg-yellow-100 text-yellow-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  return (
    <div className="p-6">
      <div className="mb-6">
        <h1 className="text-3xl font-bold text-gray-800">Tickets Management</h1>
        <p className="text-gray-600">Manage all game tickets</p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <div className="bg-white rounded-lg shadow-md p-4">
          <h3 className="text-sm text-gray-500">Total Tickets</h3>
          <p className="text-2xl font-bold text-gray-800">{stats.totalBookings || 0}</p>
        </div>
        <div className="bg-white rounded-lg shadow-md p-4">
          <h3 className="text-sm text-gray-500">Active Tickets</h3>
          <p className="text-2xl font-bold text-blue-600">{stats.activeBookings || 0}</p>
        </div>
        <div className="bg-white rounded-lg shadow-md p-4">
          <h3 className="text-sm text-gray-500">Winning Tickets</h3>
          <p className="text-2xl font-bold text-green-600">2,456</p>
        </div>
        <div className="bg-white rounded-lg shadow-md p-4">
          <h3 className="text-sm text-gray-500">Revenue</h3>
          <p className="text-2xl font-bold text-purple-600">₹18,90,340</p>
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
                placeholder="Search by ticket number, user name..."
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
              <option>Won</option>
              <option>Lost</option>
              <option>Pending</option>
            </select>
            <select className="px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500">
              <option>All Games</option>
              <option>Live Game</option>
              <option>FAM-JAM</option>
            </select>
          </div>
        </div>
      </div>

      {/* Tickets Table */}
      <div className="bg-white rounded-lg shadow-md overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Ticket ID</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">User</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Ticket Number</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Game Type</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Time Slot</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Price</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Status</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Actions</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr><td colSpan="8" className="text-center py-4">Loading...</td></tr>
              ) : displayTickets.length === 0 ? (
                <tr><td colSpan="8" className="text-center py-8 text-gray-500">No tickets found. Bookings will appear here once users book tickets.</td></tr>
              ) : displayTickets.map((ticket) => (
                <tr key={ticket.id} className="border-b hover:bg-gray-50">
                  <td className="py-3 px-4 font-medium">{ticket.ticketNumber}</td>
                  <td className="py-3 px-4">
                    <div>
                      <div className="font-medium">{ticket.userName}</div>
                      <div className="text-xs text-gray-500">{ticket.phone}</div>
                    </div>
                  </td>
                  <td className="py-3 px-4 font-mono">{ticket.cardNumber}</td>
                  <td className="py-3 px-4">
                    <span className="px-2 py-1 rounded-full text-xs bg-orange-100 text-orange-800">
                      {ticket.gameType}
                    </span>
                  </td>
                  <td className="py-3 px-4">{ticket.timeSlot}</td>
                  <td className="py-3 px-4 font-medium">Free</td>
                  <td className="py-3 px-4">
                    <span className={`px-2 py-1 rounded-full text-xs ${getStatusColor(ticket.status)}`}>
                      {ticket.status}
                    </span>
                  </td>
                  <td className="py-3 px-4">
                    <div className="flex space-x-2">
                      <button className="p-1 text-blue-600 hover:bg-blue-100 rounded">
                        <Eye size={16} />
                      </button>
                      <button className="p-1 text-green-600 hover:bg-green-100 rounded">
                        <Download size={16} />
                      </button>
                      {ticket.status === 'Won' && (
                        <button className="p-1 text-green-600 hover:bg-green-100 rounded">
                          <CheckCircle size={16} />
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

export default Tickets;