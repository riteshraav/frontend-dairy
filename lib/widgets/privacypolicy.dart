import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'appbar.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  void _showAcceptedDialog(BuildContext context) {
    Fluttertoast.showToast(
      msg: "Privacy Policy Accepted",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Color(0xFF24A1DE),
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: CustomWidgets.buildAppBar("Privacy Policy"),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Privacy Policy',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),

                  Text(
                    "Thank you for using our Mobile Dairy Application. This Privacy Policy explains how we collect, use, and protect your information when you use our application.",
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  SizedBox(height: 16),

                  Text(
                    "1. Information We Collect",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "• Personal Information: Names, phone numbers, addresses of customers and suppliers.\n"
                        "• Transaction Data: Milk quantity, rate, payment mode, deductions, advance, interest, and balance information.\n"
                        "• Storage Access: To store data locally and generate reports (e.g., PDFs).\n"
                        "We do not collect or store sensitive personal data like passwords, usernames, national ID numbers, or financial credentials.",
                    style: TextStyle(fontSize: 15),
                  ),
                  SizedBox(height: 16),

                  Text(
                    "2. How We Use Your Data",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "• Manage customer billing and balances.\n"
                        "• Generate invoices and reports.\n"
                        "• Store records locally or on a secure backend server.\n"
                        "• Improve app features and performance.",
                    style: TextStyle(fontSize: 15),
                  ),
                  SizedBox(height: 16),

                  Text(
                    "3. Data Storage and Security",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "• Data is stored securely on your device and/or synced with our backend (if applicable).\n"
                        "• We use encryption and secure protocols to protect data in transit and at rest.\n"
                        "• Access is limited to authorized personnel or services only.",
                    style: TextStyle(fontSize: 15),
                  ),
                  SizedBox(height: 16),

                  Text(
                    "4. Sharing of Information",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "We do not share your personal or business data with third parties, except:\n"
                        "• When required by law.\n"
                        "• With your explicit consent.\n"
                        "• For support and debugging purposes with trusted developers under NDA.",
                    style: TextStyle(fontSize: 15),
                  ),
                  SizedBox(height: 16),

                  Text(
                    "5. Your Choices",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "• You can delete customer or transaction data anytime from within the app.\n"
                        "• If you uninstall the app, your local data may be removed.\n"
                        "• For backend-stored data, contact us at binarykop@gmail.com to request deletion.",
                    style: TextStyle(fontSize: 15),
                  ),
                  SizedBox(height: 16),

                  Text(
                    "6. Changes to This Policy",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "We may update this Privacy Policy from time to time. We will notify you of significant changes via the app.",
                    style: TextStyle(fontSize: 15),
                  ),
                  SizedBox(height: 16),

                  Text(
                    "7. Contact Us",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "If you have any questions about this Privacy Policy, please contact us:\n\n"
                        "📧 Email: binarykop@gmail.com\n"
                        "📞 Phone: 8830680317\n"
                        "🌐 Website: https://newbinarysolutions.netlify.app/",
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            child: ElevatedButton.icon(
              onPressed: () => _showAcceptedDialog(context),
              icon: const Icon(Icons.check_circle),
              label: const Text("Accept Privacy Policy"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Color(0xFF24A1DE),
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
