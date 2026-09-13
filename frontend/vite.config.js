import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue2';
import path from 'path';

// 构建产物输出到 Spring Boot 静态资源目录的 vue/ 子目录
// 访问入口: http://localhost:8080/vue/
export default defineConfig({
  plugins: [vue()],
  base: '/',
  resolve: {
    alias: {
      '@': path.resolve(__dirname, 'src')
    }
  },
  server: {
    port: 5173,
    proxy: {
      // 开发模式代理后端 API
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true
      },
      '/ai': {
        target: 'http://localhost:8080',
        changeOrigin: true
      },
      '/animals': {
        target: 'http://localhost:8080',
        changeOrigin: true
      },
      '/FishSpecies': {
        target: 'http://localhost:8080',
        changeOrigin: true
      },
      '/WhaleSpecies': {
        target: 'http://localhost:8080',
        changeOrigin: true
      },
      '/invertebrate': {
        target: 'http://localhost:8080',
        changeOrigin: true
      }
    }
  },
  build: {
    outDir: path.resolve(__dirname, 'dist'),
    emptyOutDir: true,
    assetsDir: 'assets',
    rollupOptions: {
      // 后端 Spring Boot 提供的静态资源（/images、/js）不参与打包，运行时由后端提供
      external: [/^\/images\//, /^\/js\//],
      output: {
        // 统一资源前缀
        assetFileNames: 'assets/[name].[hash][extname]',
        chunkFileNames: 'assets/[name].[hash].js',
        entryFileNames: 'assets/[name].[hash].js'
      }
    }
  }
});
