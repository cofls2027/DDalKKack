// src/controllers/batchController.js

import { supabase }         from '../lib/supabase.js';
import { uploadToStorage, getPublicUrl } from '../services/storageService.js';
import FormData             from 'form-data';
import fs                   from 'fs';
import fetch                from 'node-fetch';

const AI_URL = 'http://localhost:8000';

/** POST /api/receipts/batch */
export async function batchUpload(req, res, next) {
  try {
    const files     = req.files;
    const card_type = req.body.card_type ?? '회사카드';
    const companyId = req.user.company_id;

    if (!files?.length)
      return res.status(400).json({ error: '파일이 없습니다' });
    if (files.length > 10)
      return res.status(400).json({ error: '최대 10장까지 가능합니다' });

    const results = [];

    for (const file of files) {
      try {
        // 1) Storage 업로드
        const storagePath = await uploadToStorage(
          file.path, req.user.id, file.filename
        );

        // 2) FastAPI 호출 (OCR + 검증)
        const form = new FormData();
        form.append('image', fs.createReadStream(file.path), file.filename);
        form.append('card_type', card_type);
        form.append('company_id', String(companyId));

        const aiRes = await fetch(`${AI_URL}/ai/analyze`, {
          method: 'POST', body: form, headers: form.getHeaders(),
        });
        const ai = await aiRes.json();

        // 3) DB 저장
        const { data } = await supabase.from('receipts').insert({
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
        }).select().single();

        results.push({ success: true, filename: file.originalname, receipt: data });

      } catch (err) {
        // 한 장 실패해도 나머지 계속
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