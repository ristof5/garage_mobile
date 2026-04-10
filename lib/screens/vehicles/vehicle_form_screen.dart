import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/vehicle_model.dart';
import '../../services/vehicle_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/green_accent_bar.dart';

class VehicleFormScreen extends StatefulWidget {
  final Vehicle? vehicle; // null = tambah, isi = edit

  const VehicleFormScreen({super.key, this.vehicle});

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _vehicleService = VehicleService();

  bool _isLoading = false;
  String? _error;

  bool get _isEdit => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    // Kalau edit, isi field dengan data existing
    if (_isEdit) {
      _brandController.text = widget.vehicle!.brand;
      _modelController.text = widget.vehicle!.model;
      _yearController.text = widget.vehicle!.year.toString();
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    // Validasi
    final brand = _brandController.text.trim();
    final model = _modelController.text.trim();
    final yearText = _yearController.text.trim();

    if (brand.isEmpty || model.isEmpty || yearText.isEmpty) {
      setState(() => _error = 'Semua field wajib diisi');
      return;
    }

    final year = int.tryParse(yearText);
    if (year == null || year < 1900 || year > DateTime.now().year + 1) {
      setState(() => _error = 'Tahun tidak valid');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (_isEdit) {
        await _vehicleService.updateVehicle(
            widget.vehicle!.id, brand, model, year);
      } else {
        await _vehicleService.createVehicle(brand, model, year);
      }

      if (mounted) {
        // Kembali ke screen sebelumnya dengan signal sukses
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'EDIT KENDARAAN' : 'TAMBAH KENDARAAN'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: GreenAccentBar(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              _isEdit ? 'EDIT DATA' : 'DATA BARU',
              style: AppTextStyles.label,
            ),
            const SizedBox(height: 8),
            Text(
              _isEdit ? 'Ubah informasi kendaraan' : 'Tambah kendaraan baru',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 32),

            // Field Brand
            Text('BRAND', style: AppTextStyles.label),
            const SizedBox(height: 8),
            TextField(
              controller: _brandController,
              style: AppTextStyles.body,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'Contoh: Honda, Toyota',
                prefixIcon: Icon(Icons.business_outlined, size: 18),
              ),
            ),
            const SizedBox(height: 20),

            // Field Model
            Text('MODEL', style: AppTextStyles.label),
            const SizedBox(height: 8),
            TextField(
              controller: _modelController,
              style: AppTextStyles.body,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'Contoh: Brio, Avanza',
                prefixIcon: Icon(Icons.directions_car_outlined, size: 18),
              ),
            ),
            const SizedBox(height: 20),

            // Field Tahun
            Text('TAHUN', style: AppTextStyles.label),
            const SizedBox(height: 8),
            TextField(
              controller: _yearController,
              style: AppTextStyles.body,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleSubmit(),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              decoration: const InputDecoration(
                hintText: 'Contoh: 2023',
                prefixIcon: Icon(Icons.calendar_today_outlined, size: 18),
              ),
            ),
            const SizedBox(height: 32),

            // Error
            if (_error != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 13, vertical: 11),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: AppColors.error),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.error, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_error!,
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.error)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: _isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.green,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _handleSubmit,
                      child: Text(_isEdit ? 'SIMPAN PERUBAHAN' : 'TAMBAH'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}