import { useNavigate } from 'react-router-dom'

export function useAuth() {
  const navigate = useNavigate()

  const token = localStorage.getItem('token')
  const role = localStorage.getItem('role')
  const isAuthenticated = !!token
  const canDelete = role === 'MANAGER' || role === 'ADMIN'

  const logout = () => {
    localStorage.removeItem('token')
    localStorage.removeItem('role')
    navigate('/login')
  }

  return { isAuthenticated, token, role, canDelete, logout }
}
