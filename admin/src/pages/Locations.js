import React, { useState, useEffect } from 'react';
import { 
  MapPin, 
  Users, 
  GamepadIcon, 
  DollarSign, 
  TrendingUp,
  Activity,
  Plus,
  Eye,
  Edit,
  Zap
} from 'lucide-react';

const Locations = () => {
  const [liveData, setLiveData] = useState({
    totalLocations: 45,
    activeUsers: 3247,
    liveGames: 67,
    revenue: 156780
  });

  // Real-time updates every 2 seconds
  useEffect(() => {
    const interval = setInterval(() => {
      setLiveData(prev => ({
        totalLocations: prev.totalLocations + Math.floor(Math.random() * 2),
        activeUsers: prev.activeUsers + Math.floor(Math.random() * 20) - 10,
        liveGames: Math.max(50, prev.liveGames + Math.floor(Math.random() * 8) - 4),
        revenue: prev.revenue + Math.floor(Math.random() * 1000)
      }));
    }, 2000);

    return () => clearInterval(interval);
  }, []);

  const [locations] = useState([
    {
      id: 'L001',
      city: 'Visakhapatnam',
      areas: ['Pendurthi', 'MVP Colony', 'Gajuwaka', 'Dwaraka Nagar', 'Madhurawada'],
      activeUsers: 1247,
      liveGames: 23,
      todayRevenue: 45670,
      status: 'High Activity',
      coordinates: '17.6868°N, 83.2185°E',
      lastUpdate: 'Live'
    },
    {
      id: 'L002',
      city: 'Hyderabad',
      areas: ['Hitech City', 'Gachibowli', 'Madhapur', 'Kondapur', 'Jubilee Hills'],
      activeUsers: 987,
      liveGames: 18,
      todayRevenue: 38920,
      status: 'High Activity',
      coordinates: '17.3850°N, 78.4867°E',
      lastUpdate: 'Live'
    },
    {
      id: 'L003',
      city: 'Bangalore',
      areas: ['Koramangala', 'Indiranagar', 'Whitefield', 'Electronic City', 'HSR Layout'],
      activeUsers: 756,
      liveGames: 14,
      todayRevenue: 29450,
      status: 'Medium Activity',
      coordinates: '12.9716°N, 77.5946°E',
      lastUpdate: 'Live'
    },
    {
      id: 'L004',
      city: 'Chennai',
      areas: ['T Nagar', 'Anna Nagar', 'Velachery', 'OMR', 'Adyar'],
      activeUsers: 634,
      liveGames: 11,
      todayRevenue: 24780,
      status: 'Medium Activity',
      coordinates: '13.0827°N, 80.2707°E',
      lastUpdate: 'Live'
    },
    {
      id: 'L005',
      city: 'Delhi',
      areas: ['Connaught Place', 'Karol Bagh', 'Lajpat Nagar', 'Dwarka', 'Rohini'],
      activeUsers: 523,
      liveGames: 9,
      todayRevenue: 19340,
      status: 'Low Activity',
      coordinates: '28.7041°N, 77.1025°E',
      lastUpdate: 'Live'
    }
  ]);

  const getStatusColor = (status) => {
    switch(status) {
      case 'High Activity': return 'bg-green-100 text-green-800 border-green-200';
      case 'Medium Activity': return 'bg-yellow-100 text-yellow-800 border-yellow-200';
      case 'Low Activity': return 'bg-red-100 text-red-800 border-red-200';
      default: return 'bg-gray-100 text-gray-800 border-gray-200';
    }
  };

  const realtimeActivity = [
    { time: '1 sec ago', location: 'Visakhapatnam', event: 'New game started in Pendurthi', type: 'game' },
    { time: '3 sec ago', location: 'Hyderabad', event: '5 users joined live game', type: 'user' },
    { time: '7 sec ago', location: 'Bangalore', event: 'Winner: ₹500 in Koramangala', type: 'win' },
    { time: '12 sec ago', location: 'Chennai', event: 'FAM-JAM game completed', type: 'game' },
    { time: '18 sec ago', location: 'Delhi', event: 'New user registration', type: 'user' }
  ];

  return (
    <div className="p-6 bg-gray-50 min-h-screen">
      {/* Header */}
      <div className="mb-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold text-gray-800 flex items-center">
              <MapPin className="mr-3 text-blue-600" size={32} />
              Live Location Analytics
            </h1>
            <p className="text-gray-600">Real-time monitoring across all cities</p>
          </div>
          <div className="flex items-center space-x-4">
            <div className="flex items-center space-x-2 bg-green-100 px-4 py-2 rounded-lg">
              <div className="w-3 h-3 bg-green-500 rounded-full animate-pulse"></div>
              <span className="text-green-800 font-medium">Live Updates</span>
            </div>
            <button className="bg-blue-600 text-white px-4 py-2 rounded-lg flex items-center hover:bg-blue-700">
              <Plus size={20} className="mr-2" />
              Add Location
            </button>
          </div>
        </div>
      </div>

      {/* Real-time Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
        <div className="bg-white rounded-xl shadow-lg p-6 border-l-4 border-blue-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-500 text-sm font-medium">Total Locations</p>
              <p className="text-3xl font-bold text-gray-800">{liveData.totalLocations}</p>
              <div className="flex items-center mt-2">
                <TrendingUp className="text-green-500 mr-1" size={16} />
                <span className="text-green-500 text-sm font-medium">+8.2%</span>
              </div>
            </div>
            <MapPin size={32} className="text-blue-500" />
          </div>
        </div>

        <div className="bg-white rounded-xl shadow-lg p-6 border-l-4 border-green-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-500 text-sm font-medium">Active Users</p>
              <p className="text-3xl font-bold text-gray-800">{liveData.activeUsers.toLocaleString()}</p>
              <div className="flex items-center mt-2">
                <Activity className="text-green-500 mr-1 animate-pulse" size={16} />
                <span className="text-green-500 text-sm font-medium">Live</span>
              </div>
            </div>
            <Users size={32} className="text-green-500" />
          </div>
        </div>

        <div className="bg-white rounded-xl shadow-lg p-6 border-l-4 border-purple-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-500 text-sm font-medium">Live Games</p>
              <p className="text-3xl font-bold text-gray-800">{liveData.liveGames}</p>
              <div className="flex items-center mt-2">
                <Zap className="text-purple-500 mr-1 animate-bounce" size={16} />
                <span className="text-purple-500 text-sm font-medium">Active Now</span>
              </div>
            </div>
            <GamepadIcon size={32} className="text-purple-500" />
          </div>
        </div>

        <div className="bg-white rounded-xl shadow-lg p-6 border-l-4 border-orange-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-500 text-sm font-medium">Today Revenue</p>
              <p className="text-3xl font-bold text-gray-800">₹{liveData.revenue.toLocaleString()}</p>
              <div className="flex items-center mt-2">
                <TrendingUp className="text-orange-500 mr-1" size={16} />
                <span className="text-orange-500 text-sm font-medium">+15.7%</span>
              </div>
            </div>
            <DollarSign size={32} className="text-orange-500" />
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
        {/* Live Activity Feed */}
        <div className="bg-white rounded-xl shadow-lg p-6">
          <h3 className="text-xl font-bold text-gray-800 mb-4 flex items-center">
            <Activity className="mr-2 text-red-500 animate-pulse" size={20} />
            Live Activity Feed
          </h3>
          <div className="space-y-3 max-h-80 overflow-y-auto">
            {realtimeActivity.map((activity, index) => (
              <div key={index} className="flex items-start space-x-3 p-3 bg-gray-50 rounded-lg border-l-4 border-blue-400">
                <div className={`w-3 h-3 rounded-full mt-1 animate-pulse ${
                  activity.type === 'game' ? 'bg-blue-500' :
                  activity.type === 'win' ? 'bg-green-500' : 'bg-purple-500'
                }`}></div>
                <div className="flex-1">
                  <div className="flex items-center justify-between">
                    <p className="font-medium text-gray-800 text-sm">{activity.location}</p>
                    <span className="text-xs text-red-500 font-medium">{activity.time}</span>
                  </div>
                  <p className="text-xs text-gray-600">{activity.event}</p>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Top Performing Areas */}
        <div className="bg-white rounded-xl shadow-lg p-6 col-span-2">
          <h3 className="text-xl font-bold text-gray-800 mb-4">Real-time Location Performance</h3>
          <div className="space-y-4">
            {locations.slice(0, 3).map((location, index) => (
              <div key={location.id} className="p-4 bg-gradient-to-r from-blue-50 to-purple-50 rounded-lg border">
                <div className="flex items-center justify-between mb-2">
                  <div className="flex items-center">
                    <div className={`w-4 h-4 rounded-full mr-3 animate-pulse ${
                      index === 0 ? 'bg-green-500' : index === 1 ? 'bg-yellow-500' : 'bg-blue-500'
                    }`}></div>
                    <h4 className="font-bold text-gray-800">{location.city}</h4>
                    <span className="ml-2 text-xs bg-red-100 text-red-800 px-2 py-1 rounded-full animate-pulse">
                      {location.lastUpdate}
                    </span>
                  </div>
                  <div className="text-right">
                    <p className="text-sm text-gray-500">Revenue</p>
                    <p className="font-bold text-green-600">₹{location.todayRevenue.toLocaleString()}</p>
                  </div>
                </div>
                <div className="grid grid-cols-3 gap-4 text-center">
                  <div>
                    <p className="text-2xl font-bold text-blue-600">{location.activeUsers}</p>
                    <p className="text-xs text-gray-500">Active Users</p>
                  </div>
                  <div>
                    <p className="text-2xl font-bold text-purple-600">{location.liveGames}</p>
                    <p className="text-xs text-gray-500">Live Games</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">{location.areas.length} Areas</p>
                    <p className="text-xs text-gray-500">Coverage</p>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Locations Table */}
      <div className="bg-white rounded-xl shadow-lg overflow-hidden">
        <div className="p-6 border-b">
          <h3 className="text-xl font-bold text-gray-800 flex items-center">
            <MapPin className="mr-2 text-blue-600" size={20} />
            All Locations - Live Status
          </h3>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="text-left py-3 px-4 font-medium text-gray-700">City</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Areas Covered</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Active Users</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Live Games</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Today Revenue</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Status</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Actions</th>
              </tr>
            </thead>
            <tbody>
              {locations.map((location) => (
                <tr key={location.id} className="border-b hover:bg-gray-50">
                  <td className="py-3 px-4">
                    <div>
                      <p className="font-medium text-gray-800">{location.city}</p>
                      <p className="text-xs text-gray-500">{location.coordinates}</p>
                    </div>
                  </td>
                  <td className="py-3 px-4">
                    <div className="flex flex-wrap gap-1">
                      {location.areas.slice(0, 3).map((area, index) => (
                        <span key={index} className="text-xs bg-blue-100 text-blue-800 px-2 py-1 rounded">
                          {area}
                        </span>
                      ))}
                      {location.areas.length > 3 && (
                        <span className="text-xs text-gray-500">+{location.areas.length - 3} more</span>
                      )}
                    </div>
                  </td>
                  <td className="py-3 px-4">
                    <div className="flex items-center">
                      <Users size={16} className="text-blue-500 mr-1" />
                      <span className="font-bold text-blue-600">{location.activeUsers}</span>
                    </div>
                  </td>
                  <td className="py-3 px-4">
                    <div className="flex items-center">
                      <div className="w-2 h-2 bg-green-500 rounded-full mr-2 animate-pulse"></div>
                      <span className="font-bold text-green-600">{location.liveGames}</span>
                    </div>
                  </td>
                  <td className="py-3 px-4 font-bold text-green-600">₹{location.todayRevenue.toLocaleString()}</td>
                  <td className="py-3 px-4">
                    <span className={`px-3 py-1 rounded-full text-xs border ${getStatusColor(location.status)}`}>
                      {location.status}
                    </span>
                  </td>
                  <td className="py-3 px-4">
                    <div className="flex space-x-2">
                      <button className="p-1 text-blue-600 hover:bg-blue-100 rounded">
                        <Eye size={16} />
                      </button>
                      <button className="p-1 text-green-600 hover:bg-green-100 rounded">
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

export default Locations;