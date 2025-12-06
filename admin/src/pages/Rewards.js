import React, { useState } from 'react';
import { Gift, Plus, Search, Edit, Trash2, Eye, Percent, DollarSign } from 'lucide-react';

const Rewards = () => {
  const [activeTab, setActiveTab] = useState('coupons');

  const coupons = [
    {
      id: 'C001',
      code: 'KANUSH35',
      brand: 'Burger King',
      value: '₹50',
      type: 'Gift Card',
      status: 'Active',
      usageCount: 234,
      maxUsage: 1000,
      expiryDate: '2024-12-31',
      createdDate: '2024-01-01'
    },
    {
      id: 'C002',
      code: 'NESCAFE20',
      brand: 'Nescafe',
      value: '₹25',
      type: 'Discount',
      status: 'Active',
      usageCount: 156,
      maxUsage: 500,
      expiryDate: '2024-06-30',
      createdDate: '2024-01-05'
    },
    {
      id: 'C003',
      code: 'HORLICKS15',
      brand: 'Horlicks',
      value: '₹30',
      type: 'Gift Card',
      status: 'Expired',
      usageCount: 89,
      maxUsage: 200,
      expiryDate: '2024-01-15',
      createdDate: '2023-12-01'
    }
  ];

  const scratchCards = [
    {
      id: 'S001',
      name: 'Daily Luck',
      minReward: '₹5',
      maxReward: '₹500',
      winRate: '25%',
      totalCards: 10000,
      usedCards: 3456,
      status: 'Active'
    },
    {
      id: 'S002',
      name: 'Mega Win',
      minReward: '₹10',
      maxReward: '₹1000',
      winRate: '15%',
      totalCards: 5000,
      usedCards: 1234,
      status: 'Active'
    },
    {
      id: 'S003',
      name: 'Lucky Draw',
      minReward: '₹1',
      maxReward: '₹100',
      winRate: '40%',
      totalCards: 20000,
      usedCards: 8765,
      status: 'Paused'
    }
  ];

  const rewardHistory = [
    {
      id: 'R001',
      userId: 'U001',
      userName: 'Kishore',
      rewardType: 'Coupon',
      rewardValue: '₹50',
      code: 'KANUSH35',
      status: 'Redeemed',
      date: '2024-01-15'
    },
    {
      id: 'R002',
      userId: 'U002',
      userName: 'Nandha Kishore',
      rewardType: 'Scratch Card',
      rewardValue: '₹25',
      code: 'SC789012',
      status: 'Pending',
      date: '2024-01-15'
    }
  ];

  const getStatusColor = (status) => {
    switch(status) {
      case 'Active': return 'bg-green-100 text-green-800';
      case 'Paused': return 'bg-yellow-100 text-yellow-800';
      case 'Expired': return 'bg-red-100 text-red-800';
      case 'Redeemed': return 'bg-blue-100 text-blue-800';
      case 'Pending': return 'bg-orange-100 text-orange-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-3xl font-bold text-gray-800">Rewards Management</h1>
          <p className="text-gray-600">Manage coupons, scratch cards, and rewards</p>
        </div>
        <button className="bg-purple-600 text-white px-4 py-2 rounded-lg flex items-center hover:bg-purple-700">
          <Plus size={20} className="mr-2" />
          Create Reward
        </button>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <div className="bg-white rounded-lg shadow-md p-4">
          <h3 className="text-sm text-gray-500">Total Rewards</h3>
          <p className="text-2xl font-bold text-gray-800">15,678</p>
        </div>
        <div className="bg-white rounded-lg shadow-md p-4">
          <h3 className="text-sm text-gray-500">Active Coupons</h3>
          <p className="text-2xl font-bold text-green-600">234</p>
        </div>
        <div className="bg-white rounded-lg shadow-md p-4">
          <h3 className="text-sm text-gray-500">Redeemed Today</h3>
          <p className="text-2xl font-bold text-blue-600">89</p>
        </div>
        <div className="bg-white rounded-lg shadow-md p-4">
          <h3 className="text-sm text-gray-500">Total Value</h3>
          <p className="text-2xl font-bold text-purple-600">₹4,56,780</p>
        </div>
      </div>

      {/* Tabs */}
      <div className="mb-6">
        <div className="flex space-x-4 border-b">
          <button
            onClick={() => setActiveTab('coupons')}
            className={`pb-2 px-1 ${
              activeTab === 'coupons' 
                ? 'border-b-2 border-purple-600 text-purple-600 font-medium' 
                : 'text-gray-600'
            }`}
          >
            Coupons
          </button>
          <button
            onClick={() => setActiveTab('scratch')}
            className={`pb-2 px-1 ${
              activeTab === 'scratch' 
                ? 'border-b-2 border-purple-600 text-purple-600 font-medium' 
                : 'text-gray-600'
            }`}
          >
            Scratch Cards
          </button>
          <button
            onClick={() => setActiveTab('history')}
            className={`pb-2 px-1 ${
              activeTab === 'history' 
                ? 'border-b-2 border-purple-600 text-purple-600 font-medium' 
                : 'text-gray-600'
            }`}
          >
            Reward History
          </button>
        </div>
      </div>

      {/* Coupons Tab */}
      {activeTab === 'coupons' && (
        <div className="bg-white rounded-lg shadow-md overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50">
                <tr>
                  <th className="text-left py-3 px-4 font-medium text-gray-700">Code</th>
                  <th className="text-left py-3 px-4 font-medium text-gray-700">Brand</th>
                  <th className="text-left py-3 px-4 font-medium text-gray-700">Value</th>
                  <th className="text-left py-3 px-4 font-medium text-gray-700">Type</th>
                  <th className="text-left py-3 px-4 font-medium text-gray-700">Usage</th>
                  <th className="text-left py-3 px-4 font-medium text-gray-700">Status</th>
                  <th className="text-left py-3 px-4 font-medium text-gray-700">Expiry</th>
                  <th className="text-left py-3 px-4 font-medium text-gray-700">Actions</th>
                </tr>
              </thead>
              <tbody>
                {coupons.map((coupon) => (
                  <tr key={coupon.id} className="border-b hover:bg-gray-50">
                    <td className="py-3 px-4 font-mono font-medium">{coupon.code}</td>
                    <td className="py-3 px-4">{coupon.brand}</td>
                    <td className="py-3 px-4 font-bold text-green-600">{coupon.value}</td>
                    <td className="py-3 px-4">
                      <span className={`px-2 py-1 rounded-full text-xs ${
                        coupon.type === 'Gift Card' ? 'bg-purple-100 text-purple-800' : 'bg-blue-100 text-blue-800'
                      }`}>
                        {coupon.type}
                      </span>
                    </td>
                    <td className="py-3 px-4">
                      <div className="text-sm">
                        <span className="font-medium">{coupon.usageCount}</span>
                        <span className="text-gray-500">/{coupon.maxUsage}</span>
                      </div>
                    </td>
                    <td className="py-3 px-4">
                      <span className={`px-2 py-1 rounded-full text-xs ${getStatusColor(coupon.status)}`}>
                        {coupon.status}
                      </span>
                    </td>
                    <td className="py-3 px-4 text-sm">{coupon.expiryDate}</td>
                    <td className="py-3 px-4">
                      <div className="flex space-x-2">
                        <button className="p-1 text-blue-600 hover:bg-blue-100 rounded">
                          <Eye size={16} />
                        </button>
                        <button className="p-1 text-green-600 hover:bg-green-100 rounded">
                          <Edit size={16} />
                        </button>
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
      )}

      {/* Scratch Cards Tab */}
      {activeTab === 'scratch' && (
        <div className="bg-white rounded-lg shadow-md overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50">
                <tr>
                  <th className="text-left py-3 px-4 font-medium text-gray-700">Name</th>
                  <th className="text-left py-3 px-4 font-medium text-gray-700">Reward Range</th>
                  <th className="text-left py-3 px-4 font-medium text-gray-700">Win Rate</th>
                  <th className="text-left py-3 px-4 font-medium text-gray-700">Cards Used</th>
                  <th className="text-left py-3 px-4 font-medium text-gray-700">Status</th>
                  <th className="text-left py-3 px-4 font-medium text-gray-700">Actions</th>
                </tr>
              </thead>
              <tbody>
                {scratchCards.map((card) => (
                  <tr key={card.id} className="border-b hover:bg-gray-50">
                    <td className="py-3 px-4 font-medium">{card.name}</td>
                    <td className="py-3 px-4">
                      <span className="text-green-600 font-medium">{card.minReward} - {card.maxReward}</span>
                    </td>
                    <td className="py-3 px-4">
                      <div className="flex items-center">
                        <Percent className="text-blue-500 mr-1" size={16} />
                        <span className="font-medium">{card.winRate}</span>
                      </div>
                    </td>
                    <td className="py-3 px-4">
                      <div className="text-sm">
                        <span className="font-medium">{card.usedCards}</span>
                        <span className="text-gray-500">/{card.totalCards}</span>
                      </div>
                    </td>
                    <td className="py-3 px-4">
                      <span className={`px-2 py-1 rounded-full text-xs ${getStatusColor(card.status)}`}>
                        {card.status}
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
      )}

      {/* History Tab */}
      {activeTab === 'history' && (
        <div className="bg-white rounded-lg shadow-md overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50">
                <tr>
                  <th className="text-left py-3 px-4 font-medium text-gray-700">User</th>
                  <th className="text-left py-3 px-4 font-medium text-gray-700">Reward Type</th>
                  <th className="text-left py-3 px-4 font-medium text-gray-700">Value</th>
                  <th className="text-left py-3 px-4 font-medium text-gray-700">Code</th>
                  <th className="text-left py-3 px-4 font-medium text-gray-700">Status</th>
                  <th className="text-left py-3 px-4 font-medium text-gray-700">Date</th>
                </tr>
              </thead>
              <tbody>
                {rewardHistory.map((reward) => (
                  <tr key={reward.id} className="border-b hover:bg-gray-50">
                    <td className="py-3 px-4 font-medium">{reward.userName}</td>
                    <td className="py-3 px-4">{reward.rewardType}</td>
                    <td className="py-3 px-4 font-bold text-green-600">{reward.rewardValue}</td>
                    <td className="py-3 px-4 font-mono">{reward.code}</td>
                    <td className="py-3 px-4">
                      <span className={`px-2 py-1 rounded-full text-xs ${getStatusColor(reward.status)}`}>
                        {reward.status}
                      </span>
                    </td>
                    <td className="py-3 px-4 text-sm">{reward.date}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  );
};

export default Rewards;