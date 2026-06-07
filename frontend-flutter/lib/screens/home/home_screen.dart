import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _primary = Color(0xFF3D3B6E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'DDalKKack',
          style: TextStyle(
            color: _primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black54),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const Text(
            '안녕하세요',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          const Text(
            '무엇을 도와드릴까요?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          _NavCard(
            icon: Icons.bar_chart,
            title: '내 통계',
            subtitle: '이번 달 지출 현황 및 카테고리별 분석',
            color: const Color(0xFF3D3B6E),
            onTap: () => context.go('/stats'),
          ),
          const SizedBox(height: 12),
          _NavCard(
            icon: Icons.credit_card,
            title: '카드 조회',
            subtitle: '회사에 등록된 카드 목록 확인',
            color: const Color(0xFF3D3B6E),
            onTap: () => context.push('/cards'), 
          ),
          const SizedBox(height: 12),
          _NavCard(
            icon: Icons.policy_outlined,
            title: '규정 확인',
            subtitle: '회사 경비 처리 규정 및 한도 확인',
            color: const Color(0xFF3D3B6E),
            onTap: () => context.go('/rules'),
          ),
          const SizedBox(height: 12),
          
          // 🌟 추가된 버튼: 영수증 내역
          _NavCard(
            icon: Icons.receipt_long,
            title: '영수증 내역',
            subtitle: '제출한 영수증 목록 및 승인 상태 확인',
            color: const Color(0xFF3366FF),
            onTap: () => context.go('/history'),
          ),
          const SizedBox(height: 12),
          
          // 🌟 추가된 버튼: 출장 관리
          _NavCard(
            icon: Icons.luggage,
            title: '출장 관리',
            subtitle: '출장 등록 및 관련 경비 정산 관리',
            color: const Color(0xFF3366FF),
            onTap: () => context.go('/trip'),
          ),
        ],
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _NavCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}