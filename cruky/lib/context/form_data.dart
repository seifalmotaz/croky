part of 'request.dart';

/// presenting file data and bytes stream
class FilePart {
  /// name of the field
  final String name;

  /// name of the file
  final String filename;

  /// streamed bytes of the files
  final Stream<List<int>> bytes;

  /// presenting file data and bytes stream
  FilePart(this.name, this.filename, this.bytes);
}

/// `multipart/form-data` and `application/x-www-form-urlencoded`  content data
class FormData {
  /// form fields as a list of string value for multiple value field
  final Map<String, List<String>> formFields;

  /// form fields as a list of [FilePart] value for multiple value field
  final Map<String, List<FilePart>> formFiles;

  /// get data from [formFields] or [formFiles] variables with the field name [i]
  List? operator [](String i) => formFields[i] ?? formFiles[i];

  /// get single value from [formFiles] with the field name [i]
  FilePart? file(String i) => formFiles[i]?.first;

  /// init new content
  FormData(this.formFields, this.formFiles);

  /// get value of field as [int]
  String? getString(String name) => formFields[name]?.first;

  /// get value of field as [int]
  int? getInt(String name) => formFields[name]?.first.toInt();

  /// get value of field as [doubel]
  double? getDouble(String name) => formFields[name]?.first.toDouble();

  /// get value of field as [num]
  num? getNum(String name) => formFields[name]?.first.toNum();

  /// get value of field as [Map]
  Map? getMap(String name) => formFields[name]?.first.toMap();

  /// get value of field as [bool]
  bool? getBool(String name) => formFields[name]?.first.toBool();

  /// get value as bool
  ///
  /// if [required] argument is true then all the list is not null
  List<bool?>? listBool(String i, [bool required = false]) {
    final data = formFields[i];
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

  /// get value as int
  ///
  /// if [required] argument is true then all the list is not null
  List<int?>? listInt(String i, [bool required = false]) {
    final data = formFields[i];
    if (data == null) {
      throw HTTPException(422, 'field $i is required');
    }
    return data.map((e) {
      int? i2 = e.toLowerCase().toInt();
      if (i2 == null && required) {
        throw HTTPException(422, 'field $i is not a list of integers');
      }
      return i2;
    }).toList();
  }

  /// get value as double
  ///
  /// if [required] argument is true then all the list is not null
  List<double?>? listDouble(String i, [bool required = false]) {
    final data = formFields[i];
    if (data == null) {
      throw HTTPException(422, 'field $i is required');
    }
    return data.map((e) {
      double? i2 = e.toLowerCase().toDouble();
      if (i2 == null && required) {
        throw HTTPException(422, 'field $i is not a list of doubles');
      }
      return i2;
    }).toList();
  }

  /// get value as num
  ///
  /// if [required] argument is true then all the list is not null
  List<num?>? listNum(String i, [bool required = false]) {
    final data = formFields[i];
    if (data == null) {
      throw HTTPException(422, 'field $i is required');
    }
    return data.map((e) {
      num? i2 = e.toLowerCase().toNum();
      if (i2 == null && required) {
        throw HTTPException(422, 'field $i is not a list of numbers');
      }
      return i2;
    }).toList();
  }
}
