final class MessageException implements Exception {
  final String message;

  const MessageException(this.message);

  @override
  String toString() => message;
}

final class AgeSecretKeyRequiredException implements Exception {
  const AgeSecretKeyRequiredException();
}

/// [reason] is DownloadManager's COLUMN_REASON, null without a download.
final class SystemDownloadException implements Exception {
  final int? reason;

  const SystemDownloadException(this.reason);

  @override
  String toString() => 'SystemDownloadException: $reason';
}

final class ReleaseNotVerifiedException implements Exception {
  final String name;

  const ReleaseNotVerifiedException(this.name);

  @override
  String toString() => 'ReleaseNotVerifiedException: $name';
}

/// The subscription body arrived AES-encrypted; [passwordWrong] marks a
/// decryption attempt that ran and failed, so a prompt asks again.
final class SubscriptionEncryptedException implements Exception {
  final bool passwordWrong;

  const SubscriptionEncryptedException({this.passwordWrong = false});
}
