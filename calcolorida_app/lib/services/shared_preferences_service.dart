import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static const String keyResult = "key_result";
  static const String keyOperation = "key_operation";
  static const String keyInstrument = "key_instrument";
  static const String keyZoom = "key_zoom";
  static const String keyNoteDuration = "key_note_duration";
  static const String keyMosaicDigitsPerRow = "key_mosaic_digits_per_row";

static Future<void> saveMosaicDigitsPerRow(int digitsPerRow) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(keyMosaicDigitsPerRow, digitsPerRow);
}

static Future<int?> getMosaicDigitsPerRow() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt(keyMosaicDigitsPerRow);
}


  static Future<void> saveResult(String result) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyResult, result);
  }

  static Future<String?> getResult() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyResult);
  }

  static Future<void> saveOperation(String operation) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyOperation, operation);
  }

  static Future<String?> getOperation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyOperation);
  }

  static Future<void> saveInstrument(String instrument) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyInstrument, instrument);
  }

  static Future<String?> getInstrument() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyInstrument);
  }

  static Future<void> saveZoom(double zoom) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(keyZoom, zoom);
  }

  static Future<double?> getZoom() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(keyZoom);
  }
static Future<void> saveNoteDuration(int duration) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyNoteDuration, duration);
  }

  static Future<int?> getNoteDuration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyNoteDuration);
  }

}
