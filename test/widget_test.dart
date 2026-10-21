import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vuukiendinh_2380600509/main.dart';
import 'package:vuukiendinh_2380600509/screens/admin/admin_main_screen.dart';
import 'package:vuukiendinh_2380600509/screens/auth/face_auth_screen.dart';
import 'package:vuukiendinh_2380600509/screens/auth/otp_screen.dart';
import 'package:vuukiendinh_2380600509/screens/auth/register_screen.dart';
import 'package:vuukiendinh_2380600509/screens/nhanvien/cham_cong_qr_screen.dart';
import 'package:vuukiendinh_2380600509/screens/nhanvien/don_nghi_phep_screen.dart';
import 'package:vuukiendinh_2380600509/screens/nhanvien/nhanvien_main_screen.dart';
import 'package:vuukiendinh_2380600509/screens/quanly/may_cham_cong_qr_screen.dart';
import 'package:vuukiendinh_2380600509/screens/quanly/quanly_dashboard_screen.dart';
import 'package:vuukiendinh_2380600509/services/mock_data_repository.dart';

void main() {
  testWidgets(
    'All 10 screens and tabs render without RenderFlex overflow on narrow 340x800 screen',
    (WidgetTester tester) async {
      // Giả lập kích thước màn hình điện thoại nhỏ hẹp (340x800) để kiểm tra chống tràn toàn diện
      tester.view.physicalSize = const Size(340, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repo = MockDataRepository.instance;
      final mainUser = repo.danhSachNguoiDung.first;

      // 1. LoginScreen
      await tester.pumpWidget(const ChamCongEnterpriseApp());
      await tester.pump();
      expect(find.text('ĐĂNG NHẬP'), findsOneWidget);

      // 2. RegisterScreen
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));
      await tester.pump();

      // 3. OtpScreen
      await tester.pumpWidget(
        MaterialApp(home: OtpScreen(pendingUser: mainUser)),
      );
      await tester.pump();

      // 4. FaceAuthScreen
      await tester.pumpWidget(const MaterialApp(home: FaceAuthScreen()));
      await tester.pump();

      // 5. NhanVienMainScreen (3 Tabs)
      await tester.pumpWidget(const MaterialApp(home: NhanVienMainScreen()));
      await tester.pump();
      expect(find.textContaining('Vưu Kiên Định'), findsWidgets);

      await tester.tap(find.text('Lịch Sử Công'));
      await tester.pump();
      await tester.tap(find.text('Đơn Nghỉ Phép'));
      await tester.pump();

      // 6. DonNghiPhepScreen (standalone)
      await tester.pumpWidget(
        MaterialApp(home: DonNghiPhepScreen(currentUser: mainUser)),
      );
      await tester.pump();

      // 7. ChamCongQrScreen
      await tester.pumpWidget(
        MaterialApp(home: ChamCongQrScreen(currentUser: mainUser)),
      );
      await tester.pump();

      // 8. AdminMainScreen (3 Tabs)
      await tester.pumpWidget(const MaterialApp(home: AdminMainScreen()));
      await tester.pump();
      await tester.tap(find.text('CRUD Ca Làm'));
      await tester.pump();
      await tester.tap(find.text('CRUD Nhân Sự'));
      await tester.pump();

      // 9. QuanLyDashboardScreen (3 Tabs)
      await tester.pumpWidget(const MaterialApp(home: QuanLyDashboardScreen()));
      await tester.pump();
      await tester.tap(find.text('Duyệt Đơn Từ'));
      await tester.pump();
      await tester.tap(find.text('Phát QR Động'));
      await tester.pump();

      // 10. MayChamCongQrScreen (standalone)
      await tester.pumpWidget(const MaterialApp(home: MayChamCongQrScreen()));
      await tester.pump();
    },
  );
}
