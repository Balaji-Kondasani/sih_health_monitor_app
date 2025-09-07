// THE FIX: Changed the import from google_maps_flutter to latlong2
import 'package:latlong2/latlong.dart';

class Report {
  final int id;
  final DateTime createdAt;
  final String userId;
  final String villageName;
  final int diarrheaCases;
  final int feverCases;
  final int waterTurbidity;
  final String submissionType;
  final String riskLevel;
  final String? weatherSnapshot;
  final String? analysisNotes;
  // THE FIX: This is now a LatLng object from the latlong2 package
  final LatLng location;

  Report({
    required this.id,
    required this.createdAt,
    required this.userId,
    required this.villageName,
    required this.diarrheaCases,
    required this.feverCases,
    required this.waterTurbidity,
    required this.submissionType,
    required this.riskLevel,
    this.weatherSnapshot,
    this.analysisNotes,
    required this.location,
  });

  factory Report.fromMap(Map<String, dynamic> map) {
    // Helper function to parse the 'POINT(lon lat)' string from PostGIS
    LatLng parseLocation(String? pointString) {
      if (pointString == null) {
        return LatLng(21.1702, 72.8311); // Default to Surat, Gujarat
      }
      try {
        final sanitized = pointString.replaceAll('POINT(', '').replaceAll(')', '');
        final coords = sanitized.split(' ');
        final lon = double.parse(coords[0]);
        final lat = double.parse(coords[1]);
        return LatLng(lat, lon);
      } catch (e) {
        return LatLng(21.1702, 72.8311); // Default on parsing error
      }
    }

    return Report(
      id: map['id'] ?? 0,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
      userId: map['user_id'] ?? 'Unknown User',
      villageName: map['village_name'] ?? 'Unknown Village',
      diarrheaCases: map['diarrhea_cases'] ?? 0,
      feverCases: map['fever_cases'] ?? 0,
      waterTurbidity: map['water_turbidity'] ?? 0,
      submissionType: map['submission_type'] ?? 'N/A',
      riskLevel: map['risk_level'] ?? 'Pending',
      weatherSnapshot: map['weather_snapshot'],
      analysisNotes: map['analysis_notes'],
      location: parseLocation(map['location']),
    );
  }
}

