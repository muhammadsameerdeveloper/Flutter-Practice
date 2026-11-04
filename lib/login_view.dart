import 'package:flutter/material.dart';
import 'package:practiceapp/periodictable.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  // Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Form Key
  final formKey = GlobalKey<FormState>();

  // Focus Nodes
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();

  // Boolean Variables
  bool isPasswordVisible = false;
  bool rememberMe = false;
  bool isLoading = false;
  bool isEmailFocused = false;
  bool isPasswordFocused = false;

  // Animation Controller
  late AnimationController animationController;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    fadeAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    );

    animationController.forward();

    // Focus Listeners
    emailFocus.addListener(() {
      setState(() {
        isEmailFocused = emailFocus.hasFocus;
      });
    });

    passwordFocus.addListener(() {
      setState(() {
        isPasswordFocused = passwordFocus.hasFocus;
      });
    });
  }

  // Password Strength
  double get passwordStrength {
    String password = passwordController.text;

    if (password.isEmpty) return 0;

    double strength = 0;

    if (password.length >= 6) strength += 0.25;
    if (password.length >= 10) strength += 0.25;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (password.contains(RegExp(r'[0-9!@#$%^&*]'))) {
      strength += 0.25;
    }

    return strength;
  }

  String get strengthText {
    if (passwordStrength <= 0.25) return "Weak Password";
    if (passwordStrength <= 0.50) return "Medium Password";
    if (passwordStrength <= 0.75) return "Good Password";
    return "Strong Password";
  }

  Color get strengthColor {
    if (passwordStrength <= 0.25) return Colors.red;
    if (passwordStrength <= 0.50) return Colors.orange;
    if (passwordStrength <= 0.75) return Colors.blue;
    return Colors.green;
  }

  // Login Function
  Future<void> login() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    bool isSuccess =
        emailController.text.trim().toLowerCase() == "admin@gmail.com" &&
        passwordController.text == "123456";

    setState(() {
      isLoading = false;
    });

    if (isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login Successful!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PeriodicTable()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid Email or Password"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Custom Input Decoration
  InputDecoration inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
    bool focused = false,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: focused ? Colors.blue : Colors.grey),
      suffixIcon: suffix,

      filled: true,
      fillColor: focused ? Colors.blue.withOpacity(0.06) : Colors.grey.shade100,

      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.blue, width: 1.8),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    emailFocus.dispose();
    passwordFocus.dispose();

    animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xff0D47A1),
                  Color(0xff1976D2),
                  Color(0xff64B5F6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Background Circle 1
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              height: 220,
              width: 220,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Background Circle 2
          Positioned(
            bottom: -100,
            left: -70,
            child: Container(
              height: 250,
              width: 250,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Main UI
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double screenWidth = constraints.maxWidth;

                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),

                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: screenWidth > 700 ? 450 : 500,
                      ),

                      child: FadeTransition(
                        opacity: fadeAnimation,

                        child: Column(
                          children: [
                            // Top Logo
                            Container(
                              height: 90,
                              width: 90,

                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),

                              child: const Icon(
                                Icons.lock_person_rounded,
                                size: 48,
                                color: Color(0xff1565C0),
                              ),
                            ),

                            const SizedBox(height: 20),

                            const Text(
                              "Welcome Back!",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              "Login to access your account",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 15,
                              ),
                            ),

                            const SizedBox(height: 35),

                            // Login Card
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 400),

                              padding: const EdgeInsets.all(25),

                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),

                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 30,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),

                              child: Form(
                                key: formKey,

                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    const Text(
                                      "Sign In",
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      "Enter your details below",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),

                                    const SizedBox(height: 30),

                                    // Email Label
                                    const Text(
                                      "Email Address",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    // Email Field
                                    TextFormField(
                                      controller: emailController,
                                      focusNode: emailFocus,

                                      keyboardType: TextInputType.emailAddress,

                                      textInputAction: TextInputAction.next,

                                      onFieldSubmitted: (_) {
                                        FocusScope.of(
                                          context,
                                        ).requestFocus(passwordFocus);
                                      },

                                      decoration: inputDecoration(
                                        hint: "Enter your email",
                                        icon: Icons.email_outlined,
                                        focused: isEmailFocused,
                                      ),

                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return "Email is required";
                                        }

                                        if (!RegExp(
                                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                        ).hasMatch(value.trim())) {
                                          return "Enter a valid email";
                                        }

                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 22),

                                    // Password Label
                                    const Text(
                                      "Password",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    // Password Field
                                    TextFormField(
                                      controller: passwordController,
                                      focusNode: passwordFocus,

                                      obscureText: !isPasswordVisible,

                                      textInputAction: TextInputAction.done,

                                      onChanged: (value) {
                                        setState(() {});
                                      },

                                      onFieldSubmitted: (_) => login(),

                                      decoration: inputDecoration(
                                        hint: "Enter your password",
                                        icon: Icons.lock_outline,
                                        focused: isPasswordFocused,

                                        suffix: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              isPasswordVisible =
                                                  !isPasswordVisible;
                                            });
                                          },

                                          icon: AnimatedSwitcher(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),

                                            child: Icon(
                                              isPasswordVisible
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              key: ValueKey(isPasswordVisible),
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),

                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Password is required";
                                        }

                                        if (value.length < 6) {
                                          return "Minimum 6 characters required";
                                        }

                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 12),

                                    // Password Strength
                                    if (passwordController.text.isNotEmpty)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),

                                            child: LinearProgressIndicator(
                                              value: passwordStrength,
                                              minHeight: 7,
                                              backgroundColor:
                                                  Colors.grey.shade200,
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                    strengthColor,
                                                  ),
                                            ),
                                          ),

                                          const SizedBox(height: 7),

                                          Text(
                                            strengthText,
                                            style: TextStyle(
                                              color: strengthColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),

                                    const SizedBox(height: 15),

                                    // Remember Me
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: rememberMe,
                                          activeColor: Colors.blue,

                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),

                                          onChanged: (value) {
                                            setState(() {
                                              rememberMe = value ?? false;
                                            });
                                          },
                                        ),

                                        const Text(
                                          "Remember Me",
                                          style: TextStyle(fontSize: 13),
                                        ),

                                        const Spacer(),

                                        TextButton(
                                          onPressed: () {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Forgot Password Clicked",
                                                ),
                                              ),
                                            );
                                          },

                                          child: const Text(
                                            "Forgot Password?",
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 20),

                                    // Login Button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 55,

                                      child: ElevatedButton(
                                        onPressed: isLoading ? null : login,

                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xff1565C0,
                                          ),
                                          foregroundColor: Colors.white,
                                          elevation: 5,

                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                        ),

                                        child: AnimatedSwitcher(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),

                                          child: isLoading
                                              ? const SizedBox(
                                                  key: ValueKey("loading"),
                                                  height: 25,
                                                  width: 25,
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 3,
                                                      ),
                                                )
                                              : const Row(
                                                  key: ValueKey("login"),
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "LOGIN",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Icon(
                                                      Icons.arrow_forward,
                                                      size: 20,
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 25),

                                    // Bottom Text
                                    Center(
                                      child: Text(
                                        "Secure Login • Welcome to our App",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),

                            const Text(
                              "Powered by Flutter",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
