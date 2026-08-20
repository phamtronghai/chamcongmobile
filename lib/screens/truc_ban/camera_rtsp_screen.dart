import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:attendancebyface/core/app_config.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/custom_app_bar.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/widgets/samcom_tab_bar.dart';

/// Màn hình xem camera RTSP giám sát
/// Hỗ trợ chuyển đổi giữa nhiều camera, 1 player duy nhất để tiết kiệm tài nguyên
class CameraRTSPScreen extends StatefulWidget {
  const CameraRTSPScreen({super.key});

  @override
  State<CameraRTSPScreen> createState() => _CameraRTSPScreenState();
}

class _CameraRTSPScreenState extends State<CameraRTSPScreen>
    with TickerProviderStateMixin {
  late final Player _player;
  late final VideoController _videoController;
  late TabController _tabController;
  bool _isPlayerInitialized = false;
  bool _isCameraLoading = true;
  String? _cameraError;
  int _selectedCameraIndex = 0;
  bool _isDisposed = false;
  final List<StreamSubscription<dynamic>> _cameraSubscriptions = [];
  static const int _cameraTimeout = 30;

  @override
  void initState() {
    super.initState();
    // Cho phép xoay ngang ở màn hình camera
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _tabController = TabController(
      length: AppConfig.camerasRTSP.length,
      vsync: this,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      _switchCamera(_tabController.index);
    });
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      MediaKit.ensureInitialized();
      _player = Player();
      _videoController = VideoController(_player);
      _isPlayerInitialized = true;

      await _configurePlayerForRTSP();

      _cameraSubscriptions.add(
        _player.stream.error.listen((error) {
          if (mounted && !_isDisposed) {
            setState(() {
              _cameraError = 'Lỗi stream: $error';
              _isCameraLoading = false;
            });
          }
        }),
      );

      _cameraSubscriptions.add(
        _player.stream.playing.listen((playing) {
          if (mounted && !_isDisposed && playing) {
            setState(() {
              _isCameraLoading = false;
              _cameraError = null;
            });
          }
        }),
      );

      _cameraSubscriptions.add(
        _player.stream.buffering.listen((buffering) {
          if (mounted && !_isDisposed) {
            setState(() {
              _isCameraLoading = buffering;
            });
          }
        }),
      );

      if (mounted) {
        await _openCameraStream();
      }
    } catch (e) {
      debugPrint('Lỗi khởi tạo camera: $e');
      if (mounted) {
        setState(() {
          _cameraError = 'Lỗi khởi tạo: $e';
          _isCameraLoading = false;
        });
      }
    }
  }

  Future<void> _configurePlayerForRTSP() async {
    if (_player.platform is NativePlayer) {
      final nativePlayer = _player.platform as NativePlayer;
      await nativePlayer.setProperty('hwdec', 'auto');
      await nativePlayer.setProperty('profile', 'low-latency');
      await nativePlayer.setProperty('untimed', 'yes');
      await nativePlayer.setProperty('rtsp-transport', 'tcp');
      await nativePlayer.setProperty('framedrop', 'vo');
      await nativePlayer.setProperty('demuxer-max-bytes', '32M');
      await nativePlayer.setProperty('demuxer-max-back-bytes', '0');
      await nativePlayer.setProperty('network-timeout', '$_cameraTimeout');
    }
  }

  /// Mở stream camera theo index hiện tại
  Future<void> _openCameraStream() async {
    if (!_isPlayerInitialized || _isDisposed) return;
    try {
      final url = AppConfig.camerasRTSP[_selectedCameraIndex].url;
      await _player.open(Media(url));
    } catch (e) {
      if (mounted && !_isDisposed) {
        setState(() {
          _cameraError = 'Không thể kết nối: $e';
          _isCameraLoading = false;
        });
      }
    }
  }

  /// Dừng player an toàn trước khi chuyển/dispose
  Future<void> _stopPlayer() async {
    if (!_isPlayerInitialized) return;
    try {
      await _player.stop();
    } catch (e) {
      debugPrint('Lỗi khi dừng player: $e');
    }
  }

  /// Chuyển đổi camera
  Future<void> _switchCamera(int index) async {
    if (index == _selectedCameraIndex || _isDisposed) return;
    setState(() {
      _selectedCameraIndex = index;
      _isCameraLoading = true;
      _cameraError = null;
    });
    // Dừng stream hiện tại trước khi mở stream mới
    await _stopPlayer();
    if (!_isDisposed) {
      await _openCameraStream();
    }
  }

  Future<void> _retryCamera() async {
    if (!_isPlayerInitialized || _isDisposed) return;
    setState(() {
      _isCameraLoading = true;
      _cameraError = null;
    });
    await _stopPlayer();
    if (!_isDisposed) {
      await _openCameraStream();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;

    // Reset orientation khi thoát
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Cancel subscriptions trước để không còn callback nào gọi lại
    for (final sub in _cameraSubscriptions) {
      sub.cancel();
    }
    _cameraSubscriptions.clear();

    _tabController.dispose();
    if (_isPlayerInitialized) {
      try {
        _player.dispose();
      } catch (e) {
        debugPrint('Lỗi khi dispose player: $e');
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Camera Giám Sát'),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Video player
          Center(
            child: _isPlayerInitialized
                ? Video(controller: _videoController)
                : const CircularProgressIndicator(),
          ),

          // Loading / Error overlay
          if (_isCameraLoading || _cameraError != null)
            Container(
              color: ColorConstants.backgroundDark.withValues(alpha: 0.87),
              child: Center(
                child: _isCameraLoading
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            color: ColorConstants.backgroundLight,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Đang kết nối camera...',
                            style: TextConstants.appTextRegular.copyWith(
                              color: ColorConstants.backgroundLight,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: ColorConstants.errorColor,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _cameraError ?? 'Lỗi không xác định',
                            style: TextConstants.appTextRegular.copyWith(
                              color: ColorConstants.backgroundLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                            text: 'Thử lại',
                            icon: Icons.refresh,
                            onPressed: _retryCamera,
                            width: 120,
                          ),
                        ],
                      ),
              ),
            ),

          // Camera selector chips
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: SafeArea(child: _buildCameraSelector()),
          ),

        ],
      ),
    );
  }

  /// Widget chọn camera dùng ButtonsTabBar
  Widget _buildCameraSelector() {
    return SamcomTabBar(
      controller: _tabController,
      center: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      unselectedBackgroundColor: ColorConstants.backgroundDark.withValues(
        alpha: 0.54,
      ),
      labelStyle: TextConstants.appTextBold.copyWith(
        color: ColorConstants.backgroundLight,
      ),
      unselectedLabelStyle: TextConstants.appTextRegular.copyWith(
        color: ColorConstants.backgroundLight.withValues(alpha: 0.7),
      ),
      tabs: AppConfig.camerasRTSP
          .map(
            (c) => Tab(
              icon: const Icon(Icons.videocam, size: 16),
              text: c.label,
            ),
          )
          .toList(),
    );
  }
}
