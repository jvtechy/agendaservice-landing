/**
 * Gera PNGs anonimizados (blur em nomes/endereços) para a landing page.
 * Uso: node scripts/anonymize-screenshots.mjs
 */
import sharp from 'sharp';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __dirname = dirname(fileURLToPath(import.meta.url));
const assetsDir = join(__dirname, '..', 'assets');

/** Região em percentual: { left, top, width, height } */
async function blurRegions(inputPath, outputPath, regions, imgW, imgH) {
  let image = sharp(inputPath);
  const composites = [];

  for (const r of regions) {
    const left = Math.round((r.left / 100) * imgW);
    const top = Math.round((r.top / 100) * imgH);
    const width = Math.max(1, Math.round((r.width / 100) * imgW));
    const height = Math.max(1, Math.round((r.height / 100) * imgH));

    const patch = await sharp(inputPath)
      .extract({ left, top, width, height })
      .blur(22)
      .toBuffer();

    composites.push({ input: patch, left, top });
  }

  await image.composite(composites).png({ quality: 90 }).toFile(outputPath);
  console.log('OK:', outputPath);
}

const clienteRegions = [
  { left: 68, top: 1.5, width: 22, height: 5.5 },
  { left: 90, top: 1, width: 8, height: 6 },
  { left: 58, top: 18, width: 38, height: 3.5 },
  { left: 28, top: 27, width: 32, height: 5 },
  { left: 58, top: 41, width: 38, height: 3.5 },
  { left: 28, top: 49.5, width: 34, height: 5 },
  { left: 28, top: 73, width: 34, height: 5 },
];

const prestadorRegions = [
  { left: 88, top: 1, width: 10, height: 6.5 },
  { left: 17, top: 27, width: 72, height: 9 },
  { left: 4, top: 55.5, width: 26, height: 6 },
  { left: 17, top: 66, width: 74, height: 10 },
  { left: 4, top: 84, width: 26, height: 6 },
];

const clienteMeta = await sharp(join(assetsDir, 'iamagem_cliente.png')).metadata();
const prestadorMeta = await sharp(join(assetsDir, 'iamagem_prestador.png')).metadata();

await blurRegions(
  join(assetsDir, 'iamagem_cliente.png'),
  join(assetsDir, 'screenshot-cliente.png'),
  clienteRegions,
  clienteMeta.width,
  clienteMeta.height
);

await blurRegions(
  join(assetsDir, 'iamagem_prestador.png'),
  join(assetsDir, 'screenshot-prestador.png'),
  prestadorRegions,
  prestadorMeta.width,
  prestadorMeta.height
);
