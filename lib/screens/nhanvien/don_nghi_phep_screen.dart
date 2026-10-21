import 'package:flutter/material.dart';
import '../../models/nguoi_dung.dart';
import '../../models/don_nghi_phep.dart';
import '../../services/mock_data_repository.dart';
import '../../services/session_manager.dart';

class DonNghiPhepScreen extends StatefulWidget {
  final NguoiDung? currentUser;
  final bool embedded;
  final VoidCallback? onDataChanged;

  const DonNghiPhepScreen({
    super.key,
    this.currentUser,
    this.embedded = false,
    this.onDataChanged,
  });

  @override
  State<DonNghiPhepScreen> createState() => _DonNghiPhepScreenState();
}

class _DonNghiPhepScreenState extends State<DonNghiPhepScreen> {
  final MockDataRepository _repo = MockDataRepository.instance;
  String _selectedStatusFilter = 'TatCa';

  static const Color primaryDark = Color(0xFF0F172A);
  static const Color primaryBlue = Color(0xFF2563EB);

  NguoiDung get _employee =>
      widget.currentUser ??
      SessionManager.instance.currentUser ??
      _repo.danhSachNguoiDung.firstWhere(
        (u) => u.MaNV == '2380600509',
        orElse: () => _repo.danhSachNguoiDung.last,
      );

  // ==================== MODAL THÊM MỚI / SỬA ĐƠN NGHỈ PHÉP & TĂNG CA ====================

  void showDonFormModal({DonNghiPhep? editingDon}) {
    final isEditing = editingDon != null;
    final formKey = GlobalKey<FormState>();

    String selectedLoaiDon = editingDon?.LoaiDon ?? 'NghiPhep';
    final ngayApDungCtrl = TextEditingController(
      text: editingDon?.NgayApDung ?? _repo.formatDate(DateTime.now()),
    );
    final lyDoCtrl = TextEditingController(text: editingDon?.LyDo ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              isEditing
                                  ? 'Chỉnh Sửa Đơn (${editingDon.MaDon})'
                                  : 'Tạo Đơn Nghỉ Phép / Đi Muộn / Tăng Ca',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: primaryDark,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(ctx),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 10),

                      // Thông tin nhân viên gửi đơn
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.badge_rounded,
                              color: primaryBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Người gửi: ${_employee.MaNV} - ${_employee.HoTen}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: primaryDark,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Chọn Loại Đơn ("NghiPhep", "DiMuon", "TangCa")
                      DropdownButtonFormField<String>(
                        initialValue: selectedLoaiDon,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Loại đơn đăng ký',
                          prefixIcon: const Icon(
                            Icons.category_outlined,
                            color: primaryBlue,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'NghiPhep',
                            child: Text(
                              'Nghỉ phép (NghiPhep)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'DiMuon',
                            child: Text(
                              'Đi muộn / Về sớm (DiMuon)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'TangCa',
                            child: Text(
                              'Đăng ký Tăng ca (TangCa)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => selectedLoaiDon = val);
                          }
                        },
                      ),
                      const SizedBox(height: 14),

                      // Chọn Ngày Áp Dụng (hỗ trợ DatePicker)
                      TextFormField(
                        controller: ngayApDungCtrl,
                        readOnly: true,
                        onTap: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: now,
                            firstDate: now.subtract(const Duration(days: 30)),
                            lastDate: now.add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setModalState(() {
                              ngayApDungCtrl.text = _repo.formatDate(picked);
                            });
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Ngày áp dụng (YYYY-MM-DD)',
                          prefixIcon: const Icon(
                            Icons.calendar_month_rounded,
                            color: primaryBlue,
                          ),
                          suffixIcon: const Icon(Icons.edit_calendar_rounded),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (val) =>
                            (val == null || val.trim().isEmpty)
                            ? 'Vui lòng chọn ngày áp dụng'
                            : null,
                      ),
                      const SizedBox(height: 14),

                      // Nhập Lý Do
                      TextFormField(
                        controller: lyDoCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Lý do chi tiết',
                          hintText:
                              'Nhập lý do xin nghỉ phép, đi muộn hoặc nội dung công việc tăng ca...',
                          alignLabelWithHint: true,
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(bottom: 42),
                            child: Icon(
                              Icons.notes_rounded,
                              color: primaryBlue,
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().length < 5) {
                            return 'Vui lòng nhập lý do rõ ràng (tối thiểu 5 ký tự)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          if (!formKey.currentState!.validate()) return;

                          setState(() {
                            if (isEditing) {
                              _repo.updateDonNghiPhep(
                                maDon: editingDon.MaDon,
                                loaiDon: selectedLoaiDon,
                                ngayApDung: ngayApDungCtrl.text.trim(),
                                lyDo: lyDoCtrl.text.trim(),
                              );
                            } else {
                              _repo.createDonNghiPhep(
                                nhanVien: _employee,
                                loaiDon: selectedLoaiDon,
                                ngayApDung: ngayApDungCtrl.text.trim(),
                                lyDo: lyDoCtrl.text.trim(),
                              );
                            }
                          });

                          widget.onDataChanged?.call();
                          Navigator.pop(ctx);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEditing
                                    ? 'Đã cập nhật đơn ${editingDon.MaDon} thành công!'
                                    : 'Đã gửi đơn ${_formatLoaiDon(selectedLoaiDon)} thành công!',
                              ),
                              backgroundColor: Colors.green.shade700,
                            ),
                          );
                        },
                        icon: Icon(
                          isEditing ? Icons.save_rounded : Icons.send_rounded,
                        ),
                        label: Text(
                          isEditing ? 'LƯU THAY ĐỔI ĐƠN' : 'GỬI ĐƠN XÉT DUYỆT',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteDon(DonNghiPhep don) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Expanded(child: Text('Hủy / Xóa Đơn Chờ Duyệt')),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn hủy và xóa đơn "${_formatLoaiDon(don.LoaiDon)}" (Mã: ${don.MaDon}, ngày ${don.NgayApDung}) không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              setState(() {
                _repo.deleteDonNghiPhep(don.MaDon);
              });
              widget.onDataChanged?.call();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã hủy đơn ${don.MaDon} thành công!'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            child: const Text('Xác nhận hủy đơn'),
          ),
        ],
      ),
    );
  }

  String _formatLoaiDon(String loaiDon) {
    switch (loaiDon) {
      case 'NghiPhep':
        return 'Nghỉ phép';
      case 'DiMuon':
        return 'Đi muộn';
      case 'TangCa':
        return 'Tăng ca';
      default:
        return loaiDon;
    }
  }

  IconData _getLoaiDonIcon(String loaiDon) {
    switch (loaiDon) {
      case 'NghiPhep':
        return Icons.event_busy_rounded;
      case 'DiMuon':
        return Icons.schedule_send_rounded;
      case 'TangCa':
      default:
        return Icons.more_time_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allMyLeaves = _repo.getDonNghiPhepByMaNV(_employee.MaNV);
    final filteredLeaves = allMyLeaves.where((d) {
      if (_selectedStatusFilter == 'TatCa') return true;
      return d.TrangThaiDuyet == _selectedStatusFilter;
    }).toList();

    final content = Column(
      children: [
        // Bộ lọc trạng thái đơn & Nút tạo đơn nhanh
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Danh sách đơn từ (${allMyLeaves.length})',
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                        color: primaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => showDonFormModal(),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Tạo đơn mới'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('TatCa', 'Tất cả (${allMyLeaves.length})'),
                    const SizedBox(width: 8),
                    _buildFilterChip('ChoDuyet', 'Chờ duyệt (ChoDuyet)'),
                    const SizedBox(width: 8),
                    _buildFilterChip('DaDuyet', 'Đã duyệt (DaDuyet)'),
                    const SizedBox(width: 8),
                    _buildFilterChip('TuChoi', 'Từ chối (TuChoi)'),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: filteredLeaves.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.inbox_outlined,
                        size: 52,
                        color: Colors.black26,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Chưa có đơn xin nghỉ phép / tăng ca nào!',
                        style: TextStyle(color: Colors.black54, fontSize: 15),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => showDonFormModal(),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Tạo đơn ngay'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                  itemCount: filteredLeaves.length,
                  itemBuilder: (context, index) {
                    final don = filteredLeaves[index];
                    final isChoDuyet = don.TrangThaiDuyet == 'ChoDuyet';
                    final badgeColor = don.TrangThaiDuyet == 'DaDuyet'
                        ? Colors.green.shade700
                        : don.TrangThaiDuyet == 'TuChoi'
                        ? Colors.redAccent
                        : Colors.orange.shade800;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: primaryBlue.withValues(
                                    alpha: 0.12,
                                  ),
                                  child: Icon(
                                    _getLoaiDonIcon(don.LoaiDon),
                                    color: primaryBlue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${_formatLoaiDon(don.LoaiDon)} (${don.LoaiDon})',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.5,
                                          color: primaryDark,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Mã đơn: ${don.MaDon} • Ngày áp dụng: ${don.NgayApDung}',
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          color: primaryBlue,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: badgeColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    don.TrangThaiDuyet,
                                    style: TextStyle(
                                      color: badgeColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Lý do: ${don.LyDo}',
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            if (isChoDuyet) ...[
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Wrap(
                                  alignment: WrapAlignment.end,
                                  spacing: 8,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () =>
                                          showDonFormModal(editingDon: don),
                                      icon: const Icon(
                                        Icons.edit_note_rounded,
                                        size: 19,
                                      ),
                                      label: const Text('Sửa đơn'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: primaryBlue,
                                      ),
                                    ),
                                    TextButton.icon(
                                      onPressed: () => _confirmDeleteDon(don),
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        size: 19,
                                      ),
                                      label: const Text('Hủy / Xóa đơn'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );

    if (widget.embedded) {
      return content;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        title: const Text('Quản Lý Đơn Nghỉ Phép & Tăng Ca'),
      ),
      body: content,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        onPressed: () => showDonFormModal(),
        icon: const Icon(Icons.note_add_rounded),
        label: const Text('Tạo Đơn Mới'),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedStatusFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: primaryBlue.withValues(alpha: 0.18),
      labelStyle: TextStyle(
        color: isSelected ? primaryBlue : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) => setState(() => _selectedStatusFilter = value),
    );
  }
}
