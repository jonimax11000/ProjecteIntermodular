export interface Video {
  id: string;
  duracio: number;
  thumbnail: string;
  videoUrl: string;
  width: number;
  height: number;
  fps: number;
  bitrate: number;
  codec: string;
  fileSize: number;
  createdAt: string;
}