import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

import '../../widgets/floating_bottom_nav.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/driver_provider.dart';
import '../../../data/models/trip_model.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  // Form controllers
  final _incomeFormKey = GlobalKey<FormState>();
  final _expenseFormKey = GlobalKey<FormState>();

  // Income form fields
  String _selectedIncomeVehicle = '';
  String _incomeType = '';
  String _mileage = '';
  String _incomeAmount = '';
  DateTime _incomeDate = DateTime.now();

  // Expense form fields
  String _selectedExpenseVehicle = '';
  String _expenseType = '';
  String _expenseAmount = '';
  String _expenseNote = '';
  DateTime _expenseDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Fetch expenses data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final driverProvider = Provider.of<DriverProvider>(context, listen: false);
      driverProvider.fetchExpenses();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              child: SizedBox(height: 60, child: Center(child: FloatingBottomNav(currentIndex: 2))),
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
                    'Error loading expenses',
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
                    onPressed: () => driverProvider.fetchExpenses(),
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
              child: SizedBox(height: 60, child: Center(child: FloatingBottomNav(currentIndex: 2))),
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
                    Tab(text: 'Income'),
                    Tab(text: 'Expenses'),
                  ],
                ),
              ),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildIncomeTab(driverProvider.expenses),
                    _buildExpenseTab(driverProvider.expenses),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SizedBox(height: 60, child: Center(child: FloatingBottomNav(currentIndex: 2))),
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
            'Expense Management',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Track your income & expenses',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeTab(List<Expense> expenses) {
    final incomeRecords = expenses.where((expense) => expense.category == 'income').toList();
    final totalIncome = incomeRecords.fold<double>(0, (sum, record) => sum + record.amount);
    final todayIncome = incomeRecords
        .where((record) => record.date == DateTime.now().toString().split(' ')[0])
        .fold<double>(0, (sum, record) => sum + record.amount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Today\'s Income',
                  '₹${todayIncome.toStringAsFixed(2)}',
                  Ionicons.trending_up_outline,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildSummaryCard(
                  'Total Income',
                  '₹${totalIncome.toStringAsFixed(2)}',
                  Ionicons.wallet_outline,
                  AppColors.lightPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Add Income Form
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
              key: _incomeFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Ionicons.add_circle_outline, color: AppColors.lightPrimary, size: 24),
                      const SizedBox(width: 10),
                      Text(
                        'Add Income Record',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildDropdownField('Vehicle', 'Select vehicle...', _selectedIncomeVehicle, (value) {
                    setState(() => _selectedIncomeVehicle = value ?? '');
                  }),
                  const SizedBox(height: 15),
                  _buildDropdownField('Income Type', 'Select type...', _incomeType, (value) {
                    setState(() => _incomeType = value ?? '');
                  }),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: _buildTextField('Mileage', 'km', _mileage, (value) => _mileage = value)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildTextField('Amount', '₹', _incomeAmount, (value) => _incomeAmount = value)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildDateField('Date', _incomeDate, (date) => setState(() => _incomeDate = date)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_incomeFormKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Income record added successfully', style: GoogleFonts.poppins()),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                        shadowColor: Colors.green.withValues(alpha: 0.3),
                      ),
                      child: Text(
                        'Add Income',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Income Records
          Text(
            'Income Records',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),

          if (incomeRecords.isEmpty)
            _buildEmptyState('No income records found', 'Add your first income record above')
          else
            ...incomeRecords.map((record) => _buildIncomeRecordCard(record)),
        ],
      ),
    );
  }

  Widget _buildExpenseTab(List<Expense> expenses) {
    final expenseRecords = expenses.where((expense) => expense.category == 'expense').toList();
    final totalExpense = expenseRecords.fold<double>(0, (sum, record) => sum + record.amount);
    final todayExpense = expenseRecords
        .where((record) => record.date == DateTime.now().toString().split(' ')[0])
        .fold<double>(0, (sum, record) => sum + record.amount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Today\'s Expenses',
                  '₹${todayExpense.toStringAsFixed(2)}',
                  Ionicons.trending_down_outline,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildSummaryCard(
                  'Total Expenses',
                  '₹${totalExpense.toStringAsFixed(2)}',
                  Ionicons.card_outline,
                  Colors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Add Expense Form
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
              key: _expenseFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Ionicons.remove_circle_outline, color: AppColors.lightPrimary, size: 24),
                      const SizedBox(width: 10),
                      Text(
                        'Add Expense Record',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildDropdownField('Vehicle', 'Select vehicle...', _selectedExpenseVehicle, (value) {
                    setState(() => _selectedExpenseVehicle = value ?? '');
                  }),
                  const SizedBox(height: 15),
                  _buildDropdownField('Expense Type', 'Select type...', _expenseType, (value) {
                    setState(() => _expenseType = value ?? '');
                  }),
                  const SizedBox(height: 15),
                  _buildTextField('Amount', '₹', _expenseAmount, (value) => _expenseAmount = value),
                  const SizedBox(height: 15),
                  _buildTextField('Note', '', _expenseNote, (value) => _expenseNote = value),
                  const SizedBox(height: 15),
                  _buildDateField('Date', _expenseDate, (date) => setState(() => _expenseDate = date)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_expenseFormKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Expense record added successfully', style: GoogleFonts.poppins()),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                        shadowColor: Colors.red.withValues(alpha: 0.3),
                      ),
                      child: Text(
                        'Add Expense',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Expense Records
          Text(
            'Expense Records',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),

          if (expenseRecords.isEmpty)
            _buildEmptyState('No expense records found', 'Add your first expense record above')
          else
            ...expenseRecords.map((record) => _buildExpenseRecordCard(record)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String amount, IconData icon, Color color) {
    return Container(
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
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            amount,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, String hint, String value, Function(String?) onChanged) {
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: value.isEmpty ? null : value,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            hint: Text(
              hint,
              style: GoogleFonts.poppins(color: Colors.grey.shade400),
            ),
            items: ['Option 1', 'Option 2', 'Option 3'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: GoogleFonts.poppins()),
              );
            }).toList(),
            onChanged: onChanged,
            validator: (value) => value == null || value.isEmpty ? 'This field is required' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String prefix, String value, Function(String) onChanged) {
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
          initialValue: value,
          decoration: InputDecoration(
            prefixText: prefix.isNotEmpty ? '$prefix ' : null,
            prefixStyle: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600),
            filled: true,
            fillColor: Colors.grey.shade50,
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
          keyboardType: prefix == '₹' || prefix == 'km' ? TextInputType.number : TextInputType.text,
          validator: (value) => value?.isEmpty ?? true ? 'This field is required' : null,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime selectedDate, Function(DateTime) onDateChanged) {
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
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (picked != null) {
              onDateChanged(picked);
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
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
      ],
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
          Icon(Ionicons.document_text_outline, size: 48, color: Colors.grey.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
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

  Widget _buildIncomeRecordCard(Expense record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
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
                child: Text(
                  '${record.vehicleMaker} ${record.vehicleModel}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  record.expenseType,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Ionicons.calendar_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                record.date,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(width: 16),
              Icon(Ionicons.car_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                record.licensePlate,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${record.amount.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              IconButton(
                icon: Icon(Ionicons.trash_outline, color: Colors.red.withValues(alpha: 0.7)),
                onPressed: () {
                  // TODO: Implement delete functionality
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseRecordCard(Expense record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
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
                child: Text(
                  '${record.vehicleMaker} ${record.vehicleModel}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  record.expenseType,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Ionicons.calendar_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                record.date,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(width: 16),
              Icon(Ionicons.car_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                record.licensePlate,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          if (record.note != null && record.note!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Ionicons.document_text_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    record.note!,
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${record.amount.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              IconButton(
                icon: Icon(Ionicons.trash_outline, color: Colors.red.withValues(alpha: 0.7)),
                onPressed: () {
                  // TODO: Implement delete functionality
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}



