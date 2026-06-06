import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import receiptsRouter from './src/routes/receipts.js';
import validationRouter from './src/routes/validation.js';
import { errorHandler } from './src/middlewares/errorHandler.js';

const app = express();

app.use(cors());
app.use((req, res, next) => {
  console.log(`${req.method} ${req.path}`);
  next();
});
app.use(express.json());
app.use('/api/receipts', receiptsRouter);
app.use('/api/validation', validationRouter);
app.get('/health', (req, res) => res.json({ status: 'ok' }));
app.use(errorHandler);

app.listen(3000, () => {
  console.log('Server running on port 4000');
});

app._router.stack.forEach(r => {
  if (r.handle?.stack) {
    r.handle.stack.forEach(s => {
      if (s.route) console.log(s.route.path, Object.keys(s.route.methods));
    });
  }
});