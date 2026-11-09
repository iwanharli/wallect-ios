// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2024-04-03',
  devtools: { enabled: true },
  
  css: [
    '~/assets/css/main.css'
  ],

  app: {
    head: {
      title: 'Wallect - Premium Personal Finance',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { name: 'description', content: 'Wallect: Managed Your Wealth with Purity Luxe' }
      ],
      link: [
        { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' },
        { rel: 'preconnect', href: 'https://fonts.googleapis.com' },
        { rel: 'preconnect', href: 'https://fonts.gstatic.com', crossorigin: '' },
        { rel: 'stylesheet', href: 'https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap' },
        { rel: 'stylesheet', href: 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css' }
      ],
      script: [
        { src: 'https://accounts.google.com/gsi/client', async: true, defer: true }
      ]
    },
    pageTransition: { name: 'page', mode: 'out-in' }
  },

  runtimeConfig: {
    public: {
      apiBase: 'http://localhost:3001'
    }
  },

  ssr: true,
  
  features: {
    inlineStyles: false
  }
})
