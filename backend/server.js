import { Router } from 'express';
import { authenticate }  from '../middlewares/auth.js';
import { upload }        from '../middlewares/upload.js';
import {
  uploadReceipt,
  getReceipts,
  getReceiptById,
  deleteReceipt,
} from '../controllers/receiptController.js';

const router = Router();

// 모든 라우트에 인증 적용
router.use(authenticate);

router.post  ('/upload',  upload.single('image'), uploadReceipt);
router.get   ('/',        getReceipts);
router.get   ('/:id',     getReceiptById);
router.delete('/:id',     deleteReceipt);

export default router;
