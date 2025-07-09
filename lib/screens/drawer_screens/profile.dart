import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:take8/providers/avatar_provider.dart';
import 'package:take8/widgets/appbar.dart';
import '../../model/admin.dart';
import '../../providers/admin_provider.dart';
import '../../screens/home_screen.dart';
import '../auth_screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _imageFile;
  String _selectedAvatar = AvatarProvider().avatarPath;
  final ImagePicker _picker = ImagePicker();
  Admin admin = CustomWidgets.currentAdmin();

  // Function to Open Avatar Selection Bottom Sheet
  void _showAvatarSelection() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          height: 250,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Choose Profile Picture", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAvatarOption('assets/avatar.png'),
                  _buildAvatarOption('assets/avatar2.png'),
                  _buildAvatarOption('assets/avatar3.png'),

                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAvatarOption('assets/female1.png'),
                  _buildAvatarOption('assets/female2.png'),
                  _buildAvatarOption('assets/female3.png'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to Set Selected Avatar
  void _setPredefinedAvatar(String path) {
    setState(() {
      _imageFile = null;
      _selectedAvatar = path;
    });
    Provider.of<AvatarProvider>(context,listen: false).setAvatarPath(path);

    Navigator.pop(context);
  }

  // Widget to Display Avatar Option
  Widget _buildAvatarOption(String assetPath) {
    return GestureDetector(
      onTap: () => _setPredefinedAvatar(assetPath),
      child: CircleAvatar(
        backgroundImage: AssetImage(assetPath),
        radius: 40,
      ),
    );
  }

  // Function to Open WhatsApp-Style Edit Dialog
  void _showEditDialog(String title, String currentValue) {
    TextEditingController controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        titlePadding: EdgeInsets.all(15),
        contentPadding: EdgeInsets.symmetric(horizontal: 20),
        actionsPadding: EdgeInsets.only(bottom: 10, right: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            border: UnderlineInputBorder(),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
        ),
        actions: [
          TextButton(
            child: Text("Cancel", style: TextStyle(color: Colors.grey[700])),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("Save", style: TextStyle(color: Colors.blue)),
            onPressed: () {
              Admin newAdmin = admin;
              switch (title){
                case "Edit Name":
                  newAdmin.name = controller.text;
                  break;
                case "Edit Dairy Name":
                  newAdmin.dairyName = controller.text;
                  break;
                case "Edit Phone Number":
                  newAdmin.id = controller.text;
              }
              updateAdmin();
              setState(() {
                admin = newAdmin;
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
  void updateAdmin()async{
    bool? isAdminUpdated = await CustomWidgets.updateAdmin(admin,context);
    if(isAdminUpdated == null)
    {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false, // Clears entire stack
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    Admin? admin = adminProvider.admin;
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: CustomWidgets.buildAppBar("Profile"),
      body: Column(
        children: [
          SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: _showAvatarSelection,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!) as ImageProvider
                        :  AssetImage(_selectedAvatar),
                    backgroundColor: Colors.grey[200],
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.camera_alt, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),

          // Name Field
          ListTile(
            leading: Icon(Icons.person, color: Colors.grey),
            title: Text("Name", style: TextStyle(color: Colors.grey,fontSize: 20)),
            subtitle: Text(admin.name!, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20)),
            trailing: Icon(Icons.edit, color: Colors.blue),
            onTap: () => _showEditDialog("Edit Name", admin.name!),
          ),

          // About Field
          ListTile(
            leading: Icon(Icons.info, color: Colors.grey),
            title: Text("Dairy Name", style: TextStyle(color: Colors.grey,fontSize: 20)),
            subtitle: Text(admin.dairyName!, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20)),
            trailing: Icon(Icons.edit, color: Colors.blue,size: 25,),
            onTap: () => _showEditDialog("Edit Dairy Name", admin.dairyName!),
          ),

          // Phone (Read-Only)
          ListTile(
            leading: Icon(Icons.phone, color: Colors.grey),
            title: Text("Phone", style: TextStyle(color: Colors.grey,fontSize: 20)),
            subtitle: Text("+91 8907654323", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20)),
          ),
        ],
      ),
    );
  }
}
