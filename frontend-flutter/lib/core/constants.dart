// Android 에뮬레이터에서 호스트 PC localhost는 10.0.2.2
// 실기기 테스트 시 PC의 실제 IP로 변경 필요 (예: http://192.168.0.10:3000/api)
const String kApiBaseUrl = 'http://10.0.2.2:3000/api';

const List<String> kCategories = ['식대', '회식비', '교통비', '숙박비', '복리후생', '업무용품', '기타'];
const List<String> kCardTypes = ['회사카드', '정부지원카드', '개인카드'];
