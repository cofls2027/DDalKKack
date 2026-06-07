import express from 'express';
import cors from 'cors';

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// ==========================================
// 🌟 1. 오현님 담당: 내역 & 출장 API (에러 없이 데이터 출력)
// ==========================================
app.get('/api/expenses', (req, res) => {
  res.json([
    {
      id: 'exp-001',
      merchant_name: '맛있는 갈비집',
      amount: 125000,
      payment_date: '2026-06-05T12:30:00.000Z',
      category: '식대',
      card_type: '법인카드',
      status: '승인완료',
      purpose: '팀 빌딩 및 프로젝트 회식',
      trip_id: null
    },
    {
      id: 'exp-002',
      merchant_name: '딸깍문구',
      amount: 45000,
      payment_date: '2026-06-06T15:20:00.000Z',
      category: '비품비',
      card_type: '개인카드',
      status: '대기중',
      purpose: '시연용 테스트 사무용품 구매',
      trip_id: null
    }
  ]);
});

app.get('/api/trips', (req, res) => {
  res.json([
    {
      id: 'trip-001',
      trip_name: '상반기 데이터 분석 연합 컨퍼런스 출장',
      destination: '부산',
      start_date: '2026-06-10',
      end_date: '2026-06-12',
      status: '승인완료',
      budget: 500000
    }
  ]);
});

app.get('/api/trips/:id/expenses', (req, res) => {
  res.json([
    { merchant_name: 'KTX 서울-부산', amount: 59800, payment_date: '2026-06-10', category: '교통비' }
  ]);
});

app.post('/api/trips', (req, res) => res.json({ success: true }));
app.patch('/api/receipts/:id', (req, res) => res.json({ success: true }));

// ==========================================
// 🌟 2. 팀원 담당: 카드, 규정, 통계 API (다른 탭 충돌 방어)
// ==========================================
app.get('/api/cards', (req, res) => {
  res.json([
    {
      id: 1,
      user_id: '62280fd8-2cae-4e33-9827-b1d04e1493a6',
      card_type: '법인카드',
      card_company: '신한카드',
      card_number: '****-****-****-1234',
      card_description: '개발팀 공용 법인카드',
      is_active: true
    }
  ]);
});

app.get('/api/rules', (req, res) => {
  res.json([
    {
      id: 1,
      category_code: 'MEAL',
      category_name: '식대',
      position: '사원',
      max_amount: 15000,
      allowed_time_from: '11:00',
      allowed_time_to: '14:00'
    }
  ]);
});

app.get('/api/stats/my', (req, res) => {
  res.json({
    total_amount: 170000,
    category_stats: { '식대': 125000, '비품비': 45000 },
    card_type_stats: { '법인카드': 125000, '개인카드': 45000 },
    status_stats: { '승인완료': 125000, '대기중': 45000 }
  });
});

// 알 수 없는 요청 방어용
app.use((req, res) => {
  res.status(200).json([]);
});

app.listen(PORT, () => {
  console.log(`🚀 백엔드 서버가 포트 ${PORT}에서 완벽하게 실행 중입니다.`);
});