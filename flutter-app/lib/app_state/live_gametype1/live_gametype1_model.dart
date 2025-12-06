class LiveGametype1Model {
  int? selectedNumber;
  String selectedTicketType = '1 Ticket';
  int selectedWeekDay = 1; // Default to 'Tue' (index 1)
  String? selectedTimeSlot;
  String selectedMonth = 'August';

  final List<String> ticketTypes = ['1 Ticket', '3 Ticket', '6 Ticket', 'Custom Tickets'];
  int customTicketCount = 2;
  final List<String> weekDays = ['Mon', 'Tue', 'Wed', 'Thr', 'Fri', 'Sat'];
  final List<int> weekNumbers = [1, 2, 3, 5, 6, 7];
  
  final List<Map<String, dynamic>> timeSlots = [
    {'time': '10:00 AM', 'slots': 20, 'badge': 'Best time'},
    {'time': '11:00 AM', 'slots': 20, 'badge': null},
    {'time': '1:00 PM', 'slots': 20, 'badge': 'Low Time'},
    {'time': '2:00 PM', 'slots': 20, 'badge': null},
    {'time': '3:00 PM', 'slots': 20, 'badge': 'Good time'},
    {'time': '4:00 PM', 'slots': 20, 'badge': null},
    {'time': '5:00 PM', 'slots': 20, 'badge': null},
    {'time': '6:00 PM', 'slots': 20, 'badge': 'Best time'},
  ];

  // Tambola ticket data
  final List<List<String>> ticketData = [
    ['1', '', '32', '40', '', '62', '', '90'],
    ['', '11', '29', '', '41', '', '69', '72'],
    ['9', '13', '', '30', '', '55', '', '82'],
  ];

  final List<String> blueCells = ['11', '29', '30', '41', '55', '69', '72', '82'];

  int get currentTicketCount {
    switch (selectedTicketType) {
      case '1 Ticket':
        return 1;
      case '3 Ticket':
        return 3;
      case '6 Ticket':
        return 6;
      case 'Custom Tickets':
        return customTicketCount;
      default:
        return 1;
    }
  }

  void selectNumber(int number) {
    selectedNumber = number;
  }

  void selectTicketType(String type) {
    selectedTicketType = type;
  }

  void selectWeekDay(int index) {
    if (selectedWeekDay == index) {
      selectedWeekDay = -1;
    } else {
      selectedWeekDay = index;
    }
  }

  void selectTimeSlot(String time) {
    selectedTimeSlot = time;
  }

  void setCustomTicketCount(int count) {
    customTicketCount = count;
  }

  bool get canProceed => selectedWeekDay != -1 && selectedTimeSlot != null;
}
