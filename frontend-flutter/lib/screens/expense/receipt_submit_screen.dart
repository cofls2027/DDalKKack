import 'package:flutter/material.dart';

class ReceiptSubmitScreen extends StatelessWidget {
  const ReceiptSubmitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('영수증 제출', style: TextStyle(color: Colors.black, fontSize: 18)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: const Center(
        child: Text('시연용 영수증 제출 화면입니다.', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}