import { Router as RouterBroker } from 'express';
import { brokerController } from '../controllers/BrokerController';

const brokerRoutes = RouterBroker();
brokerRoutes.post('/register', brokerController.register);
brokerRoutes.post('/login', brokerController.login);

export default brokerRoutes;