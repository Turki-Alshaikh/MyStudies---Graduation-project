class CustomException implements Exception {
  final String message;
  final String? code;
  CustomException(this.message, {this.code});

  @override
  String toString() => 'CustomException(${code ?? 'error'}): $message';
}

