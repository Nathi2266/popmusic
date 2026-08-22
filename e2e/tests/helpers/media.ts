import { execFileSync } from 'child_process';
import fs from 'fs';
import os from 'os';
import path from 'path';
import sharp from 'sharp';

/** Uptodown feature graphic dimensions. */
export const FEATURE_WIDTH = 1024;
export const FEATURE_HEIGHT = 500;

export function ffmpegBinary(): string {
  const candidates = [
    process.env.FFMPEG_PATH,
    path.join(os.homedir(), 'AppData', 'Local', 'ms-playwright', 'ffmpeg-1011', 'ffmpeg.exe'),
    path.join(os.homedir(), 'AppData', 'Local', 'ms-playwright', 'ffmpeg-1011', 'ffmpeg'),
    'ffmpeg',
  ].filter(Boolean) as string[];

  for (const bin of candidates) {
    if (fs.existsSync(bin)) return bin;
  }
  return 'ffmpeg';
}

/** Convert Playwright webm recording to Uptodown-ready MP4 (H.264). */
export function convertWebmToMp4(webmPath: string, mp4Path: string): void {
  if (!fs.existsSync(webmPath)) {
    throw new Error(`Video source missing: ${webmPath}`);
  }
  fs.mkdirSync(path.dirname(mp4Path), { recursive: true });
  execFileSync(
    ffmpegBinary(),
    [
      '-y',
      '-i',
      webmPath,
      '-c:v',
      'libx264',
      '-preset',
      'fast',
      '-crf',
      '22',
      '-pix_fmt',
      'yuv420p',
      '-movflags',
      '+faststart',
      mp4Path,
    ],
    { stdio: 'pipe' },
  );
}

/** Resize any PNG to exact 1024×500 feature size (cover crop). */
export async function resizeToFeatureSize(srcPath: string, destPath: string): Promise<void> {
  fs.mkdirSync(path.dirname(destPath), { recursive: true });
  await sharp(srcPath)
    .resize(FEATURE_WIDTH, FEATURE_HEIGHT, { fit: 'cover', position: 'centre' })
    .png({ compressionLevel: 6 })
    .toFile(destPath);
}
