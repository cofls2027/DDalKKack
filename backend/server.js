import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import receiptsRouter from './src/routes/receipts.js';
import validationRouter from './src/routes/validation.js';
import { errorHandler } from './src/middlewares/errorHandler.js';
import authRouter from './src/routes/auth.rotes.js';

const app = express();

app.use(cors());
app.use((req, res, next) => {
  console.log(`${req.method} ${req.path}`);
  next();
});

app.use(express.json());
app.use('/api/receipts', receiptsRouter);
app.use('/api/validation', validationRouter);
app.use('/api/auth', authRouter);
app.get('/health', (req, res) => res.json({ status: 'ok' }));
app.use(errorHandler);

const PORT = 4001; // 하드코딩
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
