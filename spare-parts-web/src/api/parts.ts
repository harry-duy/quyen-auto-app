import apiClient from './client'
import type { CreateSparePartRequest, SparePartResponse, UpdateSparePartRequest, PageResponse } from '../types'

export const partsApi = {
  getAll: (params: { keyword?: string; category?: string; page?: number; size?: number }) =>
    apiClient.get<{ data: PageResponse<SparePartResponse> }>('/staff/spare-parts', { params }),

  getById: (id: number) =>
    apiClient.get<{ data: SparePartResponse }>(`/staff/spare-parts/${id}`),

  create: (data: CreateSparePartRequest, image: File) => {
    const formData = new FormData()
    formData.append('data', new Blob([JSON.stringify(data)], { type: 'application/json' }))
    formData.append('image', image)
    return apiClient.post<{ data: SparePartResponse }>('/staff/spare-parts', formData)
  },

  update: (id: number, data: UpdateSparePartRequest, image?: File) => {
    const formData = new FormData()
    formData.append('data', new Blob([JSON.stringify(data)], { type: 'application/json' }))
    if (image) formData.append('image', image)
    return apiClient.put<{ data: SparePartResponse }>(`/staff/spare-parts/${id}`, formData)
  },

  delete: (id: number) =>
    apiClient.delete(`/staff/spare-parts/${id}`),

  exportExcel: () =>
    apiClient.get('/staff/spare-parts/export/excel', { responseType: 'blob' }),
}
