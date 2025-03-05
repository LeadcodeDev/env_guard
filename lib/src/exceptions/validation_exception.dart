class EnvGuardException implements Exception {
  String code = 'E_ENVIRONMENT_ERROR';

  final String message;
  EnvGuardException(this.message);


  @override
  String toString() => '[$code]: $message';
}
