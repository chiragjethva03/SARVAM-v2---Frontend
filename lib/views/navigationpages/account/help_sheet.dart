import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSheet extends StatelessWidget {
  const HelpSheet({super.key});

  void _makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _sendSms(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'sms', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget _buildContactTile(String phoneNumber) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2196F3).withOpacity(0.11),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(phoneNumber),
        trailing: Wrap(
          spacing: 12,
          children: [
            IconButton(
              icon: const Icon(Icons.call, color: Colors.black),
              onPressed: () => _makePhoneCall(phoneNumber),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Help",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildContactTile("+91 6354809704"),
          const SizedBox(height: 10),
          _buildContactTile("+91 8200055293"),
        ],
      ),
    );
  }
}
