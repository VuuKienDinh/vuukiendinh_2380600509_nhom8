# Ứng Dụng Chấm Công Cho Nhân Viên (`vuukiendinh_2380600509`)

- **Sinh viên thực hiện**: **2380600509 - Vưu Kiên Định**
- **Nhóm / Đề tài**: **Nhóm 8 - Đề số 2** (Ứng dụng chấm công cho nhân viên)
- **Công nghệ**: Flutter / Dart (Material 3, PascalCase JSON Model đồng bộ Web API)

---

## 1. Tài Khoản Demo 3 Phân Quyền & Mã OTP Mặc Định
- **Mã xác thực OTP 6 số mặc định**: `123456`

| Phân quyền | Tên đăng nhập | Mật khẩu | Họ tên / Mã NV |
| :--- | :--- | :--- | :--- |
| **NHÂN VIÊN (Sinh viên chính)** | `2380600509` | `123` | **Vưu Kiên Định (`2380600509`)** |
| **QUẢN LÝ (HR)** | `ql01` | `123` | Trần Thị Mai Phương (`QL001`) |
| **ADMIN** | `admin` | `123` | Quản Trị Viên Hệ Thống (`AD001`) |

---

## 2. Các Chức Năng Đã Triển Khai
1. **Xác thực đa tầng & Phân quyền (`ADMIN`, `QUANLY`, `NHANVIEN`)**:
   - Đăng nhập, Đăng ký tài khoản nhân viên mới, Xác thực OTP 6 số có đếm ngược 60s (`lib/screens/auth/`).
   - Lưu phiên đăng nhập bằng `SharedPreferences` (`lib/services/session_manager.dart`).
2. **CRUD theo 3 phân quyền**:
   - **ADMIN** (`lib/screens/admin/admin_main_screen.dart`): Thống kê tổng quan KPI, CRUD Ca làm việc & Phòng ban, CRUD Tài khoản nhân viên.
   - **QUẢN LÝ / HR** (`lib/screens/quanly/quanly_dashboard_screen.dart`): CRUD Bảng chấm công (thêm chấm công bù, sửa giờ/trạng thái, xóa bản ghi lỗi), Duyệt / Từ chối đơn nghỉ phép & tăng ca.
   - **NHÂN VIÊN** (`lib/screens/nhanvien/nhanvien_main_screen.dart`, `don_nghi_phep_screen.dart`): Xem tổng ngày công, tổng lương tạm tính (VNĐ), lịch sử chấm công cá nhân, CRUD Đơn xin nghỉ phép / đi muộn / tăng ca khi ở trạng thái `ChoDuyet`.
3. **3 Chức năng nâng cao & Tính năng mới sáng tạo**:
   - **(a) Nhận diện Khuôn mặt AI (`google_mlkit_face_detection`)**: Kiểm tra xác suất mở mắt (`leftEyeOpenProbability > 0.5` và `rightEyeOpenProbability > 0.5`) chống dùng ảnh tĩnh (`lib/screens/auth/face_auth_screen.dart`).
   - **(b) Định vị GPS & Kiểm tra bán kính văn phòng $\le 50\text{m}$ (`geolocator`)**: Tính khoảng cách thực tế từ nhân viên đến công ty, chặn chấm công nếu ở ngoài bán kính $50\text{m}$.
   - **(e) Sinh trắc học Vân tay (`local_auth`) + Quét mã QR (`mobile_scanner` & `qr_flutter`)**.
   - **Tính năng mới (Chống chấm công hộ đa tầng & Tính lương Realtime)**:
     - **Dynamic QR 15s**: Mã QR tại máy trạm Quản lý (`may_cham_cong_qr_screen.dart`) tự động xoay vòng chuỗi token `MaQRDong` mỗi 15 giây.
     - **Khóa cứng DeviceID (`device_info_plus`)**: Phát hiện và chặn ngay nếu 1 thiết bị di động cố tình chấm công hộ cho 2 mã nhân viên khác nhau trong cùng ngày.
     - **Tính lương Realtime**: Tự động tính `SoGioLam` và `TienCongNgay` ngay khi nhân viên Check-out.
