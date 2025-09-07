import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:sih_health_monitor_app/services/supabase_service.dart';

class AddNewReportScreen extends StatefulWidget {
  const AddNewReportScreen({super.key});

  @override
  State<AddNewReportScreen> createState() => _AddNewReportScreenState();
}

class _AddNewReportScreenState extends State<AddNewReportScreen> {
  final _formKey = GlobalKey<FormState>();
  // Existing controllers
  final _villageController = TextEditingController();
  final _diarrheaController = TextEditingController();
  final _feverController = TextEditingController();
  final _turbidityController = TextEditingController();
  // New controllers
  final _phController = TextEditingController();
  final _vomitingController = TextEditingController();
  final _childrenCasesController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedWaterSource;
  final List<String> _waterSources = ['Community Well', 'Hand Pump', 'River', 'Pond', 'Tap Water', 'Other'];

  final SupabaseService _supabaseService = SupabaseService();

  LocationData? _currentLocation;
  bool _isLoading = true; // Start loading immediately to get location
  String _locationError = '';

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    if (!_isLoading) {
      if (mounted) setState(() => _isLoading = true);
    }
    _locationError = '';

    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        if (mounted) setState(() => _locationError = 'Location services are disabled.');
        _stopLoading();
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        if (mounted) setState(() => _locationError = 'Location permission denied.');
        _stopLoading();
        return;
      }
    }

    try {
      final locationData = await location.getLocation();
      if (mounted) {
        setState(() {
          _currentLocation = locationData;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _locationError = 'Failed to get location.');
    } finally {
      _stopLoading();
    }
  }

  void _stopLoading() {
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      if (_currentLocation == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not get location. Please ensure location is enabled and try again.')),
          );
        }
        return;
      }

      setState(() => _isLoading = true);

      try {
        await _supabaseService.addHealthReport(
          villageName: _villageController.text.trim(),
          diarrheaCases: int.tryParse(_diarrheaController.text.trim()) ?? 0,
          feverCases: int.tryParse(_feverController.text.trim()) ?? 0,
          waterTurbidity: int.tryParse(_turbidityController.text.trim()) ?? 0,
          locationData: _currentLocation!,
          // --- PASSING NEW DATA ---
          waterSource: _selectedWaterSource,
          phLevel: double.tryParse(_phController.text.trim()),
          vomitingCases: int.tryParse(_vomitingController.text.trim()) ?? 0,
          casesInChildren: int.tryParse(_childrenCasesController.text.trim()) ?? 0,
          notes: _notesController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report submitted successfully!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit report: ${e.toString()}')),
          );
        }
      } finally {
        _stopLoading();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Health Report")),
      body: _isLoading && _currentLocation == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Getting Location..."),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // --- Location Info ---
                    if (_locationError.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(_locationError, style: const TextStyle(color: Colors.red)),
                      ),
                    if (_currentLocation != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'Location Captured: Lat ${_currentLocation!.latitude?.toStringAsFixed(4)}, Lon ${_currentLocation!.longitude?.toStringAsFixed(4)}',
                          style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold),
                        ),
                      ),
                    const SizedBox(height: 8),

                    // --- Report Details ---
                    Text("Village & Symptom Data", style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _villageController,
                      decoration: const InputDecoration(labelText: 'Village Name'),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter a village name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _diarrheaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Number of Diarrhea Cases'),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter a number' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _feverController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Number of Fever Cases'),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter a number' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _vomitingController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Number of Vomiting Cases'),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter a number' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _childrenCasesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Cases in Children (< 5 years)'),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter a number' : null,
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // --- Water Quality Details ---
                    Text("Water Quality Details", style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedWaterSource,
                      hint: const Text('Select Water Source Tested'),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedWaterSource = newValue;
                        });
                      },
                      items: _waterSources.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _turbidityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Water Turbidity (NTU)'),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter a number' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'pH Level (e.g., 7.2)'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Additional Notes',
                        hintText: 'e.g., Water has a strange smell...',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // --- Submit Button ---
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitReport,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Submit Report'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

