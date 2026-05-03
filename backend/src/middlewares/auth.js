import { supabase } from '../lib/supabase.js';

/**
 * Supabase JWT 검증 미들웨어
 * auth_id로 users 테이블에서 유저 정보 가져오기
 */
export async function authenticate(req, res, next) {
  const authHeader = req.headers['authorization'];
  console.log('authHeader:', authHeader);
  if (!authHeader?.startsWith('Bearer ')) {
    return res.status(401).json({ error: '인증 토큰이 없습니다' });
  }

  const token = authHeader.slice(7);
  console.log('token 앞 20자:', token.slice(0, 20));
  // 1) JWT 검증
  const { data: { user }, error } = await supabase.auth.getUser(token);
  console.log('user:', user); // ← 추가
  console.log('error:', error); // ← 추가

  if (error || !user) {
    return res.status(401).json({ error: '유효하지 않은 토큰입니다' });
  }

  // 2) users 테이블에서 유저 정보 가져오기 (company_id 등)
  const { data: userInfo, error: userError } = await supabase
    .from('users')
    .select('*')
    .eq('auth_id', user.id)
    .maybeSingle();
  console.log('userInfo:', userInfo);      // ← 추가
  console.log('userError:', userError);    // ← 추가
  console.log('조회한 auth_id:', user.id);  // ← 추가
  if (userError || !userInfo) {
    return res.status(401).json({ error: '등록되지 않은 사용자입니다' });
  }

  // 3) req.user에 합쳐서 저장
  // 이후 컨트롤러에서 req.user.id, req.user.company_id 등으로 사용
  req.user = {
    ...user,
    ...userInfo,
    auth_id: user.id,      // Supabase auth uuid
    id: userInfo.id,       // users 테이블 bigint id
  };

  next();
}