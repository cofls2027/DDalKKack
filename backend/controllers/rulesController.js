const supabase = require('../supabase');

async function getRules(req, res) {
  const { company_id } = req.query;

  if (!company_id) {
    return res.status(400).json({ error: 'company_id는 필수입니다.' });
  }

  const companyId = parseInt(company_id, 10);
  if (isNaN(companyId)) {
    return res.status(400).json({ error: 'company_id가 올바르지 않습니다.' });
  }

  const [rulesResult, categoriesResult] = await Promise.all([
    supabase
      .from('rules')
      .select('id, company_id, category_code, position, max_amount, allowed_time_from, allowed_time_to, created_at')
      .eq('company_id', companyId)
      .order('id', { ascending: true }),
    supabase
      .from('categories')
      .select('category_code, category_name')
      .eq('company_id', companyId),
  ]);

  if (rulesResult.error) return res.status(500).json({ error: rulesResult.error.message });
  if (categoriesResult.error) return res.status(500).json({ error: categoriesResult.error.message });

  const categoryMap = Object.fromEntries(
    categoriesResult.data.map(c => [c.category_code, c.category_name])
  );

  const data = rulesResult.data.map(rule => ({
    ...rule,
    category_name: categoryMap[rule.category_code] ?? null,
  }));

  res.json(data);
}

module.exports = { getRules };
