import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();
  final TextEditingController _regEmailController = TextEditingController();
  final TextEditingController _regPasswordController = TextEditingController();
  final TextEditingController _regConfirmPasswordController =
      TextEditingController();

  bool _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _regConfirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await AuthService.instance.signInWithEmail(
        _loginEmailController.text,
        _loginPasswordController.text,
      );
    } on AuthException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } catch (e) {
      debugPrint('[AuthScreen] Login error: $e');
      if (mounted) {
        setState(() => _errorMessage = 'Failed to sign in: $e');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleRegister() async {
    final String password = _regPasswordController.text;
    final String confirmPassword = _regConfirmPasswordController.text;

    if (password != confirmPassword) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await AuthService.instance.registerWithEmail(
        _regEmailController.text,
        password,
      );
    } on AuthException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } catch (e) {
      debugPrint('[AuthScreen] Registration error: $e');
      if (mounted) {
        setState(() => _errorMessage = 'Registration error: $e');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleGuestLogin() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await AuthService.instance.signInAnonymously();
    } on AuthException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } catch (e) {
      debugPrint('[AuthScreen] Guest login error: $e');
      if (mounted) {
        setState(() => _errorMessage = 'Guest session error: $e');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _fillDemoCredentials() {
    _loginEmailController.text = 'player@playpal.com';
    _loginPasswordController.text = 'password123';
    _tabController.animateTo(0);
    setState(() => _errorMessage = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1c1d2a),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Brand Header
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xff2a2245),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xffefc249), width: 2),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: const Color(0xffefc249).withValues(alpha: 0.25),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.sports_esports_rounded,
                      size: 44,
                      color: Color(0xffefc249),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'PLAYPAL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    'Enter the Arena. Challenge Friends.',
                    style: TextStyle(color: Color(0xffb5b3c3), fontSize: 13),
                  ),
                ),
                const SizedBox(height: 28),

                // Error Banner
                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xff521a24),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xfff87171)),
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.error_outline_rounded,
                            color: Color(0xfff87171), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Tab Switcher
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xff262735),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: const Color(0xffefc249),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    labelColor: const Color(0xff1c1d2a),
                    unselectedLabelColor: Colors.white70,
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 14),
                    tabs: const <Widget>[
                      Tab(text: 'Log In'),
                      Tab(text: 'Sign Up'),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Tab Views
                SizedBox(
                  height: 230,
                  child: TabBarView(
                    controller: _tabController,
                    children: <Widget>[
                      _buildLoginForm(),
                      _buildRegisterForm(),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Guest Mode Divider
                Row(
                  children: const <Widget>[
                    Expanded(child: Divider(color: Color(0xff3c3d4b))),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('OR',
                          style: TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ),
                    Expanded(child: Divider(color: Color(0xff3c3d4b))),
                  ],
                ),
                const SizedBox(height: 16),

                // Play as Guest Button
                OutlinedButton.icon(
                  onPressed: _loading ? null : _handleGuestLogin,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xffefc249),
                    side: const BorderSide(color: Color(0xffefc249), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.bolt_rounded, size: 20),
                  label: const Text(
                    'PLAY AS GUEST (INSTANT)',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 16),

                // Demo Helper
                Center(
                  child: TextButton(
                    onPressed: _fillDemoCredentials,
                    child: const Text(
                      'Demo account: Fill player@playpal.com',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildTextField(
          controller: _loginEmailController,
          hint: 'Email address',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _loginPasswordController,
          hint: 'Password',
          icon: Icons.lock_outline_rounded,
          obscureText: true,
        ),
        const SizedBox(height: 18),
        _buildActionButton(
          label: 'LOG IN',
          onPressed: _handleLogin,
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildTextField(
          controller: _regEmailController,
          hint: 'Email address',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 10),
        _buildTextField(
          controller: _regPasswordController,
          hint: 'Create password',
          icon: Icons.lock_outline_rounded,
          obscureText: true,
        ),
        const SizedBox(height: 10),
        _buildTextField(
          controller: _regConfirmPasswordController,
          hint: 'Confirm password',
          icon: Icons.lock_outline_rounded,
          obscureText: true,
        ),
        const SizedBox(height: 14),
        _buildActionButton(
          label: 'CREATE ACCOUNT',
          onPressed: _handleRegister,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff262735),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xff444558)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xffa1a0b0), size: 20),
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xff717082), fontSize: 14),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: _loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xffefc249),
        foregroundColor: const Color(0xff1c1d2a),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: _loading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xff1c1d2a),
              ),
            )
          : Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
    );
  }
}

