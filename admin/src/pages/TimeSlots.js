import React, { useState, useEffect } from 'react';
import { 
  Clock, 
  Users, 
  GamepadIcon, 
  Calendar,
  Activity,
  Plus,
  Play,
  Pause,
  Edit,
  Zap,
  TrendingUp
} from 'lucide-react';

const TimeSlots = () => {
  const [currentTime, setCurrentTime] = useState(new Date());
  const [liveStats, setLiveStats] = useState({
    activeSlots: 12,
    totalBookings: 456,
    currentPlayers: 1247,
    nextGameIn: 180
  });

  // Update current time every second
  useEffect(() => {
    const timeInterval = setInterval(() => {
      setCurrentTime(new Date());
    }, 1000);

    return () => clearInterval(timeInterval);
  }, []);

  // Real-time stats updates
  useEffect(() => {
    const interval = setInterval(() => {
      setLiveStats(prev => ({
        activeSlots: Math.max(8, prev.activeSlots + Math.floor(Math.random() * 4) - 2),
        totalBookings: prev.totalBookings + Math.floor(Math.random() * 5),
        currentPlayers: prev.currentPlayers + Math.floor(Math.random() * 20) - 10,
        nextGameIn: prev.nextGameIn > 0 ? prev.nextGameIn - 1 : 300
      }));
    }, 1000);

    return () => clearInterval(interval);
  }, []);

  const timeSlots = [
    {
      id: 'TS001',
      time: '10:00 AM',
      duration: '30 min',
      maxPlayers: 100,
      currentPlayers: 87,
      gameType: 'Live Game',
      status: 'Active',
      revenue: 4350,
      startTime: '10:00',
      endTime: '10:30'
    },
    {
      id: 'TS002',
      time: '10:30 AM',
      duration: '30 min',
      maxPlayers: 50,
      currentPlayers: 23,
      gameType: 'FAM-JAM',
      status: 'Filling',
      revenue: 1150,
      startTime: '10:30',
      endTime: '11:00'
    },
    {
      id: 'TS003',
      time: '11:00 AM',
      duration: '45 min',
      maxPlayers: 150,
      currentPlayers: 134,
      gameType: 'Live Game',
      status: 'Almost Full',
      revenue: 6700,
      startTime: '11:00',
      endTime: '11:45'
    },
    {
      id: 'TS004',
      time: '11:30 AM',
      duration: '30 min',
      maxPlayers: 75,
      currentPlayers: 12,
      gameType: 'FAM-JAM',
      status: 'Open',
      revenue: 600,
      startTime: '11:30',
      endTime: '12:00'
    },
    {
      id: 'TS005',
      time: '12:00 PM',
      duration: '60 min',
      maxPlayers: 200,
      currentPlayers: 0,
      gameType: 'Mega Live',
      status: 'Scheduled',
      revenue: 0,
      startTime: '12:00',
      endTime: '13:00'
    },
    {
      id: 'TS006',
      time: '1:00 PM',
      duration: '30 min',
      maxPlayers: 100,
      currentPlayers: 45,
      gameType: 'Live Game',
      status: 'Filling',
      revenue: 2250,
      startTime: '13:00',
      endTime: '13:30'
    }
  ];

  const getStatusColor = (status) => {
    switch(status) {
      case 'Active': return 'bg-green-100 text-green-800 border-green-200';
      case 'Almost Full': return 'bg-orange-100 text-orange-800 border-orange-200';
      case 'Filling': return 'bg-blue-100 text-blue-800 border-blue-200';
      case 'Open': return 'bg-purple-100 text-purple-800 border-purple-200';
      case 'Scheduled': return 'bg-gray-100 text-gray-800 border-gray-200';
      default: return 'bg-gray-100 text-gray-800 border-gray-200';
    }
  };

  const getGameTypeColor = (type) => {
    switch(type) {
      case 'Live Game': return 'bg-orange-100 text-orange-800';
      case 'FAM-JAM': return 'bg-pink-100 text-pink-800';
      case 'Mega Live': return 'bg-red-100 text-red-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const formatTime = (seconds) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  const realtimeUpdates = [
    { time: '2 sec ago', event: '5 players joined 11:00 AM slot', type: 'join' },
    { time: '5 sec ago', event: '10:30 AM game started', type: 'start' },
    { time: '8 sec ago', event: 'New booking for 1:00 PM slot', type: 'booking' },
    { time: '12 sec ago', event: '10:00 AM slot reached capacity', type: 'full' },
    { time: '15 sec ago', event: '3 players joined 11:30 AM slot', type: 'join' }
  ];

  return (
    <div className="p-6 bg-gray-50 min-h-screen">
      {/* Header */}
      <div className="mb-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold text-gray-800 flex items-center">
              <Clock className="mr-3 text-purple-600" size={32} />
              Live Time Slots Management
            </h1>
            <p className="text-gray-600">Real-time slot monitoring and booking management</p>
          </div>
          <div className="flex items-center space-x-4">
            <div className="bg-black text-white px-4 py-2 rounded-lg font-mono text-lg">
              {currentTime.toLocaleTimeString()}
            </div>
            <div className="flex items-center space-x-2 bg-green-100 px-4 py-2 rounded-lg">
              <div className="w-3 h-3 bg-green-500 rounded-full animate-pulse"></div>
              <span className="text-green-800 font-medium">Live Tracking</span>
            </div>
            <button className="bg-purple-600 text-white px-4 py-2 rounded-lg flex items-center hover:bg-purple-700">
              <Plus size={20} className="mr-2" />
              Add Slot
            </button>
          </div>
        </div>
      </div>

      {/* Real-time Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
        <div className="bg-white rounded-xl shadow-lg p-6 border-l-4 border-purple-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-500 text-sm font-medium">Active Slots</p>
              <p className="text-3xl font-bold text-gray-800">{liveStats.activeSlots}</p>
              <div className="flex items-center mt-2">
                <Activity className="text-purple-500 mr-1 animate-pulse" size={16} />
                <span className="text-purple-500 text-sm font-medium">Running Now</span>
              </div>
            </div>
            <Clock size={32} className="text-purple-500" />
          </div>
        </div>

        <div className="bg-white rounded-xl shadow-lg p-6 border-l-4 border-blue-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-500 text-sm font-medium">Total Bookings</p>
              <p className="text-3xl font-bold text-gray-800">{liveStats.totalBookings}</p>
              <div className="flex items-center mt-2">
                <TrendingUp className="text-blue-500 mr-1" size={16} />
                <span className="text-blue-500 text-sm font-medium">+12.3%</span>
              </div>
            </div>
            <Calendar size={32} className="text-blue-500" />
          </div>
        </div>

        <div className="bg-white rounded-xl shadow-lg p-6 border-l-4 border-green-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-500 text-sm font-medium">Current Players</p>
              <p className="text-3xl font-bold text-gray-800">{liveStats.currentPlayers}</p>
              <div className="flex items-center mt-2">
                <Zap className="text-green-500 mr-1 animate-bounce" size={16} />
                <span className="text-green-500 text-sm font-medium">Live Count</span>
              </div>
            </div>
            <Users size={32} className="text-green-500" />
          </div>
        </div>

        <div className="bg-white rounded-xl shadow-lg p-6 border-l-4 border-orange-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-500 text-sm font-medium">Next Game In</p>
              <p className="text-3xl font-bold text-gray-800">{formatTime(liveStats.nextGameIn)}</p>
              <div className="flex items-center mt-2">
                <Clock className="text-orange-500 mr-1" size={16} />
                <span className="text-orange-500 text-sm font-medium">Countdown</span>
              </div>
            </div>
            <GamepadIcon size={32} className="text-orange-500" />
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-4 gap-6 mb-8">
        {/* Live Updates Feed */}
        <div className="bg-white rounded-xl shadow-lg p-6">
          <h3 className="text-xl font-bold text-gray-800 mb-4 flex items-center">
            <Zap className="mr-2 text-yellow-500 animate-pulse" size={20} />
            Live Updates
          </h3>
          <div className="space-y-3 max-h-80 overflow-y-auto">
            {realtimeUpdates.map((update, index) => (
              <div key={index} className="flex items-start space-x-3 p-3 bg-gray-50 rounded-lg border-l-4 border-purple-400">
                <div className={`w-3 h-3 rounded-full mt-1 animate-pulse ${
                  update.type === 'start' ? 'bg-green-500' :
                  update.type === 'join' ? 'bg-blue-500' :
                  update.type === 'full' ? 'bg-red-500' : 'bg-purple-500'
                }`}></div>
                <div className="flex-1">
                  <p className="text-sm text-gray-800">{update.event}</p>
                  <p className="text-xs text-red-500 font-medium">{update.time}</p>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Time Slots Grid */}
        <div className="col-span-3 bg-white rounded-xl shadow-lg p-6">
          <h3 className="text-xl font-bold text-gray-800 mb-4">Today's Time Slots - Live Status</h3>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {timeSlots.map((slot) => (
              <div key={slot.id} className="border rounded-lg p-4 bg-gradient-to-br from-white to-gray-50 hover:shadow-md transition-shadow">
                <div className="flex items-center justify-between mb-3">
                  <div className="flex items-center">
                    <Clock className="text-purple-600 mr-2" size={18} />
                    <span className="font-bold text-lg text-gray-800">{slot.time}</span>
                  </div>
                  <span className={`px-2 py-1 rounded-full text-xs border ${getStatusColor(slot.status)}`}>
                    {slot.status}
                  </span>
                </div>
                
                <div className="mb-3">
                  <span className={`px-2 py-1 rounded-full text-xs ${getGameTypeColor(slot.gameType)}`}>
                    {slot.gameType}
                  </span>
                  <span className="ml-2 text-sm text-gray-500">{slot.duration}</span>
                </div>

                <div className="mb-3">
                  <div className="flex justify-between text-sm mb-1">
                    <span>Players</span>
                    <span className="font-medium">{slot.currentPlayers}/{slot.maxPlayers}</span>
                  </div>
                  <div className="w-full bg-gray-200 rounded-full h-2">
                    <div 
                      className={`h-2 rounded-full transition-all duration-500 ${
                        (slot.currentPlayers / slot.maxPlayers) > 0.8 ? 'bg-red-500' :
                        (slot.currentPlayers / slot.maxPlayers) > 0.6 ? 'bg-orange-500' :
                        'bg-green-500'
                      }`}
                      style={{ width: `${(slot.currentPlayers / slot.maxPlayers) * 100}%` }}
                    ></div>
                  </div>
                </div>

                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm text-gray-500">Revenue</p>
                    <p className="font-bold text-green-600">₹{slot.revenue.toLocaleString()}</p>
                  </div>
                  <div className="flex space-x-2">
                    {slot.status === 'Active' ? (
                      <button className="p-2 text-red-600 hover:bg-red-100 rounded">
                        <Pause size={16} />
                      </button>
                    ) : (
                      <button className="p-2 text-green-600 hover:bg-green-100 rounded">
                        <Play size={16} />
                      </button>
                    )}
                    <button className="p-2 text-blue-600 hover:bg-blue-100 rounded">
                      <Edit size={16} />
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Detailed Time Slots Table */}
      <div className="bg-white rounded-xl shadow-lg overflow-hidden">
        <div className="p-6 border-b">
          <h3 className="text-xl font-bold text-gray-800 flex items-center">
            <Calendar className="mr-2 text-blue-600" size={20} />
            Complete Schedule - Real-time Monitoring
          </h3>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Time Slot</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Game Type</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Players</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Capacity</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Revenue</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Status</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Actions</th>
              </tr>
            </thead>
            <tbody>
              {timeSlots.map((slot) => (
                <tr key={slot.id} className="border-b hover:bg-gray-50">
                  <td className="py-3 px-4">
                    <div className="flex items-center">
                      <Clock className="text-purple-600 mr-2" size={16} />
                      <div>
                        <p className="font-medium text-gray-800">{slot.time}</p>
                        <p className="text-xs text-gray-500">{slot.duration}</p>
                      </div>
                    </div>
                  </td>
                  <td className="py-3 px-4">
                    <span className={`px-2 py-1 rounded-full text-xs ${getGameTypeColor(slot.gameType)}`}>
                      {slot.gameType}
                    </span>
                  </td>
                  <td className="py-3 px-4">
                    <div className="flex items-center">
                      <Users className="text-blue-500 mr-1" size={16} />
                      <span className="font-bold text-blue-600">{slot.currentPlayers}</span>
                    </div>
                  </td>
                  <td className="py-3 px-4">
                    <div className="flex items-center">
                      <div className="w-16 bg-gray-200 rounded-full h-2 mr-2">
                        <div 
                          className={`h-2 rounded-full ${
                            (slot.currentPlayers / slot.maxPlayers) > 0.8 ? 'bg-red-500' :
                            (slot.currentPlayers / slot.maxPlayers) > 0.6 ? 'bg-orange-500' :
                            'bg-green-500'
                          }`}
                          style={{ width: `${(slot.currentPlayers / slot.maxPlayers) * 100}%` }}
                        ></div>
                      </div>
                      <span className="text-sm text-gray-600">{Math.round((slot.currentPlayers / slot.maxPlayers) * 100)}%</span>
                    </div>
                  </td>
                  <td className="py-3 px-4 font-bold text-green-600">₹{slot.revenue.toLocaleString()}</td>
                  <td className="py-3 px-4">
                    <span className={`px-3 py-1 rounded-full text-xs border ${getStatusColor(slot.status)}`}>
                      {slot.status}
                    </span>
                  </td>
                  <td className="py-3 px-4">
                    <div className="flex space-x-2">
                      {slot.status === 'Active' ? (
                        <button className="p-1 text-red-600 hover:bg-red-100 rounded">
                          <Pause size={16} />
                        </button>
                      ) : (
                        <button className="p-1 text-green-600 hover:bg-green-100 rounded">
                          <Play size={16} />
                        </button>
                      )}
                      <button className="p-1 text-blue-600 hover:bg-blue-100 rounded">
                        <Edit size={16} />
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

export default TimeSlots;