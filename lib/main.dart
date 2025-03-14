import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:koscom_salad/firebase_options.dart';
import 'package:koscom_salad/screens/home_screen.dart';
import 'package:koscom_salad/screens/onboarding_screen.dart';
import 'package:koscom_salad/utils/auth_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:koscom_salad/theme.dart';

Future<void> main() async {
  // 비동기 작업 우선 수행
  WidgetsFlutterBinding.ensureInitialized();

  // 환경변수 로드
  await dotenv.load(fileName: ".env");

  // Supabase 초기화
  final supabaseUrl = dotenv.env['SUPABASE_URL']!;
  final supabaseKey = dotenv.env['SUPABASE_KEY']!;
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

// Supabase 클라이언트 인스턴스
final supabase = Supabase.instance.client;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final materialTheme = MaterialTheme(Theme.of(context).textTheme);

    return MaterialApp(
      navigatorKey: navigatorKey, // 전역 navigator key 설정
      theme: materialTheme.light(), // 라이트 테마
      darkTheme: materialTheme.dark(), // 다크 테마
      home: FutureBuilder<String?>(
        future: AuthUtils.getUserId(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // userId가 없으면 온보딩 화면으로
          return snapshot.hasData ? const HomeScreen() : const OnboardingScreen();
        },
      ),
    );
  }
}
