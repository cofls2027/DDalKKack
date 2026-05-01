import { supabase } from '../lib/supabase.js';
import fs from 'fs';

const BUCKET = 'receipt-images';

/**
 * 로컬 임시 파일 → Supabase Storage 업로드
 * @returns {string} storagePath  — DB에 저장할 경로
 */
export async function uploadToStorage(localPath, userId, filename) {
  const storagePath = `receipts/${userId}/${filename}`;
  const fileBuffer  = fs.readFileSync(localPath);

  const { error } = await supabase.storage
    .from(BUCKET)
    .upload(storagePath, fileBuffer, { upsert: false });

  if (error) throw error;

  // 업로드 후 임시 파일 삭제
  fs.unlinkSync(localPath);

  return storagePath;
}

/**
 * Supabase Storage 파일 삭제
 */
export async function deleteFromStorage(storagePath) {
  const { error } = await supabase.storage
    .from(BUCKET)
    .remove([storagePath]);

  if (error) throw error;
}

/**
 * 공개 URL 생성 (이미지 미리보기용)
 */
export function getPublicUrl(storagePath) {
  const { data } = supabase.storage
    .from(BUCKET)
    .getPublicUrl(storagePath);
  return data.publicUrl;
}