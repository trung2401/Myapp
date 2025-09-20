import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();

}
class _LoginPageState extends State<LoginPage>{
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: Colors.white,)
        ),
        title: Text(
            'Cellphones',
            style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold
            ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: size.height,
          width: size.width,
          padding: EdgeInsets.only(left: 20, right: 20, top: 80, bottom: 50),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Hello, \nWelcome Back',
                  style: TextStyle(color: Colors.black, fontSize: 40, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      SizedBox(width: 130,),
                      Image(
                        width: 100
                        ,image: AssetImage('assets/images_phone/logologin.png')
                      ),
                    ],
                  ),
                  SizedBox(height: 40,),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Số điện thoại',
                      hintStyle: TextStyle(color: Colors.grey),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(20)
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black,width: 1),
                        borderRadius: BorderRadius.circular(20)
                      )
                    ),
                  ),
                  SizedBox(height: 20,),
                  TextFormField(
                    decoration: InputDecoration(
                        hintText: 'Mật khẩu',
                        hintStyle: TextStyle(color: Colors.grey),
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(20)
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black,width: 1),
                            borderRadius: BorderRadius.circular(20)
                        )
                    ),
                  ),
                  SizedBox(height: 20,),
                  Text(
                      'Quên mật khẩu?',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 19,
                          fontWeight: FontWeight.normal,
                      ),
                  ),
                  SizedBox(height: 20,),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                        )
                      ),
                      onPressed: () {

                      },
                      child: Text('Đăng nhập',style: TextStyle(color: Colors.white, fontSize: 19),),

                    ),
                  )
                ]
              ),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Bạn chưa có tài khoản? ', style: TextStyle(color: Colors.black, fontSize: 18),),
                  TextButton(onPressed: () { }, child: Text('Đăng ký ngay', style: TextStyle(color: Colors.black, fontSize: 18),))
                ],
              )
            ],
          ),
        ),
      )
    );
  }
  
}