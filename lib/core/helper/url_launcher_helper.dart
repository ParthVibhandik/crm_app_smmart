import 'package:url_launcher/url_launcher.dart';

class UrlLauncherHelper {
  static Future<void> call(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) return;
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  static Future<void> mail(String? email) async {
    if (email == null || email.isEmpty) return;
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }
  static Future<void> launchWebUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    final Uri launchUri = Uri.parse(url);
    if (!await launchUrl(launchUri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $launchUri');
    }
  }
}
