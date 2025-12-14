class HomeModel {
  static const String addsText = "Add's";
  static const String startGameText = "Start Game";
  
  static const List<String> menuItems = [
    "Settings",
    "History", 
    "Cuppons"
  ];

  String ticketNumber = '';
  String generatedNumbers = '';
  String currentLocation = 'Fetching location...';
  
  List<int> getNumbersList() {
    if (generatedNumbers.isEmpty) return [];
    return generatedNumbers.split(',').map((e) => int.tryParse(e.trim()) ?? 0).toList();
  }

  void updateLocation(String location) {
    currentLocation = location;
  }
}