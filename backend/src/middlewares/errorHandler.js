export function errorHandler(err, req, res, next) {
  console.error(`[ERROR] ${req.method} ${req.path}`, err.message);

  if (err.code === 'LIMIT_FILE_SIZE') {
    return res.status(413).json({ error: '파일 크기는 10MB 이하여야 합니다' });
  }

  // 숫자로 변환 (문자열 "404" 같은 경우 대비)
  const status = parseInt(err.statusCode ?? err.status ?? 500);
  const message = err.message ?? '서버 오류가 발생했습니다';

  return res.status(status).json({ error: message });
}