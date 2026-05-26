const express = require('express');
const { serviceClient } = require('./supabase-clients');
const { sendError } = require('./helper-http-response');
const { requireAdmin } = require('./middleware-admin-auth');
const { scopedByCompany } = require('./service-admin-profile');

const router = express.Router();

const USER_SELECT = 'id, company_id, name, phone, position, role, email, is_active, staff_initial_password, staff_current_password';

router.patch('/users/:id', requireAdmin, async (req, res) => {
  try{
    const id = String(req.params.id || '');
    const email = String(req.body.email || '').trim();
    const phone = String(req.body.phone || '').trim();
    const name = String(req.body.name || '').trim();
    const position = String(req.body.position || '').trim();
    const staff_initial_password = req.body.staff_initial_password ? String(req.body.staff_initial_password).trim() : null;
    const password = req.body.password ? String(req.body.password).trim() : null;
    if(!id || !email || !phone || !name || !position){
      return sendError(res, 400, '이메일, 전화번호, 이름, 직급을 모두 입력해주세요.');
    }
    if(password && password.length < 6){
      return sendError(res, 400, '로그인 비밀번호는 6자 이상이어야 합니다.');
    }

    const updatePayload = { email, phone, name, position, staff_initial_password };
    if(password){
      const { error: authError } = await serviceClient.auth.admin.updateUserById(id, { password });
      if(authError) throw authError;
      updatePayload.staff_current_password = password;
    }

    let query = serviceClient
      .from('users')
      .update(updatePayload)
      .eq('id', id);
    query = scopedByCompany(query, req.adminProfile);

    const { data, error } = await query
      .select(USER_SELECT)
      .maybeSingle();
    if(error) throw error;
    if(!data) return sendError(res, 404, '사용자를 찾을 수 없습니다.');

    return res.json({ user: data });
  }catch(err){
    console.error('사용자 정보 수정 실패:', err);
    return sendError(res, 500, '사용자 정보를 저장하지 못했습니다.');
  }
});

router.post('/users', requireAdmin, async (req, res) => {
  let authUserId = null;
  try{
    const email = String(req.body.email || '').trim();
    const phone = String(req.body.phone || '').trim();
    const name = String(req.body.name || '').trim();
    const position = String(req.body.position || '').trim();
    const password = String(req.body.password || '');
    if(!email || !phone || !name || !position || !password){
      return sendError(res, 400, '직원 등록 정보가 부족합니다.');
    }

    const { data: authData, error: authError } = await serviceClient.auth.admin.createUser({
      email,
      password,
      email_confirm: true
    });
    if(authError || !authData.user) throw authError || new Error('Auth user create failed');
    authUserId = authData.user.id;

    const newUser = {
      id: authUserId,
      company_id: req.adminProfile.company_id,
      name,
      email,
      phone,
      position,
      role: 'employee',
      is_active: true,
      staff_initial_password: password,
      staff_current_password: password
    };
    const { data, error } = await serviceClient
      .from('users')
      .insert([newUser])
      .select(USER_SELECT)
      .maybeSingle();
    if(error) throw error;

    return res.status(201).json({ user: data });
  }catch(err){
    console.error('사용자 등록 실패:', err);
    if(authUserId){
      await serviceClient.auth.admin.deleteUser(authUserId).catch(deleteError => {
        console.error('실패한 Auth 사용자 정리 실패:', deleteError);
      });
    }
    return sendError(res, 500, '직원 계정을 만들지 못했습니다.');
  }
});

router.patch('/users/:id/status', requireAdmin, async (req, res) => {
  try{
    const id = String(req.params.id || '');
    const is_active = Boolean(req.body.is_active);
    if(!id) return sendError(res, 400, '사용자 ID가 올바르지 않습니다.');

    let query = serviceClient
      .from('users')
      .update({ is_active })
      .eq('id', id);
    query = scopedByCompany(query, req.adminProfile);

    const { data, error } = await query
      .select('id, is_active')
      .maybeSingle();
    if(error) throw error;
    if(!data) return sendError(res, 404, '사용자를 찾을 수 없습니다.');

    return res.json({ user: data });
  }catch(err){
    console.error('사용자 상태 변경 실패:', err);
    return sendError(res, 500, '사용자 상태를 변경하지 못했습니다.');
  }
});

module.exports = router;
