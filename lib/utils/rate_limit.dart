/// True when [error] (an exception or an error message from the API) means the
/// server is throttling us.
///
/// Rate limits must never be retried automatically: every extra request extends
/// the block, and the UI already reports the failure to the user.
bool looksRateLimited(Object? error) {
  if (error == null) {
    return false;
  }
  final String text = error.toString().toLowerCase();
  return text.contains('rate limit') ||
      text.contains('too many requests') ||
      text.contains('429');
}
