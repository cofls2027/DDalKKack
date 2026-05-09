import 'package:flutter/material.dart';
import 'screens/gallery_screen.dart';
import 'services/api_service.dart';

final apiService = ApiService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await apiService.init();  // 토큰 자동 발급
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DDalKKack',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const GalleryScreen(),
    );
  }
}