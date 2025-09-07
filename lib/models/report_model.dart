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
  });

  // --- THE FIX: A more robust factory with fallbacks for every field ---
  factory Report.fromMap(Map<String, dynamic> map) {
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
      weatherSnapshot: map['weather_snapshot'], // This is already nullable, so it's safe
      analysisNotes: map['analysis_notes'], // Also nullable
    );
  }
}

