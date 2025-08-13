import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'signin_screen.dart';
import '../../widgets/auth_widgets.dart';
import '../../widgets/loading_overlay.dart';
import '../home_page.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? fullNameError;
  String? emailError;
  String? passwordError;

  bool _isLoading = false;

  bool validateForm() {
    bool isValid = true;

    if (fullNameController.text.isEmpty) {
      fullNameError = "Full name cannot be empty";
      isValid = false;
    } else {
      fullNameError = null;
    }

    if (!emailController.text.endsWith("@gmail.com")) {
      emailError = "Email must end with @gmail.com";
      isValid = false;
    } else {
      emailError = null;
    }

    final password = passwordController.text;
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$');
    if (!passwordRegex.hasMatch(password)) {
      passwordError =
          "Password must have 1 uppercase, 1 lowercase, 1 number, 8+ characters";
      isValid = false;
    } else {
      passwordError = null;
    }

    setState(() {});
    return isValid;
  }

  Future<void> handleSignUp() async {
    if (!validateForm()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        "fullName": fullNameController.text,
        "email": emailController.text,
        "password": passwordController.text,
      };

      final result = await AuthService.signUp(data);
      final status = result['status'];
      final body = result['body'];

      if (status == 200) {
        await AuthService.saveUserData(
          context: context,
          token: body["token"],
          userId: body['user']['id'],
          name: (body['user']['fullName'] ?? "") as String,
          photoUrl: (body['user']['profilePicture'] ?? "") as String,
        );

        fullNameController.clear();
        emailController.clear();
        passwordController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body['message'] ?? "Signup successful")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body['message'] ?? "Signup failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Signup failed")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Base width from your Figma or design
    final baseWidth = 360;
    final scaleFactor = size.width / baseWidth;

    double scaledFont(double fontSize) => fontSize * scaleFactor;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: size.height * 0.25,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3).withOpacity(0.11),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(50 * scaleFactor),
                            bottomRight: Radius.circular(50 * scaleFactor),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: 32 * scaleFactor,
                          left: 24 * scaleFactor,
                          right: 24 * scaleFactor,
                          bottom: 32 * scaleFactor,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: scaledFont(35),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12 * scaleFactor),
                            Text(
                              'Signup and Discover your next Great Adventure !',
                              style: TextStyle(fontSize: scaledFont(25)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40 * scaleFactor),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0 * scaleFactor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FullNameField(
                          controller: fullNameController,
                          errorText: fullNameError,
                        ),
                        SizedBox(height: 20 * scaleFactor),
                        EmailPasswordFields(
                          emailController: emailController,
                          passwordController: passwordController,
                          emailError: emailError,
                          passwordError: passwordError,
                        ),
                        SizedBox(height: 20 * scaleFactor),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: handleSignUp,
                            child: Text(
                              'Create account',
                              style: TextStyle(fontSize: scaledFont(16)),
                            ),
                          ),
                        ),
                        SizedBox(height: 12 * scaleFactor),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: 8.0 * scaleFactor),
                              child: Text(
                                "or",
                                style: TextStyle(fontSize: scaledFont(14)),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        SizedBox(height: 20 * scaleFactor),
                        const GoogleButton(),
                        SizedBox(height: 32 * scaleFactor),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account ? ",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: scaledFont(14),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SignInScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Sign In",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                    fontSize: scaledFont(14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            LoadingOverlay(isLoading: _isLoading),
          ],
        ),
      ),
    );
  }
}
