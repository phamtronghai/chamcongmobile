class WorklogModel {
  final String id;
  final String userId;
  final String workName;
  final String workDescription;
  final int sessionId;
  final String date;
  final DateTime createdAt;

  WorklogModel({
    required this.id,
    required this.userId,
    required this.workName,
    required this.workDescription,
    required this.sessionId,
    required this.date,
    required this.createdAt,
  });

  factory WorklogModel.fromJson(Map<String, dynamic> json) {
    return WorklogModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['userID']?.toString() ?? '',
      workName: json['workName']?.toString() ?? '',
      workDescription: json['workDescription']?.toString() ?? '',
      sessionId: int.tryParse(json['sessionId']?.toString() ?? '0') ?? 0,
      date: json['date']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}


