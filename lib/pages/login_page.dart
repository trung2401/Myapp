import 'package:flutter/material.dart';
import 'package:myapp/pages/sign_up_page.dart';
import '../model/login_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/login_api_service.dart';
import 'home_page.dart';
import 'forgot_password_page.dart';


class LoginPage extends StatefulWidget {
  final bool fromDetail;
  const LoginPage({super.key, this.fromDetail = false});
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Cellphones',
          style: TextStyle(
              color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: size.height,
          width: size.width,
          padding:
          const EdgeInsets.only(left: 20, right: 20, top: 80, bottom: 50),
          color: Colors.white,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hello, \nWelcome Back',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 40,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 130),
                        const Image(
                            width: 100,
                            image: AssetImage(
                                'assets/images_phone/logologin.png')),
                      ],
                    ),
                    const SizedBox(height: 40),

                    /// SỐ ĐIỆN THOẠI
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'Số điện thoại',
                        hintStyle: const TextStyle(color: Colors.grey),
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(20)),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                            const BorderSide(color: Colors.black, width: 1),
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập số điện thoại';
                        }
                        if (!RegExp(r'^[0-9]{10}$').hasMatch(value.trim())) {
                          return 'Số điện thoại không hợp lệ';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    /// MẬT KHẨU
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Mật khẩu',
                        hintStyle: const TextStyle(color: Colors.grey),
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(20)),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                            const BorderSide(color: Colors.black, width: 1),
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mật khẩu';
                        }
                        if (value.length < 6) {
                          return 'Mật khẩu phải ít nhất 6 ký tự';
                        }
                        // 🔹 Kiểm tra có ít nhất 1 số
                        if (!RegExp(r'[0-9]').hasMatch(value)) {
                          return 'Mật khẩu phải chứa ít nhất 1 chữ số';
                        }

                        // 🔹 Kiểm tra có ít nhất 1 ký tự đặc biệt
                        // if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
                        //   return 'Mật khẩu phải chứa ít nhất 1 ký tự đặc biệt';
                        // }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                          );
                        },
                        child: Text(
                          'Quên mật khẩu?',
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        )
                    ),

                    const SizedBox(height: 20),

                    /// BUTTON ĐĂNG NHẬP
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20))),
                        onPressed: _onLoginPressed,
                        child: const Text(
                          'Đăng nhập',
                          style: TextStyle(color: Colors.white, fontSize: 19),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Bạn chưa có tài khoản? ',
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
                      },
                      child: const Text(
                        'Đăng ký ngay',
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onLoginPressed() async {
    if (_formKey.currentState!.validate()) {
      try {
        final api = LoginApiService();
        final response = await api.login(
          _phoneController.text.trim(),
          _passwordController.text.trim(),
        );

        if (response.data?.accessToken != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Đăng nhập thành công!"),
              backgroundColor: Colors.green,
            ),
          );

          // ✅ Kiểm tra đến từ đâu
          if (widget.fromDetail) {
            Navigator.pop(context); // 🔙 nếu đến từ trang chi tiết thì quay lại
          } else {
            // 🚀 nếu không, chuyển sang HomePage
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false,
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Không nhận được token từ server")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi đăng nhập: $e")),
        );
      }
    }
  }

}
