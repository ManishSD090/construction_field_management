import 'dart:convert';
import 'package:drift/drift.dart';

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String? fromDb) {
    // Renamed from mapToDart
    if (fromDb == null) {
      return [];
    }
    try {
      return (jsonDecode(fromDb) as List<dynamic>).cast<String>();
    } catch (e) {
      return [];
    }
  }

  @override
  String toSql(List<String>? value) {
    // Renamed from mapToSql
    if (value == null) {
      return '[]';
    }
    return jsonEncode(value);
  }
}
