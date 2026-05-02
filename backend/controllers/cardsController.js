const supabase = require('../supabase');

async function getCards(req, res) {
  const { company_id } = req.query;

  if (!company_id) {
    return res.status(400).json({ error: 'company_id는 필수입니다.' });
  }

  const { data, error } = await supabase
    .from('cards')
    .select('id, card_type, card_company, card_number, is_active, created_at')
    .eq('company_id', company_id)
    .order('created_at', { ascending: false });

  if (error) return res.status(500).json({ error: error.message });

  res.json(data);
}

module.exports = { getCards };
