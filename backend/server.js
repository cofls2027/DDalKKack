import 'dotenv/config';
import express    from 'express';
import cors       from 'cors';
import receiptsRouter   from './src/routes/receipts.js';
import validationRouter from './src/routes/validation.js';
import { errorHandler } from './src/middlewares/errorHandler.js';

const app  = express();
const PORT = process.env.PORT ?? 3000;

app.use(cors());
app.use(express.json());

app.use('/api/receipts',   receiptsRouter);
app.use('/api/validation', validationRouter);

app.get('/health', (req, res) => res.json({ status: 'ok' }));

app.use(errorHandler);

app.listen(PORT, () => {
  console.log(`서버 실행 중 → http://localhost:${PORT}`);
})