/**
 * 전역 에러 핸들러 — server.js 맨 마지막에 등록해야 함
 * next(err) 로 넘어온 모든 에러를 여기서 처리
 */
export function errorHandler(err, req, res, next) {
  console.error(`[ERROR] ${req.method} ${req.path}`, err.message);

  // multer 파일 크기 초과
  if (err.code === 'LIMIT_FILE_SIZE') {
    return res.status(413).json({ error: '파일 크기는 10MB 이하여야 합니다' });
  }

  // 직접 던진 에러에 statusCode가 있으면 사용
  const status = err.statusCode ?? 500;
  const message = err.message ?? '서버 오류가 발생했습니다';

  return res.status(status).json({ error: message });
}