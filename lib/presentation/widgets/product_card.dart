import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../domain/entities/product.dart';

/// Fallback images from quyenauto.com when the backend has no image yet.
/// Keyed by partial category name (case-insensitive contains check).
const _kCategoryFallbacks = <String, String>{
  'lạnh':    'https://quyenauto.com/wp-content/uploads/2021/05/F1L.2020-Isuzu-700x700.png',
  'bảo ôn':  'https://quyenauto.com/wp-content/uploads/2020/12/F1-HINO-432-tach-nen700x700.png',
  'tải kín': 'https://quyenauto.com/wp-content/uploads/2018/11/TK-HINO-FG.png',
  'composite':'https://quyenauto.com/wp-content/uploads/2022/12/TAI-KIN-DUOI-6T-VIEW1.png',
  'chuyên':  'https://quyenauto.com/wp-content/uploads/2023/06/Combo-4-xe-thiet-ke-Quyen-Auto.png',
};

String? _fallbackFor(String category) {
  final lower = category.toLowerCase();
  for (final entry in _kCategoryFallbacks.entries) {
    if (lower.contains(entry.key)) return entry.value;
  }
  return null;
}

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final fmt =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        onTap: () => context.push(AppRoutes.productOf(product.id)),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: () {
                        final url = product.imageUrls.isNotEmpty
                            ? product.imageUrls.first
                            : _fallbackFor(product.category);
                        if (url != null) {
                          return CachedNetworkImage(
                            imageUrl: url,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Shimmer.fromColors(
                              baseColor: AppColors.borderLight,
                              highlightColor: AppColors.surface,
                              child: Container(color: AppColors.borderLight),
                            ),
                            errorWidget: (_, _, _) => Container(
                              color: AppColors.primaryNavy.withValues(alpha: 0.07),
                              child: const Icon(Icons.local_shipping_outlined,
                                  size: 44, color: AppColors.primaryNavy),
                            ),
                          );
                        }
                        return Container(
                          color: AppColors.primaryNavy.withValues(alpha: 0.07),
                          child: const Icon(Icons.local_shipping_outlined,
                              size: 44, color: AppColors.primaryNavy),
                        );
                      }(),
              ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.textDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (product.truckType != null &&
                        product.truckType!.isNotEmpty)
                      Text(
                        product.truckType!,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textGray),
                      ),
                    const Spacer(),
                    Text(
                      product.price > 0
                          ? 'Từ ${fmt.format(product.price)}'
                          : 'Liên hệ báo giá',
                      style: const TextStyle(
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
