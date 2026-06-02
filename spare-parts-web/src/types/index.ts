export interface SparePartResponse {
  id: number
  name: string
  partNumber: string
  category: string
  brand: string | null
  description: string | null
  unit: string | null
  quantityInStock: number
  price: number | null
  imageUrl: string | null
  qrCodeUrl: string | null
  isActive: boolean
  createdAt: string
  updatedAt: string | null
}

export interface CreateSparePartRequest {
  name: string
  partNumber: string
  category: string
  brand?: string
  description?: string
  unit?: string
  quantityInStock: number
  price?: number
}

export interface UpdateSparePartRequest {
  name?: string
  partNumber?: string
  category?: string
  brand?: string
  description?: string
  unit?: string
  quantityInStock?: number
  price?: number
}

export interface PageResponse<T> {
  content: T[]
  page: number
  size: number
  totalElements: number
  totalPages: number
}

export const CATEGORIES = ['Engine', 'Transmission', 'Electrical', 'Body', 'Cooling', 'Brake', 'Suspension', 'Other'] as const
export const UNITS = ['Piece', 'Set', 'Liter', 'Meter', 'kg'] as const
