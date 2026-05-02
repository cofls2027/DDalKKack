const supabase = require('../supabase');

async function getMyStats(req, res) {
  const { user_id, company_id, year, month } = req.query;

  if (!user_id || !company_id || !year || !month) {
    return res.status(400).json({ error: 'user_id, company_id, year, month는 필수입니다.' });
  }

  const y = parseInt(year);
  const m = parseInt(month);
  const startDate = new Date(y, m - 1, 1).toISOString();
  const endDate = new Date(y, m, 1).toISOString();

  const { data, error } = await supabase
    .from('receipts')
    .select('amount, category, card_type, status')
    .eq('user_id', user_id)
    .eq('company_id', company_id)
    .gte('payment_date', startDate)
    .lt('payment_date', endDate);

  if (error) return res.status(500).json({ error: error.message });

  const totalAmount = data
    .filter((r) => r.status === 'approved')
    .reduce((sum, r) => sum + (r.amount || 0), 0);

  const categoryStats = {};
  const cardTypeStats = {};
  const statusStats = { approved: 0, pending: 0, rejected: 0 };

  data.forEach((r) => {
    const cat = r.category || '기타';
    categoryStats[cat] = (categoryStats[cat] || 0) + (r.amount || 0);

    const cardType = r.card_type || '개인카드';
    cardTypeStats[cardType] = (cardTypeStats[cardType] || 0) + 1;

    if (r.status in statusStats) {
      statusStats[r.status]++;
    }
  });

  res.json({
    total_amount: totalAmount,
    category_stats: categoryStats,
    card_type_stats: cardTypeStats,
    status_stats: statusStats,
  });
}

module.exports = { getMyStats };
