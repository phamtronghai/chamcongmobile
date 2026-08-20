import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/app_theme.dart';
import 'core/app_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/network/api_client.dart';
import 'core/app_config.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/notification_service.dart';
import 'core/cubits/user_cubit.dart';

import 'core/service_locator.dart';
import 'core/widgets/app_launcher_badge_sync.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Thiết lập Service Locator
  setupLocator();

  await initializeDateFormatting('vi', null);
  Intl.defaultLocale = 'vi';

  // Khóa ứng dụng theo chiều dọc
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Khởi tạo ApiClient
  final apiClient = ApiClient();
  await apiClient.init();

  // Debug: In thông tin base URL hiện tại
  debugPrint('🔧 AppConfig current state: ${AppConfig.currentConfig}');
  debugPrint('🔧 ApiClient debug info: ${apiClient.debugInfo}');

  // Khởi tạo Adaptive Theme
  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  // Khởi tạo Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.instance.initialize();
  runApp(
    BlocProvider(
      create: (context) => UserCubit(
        authService: locator(),
        faceService: locator(),
        citizenService: locator(),
      ),
      child: MyApp(savedThemeMode: savedThemeMode),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const MyApp({super.key, this.savedThemeMode});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: AppTheme.lightTheme,
      dark: AppTheme.darkTheme,
      initial: savedThemeMode ?? AdaptiveThemeMode.system,
      builder: (theme, darkTheme) => MaterialApp.router(
        title: 'Chấm công',
        theme: theme,
        darkTheme: darkTheme,
        locale: const Locale('vi'),
        supportedLocales: const [Locale('vi'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          SfGlobalLocalizations.delegate,
        ],
        routerConfig: AppRouter.router,
        builder: (context, child) {
          final mq = MediaQuery.of(context);
          return AppLauncherBadgeSync(
            child: MediaQuery(
              data: mq.copyWith(
                textScaler: mq.textScaler.clamp(
                  minScaleFactor: 0.9,
                  maxScaleFactor: 1.2,
                ),
              ),
              child: child!,
            ),
          );
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
