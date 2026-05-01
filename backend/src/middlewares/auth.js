import { supabase } from '../lib/supabase.js';

/**
 * Supabase JWT 검증 미들웨어
 * 앱에서 로그인한 사용자의 토큰을 Authorization 헤더로 받아 검증
 */
export async function authenticate(req, res, next) {
  const authHeader = req.headers['authorization'];

  if (!authHeader?.startsWith('Bearer ')) {
    return res.status(401).json({ error: '인증 토큰이 없습니다' });
  }

  const token = authHeader.slice(7);

  const { data: { user }, error } = await supabase.auth.getUser(token);

  if (error || !user) {
    return res.status(401).json({ error: '유효하지 않은 토큰입니다' });
  }

  req.user = user; // 이후 컨트롤러에서 req.user.id 로 사용
  next();
}