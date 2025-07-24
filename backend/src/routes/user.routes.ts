import { Router as RouterUser } from 'express';
import { userController } from '../controllers/UserController';

const userRoutes = RouterUser();
userRoutes.post('/register', userController.register);
userRoutes.post('/login', userController.login);

export default userRoutes;
