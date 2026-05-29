const express = require('express');
const { serviceClient } = require('./supabase-clients');
const { sendError } = require('./helper-http-response');
const { requireAdmin } = require('./middleware-admin-auth');
const { scopedByCompany } = require('./service-admin-profile');

const router = express.Router();

router.patch('/receipts/:id/decision', requireAdmin, async (req, res) => {
  try{
    const id = Number(req.params.id);
    const status = String(req.body.status || '');
    if(!Number.isFinite(id)) return sendError(res, 400, '영수증 ID가 올바르지 않습니다.');
    if(!['approved', 'rejected'].includes(status)) return sendError(res, 400, '상태 값이 올바르지 않습니다.');

    const nextValues = {
      status,
      reject_reason: status === 'approved' ? null : req.body.reject_reason || null,
      reviewed_at: new Date().toISOString()
    };

    let query = serviceClient
      .from('receipts')
      .update(nextValues)
      .eq('id', id);
    query = scopedByCompany(query, req.adminProfile);

    const { data, error } = await query
      .select('id, status, reject_reason, reviewed_at')
      .maybeSingle();
    if(error) throw error;
    if(!data) return sendError(res, 404, '영수증을 찾을 수 없습니다.');

    return res.json({ receipt: data });
  }catch(err){
    console.error('영수증 상태 저장 실패:', err);
    return sendError(res, 500, '영수증 상태를 저장하지 못했습니다.');
  }
});

module.exports = router;
