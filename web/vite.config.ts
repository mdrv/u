import { sveltekit } from '@sveltejs/kit/vite'
import { defineConfig } from 'vite'

export default defineConfig({
  plugins: [sveltekit()],
  server: {
    port: 3000,
    strictPort: false,
    watch: {
      ignored: ['**/node_modules/**', '**/.svelte-kit/**']
    }
  }
})
