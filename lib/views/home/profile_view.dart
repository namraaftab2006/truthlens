import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/services.dart';
import '../../utils/constants.dart';
import '../auth/signup_view.dart';
import '../../widgets/custom_textfield.dart';
import '../home/saved_news_view.dart';

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

  int _saved = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

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

        final savedArticles = (data?['savedArticles'] as List?) ?? [];
        _saved = savedArticles.length;
      });
    }
  }

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
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }


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

  void _logout() async {
    await _auth.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SignupView()),
          (route) => false,
    );
  }

  Widget _buildSquareBox(BuildContext context, String label, int count,
      {VoidCallback? onTap}) {
    final theme = Theme.of(context);
    final double boxSize = MediaQuery.of(context).size.width * 0.2; // 20% of screen width

    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: boxSize,
          height: boxSize,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                count.toString(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
                  child:
                  const Icon(Icons.person, color: Colors.white, size: 50),
                ),
                const SizedBox(height: 20),

                // 🔹 Only one square Saved box
                _buildSquareBox(
                  context,
                  'Saved',
                  _saved,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SavedNewsView()),
                    );
                  },
                ),

                const SizedBox(height: 30),

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
                    if (v == null || v.isEmpty) {
                      return 'Enter mobile number';
                    }
                    if (v.length != 10) {
                      return 'Mobile number must be 10 digits';
                    }
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

                ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
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
