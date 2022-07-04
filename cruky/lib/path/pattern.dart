library cruky.path.pattern;

/// Param info
class ParameterInfo {
  /// param name
  final String name;

  /// param index in path params list
  final int groupIndex;

  /// param type in path
  final ParamType type;
  ParameterInfo(this.name, this.type, this.groupIndex);
}

class PathPattern {
  /// the native path
  final String path;

  final List<ParameterInfo> parameters;

  /// Regular Expression path for matching request paths
  final RegExp regExp;
  const PathPattern(this.path, this.parameters, this.regExp);

  bool match(String reqPath) {
    reqPath = reqPath.replaceAll(r'\', "/");
    final RegExpMatch? expMatch = regExp.firstMatch(reqPath);
    if (expMatch == null) return false;
    return true;
  }

  /// map the parameters from request uri.path
  Map<String, dynamic> parse(String reqPath) {
    reqPath = reqPath.replaceAll(r'\', "/");
    final RegExpMatch expMatch = regExp.firstMatch(reqPath)!;
    final Map<String, dynamic> data = {};
    for (ParameterInfo parameter in parameters) {
      var group = expMatch.group(parameter.groupIndex);
      final String value = Uri.decodeQueryComponent(group!);
      data.addAll({parameter.name: parameter.type.convert(value)});
    }
    return data;
  }

  /// from [Route] path to PathPattern class
  factory PathPattern.parse(String path) {
    path = (path.split('/')..removeWhere((e) => e.isEmpty)).join('/');
    path = "/$path";

    final List<ParameterInfo> parameters = [];

    /// path arguments regex
    final RegExp paramRegExp = RegExp(r"<[a-zA-Z]+:?([^)]+)?>");

    int groupIndex = 0;
    String regex = path.replaceAllMapped(paramRegExp, (match) {
      String parameterRegExp = '';

      final String? type = match[1]; // parameter type

      String name;
      {
        final int i =
            type == null ? match[0]!.length - 1 : match[0]!.indexOf('(');
        name = match[0]!.substring(1, i);
      }

      // check parameter type and add the regex
      ParamType? paramType = paramTypes[type ?? "string"];
      if (paramType == null) {
        throw "Path parameter type not found for `$path`";
      }

      groupIndex++;
      parameters.add(ParameterInfo(name, paramType, groupIndex));
      return parameterRegExp;
    });
    regex += r'\/?';
    return PathPattern(path, parameters, RegExp(regex));
  }
}

//============================ CONSTANTS ============================//

class ParamType {
  /// regular expression that used to match in the path
  final String regExp;

  /// convert to dart type
  final Object Function(String i) convert;
  const ParamType(this.regExp, this.convert);
}

final Map<String, ParamType> paramTypes = {
  "string": ParamType(r"[^\/]+", (i) => i),
  "int": ParamType(r"-?\d+", (i) => int.parse(i)),
  "uint": ParamType(r"\d+", (i) => int.parse(i)),
  "double": ParamType(r"-?\d+(?:\.\d+)?", (i) => double.parse(i)),
  "path": ParamType(r".+", (i) => i),
  "uuid": ParamType(
      r"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}",
      (i) => i),
  "timestamp": ParamType(
    r"-?\d+",
    (i) => DateTime.fromMillisecondsSinceEpoch(int.parse(i)),
  ),
  "date": ParamType(
    r"-?\d{1,6}\/(?:0[1-9]|[1-9])\/(?:0[1-9]|[12][0-9]|3[01])",
    (i) {
      List<int> segmants = i.split('/').map((e) => int.parse(e)).toList();
      return DateTime(segmants[0], segmants[1], segmants[2]);
    },
  ),
};
