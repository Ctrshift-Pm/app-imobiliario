import { Request, Response } from 'express';
import connection from '../database/connection';

interface AuthRequest extends Request {
  userId?: number;
}

class PropertyController {
  async index(req: Request, res: Response) {
    try {
        const page = parseInt(req.query.page as string) || 1;
        const limit = parseInt(req.query.limit as string) || 10;
        const offset = (page - 1) * limit;

        // Parâmetros de filtro
        const { type, purpose, city, minPrice, maxPrice, searchTerm } = req.query;

        let whereClauses: string[] = [];
        const queryParams: (string | number)[] = [];

        if (type) {
            whereClauses.push('type = ?');
            queryParams.push(type as string);
        }
        if (purpose) {
            whereClauses.push('purpose = ?');
            queryParams.push(purpose as string);
        }
        if (city) {
            whereClauses.push('city LIKE ?');
            queryParams.push(`%${city}%`);
        }
        if (minPrice) {
            whereClauses.push('price >= ?');
            queryParams.push(parseFloat(minPrice as string));
        }
        if (maxPrice) {
            whereClauses.push('price <= ?');
            queryParams.push(parseFloat(maxPrice as string));
        }
        if (searchTerm) {
            whereClauses.push('title LIKE ?');
            queryParams.push(`%${searchTerm}%`);
        }

        const whereStatement = whereClauses.length > 0 ? `WHERE ${whereClauses.join(' AND ')}` : '';

        const countQuery = `SELECT COUNT(*) as total FROM properties ${whereStatement}`;
        const [totalResult] = await connection.query(countQuery, queryParams);
        const total = (totalResult as any[])[0].total;

        const dataQuery = `SELECT id, title, type, status, price, address, city, bedrooms, bathrooms, area, garage_spots, has_wifi, broker_id, created_at FROM properties ${whereStatement} ORDER BY created_at DESC LIMIT ? OFFSET ?`;
        const [data] = await connection.query(dataQuery, [...queryParams, limit, offset]);

        return res.json({ data, total });

    } catch (error) {
        console.error('Erro ao listar imóveis:', error);
        return res.status(500).json({ error: 'Ocorreu um erro inesperado no servidor.' });
    }
  }

  async show(req: Request, res: Response) {
    const { id } = req.params;
    try {
      const [rows] = await connection.query('SELECT * FROM properties WHERE id = ?', [id]);
      const properties = rows as any[];

      if (properties.length === 0) {
        return res.status(404).json({ error: 'Imóvel não encontrado.' });
      }
      return res.status(200).json(properties[0]);
    } catch (error) {
      console.error('Erro ao buscar imóvel:', error);
      return res.status(500).json({ error: 'Ocorreu um erro inesperado no servidor.' });
    }
  }
 
  async create(req: AuthRequest, res: Response) {
    const { title, description, type, purpose, price, address, city, state, bedrooms, bathrooms, area } = req.body;
    const broker_id = req.userId;
    if (!title || !price) {
        return res.status(400).json({ error: 'Título e preço são obrigatórios.' });
    }
    const insertQuery = `
      INSERT INTO properties (title, description, type, purpose, price, address, city, state, bedrooms, bathrooms, area, broker_id)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
    `;
    try {
      await connection.query(insertQuery, [title, description, type, purpose, price, address, city, state, bedrooms, bathrooms, area, broker_id]);
      return res.status(201).json({ message: 'Imóvel criado com sucesso!' });
    } catch (error) {
      console.error('Erro ao criar imóvel:', error);
      return res.status(500).json({ error: 'Ocorreu um erro inesperado no servidor.' });
    }
  }

  async update(req: AuthRequest, res: Response) {
    const { id } = req.params;
    const { title, description, type, status, purpose, price, address, city, state, bedrooms, bathrooms, area } = req.body;
    const brokerIdFromToken = req.userId;
    
    try {
      const [propertyRows] = await connection.query('SELECT broker_id FROM properties WHERE id = ?', [id]);
      const properties = propertyRows as any[];
      if (properties.length === 0) {
        return res.status(404).json({ error: 'Imóvel não encontrado.' });
      }
      const property = properties[0];
      if (property.broker_id !== brokerIdFromToken) {
        return res.status(403).json({ error: 'Você não tem permissão para alterar este imóvel.' });
      }
      const updateQuery = `
        UPDATE properties SET title = ?, description = ?, type = ?, status = ?, purpose = ?, price = ?, address = ?, city = ?, state = ?, bedrooms = ?, bathrooms = ?, area = ?
        WHERE id = ?;
      `;
      await connection.query(updateQuery, [title, description, type, status, purpose, price, address, city, state, bedrooms, bathrooms, area, id]);
      return res.status(200).json({ message: 'Imóvel atualizado com sucesso!' });
    } catch (error) {
      console.error('Erro ao atualizar imóvel:', error);
      return res.status(500).json({ error: 'Ocorreu um erro inesperado no servidor.' });
    }
  }

  async updateStatus(req: AuthRequest, res: Response) {
    const { id } = req.params;
    const { status } = req.body;
    const brokerIdFromToken = req.userId;

    if (!status) {
      return res.status(400).json({ error: 'O novo status é obrigatório.' });
    }

    try {
      const [propertyRows] = await connection.query('SELECT broker_id, price FROM properties WHERE id = ?', [id]);
      const properties = propertyRows as any[];
      if (properties.length === 0) {
        return res.status(404).json({ error: 'Imóvel não encontrado.' });
      }
      const property = properties[0];

      if (property.broker_id !== brokerIdFromToken) {
        return res.status(403).json({ error: 'Você não tem permissão para alterar este imóvel.' });
      }

      await connection.query('UPDATE properties SET status = ? WHERE id = ?', [status, id]);

      if (status === 'Vendido') {
        const commissionRate = 5.00; 
        const commissionAmount = property.price * (commissionRate / 100);
        const saleQuery = `
          INSERT INTO sales (property_id, broker_id, sale_price, commission_rate, commission_amount)
          VALUES (?, ?, ?, ?, ?)
        `;
        await connection.query(saleQuery, [id, brokerIdFromToken, property.price, commissionRate, commissionAmount]);
      }

      return res.status(200).json({ message: 'Status do imóvel atualizado com sucesso!' });
    } catch (error) {
      console.error('Erro ao atualizar status do imóvel:', error);
      return res.status(500).json({ error: 'Ocorreu um erro inesperado no servidor.' });
    }
  }

  async delete(req: AuthRequest, res: Response) {
    const { id } = req.params;
    const brokerIdFromToken = req.userId;
    try {
      const [propertyRows] = await connection.query('SELECT broker_id FROM properties WHERE id = ?', [id]);
      const properties = propertyRows as any[];
      if (properties.length === 0) {
        return res.status(404).json({ error: 'Imóvel não encontrado.' });
      }
      const property = properties[0];
      if (property.broker_id !== brokerIdFromToken) {
        return res.status(403).json({ error: 'Você não tem permissão para deletar este imóvel.' });
      }
      await connection.query('DELETE FROM properties WHERE id = ?', [id]);
      return res.status(200).json({ message: 'Imóvel deletado com sucesso!' });
    } catch (error) {
      console.error('Erro ao deletar imóvel:', error);
      return res.status(500).json({ error: 'Ocorreu um erro inesperado no servidor.' });
    }
  }
}

export const propertyController = new PropertyController();