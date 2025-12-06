class LiveGametype1Model {
  String selectedTicketType = '1 Ticket';
  int selectedWeekDay = -1;
  String? selectedTimeSlot;
  int customTicketCount = 2;
  int maxTicketsPerUser = 6;

  List<String> weekDays = [];
  List<int> weekNumbers = [];
  List<Map<String, dynamic>> timeSlots = [];
  List<int> availableTickets = [];

  List<List<String>> ticketData = [
    ['1', '', '32', '40', '', '62', '', '90'],
    ['', '11', '29', '', '41', '', '69', '72'],
    ['9', '13', '', '30', '', '55', '', '82'],
  ];

  Set<String> blueCells = {'32', '41', '55', '69'};

  int get currentTicketCount {
    if (selectedTicketType == 'Custom Tickets') {
      return customTicketCount;
    }
    final match = RegExp(r'(\d+)').firstMatch(selectedTicketType);
    return match != null ? int.parse(match.group(1)!) : 1;
  }

  void loadSlotConfig(Map<String, dynamic> config) {
    maxTicketsPerUser = config['maxTicketsPerUser'] ?? 6;
    availableTickets = List<int>.from(config['availableTickets'] ?? [1, 3, 6]);
    weekDays = List<String>.from(config['availableWeekDays'] ?? []);
    weekNumbers = List.generate(weekDays.length, (i) => i + 1);
    
    final slots = config['availableTimeSlots'] as List? ?? [];
    timeSlots = slots.map((slot) => {
      'time': slot['time'] as String,
      'slots': (slot['totalSlots'] as int) - (slot['bookedSlots'] as int? ?? 0),
      'badge': slot['badge'] as String?,
    }).toList();
  }

  void selectTicketType(String type) {
    selectedTicketType = type;
  }

  void selectWeekDay(int index) {
    selectedWeekDay = index;
  }

  void selectTimeSlot(String time) {
    selectedTimeSlot = time;
  }

  void setCustomTicketCount(int count) {
    customTicketCount = count;
  }

  bool get canProceed => selectedWeekDay != -1 && selectedTimeSlot != null && weekDays.isNotEmpty && timeSlots.isNotEmpty;
}
