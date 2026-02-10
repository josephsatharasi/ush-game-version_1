import React, { useState } from 'react';
import axios from 'axios';

const Register = ({ onSwitchToLogin }) => {
  const [step, setStep] = useState(1);
  const [formData, setFormData] = useState({ username: '', phone: '', password: '', confirmPassword: '', countryCode: '+91' });
  const [otp, setOtp] = useState(['', '', '', '']);
  const [adminId, setAdminId] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [agreed, setAgreed] = useState(false);
  const [timer, setTimer] = useState(60);
  const [canResend, setCanResend] = useState(false);

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
    setError('');
  };

  const handleOtpChange = (index, value) => {
    if (value.length > 1) value = value[0];
    const newOtp = [...otp];
    newOtp[index] = value;
    setOtp(newOtp);
    
    if (value && index < 3) {
      document.getElementById(`otp-${index + 1}`)?.focus();
    }
  };

  const handleOtpPaste = (e) => {
    e.preventDefault();
    const pastedData = e.clipboardData.getData('text').slice(0, 4);
    const newOtp = pastedData.split('');
    while (newOtp.length < 4) newOtp.push('');
    setOtp(newOtp);
    document.getElementById('otp-3')?.focus();
  };

  const handleKeyDown = (index, e) => {
    if (e.key === 'Backspace' && !otp[index] && index > 0) {
      document.getElementById(`otp-${index - 1}`)?.focus();
    }
    if (e.key === 'ArrowLeft' && index > 0) {
      document.getElementById(`otp-${index - 1}`)?.focus();
    }
    if (e.key === 'ArrowRight' && index < 3) {
      document.getElementById(`otp-${index + 1}`)?.focus();
    }
  };

  const handleRegister = async (e) => {
    e.preventDefault();
    if (!agreed) {
      setError('Please accept Terms and Conditions');
      return;
    }
    if (formData.password !== formData.confirmPassword) {
      setError('Passwords do not match');
      return;
    }
    const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;
    if (!passwordRegex.test(formData.password)) {
      setError('Password must be 8+ characters with uppercase, lowercase, number and special character');
      return;
    }
    
    setLoading(true);
    try {
      const res = await axios.post(`${process.env.REACT_APP_API_URL || 'https://ush-game-version-1.onrender.com'}/admin/auth/register`, {
        username: formData.username,
        phone: formData.phone,
        password: formData.password
      });
      setAdminId(res.data.adminId);
      setStep(2);
      setTimer(60);
      setCanResend(false);
      setError('');
    } catch (err) {
      setError(err.response?.data?.message || 'Registration failed');
    }
    setLoading(false);
  };

  React.useEffect(() => {
    if (step === 2 && timer > 0) {
      const interval = setInterval(() => {
        setTimer((prev) => {
          if (prev <= 1) {
            setCanResend(true);
            return 0;
          }
          return prev - 1;
        });
      }, 1000);
      return () => clearInterval(interval);
    }
  }, [step, timer]);

  const handleVerifyOtp = async (e) => {
    e.preventDefault();
    const otpString = otp.join('');
    if (otpString.length !== 4) {
      setError('Please enter complete OTP');
      return;
    }

    setLoading(true);
    try {
      await axios.post(`${process.env.REACT_APP_API_URL || 'https://ush-game-version-1.onrender.com'}/admin/auth/verify-otp`, {
        adminId,
        otp: otpString
      });
      alert('Registration successful! Please login with your credentials.');
      onSwitchToLogin();
    } catch (err) {
      setError(err.response?.data?.message || 'OTP verification failed');
    }
    setLoading(false);
  };

  const handleResendOtp = async () => {
    if (!canResend) return;
    setLoading(true);
    try {
      await axios.post(`${process.env.REACT_APP_API_URL || 'https://ush-game-version-1.onrender.com'}/admin/auth/resend-otp`, { adminId });
      setTimer(60);
      setCanResend(false);
      setOtp(['', '', '', '']);
      setError('');
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to resend OTP');
    }
    setLoading(false);
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-600 via-blue-500 to-blue-400 p-4">
      <div className="absolute top-0 left-0 w-full h-full overflow-hidden pointer-events-none">
        <div className="absolute top-20 left-10 w-32 h-32 bg-yellow-400 rounded-full opacity-80"></div>
        <div className="absolute top-40 right-20 w-24 h-24 bg-white opacity-30 rounded-lg transform rotate-45"></div>
        <div className="absolute bottom-32 left-1/4 w-20 h-20 bg-yellow-300 rounded-full opacity-70"></div>
      </div>

      <div className="bg-white rounded-3xl shadow-2xl p-8 w-full max-w-md relative z-10">
        <div className="flex justify-between items-center mb-8">
          <button
            onClick={onSwitchToLogin}
            className="px-6 py-2 bg-white border-2 border-blue-600 text-blue-600 rounded-full font-semibold hover:bg-blue-50 transition"
          >
            Login
          </button>
          <h2 className="text-3xl font-bold text-gray-800">
            {step === 1 ? 'Skip the wait.' : 'Verify OTP'}
          </h2>
        </div>

        {step === 1 ? (
          <>
            <p className="text-blue-600 text-xl font-semibold mb-2">Get your ticket.</p>
            <p className="text-gray-500 text-sm mb-6">Create your Account</p>

            <form onSubmit={handleRegister}>
              <div className="mb-4">
                <label className="text-sm text-gray-600 mb-2 block">Enter your Username</label>
                <input
                  type="text"
                  name="username"
                  value={formData.username}
                  onChange={handleChange}
                  placeholder="Enter Username"
                  className="w-full px-4 py-3 bg-gray-100 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  required
                />
              </div>

              <div className="mb-4">
                <label className="text-sm text-gray-600 mb-2 block">Enter your phone number</label>
                <div className="flex gap-2">
                  <select
                    name="countryCode"
                    value={formData.countryCode}
                    onChange={handleChange}
                    className="px-3 py-3 bg-gray-100 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  >
                    <option value="+91">🇮🇳 +91</option>
                    <option value="+1">🇺🇸 +1</option>
                    <option value="+44">🇬🇧 +44</option>
                    <option value="+971">🇦🇪 +971</option>
                  </select>
                  <input
                    type="tel"
                    name="phone"
                    value={formData.phone}
                    onChange={handleChange}
                    placeholder="Your Number"
                    maxLength="10"
                    className="flex-1 px-4 py-3 bg-gray-100 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    required
                  />
                </div>
              </div>

              <div className="mb-4">
                <label className="text-sm text-gray-600 mb-2 block">Password</label>
                <input
                  type="password"
                  name="password"
                  value={formData.password}
                  onChange={handleChange}
                  placeholder="Create Password"
                  className="w-full px-4 py-3 bg-gray-100 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  required
                />
              </div>

              <div className="mb-4">
                <label className="text-sm text-gray-600 mb-2 block">Confirm Password</label>
                <input
                  type="password"
                  name="confirmPassword"
                  value={formData.confirmPassword}
                  onChange={handleChange}
                  placeholder="Confirm Password"
                  className="w-full px-4 py-3 bg-gray-100 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  required
                />
              </div>

              <div className="mb-6">
                <label className="flex items-center gap-2 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={agreed}
                    onChange={(e) => setAgreed(e.target.checked)}
                    className="w-4 h-4 text-blue-600"
                  />
                  <span className="text-sm text-gray-600">Click the box to accept Terms and Conditions.</span>
                </label>
              </div>

              {error && <p className="text-red-500 text-sm mb-4">{error}</p>}

              <button
                type="submit"
                disabled={loading}
                className="w-full bg-blue-600 text-white py-3 rounded-full font-semibold hover:bg-blue-700 transition disabled:opacity-50"
              >
                {loading ? 'Processing...' : 'Sign IN'}
              </button>
            </form>
          </>
        ) : (
          <>
            <p className="text-blue-600 text-xl font-semibold mb-2">Get your ticket.</p>
            <p className="text-gray-500 text-sm mb-6">Create your Account</p>

            <form onSubmit={handleVerifyOtp}>
              <div className="mb-4">
                <label className="text-sm text-gray-600 mb-2 block">Enter OTP</label>
                <div className="flex gap-1.5 sm:gap-2 justify-center mb-4">
                  {otp.slice(0, 4).map((digit, index) => (
                    <input
                      key={index}
                      id={`otp-${index}`}
                      type="text"
                      maxLength="1"
                      value={digit}
                      onChange={(e) => handleOtpChange(index, e.target.value)}
                      onPaste={handleOtpPaste}
                      onKeyDown={(e) => handleKeyDown(index, e)}
                      className="w-10 h-10 sm:w-14 sm:h-14 text-center text-xl sm:text-2xl font-bold border-2 border-blue-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    />
                  ))}
                </div>
                <p className="text-right text-sm text-gray-500">
                  {canResend ? (
                    <button type="button" onClick={handleResendOtp} className="text-blue-600 font-semibold hover:underline">
                      Resend OTP
                    </button>
                  ) : (
                    <span>Resend OTP in <span className="text-blue-600 font-semibold">{timer}s</span></span>
                  )}
                </p>
              </div>

              {error && <p className="text-red-500 text-sm mb-4">{error}</p>}

              <button
                type="submit"
                disabled={loading}
                className="w-full bg-blue-600 text-white py-3 rounded-full font-semibold hover:bg-blue-700 transition disabled:opacity-50"
              >
                {loading ? 'Verifying...' : 'Verify'}
              </button>
            </form>
          </>
        )}
      </div>
    </div>
  );
};

export default Register;
