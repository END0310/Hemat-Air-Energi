import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_colors.dart';
import '../data/database_helper.dart';
import '../models/device_models.dart';
import '../models/electricity_profile_model.dart';
import '../services/energy_calculator_service.dart';

class CalculatorScreen extends StatefulWidget {
  final Device? initialDevice;

  const CalculatorScreen({
    super.key,
    this.initialDevice,
  });

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();

  final _powerController = TextEditingController();
  final _hoursController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');

  List<Device> _devices = [];
  Device? _selectedDevice;
  ElectricityProfile? _profile;
  bool _isLoading = true;

  double _dailyKwh = 0.0;
  double _monthlyKwh = 0.0;
  double _dailyCost = 0.0;
  double _monthlyCost = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _powerController.dispose();
    _hoursController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final devices = await DatabaseHelper.instance.getDevices();
    final profile = await DatabaseHelper.instance.getElectricityProfile();

    if (mounted) {
      setState(() {
        _devices = devices;
        _profile = profile;
        _isLoading = false;

        if (widget.initialDevice != null) {
          _selectDevice(widget.initialDevice!);
        } else if (_devices.isNotEmpty) {
          _selectDevice(_devices.first);
        } else {
          _powerController.text = '500';
          _hoursController.text = '6';
          _quantityController.text = '1';
          _recalculate();
        }
      });
    }
  }

  void _selectDevice(Device device) {
    _selectedDevice = device;
    _powerController.text = device.powerWatt.toStringAsFixed(0);
    _hoursController.text = device.dailyHours.toStringAsFixed(1);
    _quantityController.text = device.quantity.toString();
    _recalculate();
  }

  void _recalculate() {
    final power = double.tryParse(_powerController.text) ?? 0.0;
    final hours = double.tryParse(_hoursController.text) ?? 0.0;
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final tariff = _profile?.tariffPerKwh ?? 1444.70;

    final daily = EnergyCalculatorService.calculateDailyKwh(
      powerWatt: power,
      dailyHours: hours,
      quantity: quantity,
    );
    final monthly = EnergyCalculatorService.calculateMonthlyKwh(daily);
    final dailyCost = EnergyCalculatorService.calculateCost(kwh: daily, tariffPerKwh: tariff);
    final monthlyCost = EnergyCalculatorService.calculateCost(kwh: monthly, tariffPerKwh: tariff);

    setState(() {
      _dailyKwh = daily;
      _monthlyKwh = monthly;
      _dailyCost = dailyCost;
      _monthlyCost = monthlyCost;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Kalkulator Konsumsi kWh',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTariffBanner(),
                    const SizedBox(height: 16),
                    _buildDeviceSelector(),
                    const SizedBox(height: 16),
                    _buildInputCard(),
                    const SizedBox(height: 20),
                    _buildCalculationResults(),
                    const SizedBox(height: 16),
                    _buildDisclaimerCard(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTariffBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt, color: AppColors.primaryGreen, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tarif Listrik Terpasang',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_profile?.category ?? "R-1/TR"} • ${_profile?.powerVa ?? 1300} VA',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  'Rp ${(_profile?.tariffPerKwh ?? 1444.70).toStringAsFixed(2)} / kWh (Resmi PLN)',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Tarif Resmi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pilih dari Perangkat Tersimpan (Opsional)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          InputDecorator(
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Device?>(
                value: _selectedDevice,
                isExpanded: true,
                hint: const Text('Input Manual / Pilih Perangkat'),
                items: [
                  const DropdownMenuItem<Device?>(
                    value: null,
                    child: Text('Custom / Manual Input'),
                  ),
              ..._devices.map((device) {
                return DropdownMenuItem<Device?>(
                  value: device,
                  child: Text(
                    '${device.name} (${device.powerWatt.toStringAsFixed(0)}W, ${device.quantity} unit, ${device.dailyHours.toStringAsFixed(1)} jam)',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }),
            ],
            onChanged: (Device? val) {
              if (val != null) {
                _selectDevice(val);
              } else {
                setState(() => _selectedDevice = null);
              }
            },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Parameter Perangkat',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _powerController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
            decoration: const InputDecoration(
              labelText: 'Daya Listrik',
              suffixText: 'Watt',
              prefixIcon: Icon(Icons.flash_on, color: AppColors.primaryGreen),
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _recalculate(),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Daya watt wajib diisi';
              final n = double.tryParse(val.trim());
              if (n == null || n <= 0) return 'Daya harus lebih dari 0 Watt';
              return null;
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Jumlah',
                    suffixText: 'Unit',
                    prefixIcon: Icon(Icons.pin, color: AppColors.primaryGreen),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _recalculate(),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Jumlah wajib diisi';
                    final n = int.tryParse(val.trim());
                    if (n == null || n <= 0) return 'Min. 1 unit';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _hoursController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                  decoration: const InputDecoration(
                    labelText: 'Durasi / Hari',
                    suffixText: 'Jam',
                    prefixIcon: Icon(Icons.schedule, color: AppColors.primaryGreen),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _recalculate(),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Durasi wajib diisi';
                    final n = double.tryParse(val.trim());
                    if (n == null || n <= 0 || n > 24) return 'Batas 0.1 - 24 jam';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationResults() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGreen,
            AppColors.primaryGreen.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'HASIL PERHITUNGAN',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.yellowAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Estimasi',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'Konsumsi Harian',
                  value: '${_dailyKwh.toStringAsFixed(2)} kWh',
                  subtext: 'per hari',
                ),
              ),
              Container(width: 1, height: 48, color: Colors.white24),
              Expanded(
                child: _buildMetricTile(
                  label: 'Konsumsi Bulanan',
                  value: '${_monthlyKwh.toStringAsFixed(1)} kWh',
                  subtext: '30 hari pemakaian',
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 28),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'Estimasi Biaya Harian',
                  value: 'Rp ${_dailyCost.toStringAsFixed(0)}',
                  subtext: 'per hari',
                ),
              ),
              Container(width: 1, height: 48, color: Colors.white24),
              Expanded(
                child: _buildMetricTile(
                  label: 'Estimasi Biaya Bulanan',
                  value: 'Rp ${_monthlyCost.toStringAsFixed(0)}',
                  subtext: 'per bulan',
                  highlight: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required String subtext,
    bool highlight = false,
  }) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: highlight ? AppColors.yellowAccent : Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          subtext,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildDisclaimerCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.textSecondary, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Perhatian: Seluruh nilai di atas adalah hasil ESTIMASI teoretis berdasarkan spesifikasi daya dan durasi penggunaan. '
              'Konsumsi aktual riil diperoleh dari pencatatan meter fisik dan transaksi token listrik pada menu Monitoring.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
