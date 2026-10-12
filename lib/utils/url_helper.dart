import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Validates whether a given URL is a valid http or https web address.
bool isValidOfficialUrl(String? url) {
  if (url == null) return false;
  final trimmed = url.trim();
  if (trimmed.isEmpty) return false;
  final uri = Uri.tryParse(trimmed);
  if (uri == null) return false;
  return (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
}

/// Launches the official event page using [LaunchMode.externalApplication].
///
/// Shows appropriate user feedback via [SnackBar] if the URL is missing, invalid, or fails to open.
Future<void> openOfficialEventPage(
  BuildContext context, {
  required String url,
}) async {
  final trimmed = url.trim();

  if (trimmed.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'No verified official URL is available for this opportunity.'),
        ),
      );
    }
    return;
  }

  final uri = Uri.tryParse(trimmed);
  if (uri == null ||
      !(uri.scheme == 'http' || uri.scheme == 'https') ||
      uri.host.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid official event URL provided.'),
        ),
      );
    }
    return;
  }

  try {
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open the official event page.'),
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to open link: $e'),
        ),
      );
    }
  }
}
