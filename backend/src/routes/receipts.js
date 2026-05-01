import { Router } from 'express';
import { authenticate }  from '../middlewares/auth.js';
import { upload }        from '../middlewares/upload.js';
import {
  uploadReceipt, getReceipts, getReceiptById, deleteReceipt,
} from '../controllers/receiptController.js';
import { batchUpload }   from '../controllers/batchController.js';

const router = Router();
router.use(authenticate);

router.post  ('/upload', upload.single('image'),           uploadReceipt);
router.post  ('/batch',  upload.array('images', 10),       batchUpload);  // ← 배치 추가
router.get   ('/',        getReceipts);
router.get   ('/:id',     getReceiptById);
router.delete('/:id',     deleteReceipt);

export default router;