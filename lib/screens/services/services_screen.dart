import 'package:flutter/material.dart';
import '../../models/service_model.dart';
import '../../models/vehicle_model.dart';
import '../../services/service_service.dart';
import '../../services/vehicle_service.dart';
import '../../theme/app_theme.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final _serviceService = ServiceService();
  final _vehicleService = VehicleService();

  List<ServiceModel> _services = [];
  List<Vehicle> _vehicles = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _serviceService.getServices(),
        _vehicleService.getVehicles(),
      ]);
      setState(() {
        _services = results[0] as List<ServiceModel>;
        _vehicles = results[1] as List<Vehicle>;
      });
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Cari nama kendaraan dari vehicle_id
  String _vehicleName(int vehicleId) {
    try {
      final v = _vehicles.firstWhere((v) => v.id == vehicleId);
      return v.fullName;
    } catch (_) {
      return 'Kendaraan #$vehicleId';
    }
  }

  // Hitung total biaya
  int get _totalCost => _services.fold(0, (sum, s) => sum + s.cost);

  String _formatTotal(int cost) {
    final str = cost.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.green,
      backgroundColor: AppColors.nearBlack,
      onRefresh: _loadData,
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.green),
            )
          : _error != null
          ? _buildError()
          : _buildContent(),
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
            OutlinedButton(onPressed: _loadData, child: const Text('RETRY')),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_services.isEmpty) {
      return Center(
        child: Text(
          'Belum ada data servis',
          style: AppTextStyles.bodySecondary,
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header summary
        _buildSummaryHeader(),
        const SizedBox(height: 24),

        // List label
        Text('SEMUA SERVIS', style: AppTextStyles.label),
        const SizedBox(height: 12),

        // List items
        ..._services.map(
          (s) =>
              _ServiceCard(service: s, vehicleName: _vehicleName(s.vehicleId)),
        ),
      ],
    );
  }

  Widget _buildSummaryHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.nearBlack,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: AppColors.green, width: 2),
        boxShadow: const [BoxShadow(color: Color(0x4D000000), blurRadius: 5)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TOTAL SERVIS', style: AppTextStyles.label),
                const SizedBox(height: 8),
                Text(
                  '${_services.length} servis',
                  style: AppTextStyles.sectionHeading,
                ),
              ],
            ),
          ),
          Container(width: 1, height: 48, color: AppColors.borderSubtle),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TOTAL BIAYA', style: AppTextStyles.label),
                const SizedBox(height: 8),
                Text(
                  _formatTotal(_totalCost),
                  style: AppTextStyles.sectionHeading.copyWith(
                    color: AppColors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Service Card ──────────────────────────────────────────
class _ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final String vehicleName;

  const _ServiceCard({required this.service, required this.vehicleName});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.nearBlack,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: const [BoxShadow(color: Color(0x4D000000), blurRadius: 5)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Green left bar
          Container(width: 3, height: 56, color: AppColors.green),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.description, style: AppTextStyles.cardTitle),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.directions_car_outlined,
                      size: 12,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(vehicleName, style: AppTextStyles.caption),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 12,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(service.serviceDate, style: AppTextStyles.caption),
                  ],
                ),
              ],
            ),
          ),

          // Biaya
          Text(
            service.formattedCost,
            style: AppTextStyles.cardTitle.copyWith(color: AppColors.green),
          ),
        ],
      ),
    );
  }
}
