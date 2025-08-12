import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import connection from '../database/connection';

class AdminController {
  async login(req: Request, res: Response) {
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

  private async getPaginatedData(req: Request, res: Response, tableName: string, columns: string[], searchColumns: string[]) {
    try {
        const page = parseInt(req.query.page as string) || 1;
        const limit = parseInt(req.query.limit as string) || 10;
        const searchTerm = req.query.search as string || '';
        const searchColumn = req.query.searchColumn as string || 'all';
        const offset = (page - 1) * limit;

        let whereClause = '';
        const searchParams: (string | number)[] = [];

        if (searchTerm) {
            if (searchColumn === 'all') {
                whereClause = 'WHERE ' + searchColumns.map(col => `\`${col}\` LIKE ?`).join(' OR ');
                searchColumns.forEach(() => searchParams.push(`%${searchTerm}%`));
            } else {
                whereClause = `WHERE \`${searchColumn}\` LIKE ?`;
                searchParams.push(`%${searchTerm}%`);
            }
        }

        const countQuery = `SELECT COUNT(*) as total FROM ${tableName} ${whereClause}`;
        const [totalResult] = await connection.query(countQuery, searchParams);
        const total = (totalResult as any[])[0].total;

        const dataQuery = `SELECT ${columns.join(', ')} FROM ${tableName} ${whereClause} ORDER BY id DESC LIMIT ? OFFSET ?`;
        const [data] = await connection.query(dataQuery, [...searchParams, limit, offset]);

        return res.json({ data, total });

    } catch (error) {
        console.error(`Erro ao buscar dados de ${tableName}:`, error);
        return res.status(500).json({ error: 'Ocorreu um erro inesperado no servidor.' });
    }
  }

  getAllUsers = async (req: Request, res: Response) => {
    await this.getPaginatedData(req, res, 'users', ['id', 'name', 'email', 'phone', 'created_at'], ['name', 'email', 'phone']);
  }

  deleteUser = async (req: Request, res: Response) => {
    const { id } = req.params;
    await connection.query('DELETE FROM users WHERE id = ?', [id]);
    return res.status(200).json({ message: 'Utilizador deletado com sucesso.' });
  }

  getAllBrokers = async (req: Request, res: Response) => {
     await this.getPaginatedData(req, res, 'brokers', ['id', 'name', 'email', 'creci', 'created_at'], ['name', 'email', 'creci']);
  }

  deleteBroker = async (req: Request, res: Response) => {
    const { id } = req.params;
    await connection.query('DELETE FROM brokers WHERE id = ?', [id]);
    return res.status(200).json({ message: 'Corretor deletado com sucesso.' });
  }

  deleteProperty = async (req: Request, res: Response) => {
    const { id } = req.params;
    await connection.query('DELETE FROM properties WHERE id = ?', [id]);
    return res.status(200).json({ message: 'Imóvel deletado pelo administrador com sucesso.' });
  }
}
export const adminController = new AdminController();