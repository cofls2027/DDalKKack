const { authClient } = require('./supabase-clients');
const { sendError } = require('./helper-http-response');
const { getAdminProfile } = require('./service-admin-profile');

function isNetworkError(err){
  const code = err?.cause?.code || err?.code;
  return code === 'ENOTFOUND' || code === 'UND_ERR_CONNECT_TIMEOUT' || code === 'ECONNRESET' || code === 'ETIMEDOUT';
}

async function requireAdmin(req, res, next){
  try{
    const authHeader = req.get('authorization') || '';
    const token = authHeader.startsWith('Bearer ') ? authHeader.slice(7).trim() : '';
    if(!token) return sendError(res, 401, '로그인이 필요합니다.');

    const { data, error } = await authClient.auth.getUser(token);
    if(error || !data.user) return sendError(res, 401, '유효하지 않은 로그인입니다.');

    const profile = await getAdminProfile(data.user.id);
    if(!profile) return sendError(res, 403, '관리자 권한이 없습니다.');

    req.authToken = token;
    req.authUser = data.user;
    req.adminProfile = profile;
    return next();
  }catch(err){
    console.error('관리자 인증 실패:', err);
    if(isNetworkError(err)) return sendError(res, 503, '연결할 수 없습니다. 인터넷 연결 또는 DNS 상태를 확인해 주세요.');
    return sendError(res, 500, '관리자 인증 중 오류가 발생했습니다.');
  }
}

module.exports = {
  requireAdmin
};
