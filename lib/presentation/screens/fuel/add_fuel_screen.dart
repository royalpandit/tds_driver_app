import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/driver_provider.dart';
import '../../widgets/app_logo.dart';

class AddFuelScreen extends StatefulWidget {
  const AddFuelScreen({super.key});

  @override
  State<AddFuelScreen> createState() => _AddFuelScreenState();
}

class _AddFuelScreenState extends State<AddFuelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _startMeterController = TextEditingController();
  final _qtyController = TextEditingController();
  final _costPerUnitController = TextEditingController();
  final _dateController = TextEditingController();
  final _fuelFromController = TextEditingController();
  final _fuelStationIdController = TextEditingController();
  final _fuelTypeIdController = TextEditingController();
  final _referenceController = TextEditingController();
  final _noteController = TextEditingController();

  int? _selectedVehicleId;
  File? _selectedImage;
  bool _complete = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Initialize date with today's date
    _dateController.text = DateTime.now().toIso8601String().split('T')[0];
  }

  @override
  void dispose() {
    _startMeterController.dispose();
    _qtyController.dispose();
    _costPerUnitController.dispose();
    _dateController.dispose();
    _fuelFromController.dispose();
    _fuelStationIdController.dispose();
    _fuelTypeIdController.dispose();
    _referenceController.dispose();
    _noteController.dispose();
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

    // Get vehicles from ride requests
    for (final _ in driverProvider.rideRequests) {
      // If ride request has vehicle info, we could add it here
      // For now, we'll rely on trips
    }

    return vehicles.toList();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      _selectedImage = File(image.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    setState(() {
                      _selectedImage = File(image.path);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a vehicle'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final driverProvider = Provider.of<DriverProvider>(context, listen: false);

    final success = await driverProvider.addFuelEntry(
      vehicleId: _selectedVehicleId!,
      startMeter: double.parse(_startMeterController.text),
      qty: double.parse(_qtyController.text),
      costPerUnit: double.parse(_costPerUnitController.text),
      date: _dateController.text,
      fuelFrom: _fuelFromController.text.isNotEmpty ? _fuelFromController.text : null,
      fuelStationId: _fuelStationIdController.text.isNotEmpty ? int.parse(_fuelStationIdController.text) : null,
      fuelTypeId: _fuelTypeIdController.text.isNotEmpty ? int.parse(_fuelTypeIdController.text) : null,
      reference: _referenceController.text.isNotEmpty ? _referenceController.text : null,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
      complete: _complete,
      image: _selectedImage,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fuel entry added successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(driverProvider.errorMessage ?? 'Failed to add fuel entry'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Fuel Entry',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: AppLogo(size: 35),
          ),
        ],
      ),
      body: Consumer<DriverProvider>(
        builder: (context, driverProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: 16),

                  // Start Meter
                  TextFormField(
                    controller: _startMeterController,
                    decoration: const InputDecoration(
                      labelText: 'Start Meter Reading *',
                      hintText: 'Enter start meter reading',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Start meter reading is required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Quantity
                  TextFormField(
                    controller: _qtyController,
                    decoration: const InputDecoration(
                      labelText: 'Fuel Quantity (Liters) *',
                      hintText: 'Enter fuel quantity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Fuel quantity is required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Cost Per Unit
                  TextFormField(
                    controller: _costPerUnitController,
                    decoration: const InputDecoration(
                      labelText: 'Cost Per Unit *',
                      hintText: 'Enter cost per liter/unit',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Cost per unit is required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Date
                  TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Date *',
                      hintText: 'Select date',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: _selectDate,
                      ),
                    ),
                    readOnly: true,
                    onTap: _selectDate,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Date is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Fuel From
                  TextFormField(
                    controller: _fuelFromController,
                    decoration: const InputDecoration(
                      labelText: 'Fuel Station/Pump',
                      hintText: 'Enter fuel station name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Fuel Station ID
                  TextFormField(
                    controller: _fuelStationIdController,
                    decoration: const InputDecoration(
                      labelText: 'Fuel Station ID',
                      hintText: 'Enter fuel station ID',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Fuel Type ID
                  TextFormField(
                    controller: _fuelTypeIdController,
                    decoration: const InputDecoration(
                      labelText: 'Fuel Type ID',
                      hintText: 'Enter fuel type ID',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Reference
                  TextFormField(
                    controller: _referenceController,
                    decoration: const InputDecoration(
                      labelText: 'Reference',
                      hintText: 'Enter reference number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Note
                  TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Note',
                      hintText: 'Enter additional notes',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Complete Checkbox
                  CheckboxListTile(
                    title: const Text('Mark as Complete'),
                    value: _complete,
                    onChanged: (value) {
                      setState(() {
                        _complete = value ?? false;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Image Picker
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Receipt Image (Optional)',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          if (_selectedImage != null)
                            Stack(
                              children: [
                                Image.file(
                                  _selectedImage!,
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        _selectedImage = null;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            )
                          else
                            InkWell(
                              onTap: _pickImage,
                              child: Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text('Tap to add receipt image'),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: driverProvider.isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: driverProvider.isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Add Fuel Entry'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}