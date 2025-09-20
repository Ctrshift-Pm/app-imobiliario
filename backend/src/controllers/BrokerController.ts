import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import connection from '../database/connection';
import AuthRequest from '../middlewares/auth';

class BrokerController {
  async register(req: Request, res: Response) {
  const { name, email, password, creci, phone, address, city, state } = req.body;
  
  try {
    // 1. Criar usuário primeiro
    const password_hash = await bcrypt.hash(password, 8);
    const [userResult] = await connection.query(
      'INSERT INTO users (name, email, password_hash, phone, address, city, state) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [name, email, password_hash, phone, address, city, state]
    );
    
    const userId = (userResult as any).insertId;

    // 2. Criar broker com o MESMO ID
    await connection.query(
      'INSERT INTO brokers (id, creci, status) VALUES (?, ?, ?)',
      [userId, creci, 'pending_verification']
    );

    return res.status(201).json({ message: 'Corretor registrado com sucesso!' });
  } catch (error) {
    console.error('Erro no registro do corretor:', error);
    return res.status(500).json({ error: 'Erro interno do servidor.' });
  }
}
  async login(req: Request, res: Response) {
  const { email, password } = req.body;
  
  try {
    // 1. Primeiro buscar o usuário na tabela users
    const [userRows] = await connection.query(
      `SELECT users.id, users.name, users.email, users.password_hash, brokers.creci 
       FROM users 
       LEFT JOIN brokers ON users.id = brokers.id 
       WHERE users.email = ?`,
      [email]
    );

    const users = userRows as any[];
    if (users.length === 0) {
      return res.status(401).json({ error: 'Credenciais inválidas.' });
    }

    const user = users[0];

    // 2. Verificar se é realmente um corretor
    if (!user.creci) {
      return res.status(401).json({ error: 'Este usuário não é um corretor.' });
    }

    // 3. Verificar senha
    const isPasswordCorrect = await bcrypt.compare(password, user.password_hash);
    if (!isPasswordCorrect) {
      return res.status(401).json({ error: 'Credenciais inválidas.' });
    }

    // 4. Gerar token
    const token = jwt.sign(
      { id: user.id, role: 'broker' },
      process.env.JWT_SECRET || 'default_secret',
      { expiresIn: '1d' }
    );

    // 5. Retornar dados (sem password_hash)
    const { password_hash, ...userWithoutPassword } = user;
    return res.json({ broker: userWithoutPassword, token });

  } catch (error) {
    console.error('Erro no login do corretor:', error);
    return res.status(500).json({ error: 'Erro interno do servidor.' });
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

        return res.json({
          success: true,
          data: data,
          total: total,
          page: page,
          totalPages: Math.ceil(total / limit)
        });

    } catch (error) {
        console.error(`Erro ao buscar imóveis do corretor:`, error);
        return res.status(500).json({ 
          success: false,
          error: 'Ocorreu um erro inesperado no servidor.' 
        });
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
      
      // CORREÇÃO: Padronizar formato de resposta
      return res.json({
        success: true,
        data: commissions
      });
    } catch (error) {
      console.error('Erro ao buscar comissões:', error);
      return res.status(500).json({ 
        success: false,
        error: 'Ocorreu um erro inesperado no servidor.' 
      });
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

      // CORREÇÃO: Padronizar formato de resposta
      return res.json({
        success: true,
        data: report
      });
    } catch (error) {
      console.error('Erro ao gerar relatório de desempenho:', error);
      return res.status(500).json({ 
        success: false,
        error: 'Ocorreu um erro inesperado no servidor.' 
      });
    }
  }

  // BrokerController.ts - Mantenha apenas uploadVerificationDocs
async uploadVerificationDocs(req: AuthRequest, res: Response) {
  const brokerId = req.userId;

  if (!brokerId) {
    return res.status(401).json({ 
      success: false,
      error: 'Corretor não autenticado.' 
    });
  }

  const files = req.files as { [fieldname: string]: Express.Multer.File[] };

  if (!files.creciFront || !files.creciBack || !files.selfie) {
    return res.status(400).json({ 
      success: false,
      error: 'É necessário enviar os três ficheiros.' 
    });
  }
    // NOTA: Num ambiente real, aqui você faria o upload destes ficheiros
    // para um serviço de armazenamento (AWS S3, Firebase Storage, etc.).
    // Por agora, vamos simular os URLs com base no caminho local.
  const creciFrontUrl = `/uploads/docs/${files.creciFront[0].filename}`;
  const creciBackUrl = `/uploads/docs/${files.creciBack[0].filename}`;
  const selfieUrl = `/uploads/docs/${files.selfie[0].filename}`;

  try {
    const query = `
      INSERT INTO broker_documents (broker_id, creci_front_url, creci_back_url, selfie_url)
      VALUES (?, ?, ?, ?)
      ON DUPLICATE KEY UPDATE
        creci_front_url = VALUES(creci_front_url),
        creci_back_url = VALUES(creci_back_url),
        selfie_url = VALUES(selfie_url),
        status = 'pending';
    `;
    
    await connection.query(query, [brokerId, creciFrontUrl, creciBackUrl, selfieUrl]);

    return res.status(201).json({ 
      success: true,
      message: 'Documentos enviados para análise com sucesso!' 
    });

  } catch (error) {
    console.error('Erro ao guardar documentos de verificação:', error);
    return res.status(500).json({ 
      success: false,
      error: 'Ocorreu um erro inesperado no servidor.' 
    });
  }
}
  async saveDocumentUrls(req: AuthRequest, res: Response) {
  const brokerId = req.userId;
  const { creciFrontUrl, creciBackUrl, selfieUrl } = req.body as {
    creciFrontUrl: string;
    creciBackUrl: string;
    selfieUrl: string;
  };

  if (!brokerId) {
    return res.status(401).json({ 
      success: false,
      error: 'Corretor não autenticado.' 
    });
  }

  try {
    const query = `
      INSERT INTO broker_documents 
        (broker_id, creci_front_url, creci_back_url, selfie_url, status)
      VALUES (?, ?, ?, ?, 'pending')
      ON DUPLICATE KEY UPDATE
        creci_front_url = VALUES(creci_front_url),
        creci_back_url = VALUES(creci_back_url),
        selfie_url = VALUES(selfie_url),
        status = 'pending',
        updated_at = CURRENT_TIMESTAMP
    `;
    
    await connection.query(query, [brokerId, creciFrontUrl, creciBackUrl, selfieUrl]);

    return res.status(200).json({ 
      success: true,
      message: 'URLs dos documentos salvas com sucesso!' 
    });
  } catch (error) {
    console.error('Erro ao salvar URLs dos documentos:', error);
    return res.status(500).json({ 
      success: false,
      error: 'Ocorreu um erro inesperado no servidor.' 
    });
  }
}
}

export const brokerController = new BrokerController();