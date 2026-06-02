import { useRef, useState, useEffect } from 'react'
import { useForm } from 'react-hook-form'
import { toast } from 'react-toastify'
import { AxiosError } from 'axios'
import { CATEGORIES, UNITS, type SparePartResponse, type CreateSparePartRequest, type UpdateSparePartRequest } from '../types'
import { partsApi } from '../api/parts'

/** Lấy thông báo lỗi từ phản hồi backend (ApiResponse.message), nếu không có thì dùng mặc định. */
function extractError(err: unknown, fallback: string): string {
  if (err instanceof AxiosError) {
    const msg = (err.response?.data as { message?: string } | undefined)?.message
    if (msg) return msg
  }
  return fallback
}

interface Props {
  part: SparePartResponse | null
  onClose: () => void
  onSuccess: () => void
}

interface FormValues {
  name: string
  partNumber: string
  category: string
  brand: string
  description: string
  unit: string
  quantityInStock: number
  price: string
}

export default function PartModal({ part, onClose, onSuccess }: Props) {
  const isEdit = part !== null
  const fileInputRef = useRef<HTMLInputElement>(null)
  const [imageFile, setImageFile] = useState<File | null>(null)
  const [imagePreview, setImagePreview] = useState<string | null>(part?.imageUrl ?? null)
  const [imageError, setImageError] = useState('')

  const {
    register,
    handleSubmit,
    formState: { isSubmitting, errors },
    reset,
  } = useForm<FormValues>({
    defaultValues: {
      name: part?.name ?? '',
      partNumber: part?.partNumber ?? '',
      category: part?.category ?? '',
      brand: part?.brand ?? '',
      description: part?.description ?? '',
      unit: part?.unit ?? '',
      quantityInStock: part?.quantityInStock ?? 0,
      price: part?.price != null ? String(part.price) : '',
    },
  })

  useEffect(() => {
    reset({
      name: part?.name ?? '',
      partNumber: part?.partNumber ?? '',
      category: part?.category ?? '',
      brand: part?.brand ?? '',
      description: part?.description ?? '',
      unit: part?.unit ?? '',
      quantityInStock: part?.quantityInStock ?? 0,
      price: part?.price != null ? String(part.price) : '',
    })
    setImageFile(null)
    setImagePreview(part?.imageUrl ?? null)
    setImageError('')
  }, [part, reset])

  const MAX_IMAGE_BYTES = 5 * 1024 * 1024 // 5MB

  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (!file) return
    if (!file.type.startsWith('image/')) {
      setImageError('Tệp phải là hình ảnh (jpg, png, ...)')
      e.target.value = ''
      return
    }
    if (file.size > MAX_IMAGE_BYTES) {
      setImageError('Ảnh quá lớn. Vui lòng chọn ảnh nhỏ hơn 5MB')
      e.target.value = ''
      return
    }
    setImageFile(file)
    setImageError('')
    const reader = new FileReader()
    reader.onload = (ev) => setImagePreview(ev.target?.result as string)
    reader.readAsDataURL(file)
  }

  const onSubmit = async (values: FormValues) => {
    if (!isEdit && !imageFile) {
      setImageError('Vui lòng chọn hình ảnh sản phẩm')
      return
    }

    try {
      const price = values.price !== '' ? Number(values.price) : undefined
      if (isEdit) {
        const req: UpdateSparePartRequest = {
          name: values.name || undefined,
          partNumber: values.partNumber || undefined,
          category: values.category || undefined,
          brand: values.brand || undefined,
          description: values.description || undefined,
          unit: values.unit || undefined,
          quantityInStock: Number(values.quantityInStock),
          price,
        }
        await partsApi.update(part.id, req, imageFile ?? undefined)
        toast.success('Cập nhật phụ tùng thành công')
      } else {
        const req: CreateSparePartRequest = {
          name: values.name,
          partNumber: values.partNumber,
          category: values.category,
          brand: values.brand || undefined,
          description: values.description || undefined,
          unit: values.unit || undefined,
          quantityInStock: Number(values.quantityInStock),
          price,
        }
        await partsApi.create(req, imageFile!)
        toast.success('Thêm phụ tùng thành công')
      }
      onSuccess()
    } catch (err) {
      toast.error(extractError(err, isEdit ? 'Cập nhật thất bại' : 'Thêm phụ tùng thất bại'))
    }
  }

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-2xl shadow-xl w-full max-w-lg max-h-[90vh] overflow-y-auto">
        <div className="flex items-center justify-between px-6 py-4 border-b border-gray-200">
          <h2 className="text-lg font-semibold text-gray-800">
            {isEdit ? 'Cập nhật phụ tùng' : 'Thêm phụ tùng mới'}
          </h2>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600 text-xl leading-none"
          >
            ×
          </button>
        </div>

        <form onSubmit={handleSubmit(onSubmit)} className="px-6 py-4 space-y-4">
          {/* Part Number */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Mã sản phẩm <span className="text-red-500">*</span>
            </label>
            <input
              {...register('partNumber', { required: 'Mã sản phẩm là bắt buộc' })}
              className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="VD: PN-001"
            />
            {errors.partNumber && (
              <p className="text-red-500 text-xs mt-1">{errors.partNumber.message}</p>
            )}
          </div>

          {/* Name */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Tên phụ tùng <span className="text-red-500">*</span>
            </label>
            <input
              {...register('name', { required: 'Tên phụ tùng là bắt buộc' })}
              className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="VD: Lọc dầu động cơ"
            />
            {errors.name && (
              <p className="text-red-500 text-xs mt-1">{errors.name.message}</p>
            )}
          </div>

          {/* Category + Unit row */}
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Danh mục <span className="text-red-500">*</span>
              </label>
              <select
                {...register('category', { required: 'Chọn danh mục' })}
                className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="">-- Chọn --</option>
                {CATEGORIES.map((c) => (
                  <option key={c} value={c}>{c}</option>
                ))}
              </select>
              {errors.category && (
                <p className="text-red-500 text-xs mt-1">{errors.category.message}</p>
              )}
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Đơn vị</label>
              <select
                {...register('unit')}
                className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="">-- Chọn --</option>
                {UNITS.map((u) => (
                  <option key={u} value={u}>{u}</option>
                ))}
              </select>
            </div>
          </div>

          {/* Brand */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Hãng</label>
            <input
              {...register('brand')}
              className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="VD: Bosch, Denso..."
            />
          </div>

          {/* Qty + Price row */}
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Tồn kho <span className="text-red-500">*</span>
              </label>
              <input
                {...register('quantityInStock', {
                  required: 'Bắt buộc',
                  min: { value: 0, message: 'Phải ≥ 0' },
                  valueAsNumber: true,
                })}
                type="number"
                min="0"
                className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
              {errors.quantityInStock && (
                <p className="text-red-500 text-xs mt-1">{errors.quantityInStock.message}</p>
              )}
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Giá (VNĐ)</label>
              <input
                {...register('price')}
                type="number"
                min="0"
                step="1000"
                className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="0"
              />
            </div>
          </div>

          {/* Description */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Mô tả</label>
            <textarea
              {...register('description')}
              rows={2}
              className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none"
              placeholder="Mô tả ngắn về phụ tùng..."
            />
          </div>

          {/* Image upload */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Hình ảnh {!isEdit && <span className="text-red-500">*</span>}
            </label>
            <div
              className="border-2 border-dashed border-gray-300 rounded-lg p-3 text-center cursor-pointer hover:border-blue-400 transition-colors"
              onClick={() => fileInputRef.current?.click()}
            >
              {imagePreview ? (
                <img
                  src={imagePreview}
                  alt="preview"
                  className="w-24 h-24 object-cover rounded-lg mx-auto"
                />
              ) : (
                <p className="text-gray-400 text-sm py-4">Nhấn để chọn ảnh</p>
              )}
            </div>
            <input
              ref={fileInputRef}
              type="file"
              accept="image/*"
              className="hidden"
              onChange={handleImageChange}
            />
            {imageError && (
              <p className="text-red-500 text-xs mt-1">{imageError}</p>
            )}
            {imageFile && (
              <p className="text-xs text-gray-500 mt-1">{imageFile.name}</p>
            )}
          </div>

          {/* Actions */}
          <div className="flex justify-end gap-3 pt-2">
            <button
              type="button"
              onClick={onClose}
              className="px-4 py-2 text-sm border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors"
            >
              Huỷ
            </button>
            <button
              type="submit"
              disabled={isSubmitting}
              className="px-4 py-2 text-sm bg-blue-600 hover:bg-blue-700 disabled:opacity-60 text-white font-semibold rounded-lg transition-colors"
            >
              {isSubmitting ? 'Đang lưu...' : isEdit ? 'Cập nhật' : 'Thêm mới'}
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}
