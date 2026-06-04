import multer from 'multer';
import path   from 'path';
import fs     from 'fs';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const TMP_DIR = path.join(__dirname, '../../tmp/receipts');

// 폴더 없으면 생성
if (!fs.existsSync(TMP_DIR)) fs.mkdirSync(TMP_DIR, { recursive: true });

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, TMP_DIR),
  filename:    (req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, `${Date.now()}-${req.user?.id ?? 'unknown'}${ext}`);
  },
});

const fileFilter = (req, file, cb) => {
  const allowed = ['image/jpeg', 'image/png', 'image/webp', 'image/heic'];
  allowed.includes(file.mimetype)
    ? cb(null, true)
    : cb(new Error('JPG, PNG, WEBP, HEIC 파일만 가능합니다'));
};

export const upload = multer({
  storage,
  fileFilter,
  limits: { fileSize: 10 * 1024 * 1024 },
});