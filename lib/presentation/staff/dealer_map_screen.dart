import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/staff_providers.dart';
import '../../data/models/response/dealer_response.dart';

class DealerMapScreen extends ConsumerStatefulWidget {
  const DealerMapScreen({super.key});

  @override
  ConsumerState<DealerMapScreen> createState() => _DealerMapScreenState();
}

class _DealerMapScreenState extends ConsumerState<DealerMapScreen> {
  GoogleMapController? _mapController;
  DealerResponse? _selectedDealer;

  static const _defaultCenter = LatLng(10.8231, 106.6297);

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dealersAsync = ref.watch(dealerListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Đại lý & Showroom')),
      body: dealersAsync.when(
        data: (dealers) => Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: dealers.isNotEmpty
                    ? LatLng(dealers.first.lat, dealers.first.lng)
                    : _defaultCenter,
                zoom: 10,
              ),
              onMapCreated: (controller) => _mapController = controller,
              markers: dealers.map((d) => Marker(
                markerId: MarkerId(d.id.toString()),
                position: LatLng(d.lat, d.lng),
                infoWindow: InfoWindow(title: d.name),
                onTap: () => setState(() => _selectedDealer = d),
              )).toSet(),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
            ),
            if (_selectedDealer != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _DealerSheet(
                  dealer: _selectedDealer!,
                  onClose: () => setState(() => _selectedDealer = null),
                ),
              ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.errorRed, size: 40),
              const SizedBox(height: 8),
              Text(e.toString(),
                  style: const TextStyle(color: AppColors.errorRed)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DealerSheet extends StatelessWidget {
  final DealerResponse dealer;
  final VoidCallback onClose;

  const _DealerSheet({required this.dealer, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.store,
                    color: AppColors.primaryOrange, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dealer.name,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark)),
                    const SizedBox(height: 2),
                    Text(dealer.province,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textGray)),
                  ],
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close, color: AppColors.textGray),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.location_on_outlined,
                  size: 16, color: AppColors.textGray),
              const SizedBox(width: 6),
              Expanded(
                child: Text(dealer.address,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textDark)),
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.phone_outlined,
                  size: 16, color: AppColors.textGray),
              const SizedBox(width: 6),
              Text(dealer.phone,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textDark)),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => launchUrlString(
                    'https://www.google.com/maps/dir/?api=1'
                    '&destination=${dealer.lat},${dealer.lng}',
                  ),
                  icon: const Icon(Icons.directions, size: 18),
                  label: const Text('Chỉ đường'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => launchUrlString('tel:${dealer.phone}'),
                  icon: const Icon(Icons.phone, size: 18),
                  label: const Text('Gọi ngay'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
