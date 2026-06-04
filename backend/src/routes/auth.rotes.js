// src/routes/auth.js
import express from 'express';
import { supabase } from '../lib/supabase.js';

const router = express.Router();

// 플러터가 찌르고 있는 /api/auth/login 경로를 처리합니다.
router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    // 1. 수파베이스 공식 auth 시스템으로 로그인 시도
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) {
      return res.status(400).json({ error: error.message });
    }

    // 2. 로그인 성공 시 토큰과 유저 정보를 플러터 앱으로 리턴
    return res.json({
      accessToken: data.session.access_token,
      user: data.user
    });

  } catch (err) {
    console.error('백엔드 로그인 처리 에러:', err.message);
    return res.status(500).json({ error: '서버 내부 로그인 처리 오류' });
  }
});

export default router;