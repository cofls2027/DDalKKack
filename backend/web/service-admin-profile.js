const { serviceClient } = require('./supabase-clients');

async function getAdminProfile(userId){
  const { data, error } = await serviceClient
    .from('users')
    .select('id, company_id, name, phone, position, role, email, is_active')
    .eq('id', userId)
    .eq('role', 'admin')
    .eq('is_active', true)
    .maybeSingle();
  if(error) throw error;
  return data;
}

function scopedByCompany(query, profile){
  return profile.company_id == null ? query : query.eq('company_id', profile.company_id);
}

module.exports = {
  getAdminProfile,
  scopedByCompany
};
