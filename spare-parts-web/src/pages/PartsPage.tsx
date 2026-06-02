import { useState, useEffect } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { toast } from 'react-toastify'
import { CATEGORIES, type SparePartResponse } from '../types'
import { partsApi } from '../api/parts'
import { useAuth } from '../hooks/useAuth'
import PartTable from '../components/PartTable'
import PartModal from '../components/PartModal'
import QrModal from '../components/QrModal'

const PAGE_SIZE = 20

export default function PartsPage() {
  const { logout, canDelete } = useAuth()
  const queryClient = useQueryClient()

  const [keyword, setKeyword] = useState('')
  const [debouncedKeyword, setDebouncedKeyword] = useState('')
  const [category, setCategory] = useState('')
  const [page, setPage] = useState(0)
  const [showPartModal, setShowPartModal] = useState(false)
  const [editingPart, setEditingPart] = useState<SparePartResponse | null>(null)
  const [qrPart, setQrPart] = useState<SparePartResponse | null>(null)

  // Debounce keyword 400ms
  useEffect(() => {
    const timer = setTimeout(() => setDebouncedKeyword(keyword), 400)
    return () => clearTimeout(timer)
  }, [keyword])

  const handleKeywordChange = (value: string) => {
    setKeyword(value)
    setPage(0)
  }

  const queryKey = ['parts', debouncedKeyword, category, page]

  const { data, isLoading } = useQuery({
    queryKey,
    queryFn: () =>
      partsApi.getAll({ keyword: debouncedKeyword || undefined, category: category || undefined, page, size: PAGE_SIZE })
        .then((r) => r.data.data),
  })

  const deleteMutation = useMutation({
    mutationFn: (id: number) => partsApi.delete(id),
    onSuccess: () => {
      toast.success('Đã xoá phụ tùng')
      void queryClient.invalidateQueries({ queryKey: ['parts'] })
    },
    onError: () => toast.error('Xoá thất bại'),
  })

  const handleDelete = (part: SparePartResponse) => {
    if (window.confirm(`Xoá phụ tùng "${part.name}"?`)) {
      deleteMutation.mutate(part.id)
    }
  }

  const handleEdit = (part: SparePartResponse) => {
    setEditingPart(part)
    setShowPartModal(true)
  }

  const handleAddNew = () => {
    setEditingPart(null)
    setShowPartModal(true)
  }

  const handleModalClose = () => {
    setShowPartModal(false)
    setEditingPart(null)
  }

  const handleExportExcel = async () => {
    try {
      const res = await partsApi.exportExcel()
      const url = URL.createObjectURL(res.data as Blob)
      const a = document.createElement('a')
      a.href = url
      a.download = 'spare-parts.xlsx'
      a.click()
      URL.revokeObjectURL(url)
    } catch {
      toast.error('Xuất Excel thất bại')
    }
  }

  const parts = data?.content ?? []
  const totalPages = data?.totalPages ?? 0

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white border-b border-gray-200 px-6 py-4 flex items-center justify-between">
        <h1 className="text-xl font-bold text-gray-800">Quản lý phụ tùng xe</h1>
        <button
          onClick={logout}
          className="text-sm text-gray-500 hover:text-gray-700"
        >
          Đăng xuất
        </button>
      </header>

      <main className="max-w-7xl mx-auto px-6 py-6 space-y-4">
        {/* Toolbar */}
        <div className="flex flex-wrap gap-3 items-center justify-between">
          <div className="flex gap-3 flex-wrap">
            <input
              type="text"
              placeholder="Tìm theo tên, mã, hãng..."
              value={keyword}
              onChange={(e) => handleKeywordChange(e.target.value)}
              className="border border-gray-300 rounded-lg px-3 py-2 text-sm w-64 focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
            <select
              value={category}
              onChange={(e) => { setCategory(e.target.value); setPage(0) }}
              className="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="">Tất cả danh mục</option>
              {CATEGORIES.map((c) => (
                <option key={c} value={c}>{c}</option>
              ))}
            </select>
          </div>
          <div className="flex gap-2">
            <button
              onClick={handleExportExcel}
              className="border border-gray-300 bg-white hover:bg-gray-50 text-gray-700 text-sm font-medium px-4 py-2 rounded-lg transition-colors"
            >
              Xuất Excel
            </button>
            <button
              onClick={handleAddNew}
              className="bg-blue-600 hover:bg-blue-700 text-white text-sm font-semibold px-4 py-2 rounded-lg transition-colors"
            >
              + Thêm phụ tùng
            </button>
          </div>
        </div>

        {/* Table */}
        {isLoading ? (
          <div className="text-center py-12 text-gray-500">Đang tải...</div>
        ) : (
          <PartTable
            parts={parts}
            onEdit={handleEdit}
            onDelete={handleDelete}
            onQr={(part) => setQrPart(part)}
            canDelete={canDelete}
          />
        )}

        {/* Pagination */}
        {totalPages > 1 && (
          <div className="flex items-center justify-center gap-2 pt-2">
            <button
              onClick={() => setPage((p) => Math.max(0, p - 1))}
              disabled={page === 0}
              className="px-3 py-1 text-sm border border-gray-300 rounded-lg disabled:opacity-40 hover:bg-gray-50"
            >
              ← Trước
            </button>
            <span className="text-sm text-gray-600">
              Trang {page + 1} / {totalPages}
            </span>
            <button
              onClick={() => setPage((p) => Math.min(totalPages - 1, p + 1))}
              disabled={page === totalPages - 1}
              className="px-3 py-1 text-sm border border-gray-300 rounded-lg disabled:opacity-40 hover:bg-gray-50"
            >
              Sau →
            </button>
          </div>
        )}
      </main>

      {/* Modals */}
      {showPartModal && (
        <PartModal
          part={editingPart}
          onClose={handleModalClose}
          onSuccess={() => {
            handleModalClose()
            void queryClient.invalidateQueries({ queryKey: ['parts'] })
          }}
        />
      )}

      {qrPart && (
        <QrModal
          part={qrPart}
          onClose={() => setQrPart(null)}
        />
      )}
    </div>
  )
}
