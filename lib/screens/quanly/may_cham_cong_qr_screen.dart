import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/ca_lam_viec.dart';
import '../../models/phien_cham_cong.dart';
import '../../services/mock_data_repository.dart';

class MayChamCongQrScreen extends StatefulWidget {
  final bool embedded;

  const MayChamCongQrScreen({super.key, this.embedded = false});

  @override
  State<MayChamCongQrScreen> createState() => _MayChamCongQrScreenState();
}

class _MayChamCongQrScreenState extends State<MayChamCongQrScreen> {
  static const Color primaryDark = Color(0xFF0F172A);
  static const Color primaryBlue = Color(0xFF2563EB);

  final MockDataRepository _repo = MockDataRepository.instance;

  late CaLamViec _selectedShift;
  late PhienChamCong _currentQrSession;

  Timer? _qrRotationTimer;
  int _secondsLeft = 15;
  int _rotationCount = 1;
  bool _isGettingGps = false;
  String _gpsStatusMessage =
      'Đang sử dụng tọa độ văn phòng tiêu chuẩn (Bán kính cho phép: 50m)';

  @override
  void initState() {
    super.initState();
    _selectedShift = _repo.danhSachCaLamViec.first;
    _currentQrSession = _repo.createPhienChamCong(_selectedShift.MaCa);
    _startDynamicQr15sTimer();
  }

  void _startDynamicQr15sTimer() {
    _qrRotationTimer?.cancel();
    _secondsLeft = 15;
    _qrRotationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_secondsLeft > 1) {
          _secondsLeft--;
        } else {
          // Tự động đổi chuỗi token MaQRDong mỗi 15 giây
          _secondsLeft = 15;
          _rotationCount++;
          _currentQrSession = _repo.createPhienChamCong(_selectedShift.MaCa);
        }
      });
    });
  }

  void _forceRefreshQrNow() {
    setState(() {
      _secondsLeft = 15;
      _rotationCount++;
      _currentQrSession = _repo.createPhienChamCong(_selectedShift.MaCa);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 2),
        backgroundColor: primaryBlue,
        content: Text('Đã sinh mã QR Động mới & đặt lại bộ đếm 15 giây!'),
      ),
    );
  }

  // ==================== LẤY TỌA ĐỘ GPS VĂN PHÒNG HIỆN TẠI ====================

  Future<void> _fetchCurrentOfficeGps() async {
    setState(() {
      _isGettingGps = true;
      _gpsStatusMessage = 'Đang lấy tọa độ GPS thực tế của thiết bị Quản lý...';
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Dịch vụ định vị GPS trên máy đang tắt.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Quyền truy cập vị trí GPS bị từ chối.');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Quyền vị trí bị chặn vĩnh viễn trong Cài đặt.');
      }

      final Position pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      if (!mounted) return;

      _repo.updateOfficeGpsCoordinates(
        viDo: pos.latitude,
        kinhDo: pos.longitude,
        banKinh: 50.0,
      );

      setState(() {
        _isGettingGps = false;
        _selectedShift = _repo.danhSachCaLamViec.firstWhere(
          (c) => c.MaCa == _selectedShift.MaCa,
          orElse: () => _repo.danhSachCaLamViec.first,
        );
        _gpsStatusMessage =
            'Đã cập nhật GPS văn phòng theo vị trí thực tế (${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)})!';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_gpsStatusMessage),
          backgroundColor: Colors.green.shade700,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isGettingGps = false;
        _gpsStatusMessage =
            'Không lấy được GPS phần cứng ($e). Bạn có thể bấm "Sử dụng tọa độ văn phòng mẫu".';
      });
    }
  }

  void _applySampleOfficeGps() {
    const double sampleLat = 10.801618;
    const double sampleLng = 106.714546;

    _repo.updateOfficeGpsCoordinates(
      viDo: sampleLat,
      kinhDo: sampleLng,
      banKinh: 50.0,
    );

    setState(() {
      _selectedShift = _repo.danhSachCaLamViec.firstWhere(
        (c) => c.MaCa == _selectedShift.MaCa,
        orElse: () => _repo.danhSachCaLamViec.first,
      );
      _gpsStatusMessage =
          'Đang áp dụng Tọa độ Văn phòng mẫu: Lat $sampleLat, Lng $sampleLng (Bán kính 50m)';
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: primaryDark,
        content: Text(
          'Đã thiết lập Tọa độ Văn phòng mẫu (10.801618, 106.714546 - Bán kính 50m)!',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _qrRotationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shifts = _repo.danhSachCaLamViec;
    if (!shifts.any((c) => c.MaCa == _selectedShift.MaCa) && shifts.isNotEmpty) {
      _selectedShift = shifts.first;
    } else {
      _selectedShift = shifts.firstWhere((c) => c.MaCa == _selectedShift.MaCa);
    }

    final bodyContent = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card Cấu hình Tọa độ GPS Văn phòng (Chức năng b)
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.share_location_rounded,
                            color: primaryBlue,
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tọa Độ GPS Văn Phòng Công Ty (Bán Kính 50m)',
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.bold,
                                color: primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vĩ độ (ViDoCongTy): ${_selectedShift.ViDoCongTy.toStringAsFixed(6)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Kinh độ (KinhDoCongTy): ${_selectedShift.KinhDoCongTy.toStringAsFixed(6)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _gpsStatusMessage,
                              style: const TextStyle(
                                fontSize: 12,
                                color: primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: primaryBlue,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _isGettingGps
                                  ? null
                                  : _fetchCurrentOfficeGps,
                              icon: _isGettingGps
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.my_location_rounded,
                                      size: 18,
                                    ),
                              label: const Text(
                                'Lấy GPS Hiện Tại',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12.5),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _applySampleOfficeGps,
                              icon: const Icon(
                                Icons.business_rounded,
                                size: 18,
                              ),
                              label: const Text(
                                'Tọa độ VP mẫu',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Card Máy Chấm Công QR Động 15 giây (Anti-Cheat Dynamic QR)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: primaryDark,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'ANTI-CHEAT DYNAMIC QR • XOAY VÒNG #$_rotationCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'MÁY CHẤM CÔNG QR ĐỘNG 15 GIÂY',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tự động đổi mã mỗi 15s chống chụp ảnh gửi qua mạng xã hội quét hộ',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12.5, color: Colors.black54),
                      ),
                      const SizedBox(height: 14),

                      // Chọn Ca làm việc phát mã QR
                      DropdownButtonFormField<String>(
                        initialValue: _selectedShift.MaCa,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Ca làm việc đang mở chấm công',
                          prefixIcon: const Icon(
                            Icons.schedule_rounded,
                            color: primaryBlue,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        items: shifts.map((ca) {
                          return DropdownMenuItem<String>(
                            value: ca.MaCa,
                            child: Text(
                              '${ca.TenCa} (${ca.GioBatDau} - ${ca.GioKetThuc})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (maCaVal) {
                          if (maCaVal != null) {
                            setState(() {
                              _selectedShift = shifts.firstWhere(
                                (c) => c.MaCa == maCaVal,
                              );
                              _secondsLeft = 15;
                              _currentQrSession = _repo.createPhienChamCong(
                                _selectedShift.MaCa,
                              );
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 18),

                      // Khung hiển thị QrImageView
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _secondsLeft <= 4
                                ? Colors.redAccent
                                : primaryBlue,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryBlue.withValues(alpha: 0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: QrImageView(
                          data: _currentQrSession.MaQRDong,
                          version: QrVersions.auto,
                          size: 210.0,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Thanh đếm ngược 15 giây
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.timer_rounded,
                                  size: 18,
                                  color: primaryDark,
                                ),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Tự động làm mới mã QR sau:',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${_secondsLeft}s / 15s',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _secondsLeft <= 4
                                  ? Colors.redAccent
                                  : primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _secondsLeft / 15.0,
                          minHeight: 10,
                          backgroundColor: const Color(0xFFE2E8F0),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _secondsLeft <= 4 ? Colors.redAccent : primaryBlue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: SelectableText(
                          'MaQRDong: ${_currentQrSession.MaQRDong}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primaryDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _forceRefreshQrNow,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Đổi mã QR Động ngay lập tức'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.embedded) {
      return bodyContent;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        title: const Text('Máy Chấm Công QR Động 15s'),
      ),
      body: SafeArea(child: bodyContent),
    );
  }
}
