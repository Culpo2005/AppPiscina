class UserData {
  final String userId;
  final Map<String, dynamic> settings;
  final List<dynamic> payloadData;

  UserData({
    required this.userId,
    required this.settings,
    required this.payloadData,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
       userId: json['user_id'] ?? '',
      settings: Map<String, dynamic>.from(
        json['settings'] ?? {},
      ),
      payloadData: List<dynamic>.from(
        json['payload_data'] ?? [],
      ),
    );
  }
}