import { Router } from 'express';
import { brokerController } from '../controllers/BrokerController';
import { authMiddleware, isBroker } from '../middlewares/auth';

const brokerRoutes = Router();

brokerRoutes.post('/register', brokerController.register);
brokerRoutes.post('/login', brokerController.login);
brokerRoutes.get('/me/properties', authMiddleware, isBroker, brokerController.getMyProperties);
brokerRoutes.get('/me/commissions', authMiddleware, isBroker, brokerController.getMyCommissions); // NOVO
brokerRoutes.get('/me/performance', authMiddleware, isBroker, brokerController.getMyPerformanceReport); // NOVO

export default brokerRoutes;