export const useWallectApi = () => {
  const config = useRuntimeConfig()
  // Base URL should be the root of the API server (http://localhost:3001)
  const baseUrl = config.public.apiBase || 'http://localhost:3001'

  const fetchApi = async (endpoint: string, options: any = {}) => {
    // Get token from localStorage (Client-side only)
    let token = null
    if (import.meta.client) {
      token = localStorage.getItem('wallect_token')
    }

    try {
      const response = await $fetch(`${baseUrl}/${endpoint}`, {
        ...options,
        headers: {
          'Content-Type': 'application/json',
          ...(token ? { 'Authorization': `Bearer ${token}` } : {}),
          ...options.headers,
        },
      })
      return response
    } catch (error) {
      console.error(`API Error [${endpoint}]:`, error)
      throw error
    }
  }

  return {
    // Core Data
    getWallets: () => fetchApi('wallets'),
    getTransactions: () => fetchApi('transactions'),
    getBudgets: () => fetchApi('budgets'),
    getCategories: () => fetchApi('categories'),
    getDebts: () => fetchApi('debts'),
    
    // Auth & QR
    getMe: () => fetchApi('auth/me'),
    getQrGenerate: () => fetchApi('auth/qr/generate'),
    checkQrStatus: (id: string) => fetchApi(`auth/qr/check/${id}`),
    authorizeQr: (qrId: string) => fetchApi('auth/qr/authorize', { method: 'POST', body: { qrId } }),
    
    // Mutations
    createTransaction: (data: any) => fetchApi('transactions', { method: 'POST', body: data }),
    createWallet: (data: any) => fetchApi('wallets', { method: 'POST', body: data }),
    
    // Low-level fetch
    fetchApi,
  }
}
