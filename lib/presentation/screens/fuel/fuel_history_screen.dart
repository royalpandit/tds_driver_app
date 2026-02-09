import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:traveldesk_driver/data/models/fuel/fuel_history_model.dart';

import '../../providers/driver_provider.dart';
import '../../widgets/floating_bottom_nav.dart';
import '../../../core/constants/app_colors.dart';

class FuelHistoryScreen extends StatefulWidget {
  const FuelHistoryScreen({super.key});

  @override
  State<FuelHistoryScreen> createState() => _FuelHistoryScreenState();
}

class _FuelHistoryScreenState extends State<FuelHistoryScreen>
    with TickerProviderStateMixin {

  String _fuelFromType = "Fuel Station";

  late TabController _tabController;

  final _fuelFormKey = GlobalKey<FormState>();

  int? _selectedVehicleId;
  int? _selectedStationId;
  int? _selectedFuelTypeId;

  String _startMeter = '';
  String _fuelQty = '';
  String _fuelCost = '';

  String _reference = '';
  String _note = '';

  bool _completeFill = false;

  File? _selectedImage;

  DateTime _fuelDate = DateTime.now();

  final ImagePicker _picker = ImagePicker();



  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DriverProvider>(context, listen: false);

      provider.fetchDriverDetails(); // ✅ load driver + vehicle
      provider.fetchFuelHistory();
      provider.fetchFuelStations();
    });
  }


  List<Map<String, dynamic>> _getVehicles(DriverProvider provider) {

    final details = provider.driverDetails;

    if (details == null || details.vehicleInfo == null) {
      return [];
    }

    final vehicle = details.vehicleInfo!;

    return [
      {
        'id': vehicle.id,
        'display':
        '${vehicle.makeName ?? ''} ${vehicle.modelName ?? ''} - ${vehicle.licensePlate ?? ''}',
      }
    ];
  }


  // ================= IMAGE =================

  Future<void> _pickImage(ImageSource source) async {
    final img = await _picker.pickImage(source: source);
    if (img != null) setState(() => _selectedImage = File(img.path));
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Consumer<DriverProvider>(
      builder: (context, provider, _) {

        final vehicles = _getVehicles(provider);

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: Column(
            children: [

              _header(),

              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.lightPrimary,
                  labelColor: AppColors.lightPrimary,
                  tabs: const [
                    Tab(text: "Add Fuel"),
                    Tab(text: "Fuel History"),
                  ],
                ),
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _addFuelTab(provider, vehicles),
                    _historyTab(provider.fuelHistory),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SizedBox(
              height: 60,
              child: FloatingBottomNav(currentIndex: 3),
            ),
          ),
        );
      },
    );
  }

  Widget _header() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 10,
        20,
        25,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1C5479), Color(0xFF2E8BC0)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: ()=>Navigator.pop(context),
            icon: const Icon(Icons.arrow_back,color:Colors.white),
          ),
          Text(
            "Fuel Management",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ================= ADD FUEL =================

  Widget _addFuelTab(
      DriverProvider provider,
      List<Map<String, dynamic>> vehicles) {

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _fuelFormKey,
        child: Column(
          children: [

            _card(Column(children: [

              _vehicleDropdown(vehicles),

              _text("Start Meter", (v)=>_startMeter=v),

              _text("Reference", (v)=>_reference=v),

              _imagePicker(),

              _text("Note", (v)=>_note=v),

              SwitchListTile(
                title: const Text("Complete fill up"),
                value: _completeFill,
                onChanged: (v)=>setState(()=>_completeFill=v),
              )

            ])),

            const SizedBox(height: 20),

            _card(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  "Fuel is coming from",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),

                RadioListTile(
                  title: const Text("Fuel Tank"),
                  value: "Fuel Tank",
                  groupValue: _fuelFromType,
                  onChanged: (v){
                    setState(() {
                      _fuelFromType = v!;
                      _selectedStationId = null;
                      _selectedFuelTypeId = null;
                    });
                  },
                ),

                RadioListTile(
                  title: const Text("N/D"),
                  value: "N/D",
                  groupValue: _fuelFromType,
                  onChanged: (v){
                    setState(() {
                      _fuelFromType = v!;
                      _selectedStationId = null;
                      _selectedFuelTypeId = null;
                    });
                  },
                ),

                RadioListTile(
                  title: const Text("Fuel Station"),
                  value: "Fuel Station",
                  groupValue: _fuelFromType,
                  onChanged: (v){
                    setState(() {
                      _fuelFromType = v!;
                    });
                  },
                ),

                if (_fuelFromType == "Fuel Station") ...[

                  DropdownButtonFormField<int>(
                    value: _selectedStationId,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Select Fuel Station",
                    ),
                    items: provider.fuelStations.map((s) {
                      return DropdownMenuItem(
                        value: s.id,
                        child: Text(s.name),
                      );
                    }).toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedStationId = v;
                        _selectedFuelTypeId = null;
                        _fuelCost = '';
                      });

                      provider.fetchFuelTypes(v!);
                    },
                    validator: (v){
                      if (_fuelFromType == "Fuel Station" && v == null) {
                        return "Select station";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  DropdownButtonFormField<int>(
                    value: _selectedFuelTypeId,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Select Fuel Type",
                    ),
                    items: provider.fuelTypes.map((f) {
                      return DropdownMenuItem(
                        value: f.id,
                        child: Text(f.label),
                      );
                    }).toList(),
                    onChanged: (v) {
                      setState(()=>_selectedFuelTypeId=v);

                      provider.fetchFuelPrice(
                        _selectedStationId!,
                        v!,
                      );
                    },
                    validator: (v){
                      if (_fuelFromType == "Fuel Station" && v == null) {
                        return "Select fuel type";
                      }
                      return null;
                    },
                  ),

                ]

              ],
            )),

            const SizedBox(height: 20),

            _card(Column(children: [

              _text("Qty", (v)=>_fuelQty=v),

              TextFormField(
                readOnly: _fuelFromType == "Fuel Station",
                controller: TextEditingController(
                  text: _fuelFromType == "Fuel Station"
                      ? provider.fuelPrice?.price ?? ""
                      : _fuelCost,
                ),
                decoration: const InputDecoration(
                  labelText: "Cost per unit",
                  border: OutlineInputBorder(),
                ),
                onChanged: (v)=>_fuelCost=v,
                validator: (v)=>v!.isEmpty?"Required":null,
              ),

            ])),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: provider.isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightPrimary,
                ),
                child: provider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Add Fuel"),
              ),
            )

          ],
        ),
      ),
    );
  }

  // ================= HISTORY =================

  Widget _historyTab(List<FuelHistory> list) {

    if(list.isEmpty){
      return const Center(child:Text("No fuel records"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: list.length,
      itemBuilder: (_,i){
        final f = list[i];

        return Card(
          child: ListTile(
            title: Text(
              "${f.vehicle.name} (${f.vehicle.number})",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Date: ${f.formattedDate}"),
                Text("Qty: ${f.qty}"),
                Text("Cost/unit: ₹${f.costPerUnit}"),
                Text("Total: ₹${f.totalCost}"),
                Text("Fuel From: ${f.fuelFrom}"),
              ],
            ),
          ),
        );
      },
    );
  }


  // ================= HELPERS =================

  Widget _card(Widget child)=>Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.black12.withOpacity(.05), blurRadius: 10)],
    ),
    child: child,
  );

  Widget _text(String label, Function(String) onChanged){
    return Padding(
      padding: const EdgeInsets.only(bottom:14),
      child: TextFormField(
        decoration: InputDecoration(labelText: label,border:const OutlineInputBorder()),
        validator: (v)=>v!.isEmpty?"Required":null,
        onChanged: onChanged,
      ),
    );
  }

  Widget _vehicleDropdown(List<Map<String, dynamic>> vehicles) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<int>(
        decoration: const InputDecoration(
          labelText: "Select Vehicle",
          border: OutlineInputBorder(),
        ),
        value: _selectedVehicleId,
        items: vehicles.map<DropdownMenuItem<int>>((v) {
          return DropdownMenuItem<int>(
            value: v['id'] as int,
            child: Text(v['display']),
          );
        }).toList(),
        onChanged: (v) => setState(() => _selectedVehicleId = v),
        validator: (v) => v == null ? "Select vehicle" : null,
      ),
    );
  }


  Widget _imagePicker(){
    return Padding(
      padding: const EdgeInsets.only(bottom:14),
      child: GestureDetector(
        onTap:_showImagePicker,
        child: Container(
          height:140,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _selectedImage==null
              ? const Center(child:Text("Tap to upload image"))
              : Image.file(_selectedImage!,fit:BoxFit.cover),
        ),
      ),
    );
  }

  // ================= SUBMIT =================

  Future<void> _submit() async {

    if(!_fuelFormKey.currentState!.validate()) return;

    final start=double.tryParse(_startMeter);
    final qty=double.tryParse(_fuelQty);

    if(start==null || qty==null){
      _msg("Enter valid numbers");
      return;
    }

    final provider=Provider.of<DriverProvider>(context,listen:false);

    final success=await provider.addFuelEntry(
      vehicleId: _selectedVehicleId!,
      startMeter: start,
      qty: qty,

      costPerUnit: _fuelFromType == "Fuel Station"
          ? double.parse(provider.fuelPrice!.price)
          : double.parse(_fuelCost),

      date: _fuelDate.toString().split(" ")[0],

      fuelFrom: _fuelFromType,

      fuelStationId: _fuelFromType == "Fuel Station"
          ? _selectedStationId
          : null,

      fuelTypeId: _fuelFromType == "Fuel Station"
          ? _selectedFuelTypeId
          : null,

      reference: _reference,
      note: _note,
      complete: _completeFill,

      image: _selectedImage,
    );

    if(success){
      _tabController.animateTo(1);
      _msg("Fuel added successfully",green:true);
    }else{
      _msg(provider.errorMessage ?? "Failed");
    }
  }

  void _msg(String m,{bool green=false}){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(m),
        backgroundColor: green?Colors.green:Colors.red,
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:ionicons/ionicons.dart';
// import 'package:provider/provider.dart';
// import '../../../core/constants/app_colors.dart';
// import '../../providers/driver_provider.dart';
// import '../../widgets/floating_bottom_nav.dart';
//
// class FuelHistoryScreen extends StatefulWidget {
//   const FuelHistoryScreen({super.key});
//
//   @override
//   State<FuelHistoryScreen> createState() => _FuelHistoryScreenState();
// }
//
// class _FuelHistoryScreenState extends State<FuelHistoryScreen> with TickerProviderStateMixin {
//   late TabController _tabController;
//
//   // Form controllers
//   final _fuelFormKey = GlobalKey<FormState>();
//
//   // Fuel form fields
//   int? _selectedVehicleId;
//   String _startMeter = '';
//   String _fuelQty = '';
//   String _fuelCostPerUnit = '';
//   String _fuelFrom = '';
//   String _fuelNote = '';
//   DateTime _fuelDate = DateTime.now();
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//
//     // Add listener to refresh fuel history when switching to history tab
//     _tabController.addListener(() {
//       if (_tabController.index == 1 && _tabController.previousIndex != 1) { // Fuel History tab
//         Provider.of<DriverProvider>(context, listen: false).fetchFuelHistory();
//       }
//     });
//
//     // Fetch fuel history when screen loads
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<DriverProvider>(context, listen: false).fetchFuelHistory();
//     });
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   List<Map<String, dynamic>> _getAvailableVehicles(DriverProvider driverProvider) {
//     final Set<Map<String, dynamic>> vehicles = {};
//
//     // Get vehicles from trips
//     for (final trip in driverProvider.trips) {
//       vehicles.add({
//         'id': trip.vehicle.id,
//         'display': '${trip.vehicle.model} - ${trip.vehicle.numberPlate}',
//       });
//     }
//
//     return vehicles.toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<DriverProvider>(
//       builder: (context, driverProvider, child) {
//         if (driverProvider.isLoading) {
//           return Scaffold(
//             backgroundColor: const Color(0xFFF8F9FA),
//             body: const Center(
//               child: CircularProgressIndicator(),
//             ),
//             bottomNavigationBar: Padding(
//               padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
//               child: SizedBox(height: 60, child: Center(child: FloatingBottomNav(currentIndex: 3))),
//             ),
//           );
//         }
//
//         if (driverProvider.errorMessage != null) {
//           return Scaffold(
//             backgroundColor: const Color(0xFFF8F9FA),
//             body: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Ionicons.alert_circle_outline, size: 64, color: Colors.red.withValues(alpha: 0.7)),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Error loading fuel history',
//                     style: GoogleFonts.poppins(
//                       fontSize: 18,
//                       color: Colors.red,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     driverProvider.errorMessage!,
//                     style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       color: Colors.grey[600],
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: () => driverProvider.fetchFuelHistory(),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.lightPrimary,
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                       padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//                     ),
//                     child: Text(
//                       'Retry',
//                       style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             bottomNavigationBar: Padding(
//               padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
//               child: SizedBox(height: 60, child: Center(child: FloatingBottomNav(currentIndex: 3))),
//             ),
//           );
//         }
//
//         return Scaffold(
//           backgroundColor: const Color(0xFFF8F9FA),
//           body: Column(
//             children: [
//               // Header with Gradient
//               _buildHeader(),
//
//               // Tab Bar
//               Container(
//                 color: Colors.white,
//                 child: TabBar(
//                   controller: _tabController,
//                   indicatorColor: AppColors.lightPrimary,
//                   indicatorWeight: 3,
//                   labelColor: AppColors.lightPrimary,
//                   unselectedLabelColor: Colors.grey,
//                   labelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
//                   unselectedLabelStyle: GoogleFonts.poppins(fontSize: 14),
//                   tabs: const [
//                     Tab(text: 'Add Fuel'),
//                     Tab(text: 'Fuel History'),
//                   ],
//                 ),
//               ),
//
//               // Tab Content
//               Expanded(
//                 child: TabBarView(
//                   controller: _tabController,
//                   children: [
//                     _buildAddFuelTab(),
//                     _buildFuelHistoryTab(driverProvider.fuelHistory),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           bottomNavigationBar: Padding(
//             padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
//             child: SizedBox(height: 60, child: Center(child: FloatingBottomNav(currentIndex: 3))),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildHeader() {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 10, 20, 25),
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Color(0xFF1C5479), Color(0xFF2E8BC0)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
//         boxShadow: [
//           BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
//         ],
//       ),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               IconButton(
//                 onPressed: () => Navigator.pop(context),
//                 icon: const Icon(Icons.arrow_back, color: Colors.white),
//               ),
//               Row(
//                 children: [
//                   Image.asset(
//                     'assets/New/Group 9757.png',
//                     height: 30,
//                     errorBuilder: (_, __, ___) => const SizedBox(),
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     'Fuel Management',
//                     style: GoogleFonts.poppins(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(width: 48), // Balance for back button
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildAddFuelTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Add Fuel Form
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(15),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, 5),
//                 ),
//               ],
//             ),
//             child: Form(
//               key: _fuelFormKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(Ionicons.add_circle_outline, color: AppColors.lightPrimary, size: 24),
//                       const SizedBox(width: 10),
//                       Text(
//                         'Add Fuel Record',
//                         style: GoogleFonts.poppins(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   // Vehicle Selection
//                   Consumer<DriverProvider>(
//                     builder: (context, driverProvider, child) {
//                       final vehicles = _getAvailableVehicles(driverProvider);
//                       return DropdownButtonFormField<int>(
//                         initialValue: _selectedVehicleId,
//                         decoration: const InputDecoration(
//                           labelText: 'Vehicle *',
//                           hintText: 'Select a vehicle',
//                           border: OutlineInputBorder(),
//                         ),
//                         items: vehicles.map((vehicle) {
//                           return DropdownMenuItem<int>(
//                             value: vehicle['id'],
//                             child: Text(vehicle['display']),
//                           );
//                         }).toList(),
//                         onChanged: (value) {
//                           setState(() {
//                             _selectedVehicleId = value;
//                           });
//                         },
//                         validator: (value) {
//                           if (value == null) {
//                             return 'Please select a vehicle';
//                           }
//                           return null;
//                         },
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 15),
//                   _buildTextField('Start Meter Reading', '', _startMeter, (value) => _startMeter = value),
//                   const SizedBox(height: 15),
//                   _buildTextField('Quantity (Liters)', 'L', _fuelQty, (value) => _fuelQty = value),
//                   const SizedBox(height: 15),
//                   _buildTextField('Cost per Unit', '₹', _fuelCostPerUnit, (value) => _fuelCostPerUnit = value),
//                   const SizedBox(height: 15),
//                   _buildTextField('Fuel Station', '', _fuelFrom, (value) => _fuelFrom = value),
//                   const SizedBox(height: 15),
//                   _buildTextField('Note', '', _fuelNote, (value) => _fuelNote = value),
//                   const SizedBox(height: 15),
//                   _buildDateField('Date', _fuelDate, (date) => setState(() => _fuelDate = date)),
//                   const SizedBox(height: 20),
//                   SizedBox(
//                     width: double.infinity,
//                     height: 56,
//                     child: ElevatedButton(
//                       onPressed: _addFuelEntry,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.lightPrimary,
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                         elevation: 5,
//                         shadowColor: AppColors.lightPrimary.withValues(alpha: 0.3),
//                       ),
//                       child: Text(
//                         'Add Fuel Entry',
//                         style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFuelHistoryTab(List fuelHistory) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Fuel Records
//           Text(
//             'Fuel Records',
//             style: GoogleFonts.poppins(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 15),
//
//           if (fuelHistory.isEmpty)
//             _buildEmptyState('No fuel records found', 'Add your first fuel record using the Add Fuel tab')
//           else
//             ...fuelHistory.map((fuel) => _buildFuelRecordCard(fuel)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEmptyState(String title, String subtitle) {
//     return Container(
//       padding: const EdgeInsets.all(40),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Icon(Ionicons.document_text_outline, size: 64, color: Colors.grey[400]),
//           const SizedBox(height: 16),
//           Text(
//             title,
//             style: GoogleFonts.poppins(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: Colors.grey[700],
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             subtitle,
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               color: Colors.grey[500],
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFuelRecordCard(dynamic fuel) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Fuel Entry #${fuel['fuel_id'] ?? fuel['id'] ?? 'N/A'}',
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               Text(
//                 '₹${_calculateTotalCost(fuel).toStringAsFixed(2)}',
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.lightPrimary,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               Icon(Ionicons.calendar_outline, size: 16, color: Colors.grey),
//               const SizedBox(width: 4),
//               Text(
//                 fuel['date'] ?? 'N/A',
//                 style: GoogleFonts.poppins(color: Colors.grey[600]),
//               ),
//               const SizedBox(width: 16),
//               Icon(Ionicons.water_outline, size: 16, color: Colors.grey),
//               const SizedBox(width: 4),
//               Text(
//                 '${double.tryParse(fuel['qty']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00'} L',
//                 style: GoogleFonts.poppins(color: Colors.grey[600]),
//               ),
//             ],
//           ),
//           if (fuel['fuel_from'] != null && fuel['fuel_from'].toString().isNotEmpty) ...[
//             const SizedBox(height: 4),
//             Row(
//               children: [
//                 Icon(Ionicons.location_outline, size: 16, color: Colors.grey),
//                 const SizedBox(width: 4),
//                 Text(
//                   fuel['fuel_from'].toString(),
//                   style: GoogleFonts.poppins(color: Colors.grey[600]),
//                 ),
//               ],
//             ),
//           ],
//           if (fuel['note'] != null && fuel['note'].toString().isNotEmpty) ...[
//             const SizedBox(height: 8),
//             Text(
//               fuel['note'].toString(),
//               style: GoogleFonts.poppins(
//                 fontStyle: FontStyle.italic,
//                 color: Colors.grey[700],
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   double _calculateTotalCost(dynamic fuel) {
//     final qty = double.tryParse(fuel['qty']?.toString() ?? '0') ?? 0.0;
//     final costPerUnit = double.tryParse(fuel['cost_per_unit']?.toString() ?? '0') ?? 0.0;
//     return qty * costPerUnit;
//   }
//
//   Widget _buildTextField(String label, String prefix, String value, Function(String) onChanged) {
//     return TextFormField(
//       initialValue: value,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixText: prefix.isNotEmpty ? '$prefix ' : null,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey[300]!),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey[300]!),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Color(0xFF2E8BC0)),
//         ),
//         filled: true,
//         fillColor: Colors.grey[50],
//       ),
//       validator: (value) {
//         if (value == null || value.isEmpty) {
//           return 'Please enter $label';
//         }
//         return null;
//       },
//       onChanged: onChanged,
//     );
//   }
//
//   Widget _buildDateField(String label, DateTime value, Function(DateTime) onChanged) {
//     return InkWell(
//       onTap: () async {
//         final picked = await showDatePicker(
//           context: context,
//           initialDate: value,
//           firstDate: DateTime(2000),
//           lastDate: DateTime.now(),
//         );
//         if (picked != null) {
//           onChanged(picked);
//         }
//       },
//       child: InputDecorator(
//         decoration: InputDecoration(
//           labelText: label,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.grey[300]!),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.grey[300]!),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: Color(0xFF2E8BC0)),
//           ),
//           filled: true,
//           fillColor: Colors.grey[50],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               '${value.day}/${value.month}/${value.year}',
//               style: GoogleFonts.poppins(),
//             ),
//             Icon(Ionicons.calendar_outline, color: Colors.grey),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _addFuelEntry() async {
//     if (_fuelFormKey.currentState!.validate()) {
//       if (_selectedVehicleId == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Please select a vehicle'),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }
//
//       // Validate numeric fields
//       final startMeter = double.tryParse(_startMeter);
//       final qty = double.tryParse(_fuelQty);
//       final costPerUnit = double.tryParse(_fuelCostPerUnit);
//
//       if (startMeter == null || qty == null || costPerUnit == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Please enter valid numeric values'),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }
//
//       try {
//         final driverProvider = Provider.of<DriverProvider>(context, listen: false);
//         await driverProvider.addFuelEntry(
//           vehicleId: _selectedVehicleId!,
//           startMeter: startMeter,
//           qty: qty,
//           costPerUnit: costPerUnit,
//           date: _fuelDate.toString().split(' ')[0],
//           fuelFrom: _fuelFrom.isNotEmpty ? _fuelFrom : null,
//           note: _fuelNote.isNotEmpty ? _fuelNote : null,
//         );
//
//         // Clear form
//         setState(() {
//           _selectedVehicleId = null;
//           _startMeter = '';
//           _fuelQty = '';
//           _fuelCostPerUnit = '';
//           _fuelFrom = '';
//           _fuelNote = '';
//           _fuelDate = DateTime.now();
//         });
//         _fuelFormKey.currentState!.reset();
//
//         // Switch to fuel history tab
//         _tabController.animateTo(1);
//
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Fuel entry added successfully', style: GoogleFonts.poppins()),
//               backgroundColor: Colors.green,
//               behavior: SnackBarBehavior.floating,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//             ),
//           );
//         }
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Failed to add fuel entry: ${e.toString()}', style: GoogleFonts.poppins()),
//               backgroundColor: Colors.red,
//               behavior: SnackBarBehavior.floating,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//             ),
//           );
//         }
//       }
//     }
//   }
// }