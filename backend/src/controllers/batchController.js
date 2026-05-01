import { supabase }         from '../lib/supabase.js';
import { analyzeReceipt }   from '../services/geminiService.js';
import { validateReceipt }  from '../services/validateReceipt.js';
import { uploadToStorage, getPublicUrl } from '../services/storageService.js';

/**
 * POST /api/receipts/batch
 * 갤러리 사진 여러 장을 한 번에 분석
 *
 * Body (multipart): images[] + card_type
 * 각 이미지를 순서대로 처리하고 결과 배열 반환
 */
export async function batchUpload(req, res, next) {
  try {
    const files    = req.files;   // multer array
    const cardType = req.body.card_type ?? '회사카드';
    const companyId = req.user.company_id;

    if (!files?.length)
      return res.status(400).json({ error: '파일이 없습니다' });
    if (files.length > 10)
      return res.status(400).json({ error: '한 번에 최대 10장까지 가능합니다' });

    // 각 파일을 순서대로 처리 (Gemini 과부하 방지 — 병렬 X)
    const results = [];

    for (const file of files) {
      try {
        // 1) Storage 업로드
        const storagePath = await uploadToStorage(
          file.path, req.user.id, file.filename
        );

        // 2) Gemini OCR
        const ocr = await analyzeReceipt(file.path);

        // 3) RAG 기반 검증 판정
        const { status, reason } = await validateReceipt(
          ocr, cardType, companyId
        );

        // 4) DB 저장
        const { data } = await supabase.from('receipts').insert({
          user_id:      req.user.id,
          company_id:   companyId,
          storage_path: storagePath,
          image_url:    getPublicUrl(storagePath),
          merchant_name: ocr.merchant,
          amount:       ocr.amount,
          payment_date: ocr.date,
          category:     ocr.category,
          card_type:    cardType,
          items:        ocr.items,
          status,
          reject_reason: reason,
        }).select().single();

        results.push({ success: true, filename: file.originalname, receipt: data });

      } catch (err) {
        // 한 장 실패해도 나머지 계속 처리
        results.push({ success: false, filename: file.originalname, error: err.message });
      }
    }

    const succeeded = results.filter(r => r.success).length;
    res.status(207).json({
      total: files.length,
      succeeded,
      failed: files.length - succeeded,
      results,
    });

  } catch (err) { next(err); }
}