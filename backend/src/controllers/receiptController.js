import { supabase }  from '../lib/supabase.js';
import { uploadToStorage, getPublicUrl } from '../services/storageService.js';
import FormData      from 'form-data';
import fs            from 'fs';
import fetch         from 'node-fetch';

const AI_URL = 'http://localhost:8000';  // FastAPI 주소

/** FastAPI에 이미지 + 메타 전송 → OCR + 검증 결과 받기 */
async function callAI(filePath, filename, cardType, companyId) {
  const form = new FormData();
  form.append('image', fs.createReadStream(filePath), filename);
  form.append('card_type', cardType);
  form.append('company_id', String(companyId));

  const res = await fetch(`${AI_URL}/ai/analyze`, {
    method: 'POST', body: form, headers: form.getHeaders(),
  });
  if (!res.ok) throw new Error(`FastAPI 오류: ${res.status}`);
  return res.json();
}

/** POST /api/receipts/upload */
export async function uploadReceipt(req, res, next) {
  try {
    if (!req.file) return res.status(400).json({ error: '파일이 없습니다' });

    const { card_type = '회사카드' } = req.body;
    const companyId = req.user.company_id;

    // 1) Storage 업로드
    const storagePath = await uploadToStorage(
      req.file.path, req.user.id, req.file.filename
    );

    // 2) FastAPI 호출 (OCR + 검증)
    const ai = await callAI(
      req.file.path, req.file.filename, card_type, companyId
    );

    // 3) DB 저장
    const { data, error } = await supabase
      .from('receipts')
      .insert({
        user_id:       req.user.id,
        company_id:    companyId,
        storage_path:  storagePath,
        image_url:     getPublicUrl(storagePath),
        merchant_name: ai.ocr.merchant,
        amount:        ai.ocr.amount,
        payment_date:  ai.ocr.date,
        category:      ai.ocr.category,
        card_type,
        items:         ai.ocr.items,
        status:        ai.status,
        reject_reason: ai.reason,
      })
      .select().single();

    if (error) throw error;
    res.status(201).json({ receipt: data, ai });

  } catch (err) { next(err); }
}

/** GET /api/receipts */
export async function getReceipts(req, res, next) {
  try {
    const { status, page = 1, limit = 20 } = req.query;
    const from = (page - 1) * limit;
    let q = supabase.from('receipts')
      .select('*', { count: 'exact' })
      .eq('user_id', req.user.id)
      .order('created_at', { ascending: false })
      .range(from, from + limit - 1);
    if (status) q = q.eq('status', status);
    const { data, error, count } = await q;
    if (error) throw error;
    res.json({ receipts: data, total: count, page: +page, limit: +limit });
  } catch (err) { next(err); }
}

/** GET /api/receipts/:id */
export async function getReceiptById(req, res, next) {
  try {
    const { data, error } = await supabase.from('receipts')
      .select('*').eq('id', req.params.id).eq('user_id', req.user.id).single();
    if (error) return res.status(404).json({ error: '영수증을 찾을 수 없습니다' });
    res.json({ receipt: data });
  } catch (err) { next(err); }
}

/** DELETE /api/receipts/:id */
export async function deleteReceipt(req, res, next) {
  try {
    const { data: receipt, error } = await supabase.from('receipts')
      .select('*').eq('id', req.params.id).eq('user_id', req.user.id).single();
    if (error) return res.status(404).json({ error: '없습니다' });
    await deleteFromStorage(receipt.storage_path);
    await supabase.from('receipts').delete().eq('id', req.params.id);
    res.json({ message: '삭제되었습니다' });
  } catch (err) { next(err); }
}