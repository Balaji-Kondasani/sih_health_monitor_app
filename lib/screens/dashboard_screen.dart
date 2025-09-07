import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:sih_health_monitor_app/models/report_model.dart';
import 'package:sih_health_monitor_app/services/supabase_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final MapController _mapController = MapController();

  // Helper to get a specific color for each risk level for high visibility.
  Color _getRiskColor(String riskLevel) {
    switch (riskLevel) {
      case 'Critical':
        return Colors.purple.shade700;
      case 'High':
        return Colors.red.shade700;
      case 'Warning':
        return Colors.orange.shade700;
      case 'Low':
        return Colors.yellow.shade800;
      default: // Normal
        return Colors.green.shade700;
    }
  }

  // Helper to show a detailed bottom sheet when a marker or list item is tapped.
  void _showReportDetails(BuildContext context, Report report) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(report.villageName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                "Risk Level: ${report.riskLevel}",
                style: TextStyle(fontWeight: FontWeight.bold, color: _getRiskColor(report.riskLevel), fontSize: 16),
              ),
               Text("Submitted: ${DateFormat.yMMMd().add_jm().format(report.createdAt.toLocal())}"),
              const Divider(height: 24),
              Text("Symptoms Reported:", style: Theme.of(context).textTheme.titleMedium),
              Text("Diarrhea: ${report.diarrheaCases}, Fever: ${report.feverCases}"),
              const SizedBox(height: 8),
              Text("Analysis Notes:", style: Theme.of(context).textTheme.titleMedium),
              Text(report.analysisNotes ?? "No notes available from automated analysis."),
              const SizedBox(height: 8),
              Text("Weather at time of report:", style: Theme.of(context).textTheme.titleMedium),
              Text(report.weatherSnapshot ?? "No data."),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Health Official Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _supabaseService.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Report>>(
        stream: _supabaseService.getReportsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No health reports found."));
          }

          final reports = snapshot.data!;
          final markers = reports.map((report) {
            // THE UPDATE: The Marker's 'builder' property is the modern way to create custom icons.
            // It provides a context and returns any widget you want.
            return Marker(
              width: 40.0,
              height: 40.0,
              point: report.location,
              child: GestureDetector(
                onTap: () => _showReportDetails(context, report),
                child: Tooltip(
                  message: "${report.villageName}\nRisk: ${report.riskLevel}",
                  child: Icon(
                    Icons.location_pin,
                    color: _getRiskColor(report.riskLevel),
                    size: 40.0,
                  ),
                ),
              ),
            );
          }).toList();

          return Column(
            children: [
              // The Map View using FlutterMap and OpenStreetMap
              Expanded(
                flex: 2,
                child: FlutterMap(
                  mapController: _mapController,
                  // --- THE UPDATE: These parameter names are for the latest flutter_map versions ---
                  options: MapOptions(
                    initialCenter: LatLng(22.3072, 73.1812), // `center` is now `initialCenter`
                    initialZoom: 9.0,                         // `zoom` is now `initialZoom`
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    MarkerLayer(markers: markers),
                  ],
                ),
              ),
              // The List View
              Expanded(
                flex: 3,
                child: ListView.builder(
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        leading: Icon(Icons.circle, color: _getRiskColor(report.riskLevel), size: 12),
                        title: Text(report.villageName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Submitted: ${DateFormat.yMMMd().add_jm().format(report.createdAt.toLocal())}'),
                        onTap: () {
                          _showReportDetails(context, report);
                          // THE UPDATE: The 'move' method with a zoom level is the correct way to animate the map.
                          _mapController.move(report.location, 14.0);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

