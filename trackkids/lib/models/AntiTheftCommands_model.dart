class AntiTheftCommandsModel {
  final bool ring;
  final bool lock;
  final String lostMessage;
  final bool locate;

  AntiTheftCommandsModel({
    this.ring = false,
    this.lock = false,
    this.lostMessage = '',
    this.locate = false,
  });

  factory AntiTheftCommandsModel.fromMap(Map<String, dynamic> map) {
    return AntiTheftCommandsModel(
      ring: map['ring'] ?? false,
      lock: map['lock'] ?? false,
      lostMessage: map['lostMessage'] ?? '',
      locate: map['locate'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ring': ring,
      'lock': lock,
      'lostMessage': lostMessage,
      'locate': locate,
    };
  }
}
