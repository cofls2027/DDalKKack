const express = require('express');
const { serviceClient } = require('./supabase-clients');
const { sendError } = require('./helper-http-response');
const { normalizeTripCompanions } = require('./helper-trip-companions');
const { requireAdmin } = require('./middleware-admin-auth');
const { scopedByCompany } = require('./service-admin-profile');

const router = express.Router();

async function loadAdminData(profile){
  const usersQuery = scopedByCompany(
    serviceClient
      .from('users')
      .select('id, company_id, name, phone, position, role, email, is_active, staff_initial_password, staff_current_password')
      .order('created_at', { ascending: false }),
    profile
  );
  const receiptsQuery = scopedByCompany(
    serviceClient.from('receipts').select('*').order('created_at', { ascending: false }),
    profile
  );
  const tripsQuery = scopedByCompany(
    serviceClient.from('trips').select('*').order('created_at', { ascending: false }),
    profile
  );
  const cardsQuery = scopedByCompany(
    serviceClient.from('cards').select('*').order('created_at', { ascending: false }),
    profile
  );

  const [usersResult, receiptsResult, tripsResult, cardsResult] = await Promise.all([
    usersQuery,
    receiptsQuery,
    tripsQuery,
    cardsQuery
  ]);

  const failed = [usersResult, receiptsResult, tripsResult, cardsResult].find(result => result.error);
  if(failed) throw failed.error;

  return {
    users: usersResult.data || [],
    receipts: receiptsResult.data || [],
    trips: (tripsResult.data || []).map(trip => ({
      ...trip,
      trip_companions: normalizeTripCompanions(trip.trip_companions)
    })),
    cards: cardsResult.data || []
  };
}

router.get('/data', requireAdmin, async (req, res) => {
  try{
    const data = await loadAdminData(req.adminProfile);
    res.json(data);
  }catch(err){
    console.error('관리자 데이터 조회 실패:', err);
    return sendError(res, 500, '데이터를 불러오지 못했습니다.');
  }
});

module.exports = router;
