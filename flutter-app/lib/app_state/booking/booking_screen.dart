import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/backend_api_config.dart';

class BookingScreen extends StatefulWidget {
  final String gameId;
  
  const BookingScreen({Key? key, required this.gameId}) : super(key: key);

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int selectedTicketCount = 1;
  String selectedWeekDay = 'Mon';
  String selectedTimeSlot = '10:00 AM';
  bool isLoading = false;

  final List<String> weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  final List<String> timeSlots = [
    '10:00 AM', '11:00 AM', '1:00 PM', '2:00 PM', 
    '3:00 PM', '4:00 PM', '5:00 PM', '6:00 PM'
  ];

  Future<void> _bookTicket() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        throw Exception('Please login first');
      }

      final scheduledDate = DateTime.now().add(Duration(days: 1)).toIso8601String();
      
      final result = await BackendApiConfig.bookTicket(
        token: token,
        gameId: widget.gameId,
        ticketCount: selectedTicketCount,
        scheduledDate: scheduledDate,
        weekDay: selectedWeekDay,
        timeSlot: selectedTimeSlot,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully booked $selectedTicketCount ticket(s)!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Tickets'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Number of Tickets',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              children: List.generate(6, (index) {
                final count = index + 1;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedTicketCount = count;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedTicketCount == count 
                            ? Colors.blue 
                            : Colors.grey[300],
                        foregroundColor: selectedTicketCount == count 
                            ? Colors.white 
                            : Colors.black,
                      ),
                      child: Text('$count'),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 30),
            
            Text(
              'Select Week Day',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: weekDays.map((day) {
                return ChoiceChip(
                  label: Text(day),
                  selected: selectedWeekDay == day,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        selectedWeekDay = day;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 30),
            
            Text(
              'Select Time Slot',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: timeSlots.map((slot) {
                return ChoiceChip(
                  label: Text(slot),
                  selected: selectedTimeSlot == slot,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        selectedTimeSlot = slot;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            
            Spacer(),
            
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _bookTicket,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Book $selectedTicketCount Ticket(s) for $selectedWeekDay at $selectedTimeSlot',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}