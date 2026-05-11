require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { createClient } = require('@supabase/supabase-js');

const app = express();
app.use(cors());
app.use(express.json());

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_ANON_KEY);

app.get('/', (req, res) => {
  res.send('DdalKKack 백엔드 서버가 가동 중입니다! 🚀');
});

// [지출] 1. 전체 내역 조회
app.get('/api/expenses', async (req, res) => {
  try {
    const { data, error } = await supabase.from('receipts').select('*').order('created_at', { ascending: false });
    if (error) throw error;
    res.status(200).json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// [지출] 2. 영수증 제출 (POST)
app.post('/api/expenses', async (req, res) => {
  try {
    const { data, error } = await supabase.from('receipts').insert([req.body]).select();
    if (error) throw error;
    res.status(201).json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// [지출] 3. 영수증 수정 (PATCH) - 출장 연결용
app.patch('/api/expenses/:id', async (req, res) => {
  try {
    const { data, error } = await supabase.from('receipts').update(req.body).eq('id', req.params.id).select();
    if (error) throw error;
    res.status(200).json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// [출장] 1. 전체 출장 목록 조회
app.get('/api/trips', async (req, res) => {
  try {
    const { data, error } = await supabase.from('trips').select('*').order('created_at', { ascending: false });
    if (error) throw error;
    res.status(200).json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// [출장] 2. 특정 출장에 연결된 영수증만 조회
app.get('/api/trips/:id/expenses', async (req, res) => {
  try {
    const { data, error } = await supabase.from('receipts').select('*').eq('trip_id', req.params.id).order('payment_date', { ascending: false });
    if (error) throw error;
    res.status(200).json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// [출장] 3. 새 출장 등록 (POST)
app.post('/api/trips', async (req, res) => {
  try {
    const { data, error } = await supabase.from('trips').insert([req.body]).select();
    if (error) throw error;
    res.status(201).json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`🚀 서버가 포트 ${PORT}에서 실행 중입니다.`));