import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/services.dart'; // 🔹 for inputFormatters
import '../../utils/constants.dart';
import '../auth/signup_view.dart';
import '../../widgets/custom_textfield.dart';
import '../home/saved_news_view.dart';
import 'package:provider/provider.dart';
import '../../controllers/theme_controller.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  String? _country;
  bool _isLoading = false;

  int _followings = 0;
  int _saved = 0;
  int _bookmarks = 0;
  int _chats = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // 🔹 Load user data from Firestore
  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();

      setState(() {
        _nameController.text = user.displayName ?? data?['name'] ?? '';
        _emailController.text = user.email ?? data?['email'] ?? '';
        _dobController.text = data?['dob'] ?? '';
        _phoneController.text = data?['phone'] ?? '';
        _country = data?['country'];
        _countryController.text = _country ?? '';

        _followings = (data?['followings'] as List?)?.length ?? 0;
        _saved = (data?['savedArticles'] as List?)?.length ?? 0;
        _bookmarks = data?['bookmarks'] ?? 0;
        _chats = data?['chats'] ?? 0;
      });
    }
  }

  // 🔹 Update user profile
  Future<void> _updateUserProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final user = _auth.currentUser;

    try {
      await _firestore.collection('users').doc(user!.uid).update({
        'name': _nameController.text.trim(),
        'dob': _dobController.text.trim(),
        'phone': _phoneController.text.trim(),
        'country': _country,
      });

      await user.updateDisplayName(_nameController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );

      await _loadUserData();

      // 🟢 Navigate to Saved News
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SavedNewsView()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 🔹 Pick Date of Birth
  void _pickDOB() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // 🔹 Pick Country
  void _pickCountry() {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      onSelect: (country) {
        setState(() {
          _country = country.name;
          _countryController.text = _country ?? '';
        });
      },
    );
  }

  // 🔹 Logout user
  void _logout() async {
    await _auth.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SignupView()),
          (route) => false,
    );
  }

  // 🔹 Reusable Stats Box Widget
  Widget _buildStatsBox(BuildContext context, String label, int count,
      {VoidCallback? onTap}) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.15),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                count.toString(),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 UI
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: theme.colorScheme.primary,
                  child: const Icon(Icons.person,
                      color: Colors.white, size: 50),
                ),
                const SizedBox(height: 15),

                // 🔹 User Stats Row
                Row(
                  children: [
                    _buildStatsBox(context, 'Followings', _followings),
                    _buildStatsBox(context, 'Saved', _saved, onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SavedNewsView()),
                      );
                    }),
                    _buildStatsBox(context, 'Bookmarks', _bookmarks),
                    _buildStatsBox(context, 'Chats', _chats),
                  ],
                ),

                const SizedBox(height: 25),

                // 🔹 Profile Fields
                CustomTextField(
                  controller: _nameController,
                  hintText: 'Name',
                  validator: (v) =>
                  v!.isEmpty ? 'Enter your name' : null,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  isReadOnly: true,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _dobController,
                  hintText: 'Date of Birth',
                  isReadOnly: true,
                  onTap: _pickDOB,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _phoneController,
                  hintText: 'Mobile Number',
                  textInputType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter mobile number';
                    if (v.length != 10) return 'Mobile number must be 10 digits';
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _countryController,
                  hintText: 'Country',
                  isReadOnly: true,
                  onTap: _pickCountry,
                ),

                const SizedBox(height: 25),

                // 🔹 Save Changes button
                ElevatedButton(
                  onPressed: _updateUserProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                const SizedBox(height: 15),

                // 🔹 Logout button below Save Changes
                ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
