/// to throw an http exceptions
class HTTPException {
  final int status;
  final String title;
  final dynamic details;
  StackTrace? stackTrace;
  HTTPException(this.status, this.title, [this.details, this.stackTrace]);
}
