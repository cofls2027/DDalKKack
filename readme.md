## 🤝 팀원 통합(Merge) 시 필수 수정 사항 (TODO)

프론트엔드와 백엔드 API 연동은 완료된 상태이며, 다른 파트(로그인, AI) 코드가 병합될 때 아래 사항들을 반드시 수정해야 정상 작동합니다.

### 1.  로그인/회원가입 파트 연동
**출장 등록 시 로그인한 사용자의 실제 ID 값으로 교체해야 합니다.**
* **대상 파일:** `app/lib/screens/trip_registration_screen.dart`
* **수정 위치:** 등록 버튼 `onPressed` 내부의 `tripData` 맵 (약 85번째 줄 부근)
* **변경 내용:**
  ```dart
  // ❌ 수정 전 (현재 임시 하드코딩 상태)
  final tripData = {
    'user_id': '048def2e-5ff2-480d-a659-c12d18fa7ed8',
    'company_id': 1,
    // ...
  };

  // ✅ 수정 후 (로그인 연동)
  final currentUser = Supabase.instance.client.auth.currentUser;
  final tripData = {
    'user_id': currentUser?.id, 
    'company_id': 1, 
    // ...
  };