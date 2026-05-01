import { supabase }          from '../lib/supabase.js';
import { analyzeReceipt }    from '../services/geminiService.js';
import { validateReceipt }   from '../services/validateReceipt.js';
import { uploadToStorage, deleteFromStorage, getPublicUrl } from '../services/storageService.js';

/** POST /api/receipts/upload */
export async function uploadReceipt(req, res, next) {
  try {
    if (!req.file) return res.status(400).json({ error: '파일이 없습니다' });

    // 1) Storage 업로드
    const storagePath = await uploadToStorage(
      req.file.path, req.user.id, req.file.filename
    );

    // 2) Gemini OCR
    const ocr = await analyzeReceipt(req.file.path);

    // 3) 검증 판정
    const { status, reason } = await validateReceipt(ocr);

    // 4) DB 저장
    const { data, error } = await supabase
      .from('receipts')
      .insert({
        user_id:      req.user.id,
        storage_path: storagePath,
        image_url:    getPublicUrl(storagePath),
        merchant:     ocr.merchant,
        amount:       ocr.amount,
        receipt_date: ocr.date,
        category:     ocr.category,
        items:        ocr.items,
        raw_text:     ocr.rawText,
        status,
        reject_reason: reason,
      })
      .select().single();

    if (error) throw error;
    res.status(201).json({ receipt: data });

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
    const { data, error } = await supabase
      .from('receipts')
      .select('*')
      .eq('id', req.params.id)
      .eq('user_id', req.user.id)
      .single();

    if (error) return res.status(404).json({ error: '영수증을 찾을 수 없습니다' });
    res.json({ receipt: data });

  } catch (err) { next(err); }
}

/** DELETE /api/receipts/:id */
export async function deleteReceipt(req, res, next) {
  try {
    const { data: receipt, error: fetchErr } = await supabase
      .from('receipts').select('*')
      .eq('id', req.params.id).eq('user_id', req.user.id).single();

    if (fetchErr) return res.status(404).json({ error: '영수증을 찾을 수 없습니다' });
    if (receipt.status !== 'pending' && receipt.status !== 'rejected') {
      return res.status(400).json({ error: '승인된 영수증은 삭제할 수 없습니다' });
    }

    await deleteFromStorage(receipt.storage_path);
    await supabase.from('receipts').delete().eq('id', req.params.id);
    res.json({ message: '삭제되었습니다' });

  } catch (err) { next(err); }
}