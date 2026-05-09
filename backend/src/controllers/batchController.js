import { supabase } from '../lib/supabase.js';
import { uploadToStorage, getPublicUrl } from '../services/storageService.js';
import FormData from 'form-data';
import fs from 'fs';
import fetch from 'node-fetch';

const AI_URL = 'http://localhost:8000';


export async function batchUpload(req, res, next) {
  try {
    const files     = req.files;
    const card_type = req.body.card_type ?? 'company';
    const companyId = req.user.company_id;

    if (!files?.length)
      return res.status(400).json({ error: 'no files' });
    if (files.length > 10)
      return res.status(400).json({ error: 'max 10' });

    const results = [];

    for (const file of files) {
      try {
        const storagePath = await uploadToStorage(file.path, req.user.id, file.filename);

        console.log('FastAPI call:', file.filename);
        const form = new FormData();
        form.append('image', fs.createReadStream(file.path), file.filename);
        form.append('card_type', card_type);
        form.append('company_id', String(companyId));
        form.append('position', req.user.position ?? '');
        form.append('headcount', String(req.body.headcount ?? 1));

        const aiRes = await fetch(AI_URL + '/ai/analyze', {
          method: 'POST', body: form, headers: form.getHeaders(),
        });
        console.log('FastAPI status:', aiRes.status);
        const ai = await aiRes.json();
        console.log('FastA  PI result:', JSON.stringify(ai));

        const { data, error: dbError } = await supabase.from('receipts').insert({
          user_id:       req.user.id,
          company_id:    companyId,
          storage_path:  storagePath,
          image_url:     getPublicUrl(storagePath),
          merchant_name: ai.ocr.merchant,
          amount:        ai.ocr.amount,
          payment_date:  ai.ocr.date,
          category:      ai.ocr.category,
          card_type:     card_type,
          items:         ai.ocr.items,
          status:        ai.status,
          reject_reason: ai.reason,
          headcount:     parseInt(req.body.headcount ?? 1),  // ← 추가
        }).select().single();

        console.log('DB result:', data);
        console.log('DB error:', dbError);

        results.push({ success: true, filename: file.originalname, receipt: data });

      } catch (err) {
        console.log('file error:', err.message);
        results.push({ success: false, filename: file.originalname, error: err.message });
      }
    }

    const succeeded = results.filter(r => r.success).length;
    res.status(207).json({ total: files.length, succeeded, failed: files.length - succeeded, results });

  } catch (err) { next(err); }
}
