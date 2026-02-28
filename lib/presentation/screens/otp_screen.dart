import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/repositories/auth_repository.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.authRepository,
    required this.onSuccess,
    this.asBottomSheet = false,
  });

  final AuthRepository authRepository;
  final VoidCallback onSuccess;
  final bool asBottomSheet;

  static Future<void> showAsBottomSheet(
    BuildContext context, {
    required AuthRepository authRepository,
    required VoidCallback onSuccess,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: OtpScreen(
            asBottomSheet: true,
            authRepository: authRepository,
            onSuccess: () {
              Navigator.of(context).pop();
              onSuccess();
            },
          ),
        ),
      ),
    );
  }

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with TickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _enterController;
  late List<Animation<double>> _digitAnimations;
  int _resendSecondsRemaining = 45;
  Timer? _resendTimer;

  static const String _validOtp = '0000';

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _resendSecondsRemaining = 45);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_resendSecondsRemaining > 0) _resendSecondsRemaining--;
      });
      if (_resendSecondsRemaining == 0) {
        _resendTimer?.cancel();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _digitAnimations = List.generate(
      4,
      (i) => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _enterController,
          curve: Interval(0.2 + (i * 0.15), 0.5 + (i * 0.1),
              curve: Curves.easeOutBack),
        ),
      ),
    );
    _enterController.forward();
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _enterController.dispose();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _onResendCode() {
    if (_resendSecondsRemaining > 0) return;
    _startResendTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إرسال رمز جديد إلى جوالك'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String get _code =>
      _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.length == 1) {
      if (index < 3) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _verify();
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() => _errorMessage = null);
  }

  Future<void> _verify() async {
    final code = _code;
    if (code.length != 4) {
      setState(() => _errorMessage = 'أدخل رمز التحقق');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final ok = await widget.authRepository.verifyOtp(code);
      if (!mounted) return;
      if (ok) {
        await widget.authRepository.saveSession();
        widget.onSuccess();
      } else {
        setState(() {
          _errorMessage = 'رمز التحقق غير صحيح. استخدم 0000 للاختبار';
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

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    if (widget.asBottomSheet) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(context).bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                _buildDragHandle(),
                const SizedBox(height: 8),
                Text(
                  'توثيق رقم الجوال',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2937),
                      ),
                ),
                const SizedBox(height: 24),
                _buildIcon(primary),
                const SizedBox(height: 20),
                _buildTitle(context),
                const SizedBox(height: 8),
                _buildHint(context),
                const SizedBox(height: 12),
                _buildOtpHint(primary),
                const SizedBox(height: 28),
                _buildOtpInputs(primary),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  _buildErrorBanner(context),
                ],
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: _buildVerifyButton(context),
                ),
                const SizedBox(height: 20),
                _buildResendRow(context, primary),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      );
    }

    final size = MediaQuery.sizeOf(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primary.withValues(alpha: 0.08),
                    Colors.white,
                    primary.withValues(alpha: 0.04),
                    Colors.grey.shade50,
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
              ),
              child: CustomPaint(
                painter: _OtpBackgroundPainter(color: primary),
                size: size,
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  AppBar(
                    title: const Text('توثيق رقم الجوال'),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    foregroundColor: const Color(0xFF1F2937),
                    centerTitle: true,
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildIcon(primary),
                            const SizedBox(height: 28),
                            _buildTitle(context),
                            const SizedBox(height: 10),
                            _buildHint(context),
                            const SizedBox(height: 14),
                            _buildOtpHint(primary),
                            const SizedBox(height: 36),
                            _buildOtpInputs(primary),
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 20),
                              _buildErrorBanner(context),
                            ],
                            const SizedBox(height: 36),
                            _buildVerifyButton(context),
                            const SizedBox(height: 24),
                            _buildResendRow(context, primary),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildIcon(Color primary) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        Icons.phone_rounded,
        size: 52,
        color: primary,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      'أدخل رمز التحقق',
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1F2937),
          ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildHint(BuildContext context) {
    return Text(
      'تم إرسال رمز مكوّن من 4 أرقام إلى جوالك',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
          ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildOtpHint(Color primary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline_rounded, size: 20, color: primary),
          const SizedBox(width: 8),
          Text(
            'للاختبار استخدم الرمز: $_validOtp',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: primary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpInputs(Color primary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        return AnimatedBuilder(
          animation: _enterController,
          builder: (context, child) {
            return Transform.scale(
              scale: _digitAnimations[i].value,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _OtpDigitBox(
                  controller: _controllers[i],
                  focusNode: _focusNodes[i],
                  primary: primary,
                  onChanged: (v) => _onDigitChanged(i, v),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildErrorBanner(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: errorColor,
            size: 18,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: errorColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: _isLoading ? null : _verify,
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
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
            : const Text('تأكيد'),
      ),
    );
  }

  Widget _buildResendRow(BuildContext context, Color primary) {
    final canResend = _resendSecondsRemaining == 0;
    return Center(
      child: canResend
          ? TextButton(
              onPressed: _onResendCode,
              child: Text(
                'إعادة إرسال الرمز',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: primary,
                ),
              ),
            )
          : Text(
              'إعادة الإرسال خلال $_resendSecondsRemaining ثانية',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
    );
  }
}

class _OtpDigitBox extends StatefulWidget {
  const _OtpDigitBox({
    required this.controller,
    required this.focusNode,
    required this.primary,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final Color primary;
  final ValueChanged<String> onChanged;

  @override
  State<_OtpDigitBox> createState() => _OtpDigitBoxState();
}

class _OtpDigitBoxState extends State<_OtpDigitBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _focusController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _focusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1, end: 1.08).animate(
      CurvedAnimation(parent: _focusController, curve: Curves.easeOut),
    );
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (widget.focusNode.hasFocus) {
      _focusController.forward();
    } else {
      _focusController.reverse();
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    _focusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        );
      },
      child: Container(
        width: 56,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.focusNode.hasFocus
                ? widget.primary
                : Colors.grey.shade300,
            width: widget.focusNode.hasFocus ? 1.25 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SizedBox(
          height: 64,
          width: 56,
          child: TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 22),
              isDense: true,
            ),
            onChanged: widget.onChanged,
          ),
        ),
      ),
    );
  }
}

class _OtpBackgroundPainter extends CustomPainter {
  _OtpBackgroundPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.9, 80), 100, paint);
    canvas.drawCircle(Offset(0, size.height * 0.75), 120, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
