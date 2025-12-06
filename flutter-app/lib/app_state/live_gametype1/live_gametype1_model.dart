class LiveGametype1Model {
  int? selectedNumber;
  String selectedTicketType = '1 Ticket';
  int selectedWeekDay = -1;
  String? selectedTimeSlot;
  String selectedMonth = 'August';

  List<String> ticketTypes = ['1 Ticket'];
  int customTicketCount = 2;
  int maxTicketsPerUser = 6;
  List<String> weekDays = [];
  List<Map<String, dynamic>> timeSlots = [];

  int get currentTicketCount {
    if (selectedTicketType == 'Custom') {
      return customTicketCount.clamp(1, maxTicketsPerUser);
    }
    
    if (selectedTicketType.startsWith('Ticket ')) {
      final number = selectedTicketType.split(' ')[1];
      return int.tryParse(number) ?? 1;
    }
    
    final match = RegExp(r'(\d+)').firstMatch(selectedTicketType);
    if (match != null) {
      return int.parse(match.group(1)!);
    }
    
    return 1;
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
    customTicketCount = count.clamp(1, maxTicketsPerUser);
  }

  bool get canProceed => selectedWeekDay != -1 && selectedTimeSlot != null;

  void updateSlotConfiguration(Map<String, dynamic> config) {
    maxTicketsPerUser = config['maxTicketsPerUser'] ?? 6;
    weekDays = List<String>.from(config['availableWeekDays'] ?? []);
    
    // Generate preset ticket options
    ticketTypes = [];
    if (maxTicketsPerUser >= 1) ticketTypes.add('1 Ticket');
    if (maxTicketsPerUser >= 3) ticketTypes.add('3 Tickets');
    if (maxTicketsPerUser >= 6) ticketTypes.add('6 Tickets');
    
    // Add custom option for other numbers (2, 4, 5)
    if (maxTicketsPerUser > 1) {
      ticketTypes.add('Custom');
    }
    
    // Set default selection if current is invalid
    if (!ticketTypes.contains(selectedTicketType)) {
      selectedTicketType = ticketTypes.isNotEmpty ? ticketTypes.first : '1 Ticket';
    }
    
    // Update time slots from backend
    timeSlots = (config['availableTimeSlots'] as List? ?? []).map((slot) => {
      'time': slot['time'] as String,
      'slots': (slot['totalSlots'] as int) - (slot['bookedSlots'] as int? ?? 0),
      'badge': slot['badge'] as String?
    }).toList();
    
    // Reset selections if current selection is invalid
    if (selectedWeekDay >= weekDays.length) {
      selectedWeekDay = -1;
    }
    
    if (selectedTimeSlot != null && !timeSlots.any((slot) => slot['time'] == selectedTimeSlot)) {
      selectedTimeSlot = null;
    }
  }
}
