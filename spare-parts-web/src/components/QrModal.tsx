import type { SparePartResponse } from '../types'

interface Props {
  part: SparePartResponse
  onClose: () => void
}

export default function QrModal({ part, onClose }: Props) {
  const handlePrint = () => window.print()

  return (
    <>
      {/* Print styles — only the label is shown when printing */}
      <style>{`
        @media print {
          body > * { display: none !important; }
          .print-label { display: flex !important; }
          .no-print { display: none !important; }
        }
      `}</style>

      {/* Screen overlay */}
      <div className="no-print fixed inset-0 bg-black/60 flex items-center justify-center z-50 p-4">
        <div className="bg-white rounded-2xl shadow-xl w-full max-w-md">
          {/* Modal header */}
          <div className="flex items-center justify-between px-6 py-4 border-b border-gray-200">
            <h2 className="text-lg font-semibold text-gray-800">Nhãn phụ tùng</h2>
            <div className="flex items-center gap-3">
              <button
                onClick={handlePrint}
                className="bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium px-4 py-1.5 rounded-lg transition-colors"
              >
                In nhãn
              </button>
              <button
                onClick={onClose}
                className="text-gray-400 hover:text-gray-600 text-xl leading-none"
              >
                ×
              </button>
            </div>
          </div>

          {/* Label preview (visible on screen) */}
          <div className="p-6">
            <LabelContent part={part} />
          </div>
        </div>
      </div>

      {/* Print-only label — always rendered in DOM so print CSS can show it */}
      <div
        className="print-label hidden fixed inset-0 items-center justify-center bg-white p-8"
        style={{ zIndex: 9999 }}
      >
        <LabelContent part={part} />
      </div>
    </>
  )
}

function LabelContent({ part }: { part: SparePartResponse }) {
  return (
    <div className="flex items-center gap-6 border border-gray-200 rounded-xl p-4">
      {/* Product image — left */}
      <div className="flex-shrink-0">
        {part.imageUrl ? (
          <img
            src={part.imageUrl}
            alt={part.name}
            className="w-[200px] h-[200px] object-cover rounded-lg"
          />
        ) : (
          <div className="w-[200px] h-[200px] bg-gray-100 rounded-lg flex items-center justify-center text-gray-400 text-sm">
            Không có ảnh
          </div>
        )}
      </div>

      {/* Product info — center */}
      <div className="flex-1 min-w-0 space-y-1">
        <h3 className="font-bold text-gray-800 text-base leading-tight break-words">{part.name}</h3>
        <p className="text-sm text-gray-500">Mã: <span className="font-mono font-semibold text-gray-700">{part.partNumber}</span></p>
        {part.category && (
          <p className="text-sm text-gray-500">Danh mục: <span className="text-gray-700">{part.category}</span></p>
        )}
        {part.brand && (
          <p className="text-sm text-gray-500">Hãng: <span className="text-gray-700">{part.brand}</span></p>
        )}
        {part.unit && (
          <p className="text-sm text-gray-500">Đơn vị: <span className="text-gray-700">{part.unit}</span></p>
        )}
      </div>

      {/* QR code — right */}
      <div className="flex-shrink-0">
        {part.qrCodeUrl ? (
          <img
            src={part.qrCodeUrl}
            alt="QR Code"
            className="w-[200px] h-[200px] object-contain"
          />
        ) : (
          <div className="w-[200px] h-[200px] bg-gray-100 rounded-lg flex items-center justify-center text-gray-400 text-sm text-center p-2">
            QR chưa được tạo
          </div>
        )}
      </div>
    </div>
  )
}
