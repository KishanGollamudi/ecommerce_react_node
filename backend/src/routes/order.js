import express from 'express';
const router = express.Router();

import Order from '../controllers/order';
import grantAccess from '../middlewares/grantAccess';

router.post('/', grantAccess('createOwn', 'order'), Order.Create);
router.get('/', grantAccess('readAny', 'order'), Order.List);
router.get('/my-orders', grantAccess('readOwn', 'order'), Order.GetMyOrders);

export default router;
