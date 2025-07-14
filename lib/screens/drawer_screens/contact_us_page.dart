// import 'package:flutter/material.dart';
// import 'package:take8/widgets/appbar.dart';
// import 'package:take8/widgets/privacypolicy.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// class ContactProfilePage extends StatelessWidget {
//   final String website = "https://newbinarysolutions.netlify.app/";
//   final String email = "binarykop@gmail.com";
//   final String phone = "+918830680317"; // No space, no +91
//   final String address = "New Binary Solutions, Flat No.103, Atharva Skylines, Near Coforge Ltd, Ujalaiwadi, Kolhapur - 416004";
//   final String mapsUrl = "https://www.google.com/maps/search/?api=1&query=New+Binary+Solutions,+Flat+No.103,+Atharva+Skylines,+Near+Coforge+Ltd,+Ujalaiwadi,+Kolhapur+-+416004";
//
//   Future<void> _launchPhone() async {
//     final Uri url = Uri.parse("tel:$phone");
//     if (await canLaunchUrl(url)) {
//       await launchUrl(url, mode: LaunchMode.externalApplication);
//     } else {
//       throw 'Could not launch dialer';
//     }
//   }
//
//   Future<void> _launchEmail() async {
//     final Uri emailUri = Uri(
//       scheme: 'mailto',
//       path: email,
//       query: 'subject=Contact&body=Hello', // Optional: default subject/body
//     );
//     if (await canLaunchUrl(emailUri)) {
//       await launchUrl(emailUri, mode: LaunchMode.externalApplication);
//     } else {
//       throw 'Could not launch email app';
//     }
//   }
//
//   Future<void> _launchWebsite() async {
//     final Uri url = Uri.parse(website);
//     if (await canLaunchUrl(url)) {
//       await launchUrl(url, mode: LaunchMode.externalApplication);
//     } else {
//       throw 'Could not launch website';
//     }
//   }
//
//   Future<void> _launchMaps() async {
//     final Uri url = Uri.parse(mapsUrl);
//     if (await canLaunchUrl(url)) {
//       await launchUrl(url, mode: LaunchMode.externalApplication);
//     } else {
//       throw 'Could not launch Google Maps';
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.blue[50],
//       appBar: CustomWidgets.buildAppBar("Contact Profile"),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               CircleAvatar(
//                 radius: 50,
//                 backgroundColor: Colors.blue,
//                 child: Icon(Icons.business, size: 50, color: Colors.white),
//               ),
//               SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   IconButton(
//                     icon: Icon(Icons.call, size: 30),
//                     onPressed: _launchPhone,
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.email, size: 30),
//                     onPressed: _launchEmail,
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.ondemand_video, size: 30),
//                     onPressed: _launchWebsite,
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.privacy_tip, size: 30),
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => PrivacyPolicy()),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//               SizedBox(height: 20),
//               Card(
//                 child: ListTile(
//                   title: Text("Email"),
//                   subtitle: Text(email),
//                   onTap: _launchEmail,
//                 ),
//               ),
//               Card(
//                 child: ListTile(
//                   title: Text("Phone"),
//                   subtitle: Text(phone),
//                   onTap: _launchPhone,
//                 ),
//               ),
//               Card(
//                 child: ListTile(
//                   title: Text("Website"),
//                   subtitle: Text(website),
//                   onTap: _launchWebsite,
//                 ),
//               ),
//               Card(
//                 child: ListTile(
//                   title: Text("Address"),
//                   subtitle: Text(address),
//                   onTap: _launchMaps,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:take8/widgets/appbar.dart';
import 'package:take8/widgets/privacypolicy.dart';

class ContactProfilePage extends StatelessWidget {
  // ────────────────────────────────────────────────────────────────────
  // Company constants
  final String website   = "https://newbinarysolutions.netlify.app/";
  final String email     = "binarykop@gmail.com";
  final String phone     = "+918830680317"; // no spaces
  final String address   =
      "New Binary Solutions, Flat No.103, Atharva Skylines, Near Coforge Ltd, Ujalaiwadi, Kolhapur - 416004";
  final String mapsUrl   =
      "https://www.google.com/maps/search/?api=1&query=New+Binary+Solutions,+Flat+No.103,+Atharva+Skylines,+Near+Coforge+Ltd,+Ujalaiwadi,+Kolhapur+-+416004";
  final String youtubeUrl = "https://www.youtube.com/@NewBinarySolutions"; // NEW

  // ────────────────────────────────────────────────────────────────────
  // Launch helpers
  Future<void> _launchPhone() async {
    final url = Uri.parse("tel:$phone");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch dialer';
    }
  }

  Future<void> _launchEmail() async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Contact&body=Hello',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch email app';
    }
  }

  Future<void> _launchWebsite() async {
    final url = Uri.parse(website);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch website';
    }
  }

  Future<void> _launchMaps() async {
    final url = Uri.parse(mapsUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch Google Maps';
    }
  }

  Future<void> _launchYouTube() async { // NEW
    final url = Uri.parse(youtubeUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch YouTube';
    }
  }

  // ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: CustomWidgets.buildAppBar("Contact Profile"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue,
                child: Icon(Icons.business, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.call, size: 30),
                    onPressed: _launchPhone,
                  ),
                  IconButton(
                    icon: const Icon(Icons.email, size: 30),
                    onPressed: _launchEmail,
                  ),
                  IconButton( // YouTube button
                    icon: const Icon(Icons.ondemand_video, size: 30),
                    onPressed: _launchYouTube,
                  ),
                  IconButton(
                    icon: const Icon(Icons.privacy_tip, size: 30),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PrivacyPolicy()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                child: ListTile(
                  title: const Text("Email"),
                  subtitle: Text(email),
                  onTap: _launchEmail,
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text("Phone"),
                  subtitle: Text(phone),
                  onTap: _launchPhone,
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text("Website"),
                  subtitle: Text(website),
                  onTap: _launchWebsite,
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text("Address"),
                  subtitle: Text(address),
                  onTap: _launchMaps,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}