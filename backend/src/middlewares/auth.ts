import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

interface AuthRequest extends Request {
  userId?: number;
  userRole?: string;
}

export function authMiddleware(req: AuthRequest, res: Response, next: NextFunction) {
  const { authorization } = req.headers;
  if (!authorization) {
    return res.status(401).json({ error: 'Token não fornecido.' });
  }
  const [scheme, token] = authorization.split(' ');
  if (!/Bearer$/i.test(scheme) || !token) {
    return res.status(401).json({ error: 'Token mal formatado.' });
  }
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'default_secret') as { id: number; role: string };
    req.userId = decoded.id;
    req.userRole = decoded.role;
    return next();
  } catch (error) {
    return res.status(401).json({ error: 'Token inválido.' });
  }
}

export function isBroker(req: AuthRequest, res: Response, next: NextFunction) {
  if (req.userRole !== 'broker') {
    return res.status(403).json({ error: 'Acesso negado. Rota exclusiva para corretores.' });
  }
  return next();
}

export function isAdmin(req: AuthRequest, res: Response, next: NextFunction) {
  if (req.userRole !== 'admin') {
    return res.status(403).json({ error: 'Acesso negado. Rota exclusiva para administradores.' });
  }
  return next();
}

export default AuthRequest;