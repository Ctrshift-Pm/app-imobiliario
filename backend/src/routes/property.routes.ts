import { Router } from 'express';
import { propertyController } from '../controllers/PropertyController';
import { authMiddleware, isBroker } from '../middlewares/auth';

const propertyRoutes = Router();

propertyRoutes.get('/', propertyController.index);
propertyRoutes.get('/:id', propertyController.show);
propertyRoutes.post('/', authMiddleware, isBroker, propertyController.create);
propertyRoutes.put('/:id', authMiddleware, isBroker, propertyController.update);
propertyRoutes.patch('/:id/status', authMiddleware, isBroker, propertyController.updateStatus); // NOVO
propertyRoutes.delete('/:id', authMiddleware, isBroker, propertyController.delete);

export default propertyRoutes;