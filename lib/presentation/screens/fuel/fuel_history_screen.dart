import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/driver_provider.dart';
import '../../widgets/floating_bottom_nav.dart';

class FuelHistoryScreen extends StatefulWidget {
  const FuelHistoryScreen({super.key});

  @override
  State<FuelHistoryScreen> createState() => _FuelHistoryScreenState();
}

class _FuelHistoryScreenState extends State<FuelHistoryScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  // Form controllers
  final _fuelFormKey = GlobalKey<FormState>();

  // Fuel form fields
  int? _selectedVehicleId;
  String _startMeter = '';
  String _fuelQty = '';
  String _fuelCostPerUnit = '';
  String _fuelFrom = '';
  String _fuelNote = '';
  DateTime _fuelDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Add listener to refresh fuel history when switching to history tab
    _tabController.addListener(() {
      if (_tabController.index == 1 && _tabController.previousIndex != 1) { // Fuel History tab
        Provider.of<DriverProvider>(context, listen: false).fetchFuelHistory();
      }
    });

    // Fetch fuel history when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DriverProvider>(context, listen: false).fetchFuelHistory();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getAvailableVehicles(DriverProvider driverProvider) {
    final Set<Map<String, dynamic>> vehicles = {};

    // Get vehicles from trips
    for (final trip in driverProvider.trips) {
      vehicles.add({
        'id': trip.vehicle.id,
        'display': '${trip.vehicle.model} - ${trip.vehicle.numberPlate}',
      });
    }

    return vehicles.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DriverProvider>(
      builder: (context, driverProvider, child) {
        if (driverProvider.isLoading) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(height: 60, child: Center(child: FloatingBottomNav(currentIndex: 3))),
            ),
          );
        }

        if (driverProvider.errorMessage != null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Ionicons.alert_circle_outline, size: 64, color: Colors.red.withValues(alpha: 0.7)),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading fuel history',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    driverProvider.errorMessage!,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => driverProvider.fetchFuelHistory(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: Text(
                      'Retry',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(height: 60, child: Center(child: FloatingBottomNav(currentIndex: 3))),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: Column(
            children: [
              // Header with Gradient
              _buildHeader(),

              // Tab Bar
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.lightPrimary,
                  indicatorWeight: 3,
                  labelColor: AppColors.lightPrimary,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: GoogleFonts.poppins(fontSize: 14),
                  tabs: const [
                    Tab(text: 'Add Fuel'),
                    Tab(text: 'Fuel History'),
                  ],
                ),
              ),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAddFuelTab(),
                    _buildFuelHistoryTab(driverProvider.fuelHistory),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SizedBox(height: 60, child: Center(child: FloatingBottomNav(currentIndex: 3))),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 10, 20, 25),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1C5479), Color(0xFF2E8BC0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Row(
                children: [
                  Image.asset(
                    'assets/New/Group 9757.png',
                    height: 30,
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Fuel Management',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 48), // Balance for back button
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddFuelTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add Fuel Form
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Form(
              key: _fuelFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Ionicons.add_circle_outline, color: AppColors.lightPrimary, size: 24),
                      const SizedBox(width: 10),
                      Text(
                        'Add Fuel Record',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Vehicle Selection
                  Consumer<DriverProvider>(
                    builder: (context, driverProvider, child) {
                      final vehicles = _getAvailableVehicles(driverProvider);
                      return DropdownButtonFormField<int>(
                        initialValue: _selectedVehicleId,
                        decoration: const InputDecoration(
                          labelText: 'Vehicle *',
                          hintText: 'Select a vehicle',
                          border: OutlineInputBorder(),
                        ),
                        items: vehicles.map((vehicle) {
                          return DropdownMenuItem<int>(
                            value: vehicle['id'],
                            child: Text(vehicle['display']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedVehicleId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a vehicle';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildTextField('Start Meter Reading', '', _startMeter, (value) => _startMeter = value),
                  const SizedBox(height: 15),
                  _buildTextField('Quantity (Liters)', 'L', _fuelQty, (value) => _fuelQty = value),
                  const SizedBox(height: 15),
                  _buildTextField('Cost per Unit', '₹', _fuelCostPerUnit, (value) => _fuelCostPerUnit = value),
                  const SizedBox(height: 15),
                  _buildTextField('Fuel Station', '', _fuelFrom, (value) => _fuelFrom = value),
                  const SizedBox(height: 15),
                  _buildTextField('Note', '', _fuelNote, (value) => _fuelNote = value),
                  const SizedBox(height: 15),
                  _buildDateField('Date', _fuelDate, (date) => setState(() => _fuelDate = date)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _addFuelEntry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                        shadowColor: AppColors.lightPrimary.withValues(alpha: 0.3),
                      ),
                      child: Text(
                        'Add Fuel Entry',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFuelHistoryTab(List fuelHistory) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fuel Records
          Text(
            'Fuel Records',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),

          if (fuelHistory.isEmpty)
            _buildEmptyState('No fuel records found', 'Add your first fuel record using the Add Fuel tab')
          else
            ...fuelHistory.map((fuel) => _buildFuelRecordCard(fuel)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Ionicons.document_text_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFuelRecordCard(dynamic fuel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fuel Entry #${fuel['fuel_id'] ?? fuel['id'] ?? 'N/A'}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '₹${_calculateTotalCost(fuel).toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Ionicons.calendar_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                fuel['date'] ?? 'N/A',
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              ),
              const SizedBox(width: 16),
              Icon(Ionicons.water_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${double.tryParse(fuel['qty']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00'} L',
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              ),
            ],
          ),
          if (fuel['fuel_from'] != null && fuel['fuel_from'].toString().isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Ionicons.location_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  fuel['fuel_from'].toString(),
                  style: GoogleFonts.poppins(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
          if (fuel['note'] != null && fuel['note'].toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              fuel['note'].toString(),
              style: GoogleFonts.poppins(
                fontStyle: FontStyle.italic,
                color: Colors.grey[700],
              ),
            ),
          ],
        ],
      ),
    );
  }

  double _calculateTotalCost(dynamic fuel) {
    final qty = double.tryParse(fuel['qty']?.toString() ?? '0') ?? 0.0;
    final costPerUnit = double.tryParse(fuel['cost_per_unit']?.toString() ?? '0') ?? 0.0;
    return qty * costPerUnit;
  }

  Widget _buildTextField(String label, String prefix, String value, Function(String) onChanged) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix.isNotEmpty ? '$prefix ' : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E8BC0)),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
      onChanged: onChanged,
    );
  }

  Widget _buildDateField(String label, DateTime value, Function(DateTime) onChanged) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2E8BC0)),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${value.day}/${value.month}/${value.year}',
              style: GoogleFonts.poppins(),
            ),
            Icon(Ionicons.calendar_outline, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _addFuelEntry() async {
    if (_fuelFormKey.currentState!.validate()) {
      if (_selectedVehicleId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a vehicle'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validate numeric fields
      final startMeter = double.tryParse(_startMeter);
      final qty = double.tryParse(_fuelQty);
      final costPerUnit = double.tryParse(_fuelCostPerUnit);

      if (startMeter == null || qty == null || costPerUnit == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter valid numeric values'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        final driverProvider = Provider.of<DriverProvider>(context, listen: false);
        await driverProvider.addFuelEntry(
          vehicleId: _selectedVehicleId!,
          startMeter: startMeter,
          qty: qty,
          costPerUnit: costPerUnit,
          date: _fuelDate.toString().split(' ')[0],
          fuelFrom: _fuelFrom.isNotEmpty ? _fuelFrom : null,
          note: _fuelNote.isNotEmpty ? _fuelNote : null,
        );

        // Clear form
        setState(() {
          _selectedVehicleId = null;
          _startMeter = '';
          _fuelQty = '';
          _fuelCostPerUnit = '';
          _fuelFrom = '';
          _fuelNote = '';
          _fuelDate = DateTime.now();
        });
        _fuelFormKey.currentState!.reset();

        // Switch to fuel history tab
        _tabController.animateTo(1);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fuel entry added successfully', style: GoogleFonts.poppins()),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add fuel entry: ${e.toString()}', style: GoogleFonts.poppins()),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    }
  }
}