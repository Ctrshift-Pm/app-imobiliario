import { Request, Response } from 'express';
import connection from '../database/connection';
import { uploadToCloudinary } from '../config/cloudinary';
import AuthRequest from '../middlewares/auth';

// Interface para tipar os arquivos do Multer
interface MulterFiles {
  [fieldname: string]: Express.Multer.File[];
}

interface AuthRequestWithFiles extends AuthRequest {
  files?: MulterFiles;
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
 
  // propertyController.ts - create method
 async create(req: AuthRequestWithFiles, res: Response) {
    try {
      const brokerId = req.userId;
      const {
        title, description, type, purpose, price,
        address, city, state, bedrooms, bathrooms,
        area, garage_spots, has_wifi
      } = req.body;

      // Verifica se é corretor verificado
      const [brokerRows] = await connection.query(
        'SELECT status FROM brokers WHERE id = ?',
        [brokerId]
      ) as any[];
      
      if (brokerRows.length === 0 || brokerRows[0].status !== 'verified') {
        return res.status(403).json({ 
          error: 'Apenas corretores verificados podem criar imóveis.' 
        });
      }

      // Upload de imagens
      const imageUrls: string[] = [];
      if (req.files && req.files['images']) {
        for (const file of req.files['images']) {
          const result = await uploadToCloudinary(file, 'properties');
          imageUrls.push(result.url);
        }
      }

      // Upload de vídeo (se existir)
      let videoUrl = null;
      if (req.files && req.files['video'] && req.files['video'][0]) {
        const result = await uploadToCloudinary(req.files['video'][0], 'videos');
        videoUrl = result.url;
      }

      // Insere propriedade no banco
      const [result] = await connection.query(
        `INSERT INTO properties 
         (title, description, type, purpose, price, address,
          city, state, bedrooms, bathrooms, area, garage_spots,
          has_wifi, broker_id, video_url)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [title, description, type, purpose, price, address,
         city, state, bedrooms, bathrooms, area, garage_spots,
         has_wifi, brokerId, videoUrl]
      ) as any;

      const propertyId = result.insertId;

      // Insere imagens
      if (imageUrls.length > 0) {
        const imageValues = imageUrls.map(url => [propertyId, url]);
        await connection.query(
          `INSERT INTO property_images (property_id, image_url) 
           VALUES ?`,
          [imageValues]
        );
      }

      res.status(201).json({
        message: 'Imóvel criado com sucesso!',
        propertyId,
        images: imageUrls.length,
        video: !!videoUrl
      });

    } catch (error) {
      console.error('Erro ao criar imóvel:', error);
      res.status(500).json({ error: 'Erro interno do servidor.' });
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
  
  async getAvailableCities(req: Request, res: Response) {
    try {
      const query = `
        SELECT DISTINCT city 
        FROM properties 
        WHERE city IS NOT NULL AND city != '' 
        ORDER BY city ASC;
      `;
      
      const [rows] = await connection.query(query);
      
      // O resultado da query é uma lista de objetos: [{ city: 'Goiânia' }, { city: 'São Paulo' }]
      // Nós precisamos de extrair apenas os nomes das cidades para uma lista simples.
      const cities = (rows as any[]).map(row => row.city);

      return res.status(200).json(cities);

    } catch (error) {
      console.error('Erro ao buscar cidades disponíveis:', error);
      return res.status(500).json({ error: 'Ocorreu um erro inesperado no servidor.' });
    }
  }
  
  async addFavorite(req: AuthRequest, res: Response) {
    const userId = req.userId;
    const { id: propertyId } = req.params;

    if (!userId) {
      return res.status(401).json({ error: 'Usuário não autenticado.' });
    }

    try {
      // Verifica se o imóvel existe
      const [propertyRows] = await connection.query('SELECT id FROM properties WHERE id = ?', [propertyId]);
      const properties = propertyRows as any[];
      
      if (properties.length === 0) {
        return res.status(404).json({ error: 'Imóvel não encontrado.' });
      }

      // Verifica se já é favorito
      const [favoriteRows] = await connection.query(
        'SELECT * FROM favoritos WHERE usuario_id = ? AND imovel_id = ?',
        [userId, propertyId]
      );
      const favorites = favoriteRows as any[];
      
      if (favorites.length > 0) {
        return res.status(409).json({ error: 'Este imóvel já está nos seus favoritos.' });
      }

      // Adiciona aos favoritos
      const query = 'INSERT INTO favoritos (usuario_id, imovel_id) VALUES (?, ?)';
      await connection.query(query, [userId, propertyId]);
      
      return res.status(201).json({ message: 'Imóvel adicionado aos favoritos.' });
    } catch (error: any) {
      console.error('Erro ao adicionar favorito:', error);
      return res.status(500).json({ error: 'Ocorreu um erro no servidor.' });
    }
  }

  async removeFavorite(req: AuthRequest, res: Response) {
    const userId = req.userId;
    const { id: propertyId } = req.params;

    if (!userId) {
      return res.status(401).json({ error: 'Usuário não autenticado.' });
    }

    try {
      const query = 'DELETE FROM favoritos WHERE usuario_id = ? AND imovel_id = ?';
      const [result] = await connection.query(query, [userId, propertyId]);

      if ((result as any).affectedRows === 0) {
        return res.status(404).json({ error: 'Favorito não encontrado.' });
      }

      return res.status(200).json({ message: 'Imóvel removido dos favoritos.' });
    } catch (error) {
      console.error('Erro ao remover favorito:', error);
      return res.status(500).json({ error: 'Ocorreu um erro no servidor.' });
    }
  }

  async listUserFavorites(req: AuthRequest, res: Response) {
    const userId = req.userId;

    if (!userId) {
      return res.status(401).json({ error: 'Usuário não autenticado.' });
    }

    try {
      // Query corrigida para usar a tabela favoritos com os nomes corretos das colunas
      const query = `
        SELECT p.* FROM properties p
        JOIN favoritos f ON p.id = f.imovel_id
        WHERE f.usuario_id = ?;
      `;
      const [rows] = await connection.query(query, [userId]);
      return res.status(200).json(rows);
    } catch (error) {
      console.error('Erro ao listar favoritos:', error);
      return res.status(500).json({ error: 'Ocorreu um erro no servidor.' });
    }
  }
// PropertyController.ts
async listPublicProperties(req: Request, res: Response) {
    try {
      const {
        page = 1,
        limit = 20,
        type,
        purpose,
        city,
        minPrice,
        maxPrice,
        bedrooms
      } = req.query;

      const offset = (Number(page) - 1) * Number(limit);
      const whereClauses: string[] = ["p.status = 'Disponível'"];
      const queryParams: any[] = [];

      // Constrói filtros
      if (type) {
        whereClauses.push('p.type = ?');
        queryParams.push(type);
      }
      if (purpose) {
        whereClauses.push('p.purpose = ?');
        queryParams.push(purpose);
      }
      if (city) {
        whereClauses.push('p.city LIKE ?');
        queryParams.push(`%${city}%`);
      }
      if (minPrice) {
        whereClauses.push('p.price >= ?');
        queryParams.push(parseFloat(minPrice as string));
      }
      if (maxPrice) {
        whereClauses.push('p.price <= ?');
        queryParams.push(parseFloat(maxPrice as string));
      }
      if (bedrooms) {
        whereClauses.push('p.bedrooms >= ?');
        queryParams.push(parseInt(bedrooms as string));
      }

      const whereStatement = whereClauses.length > 0 
        ? `WHERE ${whereClauses.join(' AND ')}` 
        : '';

      // Query principal
      const [properties] = await connection.query(`
        SELECT 
          p.*,
          u.name as broker_name,
          u.phone as broker_phone,
          GROUP_CONCAT(pi.image_url) as images
        FROM properties p
        LEFT JOIN users u ON p.broker_id = u.id
        LEFT JOIN property_images pi ON p.id = pi.property_id
        ${whereStatement}
        GROUP BY p.id
        ORDER BY p.created_at DESC
        LIMIT ? OFFSET ?
      `, [...queryParams, Number(limit), offset]) as any[];

      // Contagem total para paginação
      const [totalResult] = await connection.query(`
        SELECT COUNT(*) as total 
        FROM properties p
        ${whereStatement}
      `, queryParams) as any[];

      // Processa imagens
      const processedProperties = properties.map((prop: any) => ({
        ...prop,
        images: prop.images ? prop.images.split(',') : [],
        price: parseFloat(prop.price)
      }));

      res.json({
        properties: processedProperties,
        total: totalResult[0].total,
        page: Number(page),
        totalPages: Math.ceil(totalResult[0].total / Number(limit))
      });

    } catch (error) {
      console.error('Erro ao listar imóveis:', error);
      res.status(500).json({ error: 'Erro interno do servidor.' });
    }
  }
}

export const propertyController = new PropertyController();