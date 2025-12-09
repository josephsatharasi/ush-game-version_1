import React from 'react';
import { NavLink } from 'react-router-dom';
import { 
  LayoutDashboard, 
  Users, 
  GamepadIcon, 
  Trophy, 
  Ticket, 
  Gift, 
  Settings, 
  BarChart3,
  MapPin,
  Clock,
  LogOut,
  X,
  Award
} from 'lucide-react';

const Sidebar = ({ onLogout, isOpen, onClose }) => {
  const menuItems = [
    { icon: LayoutDashboard, label: 'Dashboard', path: '/' },
    { icon: Users, label: 'Users', path: '/users' },
    { icon: GamepadIcon, label: 'Games', path: '/games' },
    { icon: GamepadIcon, label: 'Create Game', path: '/create-game' },
    { icon: GamepadIcon, label: 'Game Control', path: '/game-control' },
    { icon: Ticket, label: 'Tickets', path: '/tickets' },
    { icon: Award, label: 'Winners', path: '/winners' },
    // { icon: Trophy, label: 'Leaderboard', path: '/leaderboard' },
    // { icon: Gift, label: 'Rewards', path: '/rewards' },
    // { icon: BarChart3, label: 'Analytics', path: '/analytics' },
    // { icon: MapPin, label: 'Locations', path: '/locations' },
    // { icon: Clock, label: 'Time Slots', path: '/timeslots' },
    // { icon: Settings, label: 'Settings', path: '/settings' }
  ];

  return (
    <>
      {/* Mobile Overlay */}
      {isOpen && (
        <div 
          className="fixed inset-0 bg-black bg-opacity-50 z-40 lg:hidden"
          onClick={onClose}
        ></div>
      )}
      
      {/* Sidebar */}
      <div className={`
        fixed lg:static inset-y-0 left-0 z-50
        transform ${isOpen ? 'translate-x-0' : '-translate-x-full'} lg:translate-x-0
        transition-transform duration-300 ease-in-out
        bg-gradient-to-b from-blue-600 to-blue-800 text-white w-64 min-h-screen p-4
      `}>
        {/* Mobile Close Button */}
        <button 
          onClick={onClose}
          className="lg:hidden absolute top-4 right-4 text-white hover:bg-blue-700 p-2 rounded-lg"
        >
          <X size={20} />
        </button>
        
        <div className="mb-8">
          <h1 className="text-2xl font-bold text-white">Ush Admin</h1>
          <p className="text-blue-200 text-sm">Tambola Game Management</p>
        </div>
        
        <nav className="space-y-2">
          {menuItems.map((item) => (
            <NavLink
              key={item.path}
              to={item.path}
              onClick={onClose}
              className={({ isActive }) =>
                `flex items-center space-x-3 p-3 rounded-lg transition-colors ${
                  isActive 
                    ? 'bg-orange-500 text-white shadow-lg' 
                    : 'text-blue-100 hover:bg-blue-700 hover:text-white'
                }`
              }
            >
              <item.icon size={20} />
              <span>{item.label}</span>
            </NavLink>
          ))}
          
          {/* Logout Button */}
          <button
            onClick={() => {
              onLogout();
              onClose();
            }}
            className="w-full flex items-center space-x-3 p-3 rounded-lg transition-colors text-blue-100 hover:bg-red-600 hover:text-white mt-8"
          >
            <LogOut size={20} />
            <span>Logout</span>
          </button>
        </nav>
      </div>
    </>
  );
};

export default Sidebar;