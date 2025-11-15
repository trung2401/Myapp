import 'package:flutter/material.dart';
import '../services/login_api_service.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Đăng ký',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          // height: size.height,
          width: size.width,
          padding: const EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 50),
          color: Colors.white,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Bạn đã sẵn sàng?',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Logo
                Row(
                  children: const [
                    SizedBox(width: 130),
                    Image(
                      width: 100,
                      image: AssetImage('assets/logo/login.png'),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                /// HỌ VÀ TÊN
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Họ và tên',
                    hintStyle: const TextStyle(color: Colors.grey),
                    fillColor: Colors.grey.shade200,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập họ và tên';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

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
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập số điện thoại';
                    }
                    if (!RegExp(r'^[0-9]{10}$').hasMatch(value.trim())) {
                      return 'Số điện thoại phải gồm 10 số';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                /// EMAIL
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: const TextStyle(color: Colors.grey),
                    fillColor: Colors.grey.shade200,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                /// NGÀY SINH
                // TextFormField(
                //   controller: _dobController,
                //   readOnly: true,
                //   decoration: InputDecoration(
                //     hintText: 'Ngày sinh (dd/mm/yyyy)',
                //     hintStyle: const TextStyle(color: Colors.grey),
                //     fillColor: Colors.grey.shade200,
                //     filled: true,
                //     suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
                //     enabledBorder: OutlineInputBorder(
                //       borderSide: const BorderSide(color: Colors.transparent),
                //       borderRadius: BorderRadius.circular(20),
                //     ),
                //     focusedBorder: OutlineInputBorder(
                //       borderSide: const BorderSide(color: Colors.black, width: 1),
                //       borderRadius: BorderRadius.circular(20),
                //     ),
                //   ),
                //   validator: (value) {
                //     if (value == null || value.isEmpty) {
                //       return 'Vui lòng chọn ngày sinh';
                //     }
                //     return null;
                //   },
                //   onTap: () async {
                //     DateTime? pickedDate = await showDatePicker(
                //       context: context,
                //       initialDate: DateTime(2000),
                //       firstDate: DateTime(1900),
                //       lastDate: DateTime.now(),
                //     );
                //     if (pickedDate != null) {
                //       setState(() {
                //         _dobController.text =
                //         "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                //       });
                //     }
                //   },
                // ),

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
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    if (value.length < 6) {
                      return 'Mật khẩu phải ít nhất 6 ký tự';
                    }
                    if (!RegExp(r'[0-9]').hasMatch(value)) {
                      return 'Mật khẩu phải chứa ít nhất 1 chữ số';
                    }
                    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
                      return 'Mật khẩu phải chứa ít nhất 1 ký tự đặc biệt';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                /// NHẬP LẠI MẬT KHẨU
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Nhập lại mật khẩu',
                    hintStyle: const TextStyle(color: Colors.grey),
                    fillColor: Colors.grey.shade200,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập lại mật khẩu';
                    }
                    if (value != _passwordController.text) {
                      return 'Mật khẩu không khớp';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 40),

                /// BUTTON ĐĂNG KÝ
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: _onSignUpPressed,
                    child: const Text(
                      'Đăng ký',
                      style: TextStyle(color: Colors.white, fontSize: 19),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Bạn đã có tài khoản? ',
                      style: TextStyle(color: Colors.grey, fontSize: 18),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => LoginPage()));
                      },
                      child: const Text(
                        'Đăng nhập ngay',
                        style: TextStyle(color: Colors.redAccent, fontSize: 18),
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

  void _onSignUpPressed() async {
    if (_formKey.currentState!.validate()) {
      try {
        final api = LoginApiService();

        final result = await api.register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          phone: _phoneController.text.trim(),
        );

        final message = result["message"] ?? "Đăng ký thành công!";

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ),
        );

        // Chuyển qua màn hình login sau 1s
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginPage()),
          );
        });

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Đăng ký thất bại: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

}
