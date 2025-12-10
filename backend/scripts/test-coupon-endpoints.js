const axios = require('axios');

const BASE_URL = process.env.API_URL || 'http://localhost:5000/api';

// Test configuration
const TEST_CONFIG = {
  userToken: 'YOUR_USER_TOKEN_HERE',
  adminToken: 'YOUR_ADMIN_TOKEN_HERE',
  gameId: 'YOUR_GAME_ID_HERE'
};

async function testGetMyCoupons() {
  console.log('\n🧪 Testing GET /game/my-coupons...');
  try {
    const response = await axios.get(`${BASE_URL}/game/my-coupons`, {
      headers: { Authorization: `Bearer ${TEST_CONFIG.userToken}` }
    });
    console.log('✅ Success:', response.data);
    return true;
  } catch (error) {
    console.error('❌ Failed:', error.response?.data || error.message);
    return false;
  }
}

async function testGetWinners() {
  console.log('\n🧪 Testing GET /game/:gameId/winners...');
  try {
    const response = await axios.get(`${BASE_URL}/game/${TEST_CONFIG.gameId}/winners`, {
      headers: { Authorization: `Bearer ${TEST_CONFIG.adminToken}` }
    });
    console.log('✅ Success:', response.data);
    return true;
  } catch (error) {
    console.error('❌ Failed:', error.response?.data || error.message);
    return false;
  }
}

async function testAssignCoupon() {
  console.log('\n🧪 Testing POST /game/:gameId/assign-coupon...');
  try {
    const response = await axios.post(
      `${BASE_URL}/game/${TEST_CONFIG.gameId}/assign-coupon`,
      {
        winType: 'FIRST_LINE',
        couponCode: 'TEST-COUPON-123'
      },
      {
        headers: { Authorization: `Bearer ${TEST_CONFIG.adminToken}` }
      }
    );
    console.log('✅ Success:', response.data);
    return true;
  } catch (error) {
    console.error('❌ Failed:', error.response?.data || error.message);
    return false;
  }
}

async function runTests() {
  console.log('🚀 Starting Coupon API Tests...');
  console.log('📍 Base URL:', BASE_URL);
  
  if (TEST_CONFIG.userToken === 'YOUR_USER_TOKEN_HERE') {
    console.log('\n⚠️  Please update TEST_CONFIG with real tokens and gameId');
    console.log('   1. Login as user and get token');
    console.log('   2. Login as admin and get token');
    console.log('   3. Create a game and get gameId');
    console.log('   4. Update TEST_CONFIG in this file');
    return;
  }

  const results = {
    getMyCoupons: await testGetMyCoupons(),
    getWinners: await testGetWinners(),
    assignCoupon: await testAssignCoupon()
  };

  console.log('\n📊 Test Results:');
  console.log('  Get My Coupons:', results.getMyCoupons ? '✅' : '❌');
  console.log('  Get Winners:', results.getWinners ? '✅' : '❌');
  console.log('  Assign Coupon:', results.assignCoupon ? '✅' : '❌');
  
  const allPassed = Object.values(results).every(r => r);
  console.log('\n' + (allPassed ? '✅ All tests passed!' : '❌ Some tests failed'));
}

runTests();
