import { Request as ExpressRequest, Response as ExpressResponse } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import connection from '../database/connection';

class AdminController {
  async login(req: ExpressRequest, res: ExpressResponse) {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: 'Email e senha são obrigatórios.' });
    }
    try {
      const [rows] = await connection.query('SELECT * FROM admins WHERE email = ?', [email]);
      const admins = rows as any[];
      if (admins.length === 0) {
        return res.status(401).json({ error: 'Credenciais inválidas.' });
      }
      const admin = admins[0];
      const isPasswordCorrect = await bcrypt.compare(password, admin.password_hash);
      if (!isPasswordCorrect) {
        return res.status(401).json({ error: 'Credenciais inválidas.' });
      }
      const token = jwt.sign(
        { id: admin.id, role: 'admin' },
        process.env.JWT_SECRET || 'default_secret',
        { expiresIn: '1d' }
      );
      delete admin.password_hash;
      return res.status(200).json({ admin, token });
    } catch (error) {
      console.error('Erro no login do admin:', error);
      return res.status(500).json({ error: 'Ocorreu um erro inesperado no servidor.' });
    }
  }

  async getAllUsers(req: ExpressRequest, res: ExpressResponse) {
    const [users] = await connection.query('SELECT id, name, email, phone, created_at FROM users');
    return res.json(users);
  }
  async deleteUser(req: ExpressRequest, res: ExpressResponse) {
    const { id } = req.params;
    await connection.query('DELETE FROM users WHERE id = ?', [id]);
    return res.status(200).json({ message: 'Usuário deletado com sucesso.' });
  }

  async getAllBrokers(req: ExpressRequest, res: ExpressResponse) {
    const [brokers] = await connection.query('SELECT id, name, email, creci, created_at FROM brokers');
    return res.json(brokers);
  }
  async deleteBroker(req: ExpressRequest, res: ExpressResponse) {
    const { id } = req.params;
    await connection.query('DELETE FROM brokers WHERE id = ?', [id]);
    return res.status(200).json({ message: 'Corretor deletado com sucesso.' });
  }

  async deleteProperty(req: ExpressRequest, res: ExpressResponse) {
    const { id } = req.params;
    await connection.query('DELETE FROM properties WHERE id = ?', [id]);
    return res.status(200).json({ message: 'Imóvel deletado pelo administrador com sucesso.' });
  }
}
export const adminController = new AdminController();