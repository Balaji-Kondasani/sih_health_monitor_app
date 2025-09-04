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
  // We will add location later for the map

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
  });

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'],
      createdAt: DateTime.parse(map['created_at']),
      userId: map['user_id'],
      villageName: map['village_name'] ?? 'N/A',
      diarrheaCases: map['diarrhea_cases'] ?? 0,
      feverCases: map['fever_cases'] ?? 0,
      waterTurbidity: map['water_turbidity'] ?? 0,
      submissionType: map['submission_type'] ?? 'APP',
      riskLevel: map['risk_level'] ?? 'Normal',
      weatherSnapshot: map['weather_snapshot'],
    );
  }
}

