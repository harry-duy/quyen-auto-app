import { useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { useForm } from 'react-hook-form'
import { toast } from 'react-toastify'
import apiClient from '../api/client'

interface LoginForm {
  phone: string
  password: string
}

export default function LoginPage() {
  const navigate = useNavigate()
  const { register, handleSubmit, formState: { isSubmitting } } = useForm<LoginForm>()

  useEffect(() => {
    if (localStorage.getItem('token')) navigate('/parts', { replace: true })
  }, [navigate])

  const onSubmit = async (data: LoginForm) => {
    try {
      const res = await apiClient.post<{ data: { accessToken: string; user: { role: string } } }>('/auth/login', data)
      localStorage.setItem('token', res.data.data.accessToken)
      localStorage.setItem('role', res.data.data.user.role)
      navigate('/parts', { replace: true })
    } catch {
      toast.error('Sai số điện thoại hoặc mật khẩu')
    }
  }

  return (
    <div className="min-h-screen bg-gray-100 flex items-center justify-center">
      <div className="bg-white rounded-2xl shadow-lg p-8 w-full max-w-sm">
        <h1 className="text-2xl font-bold text-center text-gray-800 mb-1">Quyen Auto</h1>
        <p className="text-center text-gray-500 text-sm mb-6">Đăng nhập quản lý phụ tùng</p>
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Số điện thoại
            </label>
            <input
              {...register('phone', { required: true })}
              type="text"
              placeholder="Nhập số điện thoại"
              className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Mật khẩu
            </label>
            <input
              {...register('password', { required: true })}
              type="password"
              placeholder="Nhập mật khẩu"
              className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <button
            type="submit"
            disabled={isSubmitting}
            className="w-full bg-blue-600 hover:bg-blue-700 disabled:opacity-60 text-white font-semibold py-2 rounded-lg transition-colors text-sm"
          >
            {isSubmitting ? 'Đang đăng nhập...' : 'Đăng nhập'}
          </button>
        </form>
      </div>
    </div>
  )
}
