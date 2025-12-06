import 'package:flutter/material.dart';

class DeliveryStatusWidget extends StatefulWidget {
  const DeliveryStatusWidget({super.key});

  @override
  State<DeliveryStatusWidget> createState() => _DeliveryStatusWidgetState();
}

class _DeliveryStatusWidgetState extends State<DeliveryStatusWidget> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home', arguments: {'showTicket': true});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0A3B8E),
        title: const Text('Delivery Status', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _headerCard(),
            const SizedBox(height: 16),
            _timelineSection(),
            const SizedBox(height: 16),
            _paymentSection(),
            const SizedBox(height: 16),
            _instructionsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _headerCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A3B8E),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 6))],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
      child: Row(
        children: [
          const CircleAvatar(radius: 26, backgroundColor: Colors.white, child: Icon(Icons.person, color: Color(0xFF0A3B8E))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Ragunandhan', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                _Stars(),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.chat_bubble_outline, color: Colors.white)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.call, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _timelineSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _dot(const Color(0xFF0A3B8E)),
              Container(width: 2, height: 64, color: Colors.grey.shade300),
              _dot(Colors.grey.shade400),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Estimated Delivery Date', style: TextStyle(color: Colors.grey, fontSize: 14)),
                SizedBox(height: 4),
                Text('12 May 2022', style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 16),
                Text('Mirod Road', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text('Your House', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: Color(0xFF0A3B8E), child: Icon(Icons.credit_card, color: Colors.white)),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Payment\nINR 200/-', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          Row(children: const [
            CircleAvatar(radius: 14, backgroundColor: Colors.white, child: Text('GPay', style: TextStyle(fontSize: 10))),
            SizedBox(width: 6),
            CircleAvatar(radius: 14, backgroundColor: Colors.white, child: Text('Paytm', style: TextStyle(fontSize: 10))),
            SizedBox(width: 6),
            CircleAvatar(radius: 14, backgroundColor: Colors.white, child: Icon(Icons.local_shipping, size: 14)),
          ]),
        ],
      ),
    );
  }

  Widget _instructionsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: const [
            CircleAvatar(backgroundColor: Color(0xFF0A3B8E), child: Icon(Icons.edit, color: Colors.white)),
            SizedBox(width: 8),
            Text('Instructions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 12),
          TextField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Message',
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) => Container(width: 16, height: 16, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}

class _Stars extends StatelessWidget {
  const _Stars();
  @override
  Widget build(BuildContext context) {
    return Row(children: const [
      Icon(Icons.star, color: Colors.amber, size: 16),
      Icon(Icons.star, color: Colors.amber, size: 16),
      Icon(Icons.star, color: Colors.amber, size: 16),
      Icon(Icons.star_half, color: Colors.amber, size: 16),
      Icon(Icons.star_outline, color: Colors.white70, size: 16),
    ]);
  }
}
