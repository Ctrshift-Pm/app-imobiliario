import { Router } from 'express';
import { propertyController } from '../controllers/PropertyController';
import AuthRequest, { authMiddleware, isBroker } from '../middlewares/auth';
import { upload } from '../config/multer';

const propertyRoutes = Router();

propertyRoutes.post(
  '/',
  authMiddleware,
  isBroker,
  upload.fields([
    { name: 'images', maxCount: 20 },
    { name: 'video', maxCount: 1 }
  ]),
  (req, res) => propertyController.create(req as any, res)
);
propertyRoutes.get('/public', (req, res) => propertyController.listPublicProperties(req, res));
propertyRoutes.get('/:id', (req, res) => propertyController.show(req, res));
propertyRoutes.get('/cities', (req, res) => propertyController.getAvailableCities(req, res));
propertyRoutes.put('/:id', authMiddleware, isBroker, (req, res) => propertyController.update(req, res));
propertyRoutes.patch('/:id/status', authMiddleware, isBroker, (req, res) => propertyController.updateStatus(req, res));
propertyRoutes.delete('/:id', authMiddleware, isBroker, (req, res) => propertyController.delete(req, res));
propertyRoutes.get('/user/favorites', authMiddleware, (req, res) => propertyController.listUserFavorites(req, res));
propertyRoutes.post('/:id/favorite', authMiddleware, (req, res) => propertyController.addFavorite(req, res));
propertyRoutes.delete('/:id/favorite', authMiddleware, (req, res) => propertyController.removeFavorite(req, res));

export default propertyRoutes;