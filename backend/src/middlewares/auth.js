import { supabase } from '../lib/supabase.js';

console.log('auth middleware loaded');
export async function authenticate(req, res, next) {
  const authHeader = req.headers['authorization'];
  console.log('authHeader:', authHeader?.substring(0, 30));

  if (!authHeader?.startsWith('Bearer ')) {
    return res.status(401).json({ error: '인증 토큰이 없습니다' });
  }

  const token = authHeader.slice(7);

  try {
    const { data: { user }, error } = await supabase.auth.getUser(token);

    console.log('user:', user?.id);
    console.log('error:', error?.message);

    if (error || !user) {
      return res.status(401).json({ error: '유효하지 않은 토큰입니다' });
    }

    const { data: userInfo, error: userError } = await supabase
      .from('users')
      .select('*')
      .eq('id', user.id)
      .maybeSingle();

    console.log('userInfo:', userInfo);
    console.log('userError:', userError?.message);

    if (userError || !userInfo) {
      return res.status(401).json({ error: '등록되지 않은 사용자입니다' });
    }

    req.user = {
      ...user,
      ...userInfo,
      id: userInfo.id,
    };

    next();
  } catch (err) {
    console.error('auth 에러:', err.message);
    return res.status(401).json({ error: '인증 처리 중 오류가 발생했습니다' });
  }
}
