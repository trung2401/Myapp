import 'package:flutter/material.dart';

class VoucherScreen extends StatefulWidget{
  const VoucherScreen({super.key});
  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen>{
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Voucher Screen',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}