import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'services/mock_data_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Khởi tạo sẵn dữ liệu giả lập của hệ thống chấm công
  MockDataRepository.instance;
  runApp(const ChamCongEnterpriseApp());
}

class ChamCongEnterpriseApp extends StatelessWidget {
  const ChamCongEnterpriseApp({super.key});

  static const Color enterpriseSlate = Color(0xFF0F172A);
  static const Color enterpriseBlue = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chấm Công Doanh Nghiệp - 2380600509 - Vưu Kiên Định',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: enterpriseBlue,
          primary: enterpriseBlue,
          secondary: enterpriseSlate,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        appBarTheme: const AppBarTheme(
          backgroundColor: enterpriseSlate,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
