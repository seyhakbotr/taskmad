import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppSecrets {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get webClientId => dotenv.env['WEB_CLIENT_ID'] ?? '';
  static String get iosClientId => dotenv.env['IOS_CLIENT_ID'] ?? '';
}
