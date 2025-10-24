import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../utility/widgets.dart';
import '../repos.dart';
import '../models.dart';

class VehicleFormScreen extends StatefulWidget {
  const VehicleFormScreen({super.key});

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vehiclesRepo = VehiclesRepo();
  
  // Controllers
  final _nicknameController = TextEditingController();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _mileageController = TextEditingController();
  final _vinController = TextEditingController();
  final _licensePlateController = TextEditingController();
  
  Vehicle? _editingVehicle;
  String? _imagePath;
  bool _isLoading = false;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Get vehicle from arguments if editing
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Vehicle && _editingVehicle == null) {
      _editingVehicle = args;
      _populateForm();
    }
  }
  
  void _populateForm() {
    if (_editingVehicle == null) return;
    
    _nicknameController.text = _editingVehicle!.nickname;
    _makeController.text = _editingVehicle!.make;
    _modelController.text = _editingVehicle!.model;
    _yearController.text = _editingVehicle!.year.toString();
    _mileageController.text = _editingVehicle!.currentMileage.toString();
    _vinController.text = _editingVehicle!.vin ?? '';
    _licensePlateController.text = _editingVehicle!.licensePlate ?? '';
    _imagePath = _editingVehicle!.imagePath;
  }
  
  @override
  void dispose() {
    _nicknameController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    _vinController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }
  
  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() => _imagePath = image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }
  
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  String? _validateYear(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Year is required';
    }
    
    final year = int.tryParse(value);
    if (year == null) {
      return 'Year must be a number';
    }
    
    final currentYear = DateTime.now().year;
    if (year < 1900 || year > currentYear + 1) {
      return 'Year must be between 1900 and ${currentYear + 1}';
    }
    
    return null;
  }
  
  String? _validateMileage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mileage is required';
    }
    
    final mileage = int.tryParse(value);
    if (mileage == null) {
      return 'Mileage must be a number';
    }
    
    if (mileage < 0) {
      return 'Mileage cannot be negative';
    }
    
    // Check for mileage decrease when editing
    if (_editingVehicle != null && mileage < _editingVehicle!.currentMileage) {
      return 'New mileage ($mileage) cannot be less than current mileage (${_editingVehicle!.currentMileage})';
    }
    
    return null;
  }
  
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final vehicle = Vehicle(
        id: _editingVehicle?.id,
        nickname: _nicknameController.text.trim(),
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
        year: int.parse(_yearController.text),
        currentMileage: int.parse(_mileageController.text),
        vin: _vinController.text.trim().isEmpty ? null : _vinController.text.trim(),
        licensePlate: _licensePlateController.text.trim().isEmpty ? null : _licensePlateController.text.trim(),
        imagePath: _imagePath,
        createdAt: _editingVehicle?.createdAt,
        updatedAt: DateTime.now(),
      );
      
      if (_editingVehicle == null) {
        await _vehiclesRepo.add(vehicle);
      } else {
        await _vehiclesRepo.update(vehicle);
      }
      
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving vehicle: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isEditing = _editingVehicle != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Vehicle' : 'Add Vehicle'),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Image picker
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _imagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(_imagePath!),
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add Photo',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Nickname
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: 'Nickname *',
                  hintText: 'e.g., My Car, Work Truck',
                  prefixIcon: Icon(Icons.label),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) => _validateRequired(value, 'Nickname'),
              ),
              const SizedBox(height: 16),
              
              // Make
              TextFormField(
                controller: _makeController,
                decoration: const InputDecoration(
                  labelText: 'Make *',
                  hintText: 'e.g., Toyota, Ford, Honda',
                  prefixIcon: Icon(Icons.business),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) => _validateRequired(value, 'Make'),
              ),
              const SizedBox(height: 16),
              
              // Model
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Model *',
                  hintText: 'e.g., Camry, F-150, Civic',
                  prefixIcon: Icon(Icons.directions_car),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) => _validateRequired(value, 'Model'),
              ),
              const SizedBox(height: 16),
              
              // Year
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(
                  labelText: 'Year *',
                  hintText: 'e.g., 2020',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: _validateYear,
              ),
              const SizedBox(height: 16),
              
              // Mileage
              TextFormField(
                controller: _mileageController,
                decoration: const InputDecoration(
                  labelText: 'Current Mileage *',
                  hintText: 'e.g., 50000',
                  prefixIcon: Icon(Icons.speed),
                  suffixText: 'miles',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: _validateMileage,
              ),
              const SizedBox(height: 24),
              
              // Optional section header
              Text(
                'Optional Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              
              // VIN
              TextFormField(
                controller: _vinController,
                decoration: const InputDecoration(
                  labelText: 'VIN',
                  hintText: '17-character VIN',
                  prefixIcon: Icon(Icons.qr_code),
                ),
                textCapitalization: TextCapitalization.characters,
                maxLength: 17,
              ),
              const SizedBox(height: 16),
              
              // License Plate
              TextFormField(
                controller: _licensePlateController,
                decoration: const InputDecoration(
                  labelText: 'License Plate',
                  hintText: 'e.g., ABC 1234',
                  prefixIcon: Icon(Icons.credit_card),
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 32),
              
              // Save button
              AppButton(
                label: isEditing ? 'Update Vehicle' : 'Add Vehicle',
                icon: isEditing ? Icons.check : Icons.add,
                onPressed: _save,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
