import 'package:flutter/material.dart';
import 'signup_screen.dart';
import '../../widgets/auth_widgets.dart';
import '../../services/auth_service.dart';
import '../../widgets/loading_overlay.dart';
import '.././home_page.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? emailError;
  String? passwordError;

  bool _isLoading = false;

  bool validateForm() {
    bool isValid = true;

    if (!emailController.text.endsWith("@gmail.com")) {
      emailError = "Enter valid Gmail";
      isValid = false;
    } else {
      emailError = null;
    }

    if (passwordController.text.isEmpty) {
      passwordError = "Password cannot be empty";
      isValid = false;
    } else {
      passwordError = null;
    }

    setState(() {});
    return isValid;
  }

  void handleLogin() async {
    if (!validateForm()) return;

    setState(() => _isLoading = true);

    final data = {
      "email": emailController.text,
      "password": passwordController.text,
    };

    try {
      final response = await AuthService.login(data);

      if (response["status"] == 200) {
        final body = response["body"];

        await AuthService.saveUserData(
          context: context,
          token: body["token"],
          userId: body['user']['id'],
          name: (body['user']['fullName'] ?? "") as String,
          photoUrl: (body['user']['profilePicture'] ?? "") as String,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Welcome ${body['user']['fullName']}")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response["body"]["message"] ?? "Login failed"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Something went wrong")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final textScale = MediaQuery.of(context).textScaleFactor;

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
                        height: screenHeight * 0.25,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3).withOpacity(0.11),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(screenHeight * 0.06),
                            bottomRight: Radius.circular(screenHeight * 0.06),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: screenHeight * 0.04,
                          left: screenWidth * 0.06,
                          right: screenWidth * 0.06,
                          bottom: screenHeight * 0.04,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 35 * (screenWidth / 360) * textScale,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.015),
                            Text(
                              'Welcome back, your next\nAdventure awaits !',
                              style: TextStyle(
                                fontSize:
                                    20 * (screenWidth / 360) * textScale,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EmailPasswordFields(
                          emailController: emailController,
                          passwordController: passwordController,
                          emailError: emailError,
                          passwordError: passwordError,
                        ),
                        SizedBox(height: screenHeight * 0.025),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: handleLogin,
                            child: Text(
                              'Login',
                              style: TextStyle(
                                fontSize:
                                    16 * (screenWidth / 360) * textScale,
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              'Forgot password ?',
                              style: TextStyle(
                                fontSize:
                                    14 * (screenWidth / 360) * textScale,
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                              child: Text(
                                "or",
                                style: TextStyle(
                                  fontSize:
                                      14 * (screenWidth / 360) * textScale,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.025),
                        const GoogleButton(),
                        SizedBox(height: screenHeight * 0.04),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don’t have an account yet ? ",
                                style: TextStyle(
                                  fontSize:
                                      14 * (screenWidth / 360) * textScale,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SignUpScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    fontSize:
                                        14 * (screenWidth / 360) * textScale,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
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
