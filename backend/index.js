require('dotenv').config();
const express = require('express');
const cors = require('cors');

const statsRoutes = require('./routes/stats');
const cardsRoutes = require('./routes/cards');
const rulesRoutes = require('./routes/rules');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.use('/api/stats', statsRoutes);
app.use('/api/cards', cardsRoutes);
app.use('/api/rules', rulesRoutes);

app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: '서버 오류가 발생했습니다.' });
});

app.listen(PORT, () => {
  console.log(`서버 실행 중: http://localhost:${PORT}`);
});
