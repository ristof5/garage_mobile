import 'package:flutter/material.dart';
import '../../models/vehicle_model.dart';
import '../../services/vehicle_service.dart';
import '../../services/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'vehicle_detail_screen.dart';
import 'vehicle_form_screen.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  final _vehicleService = VehicleService();

  List<Vehicle> _vehicles = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _vehicleService.getVehicles();
      setState(() => _vehicles = data);
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.green,
        backgroundColor: AppColors.nearBlack,
        onRefresh: _loadVehicles,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.green),
              )
            : _error != null
            ? _buildError()
            : _buildList(),
      ),

      // FAB hanya untuk admin
      floatingActionButton: AuthProvider.isAdmin
          ? FloatingActionButton(
              backgroundColor: AppColors.green,
              foregroundColor: AppColors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2),
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VehicleFormScreen()),
                );
                if (result == true) _loadVehicles();
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 40),
            const SizedBox(height: 12),
            Text(
              _error!,
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _loadVehicles,
              child: const Text('RETRY'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_vehicles.isEmpty) {
      return Center(
        child: Text('Belum ada kendaraan', style: AppTextStyles.bodySecondary),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _vehicles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _VehicleCard(
        vehicle: _vehicles[i],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VehicleDetailScreen(vehicle: _vehicles[i]),
          ),
        ).then((_) => _loadVehicles()), // refresh setelah kembali
      ),
    );
  }
}

// ── Vehicle Card ──────────────────────────────────────────
class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onTap;

  const _VehicleCard({required this.vehicle, required this.onTap});

  // Warna berbeda per brand
  Color get _brandColor {
    switch (vehicle.brand.toLowerCase()) {
      case 'honda':
        return const Color(0xFF76B900); // green
      case 'toyota':
        return const Color(0xFF1EAEDB); // teal
      case 'daihatsu':
        return const Color(0xFFDF6500); // orange
      default:
        return AppColors.borderSubtle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(2),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.nearBlack,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: const [BoxShadow(color: Color(0x4D000000), blurRadius: 5)],
        ),
        child: Row(
          children: [
            // Brand color bar
            Container(width: 3, height: 52, color: _brandColor),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label brand
                  Text(vehicle.brand.toUpperCase(), style: AppTextStyles.label),
                  const SizedBox(height: 4),
                  // Model
                  Text(vehicle.model, style: AppTextStyles.cardTitle),
                  const SizedBox(height: 4),
                  // Tahun
                  Text('${vehicle.year}', style: AppTextStyles.bodySecondary),
                ],
              ),
            ),

            // Arrow + ID badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderSubtle),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text('#${vehicle.id}', style: AppTextStyles.caption),
                ),
                const SizedBox(height: 12),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.green,
                  size: 14,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
