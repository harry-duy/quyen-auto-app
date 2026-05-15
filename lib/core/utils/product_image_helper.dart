import '../../domain/entities/product.dart';

/// Maps a Product to a real image URL from quyenauto.com.
/// Used when the backend product has no imageUrls.
abstract final class ProductImageHelper {
  static String resolve(Product product) {
    if (product.imageUrls.isNotEmpty) return product.imageUrls.first;
    return _fromName(product.name, product.category);
  }

  static String resolveByCategory(String category) =>
      _categoryFallback(category.toUpperCase());

  static String _fromName(String name, String category) {
    final n = name.toLowerCase();

    // PICKUP / VAN
    if (n.contains('pickup') || n.contains('d-max') || n.contains('dmax'))
      return _kPickup;
    if (n.contains(' van ') || n.contains('van đông'))
      return _kVan;

    // Chassis brand detection
    if (n.contains('isuzu')) return _resolveIsuzu(n, category);
    if (n.contains('hino')) return _resolveHino(n, category);
    if (n.contains('fuso') || n.contains('mitsubishi') || n.contains('canter'))
      return _resolveFuso(category);
    if (n.contains('hyundai')) return _resolveHyundai(n, category);
    if (n.contains('thaco') || n.contains('ollin') || n.contains('kia k'))
      return _resolveThaco(category);
    if (n.contains('suzuki') || n.contains('carry')) return _kSuzuki;
    if (n.contains('xe gà') || n.contains('chở gà')) return _kChicken;
    if (n.contains('bán hàng') || n.contains('lưu động')) return _kMobileSales;
    if (n.contains('cánh dơi')) return _kWingvan;
    if (n.contains('rơ mooc') || n.contains('sơ-mi') || n.contains('semi'))
      return _kSemiTrailer;

    return _categoryFallback(category.toUpperCase());
  }

  static String _resolveIsuzu(String name, String category) {
    // Large frame: FRR, FSR, FVR, FVM
    if (_isLarge(name)) return _kIsuzuLarge;
    // Small frame: NPR, NMR, NQR, NMR 85H, etc.
    return _kIsuzuSmall;
  }

  static String _resolveHino(String name, String category) {
    if (_isLarge(name)) {
      return category.toUpperCase() == 'ENCLOSED'
          ? _kHinoFG
          : _kHinoLarge;
    }
    return _kHinoSmall;
  }

  static String _resolveFuso(String category) {
    return category.toUpperCase() == 'ENCLOSED' ? _kEnclosed : _kIsuzuSmall;
  }

  static String _resolveHyundai(String name, String category) {
    // HD320 = large, HD65/HD72/HD120/Mighty = small
    if (name.contains('hd320') || name.contains('hd 320')) return _kIsuzuLarge;
    return _categoryFallback(category.toUpperCase());
  }

  static String _resolveThaco(String category) {
    return category.toUpperCase() == 'ENCLOSED' ? _kEnclosed : _kInsulated;
  }

  // True if name contains a "large" truck indicator
  static bool _isLarge(String name) =>
      name.contains('frr') ||
      name.contains('fsr') ||
      name.contains('fvr') ||
      name.contains('fvm') ||
      name.contains('fl8') ||
      name.contains('fg8') ||
      name.contains('fc9') ||
      name.contains('hd320') ||
      name.contains('trên 6') ||
      name.contains('>6') ||
      name.contains('8t') ||
      name.contains('10t') ||
      name.contains('12t');

  static String _categoryFallback(String category) => switch (category) {
        'REFRIGERATED' => _kRefrigerated,
        'INSULATED' => _kInsulated,
        'ENCLOSED' => _kEnclosed,
        'CUSTOM' => _kCustom,
        _ => _kRefrigerated,
      };

  // ── Image URL constants ──────────────────────────────────────────────────

  static const _base = 'https://quyenauto.com/wp-content/uploads';

  static const _kIsuzuLarge =
      '$_base/2018/08/F1-ISUZU-tach-nen700x700.png';
  static const _kIsuzuSmall =
      '$_base/2018/08/IMG_2629-700x700px.png';
  static const _kHinoLarge =
      '$_base/2021/01/HINO-BO-TREN-6-TAN-1.png';
  static const _kHinoFG =
      '$_base/2018/11/TK-HINO-FG.png';
  static const _kHinoSmall =
      '$_base/2021/03/F1S-new-tach-nen700x700.png';
  static const _kEnclosed =
      '$_base/2018/11/TK-HINO-FG.png';
  static const _kInsulated =
      '$_base/2020/12/F1-HINO-432-tach-nen700x700.png';
  static const _kRefrigerated =
      '$_base/2021/05/F1L.2020-Isuzu-700x700.png';
  static const _kCustom =
      '$_base/2023/06/Combo-4-xe-thiet-ke-Quyen-Auto.png';
  static const _kPickup =
      '$_base/2025/01/Dmax-Quyen-Auto-700x700-front.png';
  static const _kVan =
      '$_base/2021/11/Thaco-van-front-back-tach-nen-700x700-logo.png';
  static const _kChicken =
      '$_base/2021/01/Xe-ga-HINO-2-xe-tach-nen-700x700.png';
  static const _kMobileSales =
      '$_base/2018/12/Thung-xe-ban-hang-tach-nen-700x700.png';
  static const _kWingvan =
      '$_base/2018/12/Thung-xe-canh-doi-tach-nen-700x700.png';
  static const _kSemiTrailer =
      '$_base/2019/10/SEMI-TRAILER-DL.png';
  static const _kSuzuki =
      '$_base/2021/03/F1S-new-tach-nen700x700.png';
}
