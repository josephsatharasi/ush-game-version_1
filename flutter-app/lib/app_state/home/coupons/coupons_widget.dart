import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/backend_api_config.dart';

class CouponsWidget extends StatefulWidget {
  const CouponsWidget({super.key});

  @override
  State<CouponsWidget> createState() => _CouponsWidgetState();
}

class _CouponsWidgetState extends State<CouponsWidget> {
  List<_CouponData> _coupons = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  Future<void> _loadCoupons() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      final response = await BackendApiConfig.getMyCoupons(token: token);
      final List<dynamic> couponsJson = response['coupons'] ?? [];
      
      if (mounted) {
        setState(() {
          _coupons = couponsJson.map((json) => _CouponData.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load coupons: $e')),
        );
      }
    }
  }

  List<_CouponData> get _filteredCoupons {
    if (_searchQuery.isEmpty) return _coupons;
    return _coupons.where((coupon) {
      final gameCode = coupon.gameCode?.toLowerCase() ?? '';
      final winType = coupon.winType.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return gameCode.contains(query) || winType.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A3B8E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Scratch cards', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu, color: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search Coupons',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Your Won Coupons (${_filteredCoupons.length}) ✨'),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredCoupons.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.card_giftcard, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('No coupons found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                              SizedBox(height: 8),
                              Text('Win games to earn coupons!', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredCoupons.length,
                          itemBuilder: (context, index) {
                            final coupon = _filteredCoupons[index];
                            return _buildCouponCard(coupon);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponCard(_CouponData coupon) {
    final isAssigned = coupon.status == 'ASSIGNED';
    final statusColor = isAssigned ? Colors.green : Colors.orange;
    final statusText = isAssigned ? 'Available' : 'Pending';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  coupon.gameCode ?? 'Game Coupon',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Win Type: ${coupon.winType}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            if (coupon.cardNumber != null) ...[
              const SizedBox(height: 4),
              Text(
                'Card: ${coupon.cardNumber}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
            if (coupon.couponCode != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A3B8E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Code: ${coupon.couponCode}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A3B8E),
                      ),
                    ),
                    Icon(
                      Icons.card_giftcard,
                      color: const Color(0xFF0A3B8E),
                    ),
                  ],
                ),
              ),
            ],
            if (coupon.wonAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Won on: ${_formatDate(coupon.wonAt!)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _CouponData {
  final String? gameCode;
  final String? gameId;
  final String winType;
  final String? cardNumber;
  final DateTime? wonAt;
  final String? couponCode;
  final String? status;

  _CouponData({
    this.gameCode,
    this.gameId,
    required this.winType,
    this.cardNumber,
    this.wonAt,
    this.couponCode,
    this.status,
  });

  factory _CouponData.fromJson(Map<String, dynamic> json) {
    return _CouponData(
      gameCode: json['gameCode'],
      gameId: json['gameId'],
      winType: json['winType'] ?? '',
      cardNumber: json['cardNumber'],
      wonAt: json['wonAt'] != null ? DateTime.parse(json['wonAt']) : null,
      couponCode: json['couponCode'],
      status: json['status'],
    );
  }
}
