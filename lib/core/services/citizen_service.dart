import 'package:attendancebyface/core/repositories/citizen_repository.dart';
import 'package:attendancebyface/widgets/citizen_id_form_dialog.dart';
import 'base_service.dart';

/// Service để xử lý business logic liên quan đến căn cước công dân
class CitizenService extends BaseService {
  final CitizenRepository _citizenRepository = CitizenRepository();

  /// Khởi tạo service
  @override
  Future<void> init() async {
    await _citizenRepository.init();
  }

  /// Kiểm tra xem user đã đăng ký thông tin căn cước chưa
  Future<bool> checkCitizenRegistration() async {
    return await handleServiceCall(
      () => _citizenRepository.checkCitizenRegistration(),
    );
  }

  /// Lấy thông tin căn cước chi tiết
  Future<Map<String, dynamic>?> fetchCitizenInfo() async {
    return await _citizenRepository.fetchCitizenInfo();
  }

  /// Thêm thông tin căn cước từ CitizenIDData
  Future<bool> addCitizenInfo(CitizenIDData citizenData) async {
    return await handleServiceCall(() async {
      // Format ngày sinh từ DDMMYYYY thành YYYY-MM-DD
      String formattedDateOfBirth = _formatDateForAPI(citizenData.dateOfBirth);

      // Format ngày cấp từ DDMMYYYY thành YYYY-MM-DD
      String formattedIssuedDate = _formatDateForAPI(citizenData.issueDate);

      final result = await _citizenRepository.addCitizenInfo(
        citizenNumber: citizenData.citizenId,
        oldIdNumber: citizenData.oldId,
        fullName: citizenData.fullName,
        dateOfBirth: formattedDateOfBirth,
        gender: citizenData.formattedGender,
        address: citizenData.address,
        issuedDate: formattedIssuedDate,
      );

      return result['success'] == true;
    });
  }

  /// Cập nhật thông tin căn cước từ CitizenIDData
  Future<bool> updateCitizenInfo(CitizenIDData citizenData) async {
    return await handleServiceCall(() async {
      // Format ngày sinh từ DDMMYYYY thành YYYY-MM-DD
      String formattedDateOfBirth = _formatDateForAPI(citizenData.dateOfBirth);

      // Format ngày cấp từ DDMMYYYY thành YYYY-MM-DD
      String formattedIssuedDate = _formatDateForAPI(citizenData.issueDate);

      final result = await _citizenRepository.updateCitizenInfo(
        citizenNumber: citizenData.citizenId,
        oldIdNumber: citizenData.oldId,
        fullName: citizenData.fullName,
        dateOfBirth: formattedDateOfBirth,
        gender: citizenData.formattedGender,
        address: citizenData.address,
        issuedDate: formattedIssuedDate,
      );

      return result['success'] == true;
    });
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

  /// Dispose service
  @override
  void dispose() {
    // Cleanup nếu cần
  }
}
