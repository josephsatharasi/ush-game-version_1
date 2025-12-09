enum WinType {
  FIRST_LINE,
  SECOND_LINE,
  THIRD_LINE,
  JALDI,
  HOUSIE;

  String get displayName {
    switch (this) {
      case WinType.FIRST_LINE:
        return 'First Line';
      case WinType.SECOND_LINE:
        return 'Second Line';
      case WinType.THIRD_LINE:
        return 'Third Line';
      case WinType.JALDI:
        return 'Jaldi';
      case WinType.HOUSIE:
        return 'Housie';
    }
  }

  String get apiValue {
    return name;
  }

  static WinType fromString(String value) {
    return WinType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => WinType.HOUSIE,
    );
  }
}
