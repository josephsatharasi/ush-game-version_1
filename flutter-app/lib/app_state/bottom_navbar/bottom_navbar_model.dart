class BottomNavItem {
  final String label;
  final String iconPath;
  final int index;

  BottomNavItem({
    required this.label,
    required this.iconPath,
    required this.index,
  });
}

class BottomNavbarModel {
  static final List<BottomNavItem> items = [
    BottomNavItem(label: 'Home', iconPath: 'home', index: 0),
    BottomNavItem(label: 'Tickets', iconPath: 'tickets', index: 1),
    BottomNavItem(label: 'Play Ground', iconPath: 'playground', index: 2),
    BottomNavItem(label: 'Lead board', iconPath: 'leardboard', index: 3),
  ];
}