import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Sidebar from './components/Sidebar';
import Header from './components/Header';
import Dashboard from './pages/Dashboard';
import Users from './pages/Users';
import Games from './pages/Games';
import CreateGame from './pages/CreateGame';
import GameControl from './pages/GameControl';
import Tickets from './pages/Tickets';
import Winners from './pages/Winners';
import Register from './pages/Register';
import Login from './pages/Login';

function App() {
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [showRegister, setShowRegister] = useState(false);
  const [sidebarOpen, setSidebarOpen] = useState(false);

  useEffect(() => {
    const token = localStorage.getItem('token');
    if (token) setIsLoggedIn(true);
  }, []);

  const handleLogin = () => {
    setIsLoggedIn(true);
  };

  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('admin');
    setIsLoggedIn(false);
    setSidebarOpen(false);
  };

  const toggleSidebar = () => {
    setSidebarOpen(!sidebarOpen);
  };

  const closeSidebar = () => {
    setSidebarOpen(false);
  };

  if (!isLoggedIn) {
    return showRegister ? (
      <Register onSwitchToLogin={() => setShowRegister(false)} />
    ) : (
      <Login onSuccess={handleLogin} onSwitchToRegister={() => setShowRegister(true)} />
    );
  }

  return (
    <Router>
      <div className="flex min-h-screen bg-gray-50">
        <Sidebar 
          onLogout={handleLogout} 
          isOpen={sidebarOpen}
          onClose={closeSidebar}
        />
        <div className="flex-1 flex flex-col lg:ml-0">
          <Header onMenuToggle={toggleSidebar} />
          <main className="flex-1 overflow-auto">
            <Routes>
              <Route path="/" element={<Dashboard />} />
              <Route path="/users" element={<Users />} />
              <Route path="/games" element={<Games />} />
              <Route path="/create-game" element={<CreateGame />} />
              <Route path="/game-control" element={<GameControl />} />
              <Route path="/tickets" element={<Tickets />} />
              <Route path="/winners" element={<Winners />} />
              {/* <Route path="/leaderboard" element={<Leaderboard />} /> */}
              {/* <Route path="/rewards" element={<Rewards />} /> */}
              {/* <Route path="/analytics" element={<Analytics />} /> */}
              {/* <Route path="/locations" element={<Locations />} /> */}
              {/* <Route path="/timeslots" element={<TimeSlots />} /> */}
              {/* <Route path="/settings" element={<div className="p-4 lg:p-6"><h1 className="text-2xl font-bold">Settings</h1></div>} /> */}
            </Routes>
          </main>
        </div>
      </div>
    </Router>
  );
}

export default App;
