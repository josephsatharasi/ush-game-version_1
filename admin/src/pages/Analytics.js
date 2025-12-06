import React, { useState, useEffect } from 'react';
import { 
  TrendingUp, 
  TrendingDown, 
  Users, 
  GamepadIcon, 
  DollarSign, 
  Trophy,
  Clock,
  MapPin,
  Activity,
  Eye,
  Zap
} from 'lucide-react';

const Analytics = () => {
  const [realTimeData, setRealTimeData] = useState({
    activeUsers: 1247,
    liveGames: 23,
    revenue: 45670,
    newSignups: 89
  });

  // Simulate real-time updates
  useEffect(() => {
    const interval = setInterval(() => {
      setRealTimeData(prev => ({
        activeUsers: prev.activeUsers + Math.floor(Math.random() * 10) - 5,
        liveGames: Math.max(15, prev.liveGames + Math.floor(Math.random() * 6) - 3),
        revenue: prev.revenue + Math.floor(Math.random() * 500),
        newSignups: prev.newSignups + Math.floor(Math.random() * 3)
      }));
    }, 3000);

    return () => clearInterval(interval);
  }, []);

  const todayStats = [
    { 
      title: 'Active Users', 
      value: realTimeData.activeUsers.toLocaleString(), 
      change: '+12.5%', 
      icon: Users, 
      color: 'bg-blue-500',
      trend: 'up'
    },
    { 
      title: 'Live Games', 
      value: realTimeData.liveGames, 
      change: '+8.2%', 
      icon: GamepadIcon, 
      color: 'bg-green-500',
      trend: 'up'
    },
    { 
      title: 'Revenue Today', 
      value: `₹${realTimeData.revenue.toLocaleString()}`, 
      change: '+15.7%', 
      icon: DollarSign, 
      color: 'bg-purple-500',
      trend: 'up'
    },
    { 
      title: 'New Signups', 
      value: realTimeData.newSignups, 
      change: '+22.1%', 
      icon: Trophy, 
      color: 'bg-orange-500',
      trend: 'up'
    }
  ];

  const gameTypeData = [
    { type: 'Live Game', count: 156, percentage: 68, color: 'bg-orange-400' },
    { type: 'FAM-JAM', count: 74, percentage: 32, color: 'bg-pink-400' }
  ];

  const hourlyData = [
    { hour: '9 AM', users: 234, games: 12, revenue: 5600 },
    { hour: '10 AM', users: 456, games: 18, revenue: 8900 },
    { hour: '11 AM', users: 678, games: 25, revenue: 12400 },
    { hour: '12 PM', users: 890, games: 32, revenue: 15600 },
    { hour: '1 PM', users: 1123, games: 28, revenue: 18900 },
    { hour: '2 PM', users: 1247, games: 23, revenue: 21200 },
    { hour: '3 PM', users: 1089, games: 19, revenue: 19800 },
    { hour: '4 PM', users: 967, games: 15, revenue: 17400 }
  ];

  const topLocations = [
    { city: 'Visakhapatnam', users: 3456, games: 89, revenue: '₹1,23,450' },
    { city: 'Hyderabad', users: 2890, games: 67, revenue: '₹98,760' },
    { city: 'Bangalore', users: 2345, games: 54, revenue: '₹87,650' },
    { city: 'Chennai', users: 1987, games: 43, revenue: '₹76,540' },
    { city: 'Delhi', users: 1654, games: 38, revenue: '₹65,430' }
  ];

  const recentActivity = [
    { time: '2 min ago', event: 'New game started', details: 'Live Game #G234 - 45 players joined', type: 'game' },
    { time: '3 min ago', event: 'Winner announced', details: 'Kishore won ₹500 in Game #G233', type: 'win' },
    { time: '5 min ago', event: 'New user registered', details: 'Priya Sharma from Bangalore', type: 'user' },
    { time: '7 min ago', event: 'Coupon redeemed', details: 'KANUSH35 used by Nandha Kishore', type: 'coupon' },
    { time: '10 min ago', event: 'Game completed', details: 'FAM-JAM #G232 finished with 12 players', type: 'game' }
  ];

  return (
    <div className="p-6 bg-gray-50 min-h-screen">
      {/* Header */}
      <div className="mb-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold text-gray-800 flex items-center">
              <Activity className="mr-3 text-purple-600" size={32} />
              Real-Time Analytics
            </h1>
            <p className="text-gray-600">Live insights and performance metrics</p>
          </div>
          <div className="flex items-center space-x-2 bg-green-100 px-4 py-2 rounded-lg">
            <div className="w-3 h-3 bg-green-500 rounded-full animate-pulse"></div>
            <span className="text-green-800 font-medium">Live Data</span>
          </div>
        </div>
      </div>

      {/* Real-time Stats */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        {todayStats.map((stat, index) => (
          <div key={index} className="bg-white rounded-xl shadow-lg p-6 border-l-4 border-purple-500">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-gray-500 text-sm font-medium">{stat.title}</p>
                <p className="text-3xl font-bold text-gray-800 mt-1">{stat.value}</p>
                <div className="flex items-center mt-2">
                  {stat.trend === 'up' ? (
                    <TrendingUp className="text-green-500 mr-1" size={16} />
                  ) : (
                    <TrendingDown className="text-red-500 mr-1" size={16} />
                  )}
                  <span className={`text-sm font-medium ${
                    stat.trend === 'up' ? 'text-green-500' : 'text-red-500'
                  }`}>
                    {stat.change}
                  </span>
                  <span className="text-gray-500 text-sm ml-1">vs yesterday</span>
                </div>
              </div>
              <div className={`${stat.color} p-4 rounded-full`}>
                <stat.icon size={28} className="text-white" />
              </div>
            </div>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
        {/* Game Types Distribution */}
        <div className="bg-white rounded-xl shadow-lg p-6">
          <h3 className="text-xl font-bold text-gray-800 mb-4">Game Types Today</h3>
          <div className="space-y-4">
            {gameTypeData.map((game, index) => (
              <div key={index}>
                <div className="flex justify-between items-center mb-2">
                  <span className="font-medium text-gray-700">{game.type}</span>
                  <span className="text-sm text-gray-500">{game.count} games</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-3">
                  <div 
                    className={`${game.color} h-3 rounded-full transition-all duration-500`}
                    style={{ width: `${game.percentage}%` }}
                  ></div>
                </div>
                <div className="text-right text-sm text-gray-500 mt-1">{game.percentage}%</div>
              </div>
            ))}
          </div>
        </div>

        {/* Top Locations */}
        <div className="bg-white rounded-xl shadow-lg p-6">
          <h3 className="text-xl font-bold text-gray-800 mb-4 flex items-center">
            <MapPin className="mr-2 text-purple-600" size={20} />
            Top Locations
          </h3>
          <div className="space-y-3">
            {topLocations.slice(0, 5).map((location, index) => (
              <div key={index} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                <div>
                  <p className="font-medium text-gray-800">{location.city}</p>
                  <p className="text-sm text-gray-500">{location.users} users • {location.games} games</p>
                </div>
                <div className="text-right">
                  <p className="font-bold text-green-600">{location.revenue}</p>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Recent Activity */}
        <div className="bg-white rounded-xl shadow-lg p-6">
          <h3 className="text-xl font-bold text-gray-800 mb-4 flex items-center">
            <Zap className="mr-2 text-yellow-500" size={20} />
            Live Activity
          </h3>
          <div className="space-y-3 max-h-80 overflow-y-auto">
            {recentActivity.map((activity, index) => (
              <div key={index} className="flex items-start space-x-3 p-3 bg-gray-50 rounded-lg">
                <div className={`w-2 h-2 rounded-full mt-2 ${
                  activity.type === 'game' ? 'bg-blue-500' :
                  activity.type === 'win' ? 'bg-green-500' :
                  activity.type === 'user' ? 'bg-purple-500' : 'bg-orange-500'
                }`}></div>
                <div className="flex-1">
                  <p className="font-medium text-gray-800 text-sm">{activity.event}</p>
                  <p className="text-xs text-gray-500">{activity.details}</p>
                  <p className="text-xs text-gray-400 mt-1">{activity.time}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Hourly Performance Chart */}
      <div className="bg-white rounded-xl shadow-lg p-6 mb-8">
        <h3 className="text-xl font-bold text-gray-800 mb-6 flex items-center">
          <Clock className="mr-2 text-blue-600" size={20} />
          Hourly Performance Today
        </h3>
        <div className="overflow-x-auto">
          <div className="flex items-end space-x-4 h-64 min-w-full">
            {hourlyData.map((data, index) => (
              <div key={index} className="flex-1 flex flex-col items-center">
                <div className="flex flex-col items-center space-y-2 mb-4">
                  {/* Revenue Bar */}
                  <div className="w-8 bg-purple-500 rounded-t" style={{ 
                    height: `${(data.revenue / 25000) * 150}px`,
                    minHeight: '20px'
                  }}></div>
                  {/* Games Bar */}
                  <div className="w-8 bg-green-500 rounded-t" style={{ 
                    height: `${(data.games / 35) * 100}px`,
                    minHeight: '15px'
                  }}></div>
                  {/* Users Bar */}
                  <div className="w-8 bg-blue-500 rounded-t" style={{ 
                    height: `${(data.users / 1300) * 120}px`,
                    minHeight: '25px'
                  }}></div>
                </div>
                <div className="text-center">
                  <p className="text-xs font-medium text-gray-700">{data.hour}</p>
                  <p className="text-xs text-gray-500">{data.users}</p>
                </div>
              </div>
            ))}
          </div>
          <div className="flex justify-center space-x-6 mt-4">
            <div className="flex items-center">
              <div className="w-4 h-4 bg-blue-500 rounded mr-2"></div>
              <span className="text-sm text-gray-600">Users</span>
            </div>
            <div className="flex items-center">
              <div className="w-4 h-4 bg-green-500 rounded mr-2"></div>
              <span className="text-sm text-gray-600">Games</span>
            </div>
            <div className="flex items-center">
              <div className="w-4 h-4 bg-purple-500 rounded mr-2"></div>
              <span className="text-sm text-gray-600">Revenue</span>
            </div>
          </div>
        </div>
      </div>

      {/* Performance Metrics */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-gradient-to-r from-blue-500 to-blue-600 rounded-xl shadow-lg p-6 text-white">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-blue-100">Average Session</p>
              <p className="text-3xl font-bold">24.5 min</p>
              <p className="text-blue-200 text-sm">+3.2% from last week</p>
            </div>
            <Clock size={40} className="text-blue-200" />
          </div>
        </div>

        <div className="bg-gradient-to-r from-green-500 to-green-600 rounded-xl shadow-lg p-6 text-white">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-green-100">Win Rate</p>
              <p className="text-3xl font-bold">68.4%</p>
              <p className="text-green-200 text-sm">+1.8% from yesterday</p>
            </div>
            <Trophy size={40} className="text-green-200" />
          </div>
        </div>

        <div className="bg-gradient-to-r from-purple-500 to-purple-600 rounded-xl shadow-lg p-6 text-white">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-purple-100">Avg Revenue/User</p>
              <p className="text-3xl font-bold">₹156</p>
              <p className="text-purple-200 text-sm">+5.4% from last month</p>
            </div>
            <DollarSign size={40} className="text-purple-200" />
          </div>
        </div>
      </div>
    </div>
  );
};

export default Analytics;