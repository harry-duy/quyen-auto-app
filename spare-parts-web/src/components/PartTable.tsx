import type { SparePartResponse } from '../types'

interface Props {
  parts: SparePartResponse[]
  onEdit: (part: SparePartResponse) => void
  onDelete: (part: SparePartResponse) => void
  onQr: (part: SparePartResponse) => void
  canDelete: boolean
}

export default function PartTable({ parts, onEdit, onDelete, onQr, canDelete }: Props) {
  if (parts.length === 0) {
    return (
      <div className="text-center py-12 text-gray-500">
        Chưa có phụ tùng nào. Nhấn "Thêm phụ tùng" để bắt đầu.
      </div>
    )
  }

  return (
    <div className="overflow-x-auto rounded-xl border border-gray-200">
      <table className="min-w-full text-sm">
        <thead className="bg-gray-50 text-gray-600 uppercase text-xs">
          <tr>
            <th className="px-4 py-3 text-left">Mã SP</th>
            <th className="px-4 py-3 text-left">Tên</th>
            <th className="px-4 py-3 text-left">Danh mục</th>
            <th className="px-4 py-3 text-left">Hãng</th>
            <th className="px-4 py-3 text-right">Tồn kho</th>
            <th className="px-4 py-3 text-right">Giá</th>
            <th className="px-4 py-3 text-center">Ảnh</th>
            <th className="px-4 py-3 text-center">QR</th>
            <th className="px-4 py-3 text-center">Hành động</th>
          </tr>
        </thead>
        <tbody className="divide-y divide-gray-100">
          {parts.map((part) => (
            <tr key={part.id} className="hover:bg-gray-50 transition-colors">
              <td className="px-4 py-3 font-mono text-xs text-gray-700">{part.partNumber}</td>
              <td className="px-4 py-3 font-medium text-gray-800 max-w-[200px] truncate">{part.name}</td>
              <td className="px-4 py-3 text-gray-600">{part.category}</td>
              <td className="px-4 py-3 text-gray-600">{part.brand ?? '—'}</td>
              <td className="px-4 py-3 text-right text-gray-800">{part.quantityInStock}</td>
              <td className="px-4 py-3 text-right text-gray-800">
                {part.price != null
                  ? new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(part.price)
                  : '—'}
              </td>
              <td className="px-4 py-3 text-center">
                {part.imageUrl ? (
                  <img
                    src={part.imageUrl}
                    alt={part.name}
                    className="w-10 h-10 object-cover rounded-md mx-auto"
                  />
                ) : (
                  <span className="text-gray-400 text-xs">—</span>
                )}
              </td>
              <td className="px-4 py-3 text-center">
                <button
                  onClick={() => onQr(part)}
                  className="text-indigo-600 hover:text-indigo-800 text-xs font-medium"
                  title="Xem QR"
                >
                  QR
                </button>
              </td>
              <td className="px-4 py-3 text-center space-x-2">
                <button
                  onClick={() => onEdit(part)}
                  className="text-blue-600 hover:text-blue-800 text-xs font-medium"
                >
                  Sửa
                </button>
                {canDelete && (
                  <button
                    onClick={() => onDelete(part)}
                    className="text-red-600 hover:text-red-800 text-xs font-medium"
                  >
                    Xoá
                  </button>
                )}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
