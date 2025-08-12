import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import connection from '../database/connection';
import AuthRequest from '../middlewares/auth';

class BrokerController {
  async register(req: Request, res: Response) {
    const { name, email, password, creci, address, city, state } = req.body;
    if (!name || !email || !password || !creci) {
      return res.status(400).json({ error: 'Nome, email, senha e CRECI são obrigatórios.' });
    }
    try {
      const [existingBroker] = await connection.query('SELECT id FROM brokers WHERE email = ? OR creci = ?', [email, creci]);
      if (Array.isArray(existingBroker) && existingBroker.length > 0) {
        return res.status(400).json({ error: 'Este e-mail ou CRECI já está em uso.' });
      }
      const password_hash = await bcrypt.hash(password, 8);
      const insertQuery = `
        INSERT INTO brokers (name, email, password_hash, creci, address, city, state)
        VALUES (?, ?, ?, ?, ?, ?, ?);
      `;
      await connection.query(insertQuery, [name, email, password_hash, creci, address, city, state]);
      return res.status(201).json({ message: 'Corretor criado com sucesso!' });
    } catch (error) {
      console.error('Erro no registro do corretor:', error);
      return res.status(500).json({ error: 'Ocorreu um erro inesperado no servidor.' });
    }
  }

  async login(req: Request, res: Response) {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: 'Email e senha são obrigatórios.' });
    }
    try {
      const [rows] = await connection.query('SELECT id, name, email, creci, password_hash FROM brokers WHERE email = ?', [email]);
      const brokers = rows as any[];
      if (brokers.length === 0) {
        return res.status(401).json({ error: 'Credenciais inválidas.' });
      }
      const broker = brokers[0];
      const isPasswordCorrect = await bcrypt.compare(password, broker.password_hash);
      if (!isPasswordCorrect) {
        return res.status(401).json({ error: 'Credenciais inválidas.' });
      }
      const token = jwt.sign(
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
  
  async getMyProperties(req: AuthRequest, res: Response) {
    const brokerId = req.userId; 

    try {
        const page = parseInt(req.query.page as string) || 1;
        const limit = parseInt(req.query.limit as string) || 10;
        const offset = (page - 1) * limit;

        const countQuery = `SELECT COUNT(*) as total FROM properties WHERE broker_id = ?`;
        const [totalResult] = await connection.query(countQuery, [brokerId]);
        const total = (totalResult as any[])[0].total;

        const dataQuery = `SELECT * FROM properties WHERE broker_id = ? ORDER BY created_at DESC LIMIT ? OFFSET ?`;
        const [data] = await connection.query(dataQuery, [brokerId, limit, offset]);

        return res.json({ data, total });

    } catch (error) {
        console.error(`Erro ao buscar imóveis do corretor:`, error);
        return res.status(500).json({ error: 'Ocorreu um erro inesperado no servidor.' });
    }
  }
  async getMyCommissions(req: AuthRequest, res: Response) {
    const brokerId = req.userId;
    try {
      const query = `
        SELECT s.id, p.title, s.sale_price, s.commission_rate, s.commission_amount, s.sale_date 
        FROM sales s
        JOIN properties p ON s.property_id = p.id
        WHERE s.broker_id = ?
        ORDER BY s.sale_date DESC
      `;
      const [commissions] = await connection.query(query, [brokerId]);
      return res.json(commissions);
    } catch (error) {
      console.error('Erro ao buscar comissões:', error);
      return res.status(500).json({ error: 'Ocorreu um erro inesperado no servidor.' });
    }
  }

  async getMyPerformanceReport(req: AuthRequest, res: Response) {
    const brokerId = req.userId;
    try {
      // Total de vendas e comissão
      const salesQuery = `
        SELECT COUNT(*) as total_sales, SUM(commission_amount) as total_commission 
        FROM sales 
        WHERE broker_id = ?
      `;
      const [salesResult] = await connection.query(salesQuery, [brokerId]);

      // Total de imóveis cadastrados
      const propertiesQuery = `SELECT COUNT(*) as total_properties FROM properties WHERE broker_id = ?`;
      const [propertiesResult] = await connection.query(propertiesQuery, [brokerId]);
      
      const report = {
        totalSales: (salesResult as any[])[0].total_sales || 0,
        totalCommission: (salesResult as any[])[0].total_commission || 0,
        totalProperties: (propertiesResult as any[])[0].total_properties || 0,
      };

      return res.json(report);
    } catch (error) {
      console.error('Erro ao gerar relatório de desempenho:', error);
      return res.status(500).json({ error: 'Ocorreu um erro inesperado no servidor.' });
    }
  }
}
export const brokerController = new BrokerController();
