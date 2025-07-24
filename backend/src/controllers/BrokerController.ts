import { Request as ExpressRequestBroker, Response as ExpressResponseBroker } from 'express';
import bcryptBroker from 'bcryptjs';
import jwtBroker from 'jsonwebtoken';
import connectionBroker from '../database/connection';

class BrokerController {
  async register(req: ExpressRequestBroker, res: ExpressResponseBroker) {
    const { name, email, password, creci, address, city, state } = req.body;
    if (!name || !email || !password || !creci) {
      return res.status(400).json({ error: 'Nome, email, senha e CRECI são obrigatórios.' });
    }
    try {
      const [existingBroker] = await connectionBroker.query('SELECT id FROM brokers WHERE email = ? OR creci = ?', [email, creci]);
      if (Array.isArray(existingBroker) && existingBroker.length > 0) {
        return res.status(400).json({ error: 'Este e-mail ou CRECI já está em uso.' });
      }
      const password_hash = await bcryptBroker.hash(password, 8);
      const insertQuery = `
        INSERT INTO brokers (name, email, password_hash, creci, address, city, state)
        VALUES (?, ?, ?, ?, ?, ?, ?);
      `;
      await connectionBroker.query(insertQuery, [name, email, password_hash, creci, address, city, state]);
      return res.status(201).json({ message: 'Corretor criado com sucesso!' });
    } catch (error) {
      console.error('Erro no registro do corretor:', error);
      return res.status(500).json({ error: 'Ocorreu um erro inesperado no servidor.' });
    }
  }

  async login(req: ExpressRequestBroker, res: ExpressResponseBroker) {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: 'Email e senha são obrigatórios.' });
    }
    try {
      const [rows] = await connectionBroker.query('SELECT id, name, email, creci, password_hash FROM brokers WHERE email = ?', [email]);
      const brokers = rows as any[];
      if (brokers.length === 0) {
        return res.status(401).json({ error: 'Credenciais inválidas.' });
      }
      const broker = brokers[0];
      const isPasswordCorrect = await bcryptBroker.compare(password, broker.password_hash);
      if (!isPasswordCorrect) {
        return res.status(401).json({ error: 'Credenciais inválidas.' });
      }
      const token = jwtBroker.sign(
        { id: broker.id, role: 'broker' },
        process.env.JWT_SECRET || 'default_secret',
        { expiresIn: '1d' }
      );
      delete broker.password_hash;
      return res.status(200).json({ broker, token });
    } catch (error) {
      console.error('Erro no login do corretor:', error);
      return res.status(500).json({ error: 'Ocorreu um erro inesperado no servidor.' });
    }
  }
}
export const brokerController = new BrokerController();