import multer from 'multer';

const storage = multer.memoryStorage();
export const upload = multer({
  storage,
  limits: {
    fileSize: 20 * 1024 * 1024, // 20MB por arquivo
    files: 21, // 20 imagens + 1 vídeo
  },
  fileFilter: (req, file, cb) => {
    const allowedImages = /jpeg|jpg|png|gif|webp/;
    const allowedVideos = /mp4|mov|avi|webm/;
    
    if (file.fieldname === 'images') {
      if (allowedImages.test(file.mimetype)) {
        cb(null, true);
      } else {
        cb(new Error('Tipo de imagem não suportado'));
      }
    } else if (file.fieldname === 'video') {
      if (allowedVideos.test(file.mimetype)) {
        cb(null, true);
      } else {
        cb(new Error('Tipo de vídeo não suportado'));
      }
    } else {
      cb(new Error('Campo de upload inválido'));
    }
  },
});