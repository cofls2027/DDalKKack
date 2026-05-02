import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('딸깍'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('홈 화면'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: 영수증 제출 화면으로 이동
        },
        icon: const Icon(Icons.add),
        label: const Text('영수증 제출'),
      ),
    );
  }
}
