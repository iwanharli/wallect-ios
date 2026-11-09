export const useAuth = () => {
  const isAuthenticated = useState('auth_status', () => false)
  const user = useState('auth_user', () => null)
  const api = useWallectApi()
  const router = useRouter()

  const checkAuth = async () => {
    if (!import.meta.client) return
    
    const token = localStorage.getItem('wallect_token')
    if (!token) {
      isAuthenticated.value = false
      user.value = null
      return
    }

    try {
      const userData = await api.getMe()
      user.value = userData
      isAuthenticated.value = true
    } catch (e) {
      console.error('Auth verification failed:', e)
      logout()
    }
  }

  const login = (token: string, userData: any) => {
    if (!import.meta.client) return
    localStorage.setItem('wallect_token', token)
    user.value = userData
    isAuthenticated.value = true
    router.push('/')
  }

  const logout = () => {
    if (!import.meta.client) return
    localStorage.removeItem('wallect_token')
    user.value = null
    isAuthenticated.value = false
    router.push('/login')
  }

  return {
    isAuthenticated,
    user,
    checkAuth,
    login,
    logout
  }
}
