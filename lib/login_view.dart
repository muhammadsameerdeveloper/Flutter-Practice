import 'package:flutter/material.dart';
import 'package:practiceapp/periodictable.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with TickerProviderStateMixin {
  // Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Form Key
  final formKey = GlobalKey<FormState>();

  // Focus Nodes
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();

  // Variables
  bool isPasswordVisible = false;
  bool rememberMe = false;
  bool isLoading = false;
  bool isEmailFocused = false;
  bool isPasswordFocused = false;
  bool hasSubmitted = false;

  // Animations
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  late AnimationController backgroundController;
  late Animation<double> backgroundAnimation;

  @override
  void initState() {
    super.initState();

    // Main Animation
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    fadeAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    );

    slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(
            parent: animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    animationController.forward();

    // Background Animation
    backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    backgroundAnimation = Tween<double>(begin: -20, end: 20).animate(
      CurvedAnimation(parent: backgroundController, curve: Curves.easeInOut),
    );

    // Focus Listeners
    emailFocus.addListener(() {
      if (!mounted) return;

      setState(() {
        isEmailFocused = emailFocus.hasFocus;
      });
    });

    passwordFocus.addListener(() {
      if (!mounted) return;

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

    if (password.contains(RegExp(r'[A-Z]'))) {
      strength += 0.25;
    }

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

  // Input Decoration
  InputDecoration inputDecoration({
    required String hint,
    required IconData icon,
    required bool focused,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,

      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),

      prefixIcon: Icon(
        icon,
        color: focused ? const Color(0xff2563EB) : Colors.grey,
      ),

      suffixIcon: suffix,

      filled: true,

      fillColor: focused
          ? const Color(0xff2563EB).withOpacity(0.06)
          : Colors.grey.shade50,

      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 19),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xff2563EB), width: 1.8),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  // Login Function
  Future<void> login() async {
    setState(() {
      hasSubmitted = true;
    });

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

  // Forgot Password Dialog
  void forgotPassword() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),

          title: const Text(
            "Forgot Password?",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Enter your email address to reset your password."),

              const SizedBox(height: 20),

              TextField(
                controller: controller,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Enter your email",
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                controller.dispose();
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Password reset request submitted!"),
                    ),
                  );
                }

                controller.dispose();
              },

              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  // Logo Widget
  Widget logoWidget() {
    return Container(
      height: 85,
      width: 85,

      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: const Icon(
        Icons.lock_person_rounded,
        size: 45,
        color: Color(0xff2563EB),
      ),
    );
  }

  // Password Strength Widget
  Widget passwordStrengthWidget() {
    if (passwordController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),

          child: LinearProgressIndicator(
            value: passwordStrength,
            minHeight: 7,

            backgroundColor: Colors.grey.shade200,

            valueColor: AlwaysStoppedAnimation(strengthColor),
          ),
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              strengthText,
              style: TextStyle(
                color: strengthColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              "${(passwordStrength * 100).toInt()}%",
              style: TextStyle(
                color: strengthColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Email Field
  Widget emailField() {
    return TextFormField(
      controller: emailController,
      focusNode: emailFocus,

      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,

      onFieldSubmitted: (_) {
        FocusScope.of(context).requestFocus(passwordFocus);
      },

      decoration: inputDecoration(
        hint: "Enter your email",
        icon: Icons.email_outlined,
        focused: isEmailFocused,
      ),

      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Email is required";
        }

        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
          return "Enter a valid email";
        }

        return null;
      },
    );
  }

  // Password Field
  Widget passwordField() {
    return TextFormField(
      controller: passwordController,
      focusNode: passwordFocus,

      obscureText: !isPasswordVisible,

      textInputAction: TextInputAction.done,

      onChanged: (_) {
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
              isPasswordVisible = !isPasswordVisible;
            });
          },

          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),

            child: Icon(
              isPasswordVisible
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,

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
    );
  }

  // Remember Me
  Widget rememberMeWidget() {
    return Row(
      children: [
        SizedBox(
          height: 35,
          child: Checkbox(
            value: rememberMe,

            activeColor: const Color(0xff2563EB),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),

            onChanged: (value) {
              setState(() {
                rememberMe = value ?? false;
              });
            },
          ),
        ),

        const Text("Remember Me", style: TextStyle(fontSize: 12)),

        const Spacer(),

        TextButton(
          onPressed: forgotPassword,

          child: const Text(
            "Forgot Password?",
            style: TextStyle(
              fontSize: 12,
              color: Color(0xff2563EB),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // Login Button
  Widget loginButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,

      child: ElevatedButton(
        onPressed: isLoading ? null : login,

        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff2563EB),
          foregroundColor: Colors.white,
          elevation: 5,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),

          child: isLoading
              ? const SizedBox(
                  key: ValueKey("loading"),
                  height: 25,
                  width: 25,

                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : const Row(
                  key: ValueKey("login"),

                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Text(
                      "LOGIN",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),

                    SizedBox(width: 12),

                    Icon(Icons.arrow_forward_rounded),
                  ],
                ),
        ),
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
    backgroundController.dispose();

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

          // Animated Circle 1
          AnimatedBuilder(
            animation: backgroundAnimation,

            builder: (context, child) {
              return Positioned(
                top: -80 + backgroundAnimation.value,
                right: -60,

                child: Container(
                  height: 230,
                  width: 230,

                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),

          // Animated Circle 2
          AnimatedBuilder(
            animation: backgroundAnimation,

            builder: (context, child) {
              return Positioned(
                bottom: -100 - backgroundAnimation.value,
                left: -70,

                child: Container(
                  height: 260,
                  width: 260,

                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),

          // Main Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),

                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),

                      child: SlideTransition(
                        position: slideAnimation,

                        child: FadeTransition(
                          opacity: fadeAnimation,

                          child: Column(
                            children: [
                              // Logo
                              logoWidget(),

                              const SizedBox(height: 22),

                              // Heading
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
                              Container(
                                width: double.infinity,

                                padding: const EdgeInsets.all(25),

                                decoration: BoxDecoration(
                                  color: Colors.white,

                                  borderRadius: BorderRadius.circular(28),

                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 35,
                                      offset: const Offset(0, 15),
                                    ),
                                  ],
                                ),

                                child: Form(
                                  key: formKey,

                                  autovalidateMode: hasSubmitted
                                      ? AutovalidateMode.onUserInteraction
                                      : AutovalidateMode.disabled,

                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      // Card Heading
                                      const Text(
                                        "Sign In",
                                        style: TextStyle(
                                          fontSize: 27,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 7),

                                      Text(
                                        "Enter your details below",
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 13,
                                        ),
                                      ),

                                      const SizedBox(height: 30),

                                      // Email
                                      const Text(
                                        "Email Address",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      emailField(),

                                      const SizedBox(height: 23),

                                      // Password
                                      const Text(
                                        "Password",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      passwordField(),

                                      const SizedBox(height: 12),

                                      // Password Strength
                                      passwordStrengthWidget(),

                                      const SizedBox(height: 15),

                                      // Remember Me
                                      rememberMeWidget(),

                                      const SizedBox(height: 22),

                                      // Login Button
                                      loginButton(),

                                      const SizedBox(height: 25),

                                      // Divider
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Divider(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),

                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),

                                            child: Text(
                                              "SECURE LOGIN",
                                              style: TextStyle(
                                                color: Colors.grey.shade500,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),

                                          Expanded(
                                            child: Divider(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 20),

                                      // Bottom Text
                                      Center(
                                        child: Text(
                                          "Your information is protected",
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

                              // Footer
                              const Text(
                                "Powered by Flutter",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
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
