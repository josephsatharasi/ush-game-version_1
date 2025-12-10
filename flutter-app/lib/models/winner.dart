class Winner {
  final String? userId;
  final String? username;
  final String? cardNumber;
  final DateTime? wonAt;
  final String? couponCode;
  final String winType;
  final String? gameCode;
  final String? gameId;
  final String? status;

  Winner({
    this.userId,
    this.username,
    this.cardNumber,
    this.wonAt,
    this.couponCode,
    required this.winType,
    this.gameCode,
    this.gameId,
    this.status,
  });

  factory Winner.fromJson(Map<String, dynamic> json) {
    return Winner(
      userId: json['userId'],
      username: json['username'],
      cardNumber: json['cardNumber'],
      wonAt: json['wonAt'] != null ? DateTime.parse(json['wonAt']) : null,
      couponCode: json['couponCode'],
      winType: json['winType'] ?? '',
      gameCode: json['gameCode'],
      gameId: json['gameId'],
      status: json['status'],
    );
  }
}
