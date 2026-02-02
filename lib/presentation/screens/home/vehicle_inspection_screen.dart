import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

import '../../widgets/floating_bottom_nav.dart';
import '../../../core/constants/app_colors.dart';

class VehicleInspectionScreen extends StatefulWidget {
  const VehicleInspectionScreen({super.key});

  @override
  State<VehicleInspectionScreen> createState() => _VehicleInspectionScreenState();
}

class _VehicleInspectionScreenState extends State<VehicleInspectionScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _inspections = [
    {
      'vehicle': 'Toyota Camry',
      'registration': 'MH12AB1234',
      'reviewBy': 'John Smith',
      'date': '2026-01-23',
      'status': 'Passed',
      'outgoingKm': '45000',
      'incomingKm': '45250',
      'fuelOutgoing': '3/4',
      'fuelIncoming': '1/2',
    },
    {
      'vehicle': 'Honda City',
      'registration': 'MH12CD5678',
      'reviewBy': 'Sarah Johnson',
      'date': '2026-01-22',
      'status': 'Failed',
      'outgoingKm': '38000',
      'incomingKm': '38200',
      'fuelOutgoing': 'Full',
      'fuelIncoming': '3/4',
    },
    {
      'vehicle': 'Hyundai Verna',
      'registration': 'MH12EF9012',
      'reviewBy': 'Mike Davis',
      'date': '2026-01-21',
      'status': 'Passed',
      'outgoingKm': '52000',
      'incomingKm': '52200',
      'fuelOutgoing': '1/2',
      'fuelIncoming': '1/4',
    },
  ];

  // Form state variables
  final _formKey = GlobalKey<FormState>();
  String _fuelOutgoing = '';
  String _fuelIncoming = '';
  DateTime _outgoingDateTime = DateTime.now();
  DateTime _incomingDateTime = DateTime.now();

  // Inspection checklist items with toggle states
  final Map<String, bool> _checklistItems = {
    'Engine Oil Level': false,
    'Brake Fluid Level': false,
    'Coolant Level': false,
    'Battery Condition': false,
    'Tire Pressure': false,
    'Lights Working': false,
    'Horn Working': false,
    'Seat Belts': false,
    'Emergency Kit': false,
    'First Aid Kit': false,
    'Fire Extinguisher': false,
    'Vehicle Cleanliness': false,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                Tab(text: 'Add Inspection'),
                Tab(text: 'Inspection History'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInspectionForm(),
                _buildInspectionHistory(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: SizedBox(height: 60, child: Center(child: FloatingBottomNav(currentIndex: 0))),
      ),
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
                    errorBuilder: (_,__,___) => const SizedBox(),
                  ),
                  const SizedBox(width: 8),
                  Image.asset(
                    'assets/New/Group 9756.png',
                    height: 25,
                    errorBuilder: (_,__,___) => const SizedBox(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            'Vehicle Inspection',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Ensure vehicle safety & maintenance',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle Selection Card
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
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Ionicons.car_outline, color: AppColors.lightPrimary, size: 24),
                      const SizedBox(width: 10),
                      Text(
                        'Vehicle Details',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildFormField('Select Vehicle', 'Choose vehicle...', Icons.directions_car),
                  const SizedBox(height: 15),
                  _buildFormField('Registration Number', 'Enter registration number', Icons.confirmation_number),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Meter Reading Card
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Ionicons.speedometer_outline, color: AppColors.lightPrimary, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'Meter Reading (KM)',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildFormField('Outgoing', 'Enter km', Icons.arrow_upward)),
                    const SizedBox(width: 15),
                    Expanded(child: _buildFormField('Incoming', 'Enter km', Icons.arrow_downward)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Fuel Level Card
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Ionicons.water_outline, color: AppColors.lightPrimary, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'Fuel Level',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildFuelLevelField('Outgoing'),
                const SizedBox(height: 15),
                _buildFuelLevelField('Incoming'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Date & Time Card
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Ionicons.calendar_outline, color: AppColors.lightPrimary, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'Date & Time',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDateTimeField('Outgoing'),
                const SizedBox(height: 15),
                _buildDateTimeField('Incoming'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Checklist Card
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Ionicons.checkmark_circle_outline, color: AppColors.lightPrimary, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'Inspection Checklist',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ..._checklistItems.entries.map((entry) => Column(
                  children: [
                    _buildChecklistItem(entry.key, entry.value),
                    const SizedBox(height: 10),
                  ],
                )),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Photos Card
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Ionicons.camera_outline, color: AppColors.lightPrimary, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'Photos',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildImageField(),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Inspection submitted successfully', style: GoogleFonts.poppins()),
                      backgroundColor: AppColors.lightPrimary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 5,
                shadowColor: AppColors.lightPrimary.withValues(alpha: 0.3),
              ),
              child: Text(
                'Submit Inspection',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildInspectionHistory() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _inspections.length,
      itemBuilder: (context, index) {
        final inspection = _inspections[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          inspection['vehicle'],
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          inspection['registration'],
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: inspection['status'] == 'Passed' ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      inspection['status'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: inspection['status'] == 'Passed' ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _buildHistoryDetail('Outgoing KM', inspection['outgoingKm']),
                  ),
                  Expanded(
                    child: _buildHistoryDetail('Incoming KM', inspection['incomingKm']),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildHistoryDetail('Fuel Out', inspection['fuelOutgoing']),
                  ),
                  Expanded(
                    child: _buildHistoryDetail('Fuel In', inspection['fuelIncoming']),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reviewed by ${inspection['reviewBy']}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    inspection['date'],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildFormField(String label, String hint, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade50,
            prefixIcon: Icon(icon, color: AppColors.lightPrimary.withValues(alpha: 0.7)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.lightPrimary, width: 1.5),
            ),
          ),
          style: GoogleFonts.poppins(fontSize: 14),
          validator: (value) => value?.isEmpty ?? true ? 'This field is required' : null,
        ),
      ],
    );
  }

  Widget _buildFuelLevelField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildFuelOption('1/4'),
            const SizedBox(width: 8),
            _buildFuelOption('1/2'),
            const SizedBox(width: 8),
            _buildFuelOption('3/4'),
            const SizedBox(width: 8),
            _buildFuelOption('Full'),
          ],
        ),
      ],
    );
  }

  Widget _buildFuelOption(String option) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (option.contains('Outgoing')) {
              _fuelOutgoing = option;
            } else {
              _fuelIncoming = option;
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: (option.contains('Outgoing') ? _fuelOutgoing : _fuelIncoming) == option
                ? AppColors.lightPrimary
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: (option.contains('Outgoing') ? _fuelOutgoing : _fuelIncoming) == option
                  ? AppColors.lightPrimary
                  : Colors.grey.shade300,
            ),
          ),
          child: Text(
            option,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: (option.contains('Outgoing') ? _fuelOutgoing : _fuelIncoming) == option
                  ? Colors.white
                  : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (pickedDate != null) {
              final TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (pickedTime != null) {
                setState(() {
                  if (label.contains('Outgoing')) {
                    _outgoingDateTime = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                  } else {
                    _incomingDateTime = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                  }
                });
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Ionicons.calendar_outline, color: AppColors.lightPrimary.withValues(alpha: 0.7)),
                const SizedBox(width: 12),
                Text(
                  label.contains('Outgoing')
                      ? '${_outgoingDateTime.day}/${_outgoingDateTime.month}/${_outgoingDateTime.year} ${_outgoingDateTime.hour}:${_outgoingDateTime.minute.toString().padLeft(2, '0')}'
                      : '${_incomingDateTime.day}/${_incomingDateTime.month}/${_incomingDateTime.year} ${_incomingDateTime.hour}:${_incomingDateTime.minute.toString().padLeft(2, '0')}',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistItem(String item, bool isChecked) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _checklistItems[item] = !isChecked;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isChecked ? AppColors.lightPrimary.withValues(alpha: 0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isChecked ? AppColors.lightPrimary.withValues(alpha: 0.3) : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isChecked ? Ionicons.checkmark_circle : Ionicons.ellipse_outline,
              color: isChecked ? AppColors.lightPrimary : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isChecked ? Colors.black87 : Colors.grey[700],
                  fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageField() {
    return GestureDetector(
      onTap: () {
        // TODO: Implement image picker
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image picker coming soon', style: GoogleFonts.poppins()),
            backgroundColor: AppColors.lightPrimary,
          ),
        );
      },
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Ionicons.camera_outline, color: Colors.grey, size: 32),
            const SizedBox(height: 8),
            Text(
              'Tap to add photos',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


