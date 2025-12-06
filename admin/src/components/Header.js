import React, { useState } from 'react';
import { Menu, Bell, User, X } from 'lucide-react';

const Header = ({ onMenuToggle, title = "Dashboard" }) => {
  const [showProfile, setShowProfile] = useState(false);
  const admin = JSON.parse(localStorage.getItem('admin') || '{}');

  return (
    <header className="bg-white shadow-sm border-b border-gray-200 px-4 py-3 lg:px-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-4">
          {/* Mobile Menu Button */}
          <button
            onClick={onMenuToggle}
            className="lg:hidden p-2 rounded-lg text-gray-600 hover:bg-gray-100"
          >
            <Menu size={24} />
          </button>
          
          <div>
            <h1 className="text-xl lg:text-2xl font-bold text-gray-800">{title}</h1>
            <p className="text-sm text-gray-600 hidden sm:block">Welcome to Ush Admin Panel</p>
          </div>
        </div>

        <div className="flex items-center space-x-3">
          {/* Live Indicator */}
          <div className="hidden sm:flex items-center space-x-2 bg-green-100 px-3 py-1 rounded-full">
            <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
            <span className="text-green-800 text-sm font-medium">Live</span>
          </div>
          
          {/* Notifications */}
          <button className="p-2 rounded-lg text-gray-600 hover:bg-gray-100 relative">
            <Bell size={20} />
            <span className="absolute -top-1 -right-1 w-4 h-4 bg-red-500 text-white text-xs rounded-full flex items-center justify-center">3</span>
          </button>
          
          {/* Profile */}
          <div className="relative">
            <button 
              onClick={() => setShowProfile(!showProfile)}
              className="p-2 rounded-lg text-gray-600 hover:bg-gray-100"
            >
              <User size={20} />
            </button>

            {showProfile && (
              <>
                <div 
                  className="fixed inset-0 z-40" 
                  onClick={() => setShowProfile(false)}
                ></div>
                <div className="absolute right-0 mt-2 w-72 bg-white rounded-xl shadow-2xl border border-gray-200 z-50 p-4">
                  <div className="flex justify-between items-center mb-4">
                    <h3 className="font-bold text-gray-800">Admin Profile</h3>
                    <button 
                      onClick={() => setShowProfile(false)}
                      className="text-gray-400 hover:text-gray-600"
                    >
                      <X size={18} />
                    </button>
                  </div>
                  
                  <div className="flex items-center mb-4 pb-4 border-b">
                    <div className="w-12 h-12 bg-blue-500 rounded-full flex items-center justify-center text-white font-bold text-xl">
                      {admin.username?.charAt(0).toUpperCase() || 'A'}
                    </div>
                    <div className="ml-3">
                      <p className="font-semibold text-gray-800">{admin.username || 'Admin'}</p>
                      <p className="text-sm text-gray-500">{admin.role || 'Administrator'}</p>
                    </div>
                  </div>

                  <div className="space-y-2">
                    <div className="flex justify-between py-2">
                      <span className="text-gray-600 text-sm">Username:</span>
                      <span className="font-medium text-gray-800 text-sm">{admin.username || 'N/A'}</span>
                    </div>
                    <div className="flex justify-between py-2">
                      <span className="text-gray-600 text-sm">Role:</span>
                      <span className="font-medium text-gray-800 text-sm capitalize">{admin.role || 'N/A'}</span>
                    </div>
                    <div className="flex justify-between py-2">
                      <span className="text-gray-600 text-sm">Phone:</span>
                      <span className="font-medium text-gray-800 text-sm">{admin.phone || 'N/A'}</span>
                    </div>
                    <div className="flex justify-between py-2">
                      <span className="text-gray-600 text-sm">Status:</span>
                      <span className="flex items-center text-sm">
                        <span className="w-2 h-2 bg-green-500 rounded-full mr-2"></span>
                        <span className="text-green-600 font-medium">Active</span>
                      </span>
                    </div>
                  </div>
                </div>
              </>
            )}
          </div>
        </div>
      </div>
    </header>
  );
};

export default Header;