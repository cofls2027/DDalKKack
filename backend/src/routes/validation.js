import { Router } from 'express';
import { authenticate } from '../middlewares/auth.js';
import { getRules, updateStatus } from '../controllers/validationController.js';

const router = Router();

router.use(authenticate);

router.get  ('/rules',          getRules);
router.patch('/receipts/:id',   updateStatus);  // 관리자용

export default router;