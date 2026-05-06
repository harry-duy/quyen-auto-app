import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../domain/entities/product.dart';

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
                child: product.imageUrls.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: product.imageUrls.first,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Shimmer.fromColors(
                          baseColor: AppColors.borderLight,
                          highlightColor: AppColors.surface,
                          child: Container(color: AppColors.borderLight),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.primaryNavy.withValues(alpha: 0.07),
                          child: const Icon(Icons.local_shipping_outlined,
                              size: 44, color: AppColors.primaryNavy),
                        ),
                      )
                    : Container(
                        color: AppColors.primaryNavy.withValues(alpha: 0.07),
                        child: const Icon(Icons.local_shipping_outlined,
                            size: 44, color: AppColors.primaryNavy),
                      ),
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
