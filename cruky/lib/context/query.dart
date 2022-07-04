part of 'request.dart';

/// request query parameters helper that can help you get data easily
class QueryParameters {
  /// the main data that returned fro the request uri
  final Map<String, List<String>> map;

  /// request query parameters helper that can help you get data easily
  QueryParameters(Uri uri) : map = uri.queryParametersAll;

  /// get value as string
  String? getString(String i) {
    final data = map[i];
    if (data == null) return null;
    return data.first;
  }

  /// get value as int
  int? getInt(String i) {
    final data = map[i];
    if (data == null) return null;
    return data.first.toInt();
  }

  /// get value as num
  num? getNum(String i) {
    final data = map[i];
    if (data == null) return null;
    return data.first.toNum();
  }

  /// get value as double
  double? getDouble(String i) {
    final data = map[i];
    if (data == null) return null;
    return data.first.toDouble();
  }

  /// get value as bool
  bool? getBool(String i) {
    final data = map[i];
    if (data == null) return null;
    String ii = data.first;
    return ii.toBool();
  }

  /// get value as num
  List<String>? listString(String i) {
    return map[i];
  }

  /// get value as list of bool
  ///
  /// if [required] argument is true then all the list is not null
  List<bool?>? listBool(String i, [bool required = false]) {
    final data = map[i];
    if (data == null) {
      throw HTTPException(422, 'field $i is required');
    }
    return data.map((e) {
      bool? i2 = e.toBool();
      if (i2 == null && required) {
        throw HTTPException(422, 'field $i is not a list of booleans');
      }
      return i2;
    }).toList();
  }

  /// get value as list of int
  ///
  /// if [required] argument is true then all the list is not null
  List<int?>? listInt(String i, [bool required = false]) {
    final data = map[i];
    if (data == null) {
      throw HTTPException(422, 'field $i is required');
    }
    return data.map((e) {
      int? i2 = e.toInt();
      if (i2 == null && required) {
        throw HTTPException(422, 'field $i is not a list of integers');
      }
      return i2;
    }).toList();
  }

  /// get value as list of double
  ///
  /// if [required] argument is true then all the list is not null
  List<double?>? listDouble(String i, [bool required = false]) {
    final data = map[i];
    if (data == null) {
      throw HTTPException(422, 'field $i is required');
    }
    return data.map((e) {
      double? i2 = e.toDouble();
      if (i2 == null && required) {
        throw HTTPException(422, 'field $i is not a list of doubles');
      }
      return i2;
    }).toList();
  }

  /// get value as list of num
  ///
  /// if [required] argument is true then all the list is not null
  List<num?>? listNum(String i, [bool required = false]) {
    final data = map[i];
    if (data == null) {
      throw HTTPException(422, 'field $i is required');
    }
    return data.map((e) {
      num? i2 = e.toNum();
      if (i2 == null && required) {
        throw HTTPException(422, 'field $i is not a list of numbers');
      }
      return i2;
    }).toList();
  }
}
