import { Request as ExpressRequestUser, Response as ExpressResponseUser } from 'express';
import bcryptUser from 'bcryptjs';
import jwtUser from 'jsonwebtoken';
import connectionUser from '../database/connection';

class UserController {
  async register(req: ExpressRequestUser, res: ExpressResponseUser) {
    const { name, email, password, phone, address, city, state } = req.body;
    if (!name || !email || !password) {
      return res.status(400).json({ error: 'Nome, email e senha são obrigatórios.' });
    }
    try {
      const [existingUser] = await connectionUser.query('SELECT id FROM users WHERE email = ?', [email]);
      if (Array.isArray(existingUser) && existingUser.length > 0) {
        return res.status(400).json({ error: 'Este e-mail já está em uso.' });
      }
      const password_hash = await bcryptUser.hash(password, 8);
      const insertQuery = `
        INSERT INTO users (name, email, password_hash, phone, address, city, state)
        VALUES (?, ?, ?, ?, ?, ?, ?);
      `;
      await connectionUser.query(insertQuery, [name, email, password_hash, phone, address, city, state]);
      return res.status(201).json({ message: 'Usuário criado com sucesso!' });
    } catch (error) {
      console.error('Erro no registro do usuário:', error);
      return res.status(500).json({ error: 'Ocorreu um erro inesperado no servidor.' });
    }
  }

  async login(req: ExpressRequestUser, res: ExpressResponseUser) {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: 'Email e senha são obrigatórios.' });
    }
    try {
      const [rows] = await connectionUser.query('SELECT id, name, email, password_hash FROM users WHERE email = ?', [email]);
      const users = rows as any[];
      if (users.length === 0) {
        return res.status(401).json({ error: 'Credenciais inválidas.' });
      }
      const user = users[0];
      const isPasswordCorrect = await bcryptUser.compare(password, user.password_hash);
      if (!isPasswordCorrect) {
        return res.status(401).json({ error: 'Credenciais inválidas.' });
      }
      const token = jwtUser.sign(
        { id: user.id, role: 'user' },
        process.env.JWT_SECRET || 'default_secret',
        { expiresIn: '1d' }
      );
      delete user.password_hash;
      return res.status(200).json({ user, token });
    } catch (error) {
      console.error('Erro no login do usuário:', error);
      return res.status(500).json({ error: 'Ocorreu um erro inesperado no servidor.' });
    }
  }
}
export const userController = new UserController();