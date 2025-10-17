import 'package:flutter/material.dart';
import 'package:p_learn_app/screens/auth/login_screen.dart';
import 'package:p_learn_app/services/auth_service.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // --- KHAI BÁO STATE ---
  final _formKey = GlobalKey<FormState>();
  final _studentIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _recoveryEmailController = TextEditingController();
  final _majorController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final Color _primaryColor = const Color.fromARGB(255, 235, 87, 87);

  final Map<String, String> _majorMap = {
    'DCCN': 'Công Nghệ Thông Tin',
    'DCAT': 'An Toàn Thông Tin',
    'DCKT': 'Kỹ Thuật Điện Tử Viễn Thông',
    'DCQT': 'Quản Trị Kinh Doanh',
  };

  // --- LOGIC XỬ LÝ ---
  @override
  void initState() {
    super.initState();
    // SỬA 1: Sử dụng đúng tên controller
    _studentIdController.addListener(_updateMajor);
  }

  @override
  void dispose() {
    // SỬA 1: Sử dụng đúng tên controller và dispose tất cả
    _studentIdController.removeListener(_updateMajor);
    _studentIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _recoveryEmailController.dispose();
    _majorController.dispose();
    super.dispose();
  }

  void _updateMajor() {
    // SỬA 1: Sử dụng đúng tên controller
    String studentId = _studentIdController.text.toUpperCase();

    if (studentId.length >= 8) {
      String majorCode = studentId.substring(3, 7);
      String cohort = studentId.substring(1, 3);
      if (_majorMap.containsKey(majorCode)) {
        setState(() {
          _majorController.text = '${_majorMap[majorCode]} - Khóa $cohort';
        });
      }
    } else {
      setState(() {
        _majorController.text = '';
      });
    }
  }

  Future<void> _handleRegister() async {
    // Logic đăng ký của bạn đã tốt, giữ nguyên
    print('🚀 [REGISTER] Hàm _handleRegister được gọi.');
    if (_formKey.currentState!.validate()) {
      print('✅ [REGISTER] Form validation thành công.');

      // Không cần kiểm tra mật khẩu ở đây nữa vì validator đã làm

      setState(() {
        _isLoading = true;
      });

      try {
        print('⏳ [REGISTER] Chuẩn bị gọi authService.register()...');
        final authService = Provider.of<AuthService>(context, listen: false);
        final success = await authService.register(
          _studentIdController.text.trim(),
          _recoveryEmailController.text.trim(), // THÊM: Gửi email
          _passwordController.text,
        );
        print(
          '💬 [REGISTER] authService.register() đã hoàn thành. Kết quả: success = $success',
        );

        if (success && mounted) {
          print('🎉 [REGISTER] Đăng ký thành công!');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Đăng ký tài khoản thành công! Vui lòng đăng nhập.',
              ),
              backgroundColor: Colors.green,
            ),
          );
          // Điều hướng về màn hình đăng nhập
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } else if (mounted) {
          print('❌ [REGISTER] Đăng ký thất bại.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Đăng ký thất bại. Mã sinh viên hoặc email có thể đã được sử dụng.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print('🔥 [REGISTER] ĐÃ CÓ LỖI XẢY RA! Lỗi: ${e.toString()}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        print('🧹 [REGISTER] Khối finally được thực thi.');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      print('📝 [REGISTER] Form validation thất bại.');
    }
  }

  // --- GIAO DIỆN (UI) ---
  // TÁI CẤU TRÚC: Hàm build bây giờ rất gọn gàng
  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      // SỬA LỖI: Bọc toàn bộ nội dung trong Center
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          // Bỏ LayoutBuilder và ConstrainedBox, Column sẽ tự co lại và được Center căn giữa
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildRegisterForm(),
            ],
          ),
        ),
      ),
    ),
  );
}

  // TÁI CẤU TRÚC: Tách phần Header ra một hàm riêng
  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: _primaryColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _primaryColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(Icons.school, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          'Tạo tài khoản',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // TÁI CẤU TRÚC: Tách toàn bộ Form ra một hàm riêng
  Widget _buildRegisterForm() {
    // Thêm hiệu ứng animation cho các trường trong form
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _studentIdController,
            decoration: _buildInputDecoration(
              labelText: 'Mã sinh viên',
              hintText: 'Nhập mã sinh viên của bạn',
              prefixIcon: Icons.badge_outlined,
            ),
            validator: (value) => value == null || value.isEmpty
                ? 'Vui lòng nhập mã sinh viên'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _recoveryEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _buildInputDecoration(
              labelText: 'Email khôi phục',
              hintText: 'Nhập email cá nhân',
              prefixIcon: Icons.email_outlined,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Vui lòng nhập email';
              if (!value.contains('@') || !value.contains('.'))
                return 'Email không hợp lệ';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: _buildInputDecoration(
              labelText: 'Mật khẩu',
              hintText: 'Nhập mật khẩu của bạn',
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Vui lòng nhập mật khẩu';
              if (value.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: !_isPasswordVisible,
            decoration: _buildInputDecoration(
              labelText: 'Xác nhận mật khẩu',
              hintText: 'Nhập lại mật khẩu của bạn',
              prefixIcon: Icons.lock_outline,
            ),
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Vui lòng xác nhận mật khẩu';
              if (value != _passwordController.text)
                return 'Mật khẩu không khớp';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _majorController,
            readOnly: true,
            decoration: _buildInputDecoration(
              labelText: 'Ngành học của bạn',
              prefixIcon: Icons.school_outlined,
              isReadOnly: true, // Thêm cờ để nhận biết trường chỉ đọc
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Đăng kí',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Đã có tài khoản?"),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: Text(
                  "Đăng nhập ngay",
                  style: TextStyle(
                    color: _primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // TÁI CẤU TRÚC: Cải thiện hàm helper
  InputDecoration _buildInputDecoration({
    required String labelText,
    String? hintText, // hintText có thể null
    required IconData prefixIcon,
    Widget? suffixIcon,
    bool isReadOnly = false, // Thêm cờ cho trường chỉ đọc
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icon(prefixIcon, color: Colors.grey.shade600),
      suffixIcon: suffixIcon,
      filled: isReadOnly, // Chỉ tô màu nền khi isReadOnly
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryColor, width: 2),
      ),
    );
  }

  // TÁI CẤU TRÚC: Helper method để tạo InputDecoration
}
