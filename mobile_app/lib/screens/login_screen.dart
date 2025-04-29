import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

enum AuthMode { phone, email }

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _verificationId;
  bool _codeSent = false;
  bool _loading = false;
  AuthMode _authMode = AuthMode.phone;

  @override
  void initState() {
    super.initState();
    _authService.userChanges.listen((user) {
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
      }
    });
  }

  void _showToast(String message) {
    Fluttertoast.showToast(msg: message, gravity: ToastGravity.BOTTOM);
  }

  void _verifyPhone() async {
    setState(() {
      _loading = true;
    });
    await _authService.verifyPhoneNumber(
      phoneNumber: _phoneController.text.trim(),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _authService.signInWithPhoneCredential(credential);
        _showToast('Phone number automatically verified and user signed in');
      },
      verificationFailed: (FirebaseAuthException e) {
        _showToast('Phone number verification failed: ${e.message}');
        setState(() {
          _loading = false;
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        _showToast('OTP sent to phone');
        setState(() {
          _verificationId = verificationId;
          _codeSent = true;
          _loading = false;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  void _signInWithOTP() async {
    if (_verificationId == null) {
      _showToast('Please request OTP first');
      return;
    }
    setState(() {
      _loading = true;
    });
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!, smsCode: _otpController.text.trim());
      await _authService.signInWithPhoneCredential(credential);
      _showToast('Phone number verified and user signed in');
    } catch (e) {
      _showToast('Failed to sign in: $e');
    }
    setState(() {
      _loading = false;
    });
  }

  void _signInWithGoogle() async {
    setState(() {
      _loading = true;
    });
    try {
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential != null) {
        _showToast('Signed in with Google');
      } else {
        _showToast('Google sign-in cancelled');
      }
    } catch (e) {
      _showToast('Google sign-in failed: $e');
    }
    setState(() {
      _loading = false;
    });
  }

  void _signInWithEmail() async {
    setState(() {
      _loading = true;
    });
    try {
      await _authService.signInWithEmail(
          _emailController.text.trim(), _passwordController.text.trim());
      _showToast('Signed in with email');
    } catch (e) {
      _showToast('Email sign-in failed: $e');
    }
    setState(() {
      _loading = false;
    });
  }

  Widget _buildPhoneLogin() {
    return Column(
      children: [
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(labelText: 'Phone Number (+country code)'),
        ),
        SizedBox(height: 10),
        if (_codeSent)
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Enter OTP'),
          ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: _loading
              ? null
              : _codeSent
                  ? _signInWithOTP
                  : _verifyPhone,
          child: Text(_codeSent ? 'Verify OTP' : 'Send OTP'),
        ),
      ],
    );
  }

  Widget _buildEmailLogin() {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(labelText: 'Email'),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(labelText: 'Password'),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: _loading ? null : _signInWithEmail,
          child: Text('Sign In'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Khojo App Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ToggleButtons(
              isSelected: [_authMode == AuthMode.phone, _authMode == AuthMode.email],
              onPressed: (index) {
                setState(() {
                  _authMode = index == 0 ? AuthMode.phone : AuthMode.email;
                  _codeSent = false;
                });
              },
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Phone'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Email'),
                ),
              ],
            ),
            SizedBox(height: 20),
            _authMode == AuthMode.phone ? _buildPhoneLogin() : _buildEmailLogin(),
            SizedBox(height: 20),
            Text('OR'),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loading ? null : _signInWithGoogle,
              icon: Icon(Icons.login),
              label: Text('Sign in with Google'),
            ),
          ],
        ),
      ),
    );
  }
}
