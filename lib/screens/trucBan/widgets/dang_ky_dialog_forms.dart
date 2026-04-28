import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/cubits/truc_ban_cubit.dart';
import 'package:attendancebyface/core/cubits/user_cubit.dart';
import 'package:attendancebyface/core/cubits/user_state.dart';
import 'package:attendancebyface/models/truc_ban_enums.dart';
import 'package:attendancebyface/core/widgets/date_picker_dialog.dart';

// ================== DIALOG FORMS ==================

class DangKyRaNgoaiDialogForm extends StatefulWidget {
  const DangKyRaNgoaiDialogForm({super.key});

  @override
  State<DangKyRaNgoaiDialogForm> createState() =>
      _DangKyRaNgoaiDialogFormState();
}

class _DangKyRaNgoaiDialogFormState extends State<DangKyRaNgoaiDialogForm> {
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
          TextFormField(
            controller: _lyDoController,
            decoration: InputDecoration(
              labelText: 'Lý do *',
              prefixIcon: const Icon(Icons.note_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  ColorConstants.defaultBorderRadius,
                ),
              ),
            ),
            maxLines: 2,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Vui lòng nhập lý do' : null,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'ĐĂNG KÝ',
            backgroundColor: ColorConstants.primaryColor,
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

class DangKyKhachDialogForm extends StatefulWidget {
  const DangKyKhachDialogForm({super.key});

  @override
  State<DangKyKhachDialogForm> createState() => _DangKyKhachDialogFormState();
}

class _DangKyKhachDialogFormState extends State<DangKyKhachDialogForm> {
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
          _buildDateField(
            label: 'Ngày đăng ký',
            date: _ngayDangKy,
            onTap: _selectDate,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _hoTenController,
            decoration: InputDecoration(
              labelText: 'Họ tên khách *',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  ColorConstants.defaultBorderRadius,
                ),
              ),
            ),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Vui lòng nhập họ tên' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cccdController,
            decoration: InputDecoration(
              labelText: 'Số căn cước *',
              prefixIcon: const Icon(Icons.badge_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  ColorConstants.defaultBorderRadius,
                ),
              ),
            ),
            keyboardType: TextInputType.number,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Vui lòng nhập số căn cước' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _bienSoController,
            decoration: InputDecoration(
              labelText: 'Biển số xe *',
              prefixIcon: const Icon(Icons.directions_car_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  ColorConstants.defaultBorderRadius,
                ),
              ),
            ),
            textCapitalization: TextCapitalization.characters,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Vui lòng nhập biển số xe' : null,
          ),
          const SizedBox(height: 12),
          Text(
            'Loại phương tiện:',
            style: TextStyle(
              fontSize: TextConstants.body,
              fontWeight: TextConstants.medium,
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<LoaiPhuongTien>(
            segments: const [
              ButtonSegment(
                value: LoaiPhuongTien.oto,
                label: Text('Ô tô'),
                icon: Icon(Icons.directions_car, size: 18),
              ),
              ButtonSegment(
                value: LoaiPhuongTien.khac,
                label: Text('Khác'),
                icon: Icon(Icons.two_wheeler, size: 18),
              ),
            ],
            selected: {_loaiPhuongTien},
            onSelectionChanged: (selected) =>
                setState(() => _loaiPhuongTien = selected.first),
            showSelectedIcon: false,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'ĐĂNG KÝ',
            backgroundColor: ColorConstants.primaryColor,
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

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ColorConstants.defaultBorderRadius),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today),
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
          DateFormat('dd/MM/yyyy').format(date),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    AppDatePickerDialog.show(
      context,
      initialDate: _ngayDangKy,
      onDateSelected: (picked) => setState(() => _ngayDangKy = picked),
    );
  }
}
