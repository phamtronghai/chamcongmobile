class AttendanceModel {
  final String id;
  final String userId;
  final DateTime checkInTime;
  final String location;
  final String? checkInImageUrl;
  final String? localImagePath;
  final double? lat;
  final double? long;

  AttendanceModel({
    required this.id,
    required this.userId,
    required this.checkInTime,
    required this.location,
    this.checkInImageUrl,
    this.localImagePath,
    this.lat,
    this.long,
  });

  AttendanceModel copyWith({
    String? id,
    String? userId,
    DateTime? checkInTime,
    String? location,
    String? checkInImageUrl,
    String? localImagePath,
    double? lat,
    double? long,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      checkInTime: checkInTime ?? this.checkInTime,
      location: location ?? this.location,
      checkInImageUrl: checkInImageUrl ?? this.checkInImageUrl,
      localImagePath: localImagePath ?? this.localImagePath,
      lat: lat ?? this.lat,
      long: long ?? this.long,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'checkInTime': checkInTime.toIso8601String(),
      'location': location,
      'checkInImageUrl': checkInImageUrl,
      'localImagePath': localImagePath,
      'lat': lat,
      'long': long,
    };
  }

  static AttendanceModel fromJson(Map<String, dynamic> json) {
    // Xử lý trường hợp recordtime từ API
    DateTime checkInTime;
    if (json.containsKey('recordtime')) {
      checkInTime = DateTime.parse(json['recordtime']);
    } else if (json.containsKey('checkInTime')) {
      checkInTime = DateTime.parse(json['checkInTime']);
    } else {
      checkInTime = DateTime.now();
    }

    // Xử lý trường hợp url_image từ API
    String? imageUrl;
    if (json.containsKey('url_image')) {
      imageUrl = json['url_image'];
    } else {
      imageUrl = json['checkInImageUrl'];
    }

    return AttendanceModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? json['userId'] ?? '',
      checkInTime: checkInTime,
      location: json['location'] ?? '',
      checkInImageUrl: imageUrl,
      localImagePath: json['localImagePath'],
      lat: json['lat'] != null ? double.tryParse(json['lat'].toString()) : null,
      long: json['long'] != null
          ? double.tryParse(json['long'].toString())
          : null,
    );
  }
}
