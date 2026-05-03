// 환경별 API URL
// - Chrome(웹) 테스트:       http://localhost:3000/api
// - Android 에뮬레이터:      http://10.0.2.2:3000/api
// - 실기기(같은 와이파이):   http://192.168.x.x:3000/api
const String kApiBaseUrl = 'http://localhost:3000/api';

const List<String> kCategories = ['식대', '회식비', '교통비', '숙박비', '복리후생', '업무용품', '기타'];
const List<String> kCardTypes = ['법인카드', '정부지원카드', '개인카드'];
