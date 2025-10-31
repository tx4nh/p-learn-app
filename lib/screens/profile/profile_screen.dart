import 'package:flutter/material.dart';
import 'package:p_learn_app/screens/auth/login_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:p_learn_app/screens/auth/reset_password_screen.dart';
import 'package:p_learn_app/services/notification_service.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _displayNameController = TextEditingController();
  bool _isEditing = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  void _showLogoutDialog(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận đăng xuất'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                authService.logout();
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _saveDisplayName() {
    // TODO: Lưu tên hiển thị vào database/storage
    setState(() {
      _isEditing = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã cập nhật tên hiển thị')));
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final studentCode = authService.currentUsername ?? 'Không có mã';
    
    final username = authService.currentUsername;
    String generatedName;

    if (username != null && username.length >= 3) {
      final lastThree = username.substring(username.length - 3);
      generatedName = "PTITer $lastThree";
    } else {
      generatedName = "PtiterUser";
    }

    final displayName = _displayNameController.text.isEmpty
        ? generatedName 
        : _displayNameController.text;

    final emailDisplay = authService.currentEmail ?? "Chưa có email";

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 15,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.red.shade600),
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 15),

                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.red.shade600,
                    ),
                  ),

                  const SizedBox(width: 15),

                  Column(
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          'MSV: $studentCode',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 15),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Thông tin cá nhân
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildInfoTile(
                    icon: Icons.badge_outlined,
                    title: 'Mã sinh viên',
                    subtitle: studentCode,
                  ),
                  const Divider(height: 1, indent: 72),
                  _buildEditableInfoTile(
                    icon: Icons.person_outline,
                    title: 'Tên hiển thị',
                    subtitle: displayName,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Cài đặt
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildInfoTile(
                    icon: Icons.email_outlined,
                    title: 'Email lấy mật khẩu',
                    subtitle: emailDisplay,
                  ),
                  const Divider(height: 1, indent: 72),
                  _buildActionTile(
                    icon: Icons.lock_outline,
                    title: 'Đổi mật khẩu',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ResetPasswordScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 72),
                  _buildActionTile(
                    icon: Icons.help_outline,
                    title: 'Trợ giúp',
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 72),
                  _buildActionTile(
                    icon: Icons.notifications_active_outlined,
                    title: 'Kiểm tra thông báo',
                    onTap: () async {
                      final notificationService = NotificationService();
                      await notificationService.requestPermissions();
                      await notificationService.flutterLocalNotificationsPlugin
                          .show(
                            0,
                            'Thông báo kiểm tra',
                            'Đây là một thông báo thử nghiệm từ P-Learn.',
                            const NotificationDetails(
                              android: AndroidNotificationDetails(
                                'test_channel_id',
                                'Test Channel',
                                channelDescription:
                                    'Channel for test notifications',
                                importance: Importance.max,
                                priority: Priority.high,
                              ),
                              iOS: DarwinNotificationDetails(),
                            ),
                          );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Nút đăng xuất
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(context, authService),
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Đăng xuất',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.red.shade600, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildEditableInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.red.shade600, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
      ),
      subtitle: _isEditing
          ? TextField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              autofocus: true,
            )
          : Text(
              subtitle,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
      trailing: IconButton(
        icon: Icon(_isEditing ? Icons.check : Icons.edit),
        color: Colors.red.shade600,
        onPressed: () {
          if (_isEditing) {
            _saveDisplayName();
          } else {
            setState(() {
              _isEditing = true;
              _displayNameController.text = subtitle;
            });
          }
        },
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.red.shade600, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
      onTap: onTap,
    );
  }
}
