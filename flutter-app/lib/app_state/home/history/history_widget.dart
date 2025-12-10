import 'package:flutter/material.dart';

class HistoryWidget extends StatelessWidget {
  const HistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Game #12', 'On going', Colors.orange),
      ('Game #11', 'Runner', Colors.lightBlue),
      ('Game #10', 'Won', Colors.green),
      ('Game #09', 'Lost', Colors.redAccent),
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A3B8E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('History', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Text('Hello, User', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text('Start Playing today and win!!'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A3B8E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: const Text('Start New Game'),
              ),
            ),
            const SizedBox(height: 16),
            const Text('History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final (title, chip, color) = items[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.flash_on_rounded, color: Color(0xFF0A3B8E)),
                      title: Text(title),
                      subtitle: Row(
                        children: [
                          Chip(label: Text(chip), backgroundColor: color.withOpacity(0.2), labelStyle: TextStyle(color: color)),
                        ],
                      ),
                      trailing: CircleAvatar(
                        backgroundColor: const Color(0xFF0A3B8E),
                        child: const Icon(Icons.arrow_outward_rounded, color: Colors.white),
                      ),
                      onTap: () {},
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
