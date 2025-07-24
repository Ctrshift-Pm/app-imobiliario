import { Request as ExpressRequestProperty, Response as ExpressResponseProperty } from 'express';
import connectionProperty from '../database/connection';

interface AuthRequestProperty extends ExpressRequestProperty {
  userId?: number;
}

class PropertyController {
  async index(req: ExpressRequestProperty, res: ExpressResponseProperty) {
    try {
      const [properties] = await connectionProperty.query('SELECT * FROM properties ORDER BY created_at DESC');
      return res.status(200).json(properties);
    } catch (error) {
      console.error('Erro ao listar imóveis:', error);
      return res.status(500).json({ error: 'Ocorreu um erro inesperado no servidor.' });
    }
  }

  async show(req: ExpressRequestProperty, res: ExpressResponseProperty) {
    const { id } = req.params;
    try {
      const [rows] = await connectionProperty.query('SELECT * FROM properties WHERE id = ?', [id]);
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
 
  async create(req: AuthRequestProperty, res: ExpressResponseProperty) {
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
      await connectionProperty.query(insertQuery, [title, description, type, purpose, price, address, city, state, bedrooms, bathrooms, area, broker_id]);
      return res.status(201).json({ message: 'Imóvel criado com sucesso!' });
    } catch (error) {
      console.error('Erro ao criar imóvel:', error);
      return res.status(500).json({ error: 'Ocorreu um erro inesperado no servidor.' });
    }
  }

  async update(req: AuthRequestProperty, res: ExpressResponseProperty) {
    const { id } = req.params;
    const { title, description, type, status, purpose, price, address, city, state, bedrooms, bathrooms, area } = req.body;
    const brokerIdFromToken = req.userId;
    
    try {
      const [propertyRows] = await connectionProperty.query('SELECT broker_id FROM properties WHERE id = ?', [id]);
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
      await connectionProperty.query(updateQuery, [title, description, type, status, purpose, price, address, city, state, bedrooms, bathrooms, area, id]);
      return res.status(200).json({ message: 'Imóvel atualizado com sucesso!' });
    } catch (error) {
      console.error('Erro ao atualizar imóvel:', error);
      return res.status(500).json({ error: 'Ocorreu um erro inesperado no servidor.' });
    }
  }

  async delete(req: AuthRequestProperty, res: ExpressResponseProperty) {
    const { id } = req.params;
    const brokerIdFromToken = req.userId;
    try {
      const [propertyRows] = await connectionProperty.query('SELECT broker_id FROM properties WHERE id = ?', [id]);
      const properties = propertyRows as any[];
      if (properties.length === 0) {
        return res.status(404).json({ error: 'Imóvel não encontrado.' });
      }
      const property = properties[0];
      if (property.broker_id !== brokerIdFromToken) {
        return res.status(403).json({ error: 'Você não tem permissão para deletar este imóvel.' });
      }
      await connectionProperty.query('DELETE FROM properties WHERE id = ?', [id]);
      return res.status(200).json({ message: 'Imóvel deletado com sucesso!' });
    } catch (error) {
      console.error('Erro ao deletar imóvel:', error);
      return res.status(500).json({ error: 'Ocorreu um erro inesperado no servidor.' });
    }
  }
}
export const propertyController = new PropertyController();