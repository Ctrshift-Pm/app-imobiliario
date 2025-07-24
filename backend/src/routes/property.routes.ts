import { Router as RouterProperty } from 'express';
import { propertyController } from '../controllers/PropertyController';
import { authMiddleware as authMiddlewareProperty, isBroker as isBrokerProperty } from '../middlewares/auth';

const propertyRoutes = RouterProperty();
propertyRoutes.get('/', propertyController.index);
propertyRoutes.get('/:id', propertyController.show);
propertyRoutes.post('/', authMiddlewareProperty, isBrokerProperty, propertyController.create);
propertyRoutes.put('/:id', authMiddlewareProperty, isBrokerProperty, propertyController.update);
propertyRoutes.delete('/:id', authMiddlewareProperty, isBrokerProperty, propertyController.delete);

export default propertyRoutes;