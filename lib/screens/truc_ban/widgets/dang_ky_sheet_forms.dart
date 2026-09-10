import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/custom_segmented_button.dart';
import 'package:attendancebyface/core/widgets/custom_text_field.dart';
import 'package:attendancebyface/core/cubits/truc_ban_cubit.dart';
import 'package:attendancebyface/core/cubits/user_cubit.dart';
import 'package:attendancebyface/core/cubits/user_state.dart';
import 'package:attendancebyface/models/truc_ban_enums.dart';
import 'package:attendancebyface/core/widgets/date_picker_field.dart';

// ================== DIALOG FORMS ==================

class DangKyRaNgoaiSheetForm extends StatefulWidget {
  const DangKyRaNgoaiSheetForm({super.key});

  @override
  State<DangKyRaNgoaiSheetForm> createState() =>
      _DangKyRaNgoaiSheetFormState();
}

class _DangKyRaNgoaiSheetFormState extends State<DangKyRaNgoaiSheetForm> {
  final _formKey = GlobalKey<FormState>();
  final _lyDoController = TextEditingController();
  late final TextEditingController _gioController;

  static String _formatTimeOfDay(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}${t.minute.toString().padLeft(2, '0')}';

  /// `11101230` / `11:10 - 12:30` → (ra, vào).
  static (TimeOfDay, TimeOfDay)? _parseTimeRange(String? raw) {
    if (raw == null) return null;
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) return null;
    final h1 = int.tryParse(digits.substring(0, 2));
    final m1 = int.tryParse(digits.substring(2, 4));
    final h2 = int.tryParse(digits.substring(4, 6));
    final m2 = int.tryParse(digits.substring(6, 8));
    if (h1 == null || m1 == null || h2 == null || m2 == null) return null;
    if (h1 > 23 || m1 > 59 || h2 > 23 || m2 > 59) return null;
    return (TimeOfDay(hour: h1, minute: m1), TimeOfDay(hour: h2, minute: m2));
  }

  static String _formatDigitsAsRange(String digits) {
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2 || i == 6) buf.write(':');
      if (i == 4) buf.write(' - ');
      buf.write(digits[i]);
    }
    return buf.toString();
  }

  @override
  void initState() {
    super.initState();
    final now = TimeOfDay.now();
    final vao = TimeOfDay(hour: (now.hour + 1) % 24, minute: now.minute);
    final digits = '${_formatTimeOfDay(now)}${_formatTimeOfDay(vao)}';
    _gioController = TextEditingController(text: _formatDigitsAsRange(digits));
  }

  @override
  void dispose() {
    _lyDoController.dispose();
    _gioController.dispose();
    super.dispose();
  }

  String? _validateGio(String? value) {
    final parsed = _parseTimeRange(value);
    if (parsed == null) {
      return 'Nhập 8 số, ví dụ 11101230 → 11:10 - 12:30';
    }
    final (raTod, vaoTod) = parsed;
    final now = DateTime.now();
    // So sánh theo phút: hiện tại <= giờ ra < giờ vào
    final nowFloor = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    );
    final ra = DateTime(
      now.year,
      now.month,
      now.day,
      raTod.hour,
      raTod.minute,
    );
    final vao = DateTime(
      now.year,
      now.month,
      now.day,
      vaoTod.hour,
      vaoTod.minute,
    );

    if (ra.isBefore(nowFloor)) {
      return 'Giờ ra phải từ thời điểm hiện tại trở đi';
    }
    if (!vao.isAfter(ra)) {
      return 'Giờ vào phải sau giờ ra';
    }
    return null;
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final (raTod, vaoTod) = _parseTimeRange(_gioController.text)!;
    final now = DateTime.now();
    final thoiGianRa = DateTime(
      now.year,
      now.month,
      now.day,
      raTod.hour,
      raTod.minute,
    );
    final thoiGianVao = DateTime(
      now.year,
      now.month,
      now.day,
      vaoTod.hour,
      vaoTod.minute,
    );

    final userState = context.read<UserCubit>().state;
    String tenUser = '';
    if (userState is UserLoaded) {
      tenUser = userState.user.name;
    }

    context.read<TrucBanCubit>().dangKyRaNgoai(
      thoiGianRa: thoiGianRa,
      thoiGianVao: thoiGianVao,
      lyDo: _lyDoController.text.trim(),
      tenNguoiDangKy: tenUser,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            controller: _gioController,
            label: 'Giờ ra - Giờ vào *',
            hint: '11101230 → 11:10 - 12:30',
            prefixIcon: Icons.access_time,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            textStyle: TextConstants.appTextBold.copyWith(
              fontSize: TextConstants.fontSizeApp,
            ),
            inputFormatters: const [_RaNgoaiTimeRangeFormatter()],
            validator: _validateGio,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _lyDoController,
            label: 'Lý do *',
            prefixIcon: Icons.note_outlined,
            maxLines: 2,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Vui lòng nhập lý do' : null,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'ĐĂNG KÝ',
            icon: Icons.app_registration,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

/// Chỉ nhận số (tối đa 8); tự chèn `:` và ` - ` → `11:10 - 12:30`.
class _RaNgoaiTimeRangeFormatter extends TextInputFormatter {
  const _RaNgoaiTimeRangeFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final clipped = digits.length > 8 ? digits.substring(0, 8) : digits;
    final formatted = _DangKyRaNgoaiSheetFormState._formatDigitsAsRange(
      clipped,
    );
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class DangKyKhachSheetForm extends StatefulWidget {
  const DangKyKhachSheetForm({super.key});

  @override
  State<DangKyKhachSheetForm> createState() => _DangKyKhachSheetFormState();
}

class _DangKyKhachSheetFormState extends State<DangKyKhachSheetForm> {
  final _formKey = GlobalKey<FormState>();
  final _hoTenController = TextEditingController();
  final _cccdController = TextEditingController();
  final _bienSoController = TextEditingController();

  DateTime _ngayDangKy = DateTime.now();
  LoaiPhuongTien _loaiPhuongTien = LoaiPhuongTien.khac;

  @override
  void dispose() {
    _hoTenController.dispose();
    _cccdController.dispose();
    _bienSoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DatePickerField(
            mode: DatePickerFieldMode.single,
            selectedDate: _ngayDangKy,
            label: 'Ngày đăng ký',
            dialogTitle: 'Chọn ngày',
            dialogSubtitle: 'Ngày khách đến làm việc',
            onDateChanged: (d) => setState(() => _ngayDangKy = d),
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _hoTenController,
            label: 'Họ tên khách *',
            prefixIcon: Icons.person_outline,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Vui lòng nhập họ tên' : null,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _cccdController,
            label: 'Số căn cước *',
            prefixIcon: Icons.badge_outlined,
            keyboardType: TextInputType.number,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Vui lòng nhập số căn cước' : null,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _bienSoController,
            label: 'Biển số xe *',
            prefixIcon: Icons.directions_car_outlined,
            textCapitalization: TextCapitalization.characters,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Vui lòng nhập biển số xe' : null,
          ),
          const SizedBox(height: 12),
          Text(
            'Loại phương tiện:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          CustomSegmentedButton<LoaiPhuongTien>(
            options: const [
              CustomSegmentOption(
                value: LoaiPhuongTien.oto,
                label: 'Ô tô',
                icon: Icons.directions_car,
              ),
              CustomSegmentOption(
                value: LoaiPhuongTien.khac,
                label: 'Khác',
                icon: Icons.two_wheeler,
              ),
            ],
            selected: {_loaiPhuongTien},
            onSelectionChanged: (selected) {
              if (selected.isNotEmpty) {
                setState(() => _loaiPhuongTien = selected.first);
              }
            },
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'ĐĂNG KÝ',
            icon: Icons.app_registration,
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                context.read<TrucBanCubit>().dangKyKhach(
                  hoTenKhach: _hoTenController.text.trim(),
                  soCanCuoc: _cccdController.text.trim(),
                  bienSoXe: _bienSoController.text.trim().toUpperCase(),
                  loaiPhuongTien: _loaiPhuongTien,
                  ngayDangKy: _ngayDangKy,
                );
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
