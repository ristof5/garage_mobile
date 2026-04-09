import 'package:flutter/material.dart';
import '../../models/vehicle_model.dart';
import '../../models/service_model.dart';
import '../../services/service_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/green_accent_bar.dart';

class VehicleDetailScreen extends StatefulWidget {
  final Vehicle vehicle;

  const VehicleDetailScreen({super.key, required this.vehicle});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  final _serviceService = ServiceService();

  List<ServiceModel> _services = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _serviceService.getServicesByVehicle(
        widget.vehicle.id,
      );
      setState(() => _services = data);
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Total biaya servis kendaraan ini
  int get _totalCost => _services.fold(0, (sum, s) => sum + s.cost);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vehicle.fullName),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: GreenAccentBar(),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.green,
        backgroundColor: AppColors.nearBlack,
        onRefresh: _loadServices,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info card kendaraan
            _buildVehicleInfo(),
            const SizedBox(height: 24),

            // Riwayat servis
            Text('RIWAYAT SERVIS', style: AppTextStyles.label),
            const SizedBox(height: 12),

            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.green),
                  )
                : _error != null
                ? _buildError()
                : _buildServiceList(),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.nearBlack,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: AppColors.green, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('INFORMASI KENDARAAN', style: AppTextStyles.label),
          const SizedBox(height: 16),
          _infoRow('Brand', widget.vehicle.brand),
          const Divider(height: 24),
          _infoRow('Model', widget.vehicle.model),
          const Divider(height: 24),
          _infoRow('Tahun', '${widget.vehicle.year}'),
          if (!_isLoading && _services.isNotEmpty) ...[
            const Divider(height: 24),
            _infoRow(
              'Total Biaya',
              _services.first.formattedCost.replaceAll(
                _services.first.formattedCost,
                _formatTotal(_totalCost),
              ),
              valueColor: AppColors.green,
            ),
          ],
        ],
      ),
    );
  }

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

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodySecondary),
        Text(
          value,
          style: AppTextStyles.cardTitle.copyWith(
            color: valueColor ?? AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 32),
          const SizedBox(height: 8),
          Text(_error!, style: AppTextStyles.bodySecondary),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: _loadServices, child: const Text('RETRY')),
        ],
      ),
    );
  }

  Widget _buildServiceList() {
    if (_services.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.nearBlack,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Text(
          'Belum ada riwayat servis untuk kendaraan ini',
          style: AppTextStyles.bodySecondary,
        ),
      );
    }

    return Column(
      children: _services.map((s) => _ServiceItem(service: s)).toList(),
    );
  }
}

// ── Service Item ──────────────────────────────────────────
class _ServiceItem extends StatelessWidget {
  final ServiceModel service;

  const _ServiceItem({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.nearBlack,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(width: 3, height: 48, color: AppColors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.description, style: AppTextStyles.cardTitle),
                const SizedBox(height: 4),
                Text(service.serviceDate, style: AppTextStyles.caption),
              ],
            ),
          ),
          Text(
            service.formattedCost,
            style: AppTextStyles.cardTitle.copyWith(color: AppColors.green),
          ),
        ],
      ),
    );
  }
}
