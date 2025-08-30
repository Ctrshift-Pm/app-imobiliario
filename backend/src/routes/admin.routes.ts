import { Router as RouterAdmin } from 'express';
import { adminController } from '../controllers/AdminController';
import { authMiddleware as authMiddlewareAdmin, isAdmin as isAdminAdmin } from '../middlewares/auth';

const adminRoutes = RouterAdmin();
adminRoutes.post('/login', adminController.login);
adminRoutes.get('/users', authMiddlewareAdmin, isAdminAdmin, adminController.getAllUsers);
adminRoutes.delete('/users/:id', authMiddlewareAdmin, isAdminAdmin, adminController.deleteUser);
adminRoutes.get('/brokers', authMiddlewareAdmin, isAdminAdmin, adminController.getAllBrokers);
adminRoutes.delete('/brokers/:id', authMiddlewareAdmin, isAdminAdmin, adminController.deleteBroker);
adminRoutes.delete('/properties/:id', authMiddlewareAdmin, isAdminAdmin, adminController.deleteProperty);
adminRoutes.put('/properties/:id', authMiddlewareAdmin, isAdminAdmin, adminController.updateProperty);
adminRoutes.get('/properties-with-brokers', authMiddlewareAdmin, isAdminAdmin, adminController.listPropertiesWithBrokers);
adminRoutes.put('/properties/:id', authMiddlewareAdmin, isAdminAdmin, adminController.updateProperty);
adminRoutes.delete('/properties/:id', authMiddlewareAdmin, isAdminAdmin, adminController.deleteProperty);

export default adminRoutes;