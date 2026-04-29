import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendancebyface/core/cubits/user_cubit.dart';
import 'package:attendancebyface/core/cubits/user_state.dart';
import 'package:attendancebyface/models/user_model.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';

/// Base class cho screens sử dụng `BlocBuilder` pattern
/// Giảm code trùng lặp cho BlocBuilder pattern
abstract class BaseScreen extends StatelessWidget {
  const BaseScreen({super.key});

  /// Build content khi user đã loaded
  Widget buildContent(UserModel user);

  /// Build loading widget - có thể override
  Widget buildLoading() {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  /// Build error widget - có thể override
  Widget buildError(String message) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Lỗi khi tải dữ liệu'),
            const SizedBox(height: 8),
            Text(message),
            const SizedBox(height: 16),
            Builder(
              builder: (context) => CustomButton(
                text: 'Thử lại',
                onPressed: () => context.read<UserCubit>().refresh(),
                width: 140,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        return state.when(
          initial: () => buildLoading(),
          loading: () => buildLoading(),
          loaded: (user) => buildContent(user),
          error: (message) => buildError(message),
        );
      },
    );
  }
}
