/// to throw an http exceptions
class HTTPException {
  final int status;
  final String title;
  final dynamic detail;
  StackTrace? stackTrace;
  HTTPException(this.status, this.title, [this.detail, this.stackTrace]);
}
