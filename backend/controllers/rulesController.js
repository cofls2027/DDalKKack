const supabase = require('../supabase');

async function getRules(req, res) {
  const { company_id } = req.query;

  if (!company_id) {
    return res.status(400).json({ error: 'company_id는 필수입니다.' });
  }

  const { data, error } = await supabase
    .from('rules_2')
    .select('id, rule_name, policy_data, created_at')
    .eq('company_id', company_id)
    .order('id', { ascending: true });

  if (error) return res.status(500).json({ error: error.message });

  res.json(data);
}

module.exports = { getRules };
