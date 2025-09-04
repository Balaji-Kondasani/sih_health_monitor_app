import 'package:flutter/material.dart';
import 'package:sih_health_monitor_app/models/report_model.dart';
import 'package:sih_health_monitor_app/services/supabase_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SupabaseService _supabaseService = SupabaseService();

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
              // The AuthWrapper will automatically navigate to the login screen.
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

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: report.riskLevel == 'High'
                    ? Colors.red.shade100
                    : report.riskLevel == 'Warning'
                        ? Colors.orange.shade100
                        : Colors.white,
                child: ListTile(
                  title: Text(report.villageName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      'Diarrhea: ${report.diarrheaCases}, Fever: ${report.feverCases}\n'
                      'Turbidity: ${report.waterTurbidity} NTU\n'
                      'Weather: ${report.weatherSnapshot ?? 'N/A'}'),
                  trailing: Text(
                    report.riskLevel,
                    style: TextStyle(
                      color: report.riskLevel == 'High'
                          ? Colors.red.shade900
                          : report.riskLevel == 'Warning'
                              ? Colors.orange.shade900
                              : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

