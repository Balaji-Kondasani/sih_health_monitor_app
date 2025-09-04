import 'package:sih_health_monitor_app/models/report_model.dart';
import 'package:sih_health_monitor_app/models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:location/location.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // --- AUTHENTICATION ---

  Future<void> signInWithOtp(String phoneNumber) async {
    try {
      await _client.auth.signInWithOtp(phone: '+91$phoneNumber');
    } catch (e) {
      print('Error sending OTP: $e');
      rethrow;
    }
  }

  Future<AuthResponse> verifyOtp(String phoneNumber, String token) async {
    try {
      final AuthResponse res = await _client.auth.verifyOTP(
        type: OtpType.sms,
        phone: '+91$phoneNumber',
        token: token,
      );
      return res;
    } catch (e) {
      print('Error verifying OTP: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // --- USER PROFILE DATA ---

  Future<UserProfile?> getCurrentUserProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }

    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return UserProfile.fromMap(response);
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  // --- HEALTH REPORTS ---

  Stream<List<Report>> getReportsStream() {
    return _client
        .from('reports')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map(
          (listOfMaps) => listOfMaps.map((map) => Report.fromMap(map)).toList(),
        );
  }

  Future<void> addHealthReport({
    required String villageName,
    required int diarrheaCases,
    required int feverCases,
    required int waterTurbidity,
    required LocationData locationData,
    // --- NEW FIELDS ---
    required String? waterSource,
    required double? phLevel,
    required int vomitingCases,
    required int casesInChildren,
    required String notes,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to submit a report.');
    }

    try {
      final locationString =
          'POINT(${locationData.longitude} ${locationData.latitude})';

      await _client.from('reports').insert({
        'created_by': user.id,
        'village_name': villageName,
        'diarrhea_cases': diarrheaCases,
        'fever_cases': feverCases,
        'water_turbidity': waterTurbidity,
        'location': locationString,
        'submission_type': 'APP',
        'risk_level': 'Pending',
        // --- NEW FIELDS ---
        'water_source_tested': waterSource,
        'ph_level': phLevel,
        'vomiting_cases': vomitingCases,
        'cases_in_children': casesInChildren,
        'notes': notes,
      });
    } catch (e) {
      print('Error submitting report: $e');
      rethrow;
    }
  }
}
