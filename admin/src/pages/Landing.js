import React, { useState } from 'react';
import { 
  Play, 
  Users, 
  Trophy, 
  MapPin, 
  Star, 
  Shield, 
  Zap,
  GamepadIcon,
  DollarSign,
  Clock,
  Gift
} from 'lucide-react';

const Landing = ({ onLogin }) => {
  const [showLoginForm, setShowLoginForm] = useState(false);
  const [loginData, setLoginData] = useState({ email: '', password: '' });

  const handleLogin = (e) => {
    e.preventDefault();
    // No validation - allow any input including empty fields
    onLogin();
  };

  const stats = [
    { icon: Users, label: 'Active Players', value: '50,000+', color: 'text-blue-500' },
    { icon: GamepadIcon, label: 'Games Played', value: '2,50,000+', color: 'text-green-500' },
    { icon: DollarSign, label: 'Rewards Given', value: '₹10,00,000+', color: 'text-purple-500' },
    { icon: MapPin, label: 'Cities', value: '25+', color: 'text-orange-500' }
  ];

  const features = [
    {
      icon: Play,
      title: 'Live Tambola Games',
      description: 'Real-time multiplayer Tambola games with friends and strangers',
      color: 'bg-orange-500'
    },
    {
      icon: Users,
      title: 'FAM-JAM Mode',
      description: 'Private games with family and friends for intimate gaming sessions',
      color: 'bg-pink-500'
    },
    {
      icon: Gift,
      title: 'Rewards & Coupons',
      description: 'Win exciting rewards, scratch cards, and brand coupons',
      color: 'bg-purple-500'
    },
    {
      icon: Trophy,
      title: 'Leaderboards',
      description: 'Compete globally or locally and climb the rankings',
      color: 'bg-yellow-500'
    },
    {
      icon: Shield,
      title: 'Secure Gaming',
      description: 'Safe and fair gameplay with advanced security measures',
      color: 'bg-green-500'
    },
    {
      icon: Zap,
      title: 'Real-time Updates',
      description: 'Live game updates, instant notifications, and seamless experience',
      color: 'bg-blue-500'
    }
  ];

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-600 via-blue-700 to-blue-800">
      {/* Header */}
      <header className="bg-black/20 backdrop-blur-md border-b border-white/10">
        <div className="container mx-auto px-4 lg:px-6 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-gradient-to-r from-orange-500 to-pink-500 rounded-lg flex items-center justify-center">
                <GamepadIcon className="text-white" size={24} />
              </div>
              <div>
                <h1 className="text-xl lg:text-2xl font-bold text-white">Ush Tambola</h1>
                <p className="text-blue-200 text-sm hidden sm:block">Gaming Platform</p>
              </div>
            </div>
            <button
              onClick={() => setShowLoginForm(true)}
              className="bg-gradient-to-r from-orange-500 to-pink-500 text-white px-4 lg:px-6 py-2 rounded-lg hover:from-orange-600 hover:to-pink-600 transition-all duration-300 font-medium text-sm lg:text-base"
            >
              Admin Login
            </button>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <section className="container mx-auto px-4 lg:px-6 py-12 lg:py-20">
        <div className="text-center mb-12 lg:mb-16">
          <h1 className="text-3xl lg:text-6xl font-bold text-white mb-6 leading-tight">
            India's Premier
            <span className="bg-gradient-to-r from-orange-400 to-pink-400 bg-clip-text text-transparent"> Tambola </span>
            Gaming Platform
          </h1>
          <p className="text-lg lg:text-xl text-blue-200 mb-8 max-w-3xl mx-auto">
            Experience the thrill of live Tambola games with real-time multiplayer action, 
            exciting rewards, and seamless gameplay across multiple cities in India.
          </p>
          <div className="flex items-center justify-center space-x-4">
            <div className="flex items-center space-x-2 bg-green-500/20 px-4 py-2 rounded-full">
              <div className="w-3 h-3 bg-green-400 rounded-full animate-pulse"></div>
              <span className="text-green-300 font-medium">Live Games Running</span>
            </div>
            <div className="flex items-center space-x-2 bg-blue-500/20 px-4 py-2 rounded-full">
              <Clock className="text-blue-300" size={16} />
              <span className="text-blue-300 font-medium">24/7 Available</span>
            </div>
          </div>
        </div>

        {/* Stats */}
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 lg:gap-6 mb-12 lg:mb-20">
          {stats.map((stat, index) => (
            <div key={index} className="bg-white/10 backdrop-blur-md rounded-xl p-6 text-center border border-white/20">
              <stat.icon className={`${stat.color} mx-auto mb-3`} size={32} />
              <p className="text-2xl font-bold text-white mb-1">{stat.value}</p>
              <p className="text-purple-200 text-sm">{stat.label}</p>
            </div>
          ))}
        </div>

        {/* Features */}
        <div className="mb-12 lg:mb-20">
          <h2 className="text-2xl lg:text-4xl font-bold text-white text-center mb-8 lg:mb-12">
            Why Choose Ush Tambola?
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 lg:gap-8">
            {features.map((feature, index) => (
              <div key={index} className="bg-white/10 backdrop-blur-md rounded-xl p-6 border border-white/20 hover:bg-white/20 transition-all duration-300">
                <div className={`${feature.color} w-12 h-12 rounded-lg flex items-center justify-center mb-4`}>
                  <feature.icon className="text-white" size={24} />
                </div>
                <h3 className="text-xl font-bold text-white mb-3">{feature.title}</h3>
                <p className="text-purple-200">{feature.description}</p>
              </div>
            ))}
          </div>
        </div>

        {/* Game Modes */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 lg:gap-8 mb-12 lg:mb-20">
          <div className="bg-gradient-to-br from-orange-500/20 to-red-500/20 backdrop-blur-md rounded-xl p-8 border border-orange-300/30">
            <div className="flex items-center mb-4">
              <div className="w-12 h-12 bg-orange-500 rounded-lg flex items-center justify-center mr-4">
                <Play className="text-white" size={24} />
              </div>
              <h3 className="text-2xl font-bold text-white">Live Game</h3>
            </div>
            <p className="text-orange-200 mb-4">Play with Friends, Family & Strangers</p>
            <ul className="text-orange-100 space-y-2">
              <li>• Real-time multiplayer action</li>
              <li>• Larger prize pools</li>
              <li>• Meet new players</li>
              <li>• Competitive gameplay</li>
            </ul>
          </div>

          <div className="bg-gradient-to-br from-pink-500/20 to-purple-500/20 backdrop-blur-md rounded-xl p-8 border border-pink-300/30">
            <div className="flex items-center mb-4">
              <div className="w-12 h-12 bg-pink-500 rounded-lg flex items-center justify-center mr-4">
                <Users className="text-white" size={24} />
              </div>
              <h3 className="text-2xl font-bold text-white">FAM-JAM</h3>
            </div>
            <p className="text-pink-200 mb-4">Play with Friends & Family</p>
            <ul className="text-pink-100 space-y-2">
              <li>• Private game sessions</li>
              <li>• Intimate gaming experience</li>
              <li>• Family-friendly environment</li>
              <li>• Custom game settings</li>
            </ul>
          </div>
        </div>

        {/* CTA Section */}
        <div className="text-center bg-gradient-to-r from-orange-500/30 to-pink-500/30 backdrop-blur-md rounded-xl p-8 lg:p-12 border border-orange-300/30">
          <h2 className="text-2xl lg:text-3xl font-bold text-white mb-4">Ready to Start Playing?</h2>
          <p className="text-blue-200 mb-6 lg:mb-8 text-base lg:text-lg">Join thousands of players enjoying Tambola games daily</p>
          <div className="flex flex-col sm:flex-row items-center justify-center space-y-4 sm:space-y-0 sm:space-x-4">
            <button className="w-full sm:w-auto bg-gradient-to-r from-orange-500 to-pink-500 text-white px-6 lg:px-8 py-3 rounded-lg hover:from-orange-600 hover:to-pink-600 transition-all duration-300 font-medium text-base lg:text-lg">
              Download App
            </button>
            <button className="w-full sm:w-auto border border-white/30 text-white px-6 lg:px-8 py-3 rounded-lg hover:bg-white/10 transition-all duration-300 font-medium text-base lg:text-lg">
              Learn More
            </button>
          </div>
        </div>
      </section>

      {/* Login Modal */}
      {showLoginForm && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-50">
          <div className="bg-white rounded-xl p-8 w-full max-w-md mx-4">
            <div className="text-center mb-6">
              <div className="w-16 h-16 bg-gradient-to-r from-orange-500 to-pink-500 rounded-full flex items-center justify-center mx-auto mb-4">
                <Shield className="text-white" size={32} />
              </div>
              <h2 className="text-2xl font-bold text-gray-800">Admin Login</h2>
              <p className="text-gray-600">Access the admin dashboard</p>
            </div>

            <form onSubmit={handleLogin} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Email</label>
                <input
                  type="text"
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500"
                  placeholder="admin@ushtambola.com"
                  value={loginData.email}
                  onChange={(e) => setLoginData({...loginData, email: e.target.value})}
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Password</label>
                <input
                  type="text"
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500"
                  placeholder="Enter your password"
                  value={loginData.password}
                  onChange={(e) => setLoginData({...loginData, password: e.target.value})}
                />
              </div>
              <div className="flex space-x-4">
                <button
                  type="button"
                  onClick={() => setShowLoginForm(false)}
                  className="flex-1 px-4 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="flex-1 px-4 py-3 bg-gradient-to-r from-orange-500 to-pink-500 text-white rounded-lg hover:from-orange-600 hover:to-pink-600 transition-all duration-300"
                >
                  Login
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default Landing;