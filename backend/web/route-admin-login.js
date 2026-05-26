const express = require('express');
const { authClient } = require('./supabase-clients');
const { sendError } = require('./helper-http-response');
const { requireAdmin } = require('./middleware-admin-auth');
const { getAdminProfile } = require('./service-admin-profile');

const router = express.Router();

function isNetworkError(err){
  const code = err?.cause?.code || err?.code;
  return code === 'ENOTFOUND' || code === 'UND_ERR_CONNECT_TIMEOUT' || code === 'ECONNRESET' || code === 'ETIMEDOUT';
}

router.post('/login', async (req, res) => {
  try{
    const email = String(req.body.email || '').trim();
    const password = String(req.body.password || '');
    if(!email || !password) return sendError(res, 400, '이메일과 비밀번호를 입력해주세요.');

    const { data: authData, error: authError } = await authClient.auth.signInWithPassword({ email, password });
    if(authError || !authData.user || !authData.session){
      return sendError(res, 401, '관리자 계정 정보가 올바르지 않습니다.');
    }

    const profile = await getAdminProfile(authData.user.id);
    if(!profile) return sendError(res, 403, '관리자 권한이 없거나 비활성화된 계정입니다.');

    return res.json({
      access_token: authData.session.access_token,
      expires_at: authData.session.expires_at,
      profile
    });
  }catch(err){
    console.error('관리자 로그인 실패:', err);
    if(isNetworkError(err)) return sendError(res, 503, '연결할 수 없습니다. 인터넷 연결 또는 DNS 상태를 확인해 주세요.');
    return sendError(res, 500, '로그인 중 오류가 발생했습니다.');
  }
});

router.get('/me', requireAdmin, (req, res) => {
  res.json({ profile: req.adminProfile });
});

module.exports = router;
