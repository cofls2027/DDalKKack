import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http; // 💡 http 패키지 추가
import 'trip_registration_screen.dart'; 
import 'trip_detail_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 💡 이 줄 추가!


class TripScreen extends StatefulWidget {
  const TripScreen({super.key});

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  List<dynamic> _trips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTrips();
  }

  // 🚀 Node.js 서버에서 가져오기 
  Future<void> _fetchTrips() async {
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      if (currentUserId == null) return;

      final url = Uri.parse('http://localhost:3000/api/trips?user_id=$currentUserId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _trips = data;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('서버 응답 에러');
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('🚨 데이터 불러오기 실패: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 80,
        title: const Text('내 출장', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TripRegistrationScreen()), 
              );
              setState(() { _isLoading = true; });
              _fetchTrips(); // 등록하고 돌아오면 새로고침!
            },
            child: const Text('+ 등록', style: TextStyle(color: Color(0xFF3C3489), fontSize: 16)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3C3489)))
          : _trips.isEmpty 
              ? const Center(child: Text('등록된 출장 내역이 없습니다.', style: TextStyle(fontSize: 16, color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _trips.length,
                  itemBuilder: (context, index) {
                    final trip = _trips[index];
                    final title = trip['trip_name'] ?? '제목 없음';
                    final startDate = trip['start_date'] ?? '?';
                    final endDate = trip['end_date'] ?? '?';
                    
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TripDetailScreen(trip: trip)), 
                        );
                      },
                      child: _buildTripCard(title, '$startDate ~ $endDate', '승인 대기'),
                    );
                  },
                ),
    );
  }

  Widget _buildTripCard(String title, String date, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFEEEDFE), borderRadius: BorderRadius.circular(8)),
                child: Text(status, style: const TextStyle(fontSize: 12, color: Color(0xFF3C3489), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Text(date, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}