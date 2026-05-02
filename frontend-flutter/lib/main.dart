import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/user_model.dart';
import 'providers/user_provider.dart';
import 'router/app_router.dart';

// 테스트용 유저 (로그인 구현 전 임시)
const _testUser = UserModel(
  id: 1,
  name: '조혜승',
  phone: '01038147994',
  position: '사원',
  role: 'user',
  companyId: 1,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://hczripxpbmtvqwbouexo.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhjenJpcHhwYm10dnF3Ym91ZXhvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc1MTcyMzksImV4cCI6MjA5MzA5MzIzOX0.39fhIwIrP-9bwVr_9KEggFwlho0x_OwXz89fnZoF5QY',
  );

  runApp(
    ProviderScope(
      overrides: [
        currentUserProvider.overrideWith((ref) => _testUser),
      ],
      child: const DDalKKackApp(),
    ),
  );
}

class DDalKKackApp extends ConsumerWidget {
  const DDalKKackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: '딸깍',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
