import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// 로컬 dev: /api/queue → 대기열 서버(8081), 나머지 /api → 백엔드(8080)
export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      '/api/queue': 'http://localhost:8081',
      '/api': 'http://localhost:8080',
    },
  },
})
