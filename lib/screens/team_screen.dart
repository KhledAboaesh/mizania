import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  final String facebookUrl =
      'https://www.facebook.com/profile.php?id=100078414146652';

  Future<void> _launchUrl() async {
    if (!await launchUrl(Uri.parse(facebookUrl))) {
      throw Exception('Could not launch $facebookUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('فريق العمل')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.group, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text(
              'فريق سراج تيم - Siraj Team',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'نحن فريق متخصص في تقديم حلول برمجية مبتكرة لتسهيل حياتك اليومية. تطبيق "ميزانية" هو أحد ثمار جهودنا لمساعدة الأفراد على إدارة أموالهم بذكاء.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _launchUrl,
              icon: const Icon(Icons.link),
              label: const Text('تابعنا على فيسبوك'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1877F2), // Facebook Blue
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
