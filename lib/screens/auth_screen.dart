import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/common/custom_textfield.dart';
import 'package:flutter_chat/common/my_button.dart';
import 'package:flutter_chat/screens/mobile_screen.dart';
import 'package:flutter_chat/services/auth/controller/auth_controller.dart';
import 'package:flutter_chat/utils/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cpasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLogin = true;
  bool isloading = false;
  File? selectedImage;

  Future<File?> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      return File(pickedImage.path);
    }
    return null;
  }

  void _selectImage() async {
    selectedImage = await _pickImage();
    if (selectedImage != null) {
      setState(() {});
    }
  }

  void _signup() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _cpasswordController.text) {
      showDialog(
        context: context,
        builder:
            (context) => const AlertDialog(
              title: Text('Passwords do not match!'),
              content: Text('Please make sure both passwords are identical.'),
            ),
      );
      return;
    }

    if (selectedImage == null) {
      showSnackBar(
        context: context,
        content: 'Please select a profile picture.',
      );
      return;
    }
    setState(() {
      isloading = true;
    });
    try {
      await ref
          .read(authControllerProvider)
          .signUpWithEmail(
            email: _emailController.text,
            password: _passwordController.text,
            name: _nameController.text,
            image: selectedImage,
          );

      Navigator.pushAndRemoveUntil(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => MobileScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    setState(() {
      isloading = false;
    });
  }

  void _signin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      isloading = true;
    });
    try {
      await ref
          .read(authControllerProvider)
          .signInWithEmail(
            email: _emailController.text,
            password: _passwordController.text,
          );
      Navigator.pushAndRemoveUntil(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const MobileScreen()),
        (route) => false, // Predicate to remove all previous routes
      );
    } catch (e) {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    setState(() {
      isloading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _cpasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  // Welcome message with animation
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (
                      Widget child,
                      Animation<double> animation,
                    ) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: Text(
                      isLogin ? 'Chat In' : 'Chat Up',
                      key: ValueKey<bool>(isLogin),
                      style: GoogleFonts.roboto(
                        fontSize: 33,
                        fontWeight: FontWeight.w900,
                        color:
                            isDarkMode
                                ? Colors.red
                                : theme.textTheme.headlineLarge!.color,
                      ),
                    ),
                  ),
                  Text(
                    isLogin
                        ? 'Welcome Back, You have been missed!'
                        : 'Create an account!',
                  ),
                  const SizedBox(height: 20),

                  !isLogin
                      ? GestureDetector(
                        onTap: _selectImage,
                        child: CircleAvatar(
                          backgroundColor: const Color.fromARGB(
                            255,
                            46,
                            46,
                            46,
                          ),
                          radius: 50,
                          backgroundImage:
                              selectedImage != null
                                  ? FileImage(selectedImage!)
                                  : AssetImage('assets/images/chat.png'),
                          child:
                              selectedImage == null
                                  ? Icon(Icons.add_a_photo)
                                  : null,
                        ),
                      )
                      : const SizedBox.shrink(),
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (
                      Widget child,
                      Animation<double> animation,
                    ) {
                      return SizeTransition(
                        sizeFactor: animation,
                        child: child,
                      );
                    },
                    child:
                        isLogin
                            ? const SizedBox.shrink()
                            : CustomTextfield(
                              key: const ValueKey("name"),
                              hintText: 'Name',
                              controller: _nameController,
                            ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextfield(
                    hintText: 'Email',
                    controller: _emailController,
                  ),
                  const SizedBox(height: 16),
                  CustomTextfield(
                    hintText: 'Password',
                    controller: _passwordController,
                    obsecuretext: true,
                  ),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (
                      Widget child,
                      Animation<double> animation,
                    ) {
                      return SizeTransition(
                        sizeFactor: animation,
                        child: child,
                      );
                    },
                    child:
                        isLogin
                            ? const SizedBox.shrink()
                            : CustomTextfield(
                              key: const ValueKey("confirm_password"),
                              hintText: 'Confirm Password',
                              controller: _cpasswordController,
                            ),
                  ),

                  isloading
                      ? const CircularProgressIndicator()
                      : MyButton(
                        widget:
                            isloading
                                ? const CircularProgressIndicator()
                                : Text(
                                  isLogin ? 'Login' : 'Sign Up',
                                  style: GoogleFonts.roboto(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isDarkMode
                                            ? Colors.white
                                            : theme
                                                .buttonTheme
                                                .colorScheme
                                                ?.onPrimary,
                                  ),
                                ),

                        onTap: () {
                          !isLogin ? _signup() : _signin();
                        },
                      ),

                  // Register now toggle with animation
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (
                      Widget child,
                      Animation<double> animation,
                    ) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, 0.5),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      );
                    },
                    child: RichText(
                      key: ValueKey<bool>(isLogin),
                      text: TextSpan(
                        text:
                            isLogin
                                ? 'Don\'t have an account? '
                                : 'Already have an account? ',
                        children: [
                          TextSpan(
                            text: isLogin ? 'Sign Up' : 'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap = () {
                                    setState(() {
                                      isLogin = !isLogin;
                                    });
                                  },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
