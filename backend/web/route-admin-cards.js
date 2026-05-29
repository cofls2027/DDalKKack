const express = require('express');
const { serviceClient } = require('./supabase-clients');
const { sendError } = require('./helper-http-response');
const { requireAdmin } = require('./middleware-admin-auth');
const { scopedByCompany } = require('./service-admin-profile');

const router = express.Router();

router.post('/cards', requireAdmin, async (req, res) => {
  try{
    const card_description = String(req.body.card_description || '').trim();
    const card_type = String(req.body.card_type || '').trim();
    const card_company = String(req.body.card_company || '').trim();
    const card_number = String(req.body.card_number || '').replace(/\D/g, '');
    if(!card_description || !card_type || !card_company || !card_number){
      return sendError(res, 400, '카드명, 종류, 발급처, 카드번호를 모두 입력해주세요.');
    }
    if(!['corporate', 'government'].includes(card_type)){
      return sendError(res, 400, '카드 종류가 올바르지 않습니다.');
    }
    if(card_number.length < 12 || card_number.length > 19){
      return sendError(res, 400, '카드번호는 숫자 12~19자리로 입력해주세요.');
    }

    const newCard = {
      company_id: req.adminProfile.company_id,
      card_type,
      card_company,
      card_number,
      card_description,
      is_active: true,
      user_id: null
    };

    const { data, error } = await serviceClient
      .from('cards')
      .insert([newCard])
      .select('*')
      .maybeSingle();
    if(error) throw error;

    return res.status(201).json({ card: data });
  }catch(err){
    console.error('카드 등록 실패:', err);
    return sendError(res, 500, '카드를 등록하지 못했습니다.');
  }
});

router.patch('/cards/:id/status', requireAdmin, async (req, res) => {
  try{
    const id = Number(req.params.id);
    const is_active = Boolean(req.body.is_active);
    if(!Number.isFinite(id)) return sendError(res, 400, '카드 ID가 올바르지 않습니다.');

    let query = serviceClient
      .from('cards')
      .update({ is_active })
      .eq('id', id);
    query = scopedByCompany(query, req.adminProfile);

    const { data, error } = await query
      .select('id, is_active')
      .maybeSingle();
    if(error) throw error;
    if(!data) return sendError(res, 404, '카드를 찾을 수 없습니다.');

    return res.json({ card: data });
  }catch(err){
    console.error('카드 상태 변경 실패:', err);
    return sendError(res, 500, '카드 상태를 변경하지 못했습니다.');
  }
});

module.exports = router;
