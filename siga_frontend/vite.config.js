import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  optimizeDeps: {
    include: ['html5-qrcode']
  },
  server: {
    watch: {
      usePolling: true,
    },
    host: true, // needed for docker
    proxy: {
      '/api': {
        target: 'http://localhost:8000',
        changeOrigin: true
      },
      '/auth': {
        target: 'http://localhost:8000',
        changeOrigin: true
      },
      '/core': {
        target: 'http://localhost:8000',
        changeOrigin: true
      },
      '/ws': {
        target: 'http://localhost:8000',
        changeOrigin: true,
        ws: true
      }
    }
  }
})
