import { supabase } from '../lib/supabase.js';

/** GET /api/validation/rules — 현재 규정 조회 */
export async function getRules(req, res, next) {
  try {
    const { data, error } = await supabase
      .from('validation_rules').select('*').single();
    if (error) throw error;
    res.json({ rules: data });
  } catch (err) { next(err); }
}

/** PATCH /api/receipts/:id/status — 관리자 수동 상태 변경 */
export async function updateStatus(req, res, next) {
  try {
    const { status, reject_reason } = req.body;
    const allowed = ['approved', 'rejected'];

    if (!allowed.includes(status)) {
      return res.status(400).json({ error: 'status는 approved 또는 rejected만 가능합니다' });
    }

    const { data, error } = await supabase
      .from('receipts')
      .update({ status, reject_reason: reject_reason ?? null })
      .eq('id', req.params.id)
      .select().single();

    if (error) throw error;
    res.json({ receipt: data });
  } catch (err) { next(err); }
}