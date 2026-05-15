import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/product_image_helper.dart';
import '../../domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
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
                height: 130,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: ProductImageHelper.resolve(product),
                  fit: BoxFit.contain,
                  color: AppColors.primaryNavy.withValues(alpha: 0.04),
                  colorBlendMode: BlendMode.darken,
                  placeholder: (_, __) => Shimmer.fromColors(
                    baseColor: AppColors.borderLight,
                    highlightColor: AppColors.surface,
                    child: Container(color: AppColors.borderLight),
                  ),
                  errorWidget: (_, __, ___) => _placeholder(),
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
                    Row(
                      children: [
                        const Text(
                          'Xem chi tiết',
                          style: TextStyle(
                            color: AppColors.primaryOrange,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.arrow_forward_ios,
                            size: 10, color: AppColors.primaryOrange),
                      ],
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

  Widget _placeholder() => Container(
        color: AppColors.primaryNavy.withValues(alpha: 0.07),
        child: const Center(
          child: Icon(Icons.local_shipping_outlined,
              size: 44, color: AppColors.primaryNavy),
        ),
      );
}
