import 'package:flutter/material.dart';

import '../../domain/repositories/auth_repository.dart';
import 'otp_screen.dart';

enum LoginMode { email, phone }

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.authRepository,
    required this.onLoginSuccess,
  });

  final AuthRepository authRepository;
  final VoidCallback onLoginSuccess;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  LoginMode _mode = LoginMode.email;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedCountryCode = '+966';
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const Map<String, String> _countries = {
    '+966': 'السعودية',
    '+971': 'الإمارات',
    '+965': 'الكويت',
    '+973': 'البحرين',
    '+974': 'قطر',
    '+968': 'عُمان',
    '+962': 'الأردن',
    '+963': 'سوريا',
    '+961': 'لبنان',
    '+20': 'مصر',
  };

  static const Map<String, String> _countryFlags = {
    '+966': '🇸🇦',
    '+971': '🇦🇪',
    '+965': '🇰🇼',
    '+973': '🇧🇭',
    '+974': '🇶🇦',
    '+968': '🇴🇲',
    '+962': '🇯🇴',
    '+963': '🇸🇾',
    '+961': '🇱🇧',
    '+20': '🇪🇬',
  };

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final ok = await widget.authRepository.loginWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) return;
      if (ok) {
        await widget.authRepository.saveSession();
        widget.onLoginSuccess();
      } else {
        setState(() {
          _errorMessage = 'البريد أو كلمة المرور غير صحيحة';
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'حدث خطأ، حاول مرة أخرى';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitPhone() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await widget.authRepository.loginWithPhone(
        _phoneController.text.trim(),
        _selectedCountryCode,
      );
      if (!mounted) return;
      OtpScreen.showAsBottomSheet(
        context,
        authRepository: widget.authRepository,
        onSuccess: widget.onLoginSuccess,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _submit() {
    if (_mode == LoginMode.email) {
      _submitEmail();
    } else {
      _submitPhone();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                primary.withValues(alpha: 0.06),
                Colors.white,
                Colors.grey.shade50,
              ],
              stops: const [0.0, 0.35, 1.0],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
                    child: IntrinsicHeight(
                      child: AnimatedBuilder(
                        animation: _animController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _fadeAnim.value,
                            child: SlideTransition(
                              position: _slideAnim,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildLogo(primary),
                                  const SizedBox(height: 32),
                                  _buildTitle(context),
                                  const SizedBox(height: 28),
                                  _buildCard(context, primary),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(Color primary) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.asset(
        'assets/images/logo.png',
        height: 88,
        width: 88,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 88,
          width: 88,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(Icons.shopping_cart_rounded, size: 56, color: primary),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Column(
      children: [
        Text(
          'تسجيل الدخول',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111827),
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'مرحباً بك في كويك كارت',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, Color primary) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildModeSelector(primary),
            const SizedBox(height: 24),
            if (_mode == LoginMode.email) ...[
              _buildEmailField(context),
              const SizedBox(height: 16),
              _buildPasswordField(context),
            ] else
              _buildPhoneRow(context),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              _buildErrorBanner(context),
            ],
            const SizedBox(height: 28),
            SizedBox(
              height: 54,
              child: FilledButton(
                onPressed: _isLoading ? null : _submit,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('دخول'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelector(Color primary) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _modeChip(
              primary: primary,
              mode: LoginMode.email,
              icon: Icons.email_outlined,
              label: 'البريد الإلكتروني',
            ),
          ),
          Expanded(
            child: _modeChip(
              primary: primary,
              mode: LoginMode.phone,
              icon: Icons.phone_android_outlined,
              label: 'رقم الجوال',
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeChip({
    required Color primary,
    required LoginMode mode,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _mode == mode;
    return GestureDetector(
      onTap: () => setState(() {
        _mode = mode;
        _errorMessage = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField(BuildContext context) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'البريد الإلكتروني',
        hintText: 'example@email.com',
        prefixIcon: const Icon(Icons.email_outlined),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'أدخل البريد الإلكتروني';
        if (!v.contains('@')) return 'بريد غير صالح';
        return null;
      },
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'كلمة المرور',
        prefixIcon: const Icon(Icons.lock_outline),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'أدخل كلمة المرور';
        return null;
      },
    );
  }

  Widget _buildPhoneRow(BuildContext context) {
    return FormField<String>(
      initialValue: _phoneController.text,
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'أدخل رقم الجوال';
        if (v.trim().length < 8) return 'رقم غير صالح';
        return null;
      },
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 6),
              child: Text(
                'رقم الجوال',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCountryCode,
                        isDense: true,
                        isExpanded: false,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 8),
                        icon: const Icon(
                            Icons.keyboard_arrow_down_rounded, size: 22),
                        borderRadius: BorderRadius.circular(12),
                        selectedItemBuilder: (context) => _countries.entries
                            .map((e) => Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        _countryFlags[e.key] ?? '🏳️',
                                        style: const TextStyle(fontSize: 17),
                                      ),
                                      const SizedBox(width: 6),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 3.0),
                                        child: Text(
                                          e.key,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 17,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                        items: _countries.entries
                            .map((e) => DropdownMenuItem(
                                  value: e.key,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        _countryFlags[e.key] ?? '🏳️',
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        e.key,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => _selectedCountryCode = v);
                          }
                        },
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: Colors.grey.shade300,
                    ),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(height: 1.2),
                        decoration: const InputDecoration(
                          hintText: '5xxxxxxxx',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          isDense: true,
                        ),
                        onChanged: (v) => state.didChange(v),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (state.hasError) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  state.errorText!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildErrorBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Theme.of(context).colorScheme.error,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
