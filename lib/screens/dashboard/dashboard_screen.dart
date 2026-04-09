import 'package:flutter/material.dart';
import '../../models/service_model.dart';
import '../../models/vehicle_model.dart';
import '../../services/vehicle_service.dart';
import '../../services/service_service.dart';
import '../../theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _vehicleService = VehicleService();
  final _serviceService = ServiceService();

  List<Vehicle> _vehicles = [];
  List<ServiceModel> _services = [];
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
        _vehicleService.getVehicles(),
        _serviceService.getServices(),
      ]);
      setState(() {
        _vehicles = results[0] as List<Vehicle>;
        _services = results[1] as List<ServiceModel>;
      });
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Hitung total cost semua service
  int get _totalCost => _services.fold(0, (sum, s) => sum + s.cost);

  // Service paling baru
  ServiceModel? get _latestService =>
      _services.isNotEmpty ? _services.first : null;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.green,
      backgroundColor: AppColors.nearBlack,
      onRefresh: _loadData,
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.green))
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
            Text(_error!, style: AppTextStyles.body, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: _loadData, child: const Text('RETRY')),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Greeting
        _buildGreeting(),
        const SizedBox(height: 24),

        // Summary Cards row
        Text('OVERVIEW', style: AppTextStyles.label),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.directions_car,
                label: 'VEHICLES',
                value: '${_vehicles.length}',
                sub: 'terdaftar',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: Icons.build,
                label: 'SERVICES',
                value: '${_services.length}',
                sub: 'total servis',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Total cost card — full width
        _TotalCostCard(totalCost: _totalCost),
        const SizedBox(height: 24),

        // Recent service
        Text('SERVIS TERBARU', style: AppTextStyles.label),
        const SizedBox(height: 12),
        _latestService != null
            ? _RecentServiceCard(
                service: _latestService!,
                vehicles: _vehicles,
              )
            : _buildEmpty('Belum ada data servis'),
        const SizedBox(height: 24),

        // Vehicle list ringkas
        Text('KENDARAAN', style: AppTextStyles.label),
        const SizedBox(height: 12),
        ..._vehicles.map((v) => _VehicleRow(vehicle: v)),
      ],
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('GARAGE', style: AppTextStyles.label),
        const SizedBox(height: 4),
        Text('Dashboard', style: AppTextStyles.displayHero),
        const SizedBox(height: 4),
        Text('Ringkasan data kendaraan & servis',
            style: AppTextStyles.bodySecondary),
      ],
    );
  }

  Widget _buildEmpty(String msg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.nearBlack,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Text(msg, style: AppTextStyles.bodySecondary),
    );
  }
}

// ── Summary Card ──────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String sub;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.nearBlack,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.green, size: 16),
              const SizedBox(width: 8),
              Text(label, style: AppTextStyles.label),
            ],
          ),
          const SizedBox(height: 12),
          Text(value,
              style: AppTextStyles.displayHero.copyWith(
                color: AppColors.white,
              )),
          const SizedBox(height: 2),
          Text(sub, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

// ── Total Cost Card ───────────────────────────────────────
class _TotalCostCard extends StatelessWidget {
  final int totalCost;

  const _TotalCostCard({required this.totalCost});

  String get _formatted {
    final str = totalCost.toString();
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.nearBlack,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: AppColors.green, width: 2),
        boxShadow: const [
          BoxShadow(color: Color(0x4D000000), blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.payments_outlined,
                  color: AppColors.green, size: 16),
              const SizedBox(width: 8),
              Text('TOTAL BIAYA SERVIS', style: AppTextStyles.label),
            ],
          ),
          const SizedBox(height: 12),
          Text(_formatted,
              style: AppTextStyles.displayHero.copyWith(
                color: AppColors.green,
              )),
          const SizedBox(height: 2),
          Text('akumulasi semua servis', style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

// ── Recent Service Card ───────────────────────────────────
class _RecentServiceCard extends StatelessWidget {
  final ServiceModel service;
  final List<Vehicle> vehicles;

  const _RecentServiceCard({required this.service, required this.vehicles});

  String _vehicleName() {
    try {
      final v = vehicles.firstWhere((v) => v.id == service.vehicleId);
      return v.fullName;
    } catch (_) {
      return 'Kendaraan #${service.vehicleId}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.nearBlack,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 48,
            color: AppColors.green,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.description, style: AppTextStyles.cardTitle),
                const SizedBox(height: 4),
                Text(_vehicleName(), style: AppTextStyles.bodySecondary),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(service.formattedCost,
                  style: AppTextStyles.cardTitle.copyWith(
                    color: AppColors.green,
                  )),
              const SizedBox(height: 4),
              Text(service.serviceDate, style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Vehicle Row ───────────────────────────────────────────
class _VehicleRow extends StatelessWidget {
  final Vehicle vehicle;

  const _VehicleRow({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.nearBlack,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          const Icon(Icons.directions_car_outlined,
              color: AppColors.green, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(vehicle.fullName, style: AppTextStyles.cardTitle),
          ),
          Text('${vehicle.year}', style: AppTextStyles.caption),
        ],
      ),
    );
  }
}