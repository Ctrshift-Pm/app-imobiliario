import { Router } from 'express';
import { brokerController } from '../controllers/BrokerController';
import { authMiddleware, isBroker } from '../middlewares/auth';
import { upload } from '../config/multer';

const brokerRoutes = Router();

brokerRoutes.post('/register', brokerController.register);
brokerRoutes.post('/login', brokerController.login);
brokerRoutes.get('/me/properties', authMiddleware, isBroker, brokerController.getMyProperties);
brokerRoutes.get('/me/commissions', authMiddleware, isBroker, brokerController.getMyCommissions);
brokerRoutes.get('/me/performance', authMiddleware, isBroker, brokerController.getMyPerformanceReport);
brokerRoutes.post(
  '/me/verify-documents', 
  authMiddleware, 
  upload.fields([
    { name: 'creciFront', maxCount: 1 },
    { name: 'creciBack', maxCount: 1 },
    { name: 'selfie', maxCount: 1 }
  ]), 
  brokerController.uploadVerificationDocs
);

export default brokerRoutes;