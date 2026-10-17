import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_colors.dart';
import '../data/database_helper.dart';
import '../models/device_models.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _powerController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _hoursController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _powerController.dispose();
    _quantityController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _saveDevice() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final name = _nameController.text.trim();
      final power = double.parse(_powerController.text.trim());
      final quantity = int.parse(_quantityController.text.trim());
      final hours = double.parse(_hoursController.text.trim());

      final newDevice = Device(
        name: name,
        powerWatt: power,
        quantity: quantity,
        dailyHours: hours,
      );

      await DatabaseHelper.instance.insertDevice(newDevice);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan perangkat: $e'),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Tambah Perangkat',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primaryGreen),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Isi data spesifikasi daya perangkat elektronik Anda dengan benar.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textDark,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionLabel('Nama Perangkat'),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration(
                  hintText: 'Contoh: Kipas Angin, Kulkas Mini',
                  prefixIcon: Icons.devices,
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama perangkat wajib diisi';
                  }
                  if (value.trim().length < 2) {
                    return 'Nama perangkat minimal 2 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),

              _buildSectionLabel('Daya Perangkat (Watt)'),
              TextFormField(
                controller: _powerController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _inputDecoration(
                  hintText: 'Contoh: 45 atau 120.5',
                  prefixIcon: Icons.bolt,
                  suffixText: 'Watt',
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Daya perangkat wajib diisi';
                  }
                  final power = double.tryParse(value.trim());
                  if (power == null) {
                    return 'Masukkan angka daya yang valid';
                  }
                  if (power <= 0) {
                    return 'Daya harus lebih besar dari 0 Watt';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),

              _buildSectionLabel('Jumlah Unit'),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _inputDecoration(
                  hintText: 'Contoh: 1',
                  prefixIcon: Icons.format_list_numbered,
                  suffixText: 'Unit',
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Jumlah unit wajib diisi';
                  }
                  final qty = int.tryParse(value.trim());
                  if (qty == null || qty <= 0) {
                    return 'Jumlah unit minimal 1';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),

              _buildSectionLabel('Lama Penggunaan per Hari (Jam)'),
              TextFormField(
                controller: _hoursController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _inputDecoration(
                  hintText: 'Contoh: 8 atau 4.5',
                  prefixIcon: Icons.timer_outlined,
                  suffixText: 'Jam/hari',
                ),
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lama penggunaan wajib diisi';
                  }
                  final hours = double.tryParse(value.trim());
                  if (hours == null) {
                    return 'Masukkan angka jam yang valid';
                  }
                  if (hours <= 0) {
                    return 'Lama penggunaan harus lebih dari 0 jam';
                  }
                  if (hours > 24) {
                    return 'Penggunaan tidak boleh melebihi 24 jam sehari';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isSaving ? null : _saveDevice,
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Simpan Perangkat',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    String? suffixText,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      prefixIcon: Icon(prefixIcon, color: AppColors.primaryGreen, size: 22),
      suffixText: suffixText,
      suffixStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.errorRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.errorRed, width: 2),
      ),
    );
  }
}
