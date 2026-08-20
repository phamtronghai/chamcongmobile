/// Model để parse dữ liệu QR căn cước công dân
class CitizenIDData {
  final String citizenId;
  final String oldId;
  final String fullName;
  final String dateOfBirth;
  final String gender;
  final String address;
  final String issueDate;

  CitizenIDData({
    required this.citizenId,
    required this.oldId,
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
    required this.address,
    required this.issueDate,
  });

  /// Parse dữ liệu từ QR code căn cước
  factory CitizenIDData.fromQRData(String qrData) {
    final parts = qrData.split('|');
    if (parts.length < 7) {
      throw Exception('Dữ liệu QR không hợp lệ');
    }
    return CitizenIDData(
      citizenId: parts[0].trim(),
      oldId: parts[1].trim(),
      fullName: parts[2].trim(),
      dateOfBirth: parts[3].trim(),
      gender: parts[4].trim(),
      address: parts[5].trim(),
      issueDate: parts[6].trim(),
    );
  }

  /// Format ngày sinh từ DDMMYYYY thành DD/MM/YYYY
  String get formattedDateOfBirth {
    if (dateOfBirth.length == 8) {
      return '${dateOfBirth.substring(0, 2)}/${dateOfBirth.substring(2, 4)}/${dateOfBirth.substring(4, 8)}';
    }
    return dateOfBirth;
  }

  /// Format ngày cấp từ DDMMYYYY thành DD/MM/YYYY
  String get formattedIssueDate {
    if (issueDate.length == 8) {
      return '${issueDate.substring(0, 2)}/${issueDate.substring(2, 4)}/${issueDate.substring(4, 8)}';
    }
    return issueDate;
  }

  /// Format giới tính từ mã số thành text
  String get formattedGender {
    switch (gender.toLowerCase()) {
      case 'nam':
      case '1':
        return 'Nam';
      case 'nữ':
      case '0':
        return 'Nữ';
      default:
        return gender;
    }
  }

  /// Convert to JSON format for API
  Map<String, dynamic> toJson() {
    return {
      'citizenNumber': citizenId,
      'oldIdNumber': oldId,
      'fullName': fullName,
      'dateOfBirth': _formatDateForAPI(dateOfBirth),
      'gender': formattedGender,
      'address': address,
      'issuedDate': _formatDateForAPI(issueDate),
    };
  }

  /// Format ngày từ DDMMYYYY thành YYYY-MM-DD cho API
  String _formatDateForAPI(String dateString) {
    if (dateString.length == 8) {
      final day = dateString.substring(0, 2);
      final month = dateString.substring(2, 4);
      final year = dateString.substring(4, 8);
      return '$year-$month-$day';
    }
    return dateString;
  }
}
