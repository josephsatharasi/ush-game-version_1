class HomeModel {
  static const String addsText = "Add's";
  static const String startGameText = "Start Game";
  
  static const List<String> menuItems = [
    "Settings",
    "History", 
    "Cuppons"
  ];

  static const Map<String, String> winTypeMap = {
    'FIRST LINE': 'FIRST_LINE',
    'SECOND LINE': 'SECOND_LINE',
    'THIRD LINE': 'THIRD_LINE',
    'JALDHI': 'JALDI',
    'HOUSI': 'HOUSIE',
  };

  String ticketNumber = '';
  String generatedNumbers = '';
  
  List<int> getNumbersList() {
    if (generatedNumbers.isEmpty) return [];
    return generatedNumbers.split(',').map((e) => int.tryParse(e.trim()) ?? 0).toList();
  }
}