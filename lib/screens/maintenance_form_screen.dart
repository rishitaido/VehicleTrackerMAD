import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../utility/widgets.dart';
import '../repos.dart';
import '../models.dart';
import '../utility/reminder_helper.dart';
import '../utility/validators.dart';

class MaintenanceFormScreen extends StatefulWidget {
  const MaintenanceFormScreen({super.key});

  @override
  State<MaintenanceFormScreen> createState() => _MaintenanceFormScreenState();
}

class _MaintenanceFormScreenState extends State<MaintenanceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _maintenanceRepo = MaintenanceRepo();
  final _vehiclesRepo = VehiclesRepo();
  final _reminderEngine = ReminderEngine();
  
  // Controllers
  final _mileageController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();
  
  int? _vehicleId;
  MaintenanceLog? _editingLog;
  Vehicle? _vehicle;
  
  ServiceType _selectedType = ServiceType.oilChange;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _createReminder = true;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Get arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _vehicleId = args['vehicleId'] as int?;
      
      if (args.containsKey('log') && _editingLog == null) {
        _editingLog = args['log'] as MaintenanceLog;
        _populateForm();
      }
      
      if (_vehicle == null && _vehicleId != null) {
        _loadVehicle();
      }
    }
  }
  
  Future<void> _loadVehicle() async {
    if (_vehicleId == null) return;
    
    try {
      _vehicle = await _vehiclesRepo.getById(_vehicleId!);
      if (_vehicle != null && _mileageController.text.isEmpty) {
        _mileageController.text = _vehicle!.currentMileage.toString();
      }
      setState(() {});
    } catch (e) {
      print('Error loading vehicle: $e');
    }
  }
  
  void _populateForm() {
    if (_editingLog == null) return;
    
    _selectedType = _editingLog!.type;
    _selectedDate = _editingLog!.date;
    _mileageController.text = _editingLog!.mileage.toString();
    _costController.text = _editingLog!.cost.toStringAsFixed(2);
    _notesController.text = _editingLog!.notes ?? '';
    _createReminder = false;
  }
  
  @override
  void dispose() {
    _mileageController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }
  
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_vehicleId == null || _vehicle == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      final log = MaintenanceLog(
        id: _editingLog?.id,
        vehicleId: _vehicleId!,
        type: _selectedType,
        date: _selectedDate,
        mileage: int.parse(_mileageController.text),
        cost: double.parse(_costController.text),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );
      
      if (_editingLog == null) {
        await _maintenanceRepo.add(log);
        
        if (_createReminder) {
          await _reminderEngine.createReminderAfterMaintenance(log, _vehicle!);
        }
      } else {
        await _maintenanceRepo.update(log);
      }
      
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving maintenance: $e')),
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
    final isEditing = _editingLog != null;
    final dateFormat = DateFormat.yMMMd();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Maintenance' : 'Add Maintenance'),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Vehicle info
              if (_vehicle != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.directions_car,
                          color: Theme.of(context).colorScheme.primary,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _vehicle!.nickname,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                '${_vehicle!.year} ${_vehicle!.make} ${_vehicle!.model}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                              Text(
                                'Current: ${NumberFormat('#,###').format(_vehicle!.currentMileage)} mi',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
              // Service type dropdown
              DropdownButtonFormField<ServiceType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Service Type *',
                  prefixIcon: Icon(Icons.build),
                ),
                items: ServiceType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(type.icon, size: 20),
                        const SizedBox(width: 8),
                        Text(type.label),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Date picker
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date *',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(dateFormat.format(_selectedDate)),
                ),
              ),
              const SizedBox(height: 16),
              
              // Mileage
              TextFormField(
                controller: _mileageController,
                decoration: const InputDecoration(
                  labelText: 'Mileage *',
                  hintText: 'Mileage at service',
                  prefixIcon: Icon(Icons.speed),
                  suffixText: 'miles',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (_vehicle != null) {
                    return Validators.mileageWithMax(value, _vehicle!.currentMileage);
                  }
                  return Validators.mileage(value);
                },
              ),
              const SizedBox(height: 16),
              
              // Cost
              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(
                  labelText: 'Cost *',
                  hintText: '0.00',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                validator: Validators.cost,
              ),
              const SizedBox(height: 16),
              
              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Any additional information',
                  prefixIcon: Icon(Icons.note),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),
              
              // Create reminder checkbox
              if (!isEditing) ...[
                Card(
                  child: CheckboxListTile(
                    value: _createReminder,
                    onChanged: (value) {
                      setState(() => _createReminder = value ?? true);
                    },
                    title: const Text('Create Reminder'),
                    subtitle: Text(
                      'Automatically create reminder for next ${_selectedType.label.toLowerCase()}',
                    ),
                    secondary: const Icon(Icons.notifications),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
              // Save button
              AppButton(
                label: isEditing ? 'Update Maintenance' : 'Add Maintenance',
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