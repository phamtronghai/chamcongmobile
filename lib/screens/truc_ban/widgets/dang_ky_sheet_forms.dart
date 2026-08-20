import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
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
  TimeOfDay _thoiGianRa = TimeOfDay.now();
  TimeOfDay _thoiGianVao = TimeOfDay(
    hour: (TimeOfDay.now().hour + 1) % 24,
    minute: TimeOfDay.now().minute,
  );

  @override
  void dispose() {
    _lyDoController.dispose();
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
          Row(
            children: [
              Expanded(
                child: _buildTimeField(
                  label: 'Giờ ra',
                  time: _thoiGianRa,
                  onTap: () => _selectTime(true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimeField(
                  label: 'Giờ vào',
                  time: _thoiGianVao,
                  onTap: () => _selectTime(false),
                ),
              ),
            ],
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
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                final now = DateTime.now();
                final thoiGianRa = DateTime(
                  now.year,
                  now.month,
                  now.day,
                  _thoiGianRa.hour,
                  _thoiGianRa.minute,
                );
                final thoiGianVao = DateTime(
                  now.year,
                  now.month,
                  now.day,
                  _thoiGianVao.hour,
                  _thoiGianVao.minute,
                );

                // Lấy tên user từ UserCubit
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
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeField({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ColorConstants.defaultBorderRadius),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.access_time),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              ColorConstants.defaultBorderRadius,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        child: Text(
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
          style: TextConstants.appTextBold,
        ),
      ),
    );
  }

  Future<void> _selectTime(bool isRa) async {
    Navigator.of(context).push(
      showPicker(
        context: context,
        value: Time(
          hour: isRa ? _thoiGianRa.hour : _thoiGianVao.hour,
          minute: isRa ? _thoiGianRa.minute : _thoiGianVao.minute,
        ),
        onChange: (picked) {
          setState(() {
            final newTime = TimeOfDay(hour: picked.hour, minute: picked.minute);
            isRa ? _thoiGianRa = newTime : _thoiGianVao = newTime;
          });
        },
        is24HrFormat: true,
        okText: 'CHỌN',
        cancelText: 'HỦY',
      ),
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
