import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  bool hidePassword = true;
  bool loading = false;

  String? error;

  String? socialLoading;

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // EMAIL LOGIN
  // ============================================================

  Future<void> signIn() async {
    final email = emailController.text.trim();

    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        error = 'Enter your email and password.';
      });

      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // AuthGate automatically changes
      // to EventsScreen after login.
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        error = _firebaseMessage(e);
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        error = 'Something went wrong. Try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  // ============================================================
  // GOOGLE
  // ============================================================

  Future<void> signInGoogle() async {
    final provider = GoogleAuthProvider();

    provider.addScope('email');
    provider.addScope('profile');

    await _socialSignIn(
      provider,
      'Google',
    );
  }

  // ============================================================
  // GITHUB
  // ============================================================

  Future<void> signInGithub() async {
    final provider = GithubAuthProvider();

    provider.addScope('user:email');

    await _socialSignIn(
      provider,
      'GitHub',
    );
  }

  // ============================================================
  // LINKEDIN
  // ============================================================

  Future<void> signInLinkedIn() async {
    final provider = OAuthProvider('linkedin.com');

    provider.addScope('openid');
    provider.addScope('profile');
    provider.addScope('email');

    await _socialSignIn(
      provider,
      'LinkedIn',
    );
  }

  // ============================================================
  // FEDERATED SIGN IN
  // ============================================================

  Future<void> _socialSignIn(
    AuthProvider provider,
    String providerName,
  ) async {
    if (socialLoading != null) return;

    setState(() {
      socialLoading = providerName;
      error = null;
    });

    try {
      if (kIsWeb) {
        await FirebaseAuth.instance.signInWithPopup(
          provider,
        );
      } else {
        await FirebaseAuth.instance.signInWithProvider(
          provider,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        error = _socialFirebaseMessage(
          e,
          providerName,
        );
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        error = '$providerName sign-in could not be completed.';
      });
    } finally {
      if (mounted) {
        setState(() {
          socialLoading = null;
        });
      }
    }
  }

  // ============================================================
  // PASSWORD RESET
  // ============================================================

  Future<void> forgotPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        error = 'Enter your email first.';
      });

      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password reset email sent.',
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.message ?? 'Unable to send reset email.';
      });
    }
  }

  // ============================================================
  // ERROR MESSAGES
  // ============================================================

  String _firebaseMessage(
    FirebaseAuthException e,
  ) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Incorrect email or password.';

      case 'invalid-email':
        return 'Enter a valid email address.';

      case 'too-many-requests':
        return 'Too many attempts. Try again later.';

      case 'network-request-failed':
        return 'Check your internet connection.';

      default:
        return e.message ?? 'Unable to sign in.';
    }
  }

  String _socialFirebaseMessage(
    FirebaseAuthException e,
    String provider,
  ) {
    switch (e.code) {
      case 'popup-closed-by-user':
        return '$provider sign-in was cancelled.';

      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email using another sign-in method.';

      case 'operation-not-allowed':
        return '$provider sign-in has not been enabled in Firebase yet.';

      case 'network-request-failed':
        return 'Check your internet connection.';

      default:
        return e.message ?? '$provider sign-in failed.';
    }
  }

  // ============================================================
  // SCREEN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Soft pink background decoration
            Positioned(
              right: -120,
              top: -90,
              child: Container(
                width: 330,
                height: 330,
                decoration: BoxDecoration(
                  color: AppColors.tint.withOpacity(.60),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -120,
              bottom: -80,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: AppColors.dustyRose.withOpacity(.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: -40,
              bottom: 180,
              child: Transform.rotate(
                angle: -.35,
                child: Container(
                  width: 150,
                  height: 260,
                  decoration: BoxDecoration(
                    color: AppColors.lightTint.withOpacity(.70),
                    borderRadius: BorderRadius.circular(90),
                  ),
                ),
              ),
            ),

            Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 470),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _brand(),
                      const SizedBox(height: 24),
                      _hero(),
                      const SizedBox(height: 22),
                      _loginCard(),
                      const SizedBox(height: 16),
                      _newAccount(),
                      const SizedBox(height: 10),
                      const Center(
                        child: Text(
                          'Events  •  Hackathons  •  Open Source  •  Fellowships',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 8.5,
                            letterSpacing: .15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BRAND
  // ============================================================

  Widget _brand() {
    return SizedBox(
      height: 64,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Image.asset(
          'assets/images/campuspilot_logo.png',
          fit: BoxFit.contain,
          alignment: Alignment.centerLeft,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) {
            return Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.hue,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Φ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w500,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CampusPilot',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.6,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'DISCOVER • BUILD • BELONG',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 7.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _hero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.lightTint.withOpacity(.98),
            AppColors.tint.withOpacity(.72),
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.dustyRose.withOpacity(.16),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkShade.withOpacity(.045),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -28,
            top: -35,
            child: Container(
              width: 125,
              height: 125,
              decoration: BoxDecoration(
                color: AppColors.dustyRose.withOpacity(.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 18,
            bottom: -38,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.antiqueBrass.withOpacity(.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome\nback.',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 44,
                  height: .93,
                  letterSpacing: -1.35,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 15),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    color: AppColors.textSoft,
                    height: 1.42,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text:
                          'Discover student events, open-source opportunities and experiences that shape ',
                    ),
                    TextSpan(
                      text: 'your future.',
                      style: TextStyle(
                        color: AppColors.dustyRose,
                        fontWeight: FontWeight.w800,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _heroChip(
                    Icons.event_available_rounded,
                    'Events',
                  ),
                  _heroChip(
                    Icons.code_rounded,
                    'Open Source',
                  ),
                  _heroChip(
                    Icons.school_outlined,
                    'Opportunities',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroChip(
    IconData icon,
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(.82),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.hue,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOGIN CARD
  // ============================================================

  Widget _loginCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        18,
        19,
        18,
        20,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          24,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkShade.withOpacity(.07),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sign in to CampusPilot',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 23,
              fontWeight: FontWeight.w900,
              letterSpacing: -.5,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Pick up where you left off and keep discovering opportunities.',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 10.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Email',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [
              AutofillHints.email,
            ],
            decoration: _fieldDecoration(
              hint: 'you@example.com',
              icon: Icons.mail_outline_rounded,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Text(
                'Password',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: forgotPassword,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.hue,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          TextField(
            controller: passwordController,
            obscureText: hidePassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [
              AutofillHints.password,
            ],
            onSubmitted: (_) {
              if (!loading) {
                signIn();
              }
            },
            decoration: _fieldDecoration(
              hint: 'Enter your password',
              icon: Icons.lock_outline_rounded,
              suffix: IconButton(
                onPressed: () {
                  setState(() {
                    hidePassword = !hidePassword;
                  });
                },
                icon: Icon(
                  hidePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ),
          if (error != null) ...[
            const SizedBox(
              height: 11,
            ),
            _errorBox(),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: loading || socialLoading != null ? null : signIn,
              style: _primaryButtonStyle(),
              child: loading
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 21),
          _orDivider(),
          const SizedBox(height: 15),
          // GOOGLE / GITHUB / LINKEDIN
          Row(
            children: [
              Expanded(
                child: _socialButton(
                  label: 'Google',
                  asset: 'assets/images/social/google.png',
                  loading: socialLoading == 'Google',
                  onTap: signInGoogle,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _socialButton(
                  label: 'GitHub',
                  asset: 'assets/images/social/github.png',
                  loading: socialLoading == 'GitHub',
                  onTap: signInGithub,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _socialButton(
                  label: 'LinkedIn',
                  asset: 'assets/images/social/linkedin.png',
                  loading: socialLoading == 'LinkedIn',
                  onTap: signInLinkedIn,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SOCIAL BUTTON
  // ============================================================

  Widget _socialButton({
    required String label,
    required String asset,
    required bool loading,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(13),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: socialLoading == null && !this.loading ? onTap : null,
        hoverColor: AppColors.hover,
        splashColor: AppColors.pressed,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.border,
            ),
            borderRadius: BorderRadius.circular(
              13,
            ),
          ),
          child: loading
              ? const Center(
                  child: SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.7,
                      color: AppColors.hue,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 23,
                      height: 23,
                      child: Image.asset(
                        asset,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (
                          context,
                          error,
                          stack,
                        ) {
                          return Icon(
                            _fallbackSocialIcon(
                              label,
                            ),
                            size: 20,
                            color: AppColors.text,
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    Flexible(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 9.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  IconData _fallbackSocialIcon(
    String provider,
  ) {
    switch (provider) {
      case 'GitHub':
        return Icons.code_rounded;

      case 'LinkedIn':
        return Icons.work_outline_rounded;

      default:
        return Icons.account_circle_outlined;
    }
  }

  // ============================================================
  // NEW ACCOUNT
  // ============================================================

  Widget _newAccount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'New here?',
          style: TextStyle(
            color: AppColors.secondary,
            fontSize: 11,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SignupScreen(),
              ),
            );
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.hue,
          ),
          child: const Row(
            children: [
              Text(
                'Create an account',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_rounded,
                size: 15,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INPUT
  // ============================================================

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: AppColors.secondary,
        fontSize: 10.5,
      ),
      prefixIcon: Icon(
        icon,
        size: 18,
        color: AppColors.secondary,
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          13,
        ),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          13,
        ),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          13,
        ),
        borderSide: const BorderSide(
          color: AppColors.antiqueBrass,
          width: 1.5,
        ),
      ),
    );
  }

  // ============================================================
  // BUTTON STYLE
  // ============================================================

  ButtonStyle _primaryButtonStyle() {
    return ButtonStyle(
      minimumSize: WidgetStateProperty.all(
        const Size(0, 51),
      ),
      elevation: WidgetStateProperty.all(
        0,
      ),
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(
            WidgetState.disabled,
          )) {
            return AppColors.tone.withOpacity(.45);
          }

          if (states.contains(
            WidgetState.pressed,
          )) {
            return AppColors.pressed;
          }

          if (states.contains(
            WidgetState.hovered,
          )) {
            return AppColors.hover;
          }

          return AppColors.hue;
        },
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            13,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _errorBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.dustyCoral.withOpacity(.07),
        borderRadius: BorderRadius.circular(
          11,
        ),
        border: Border.all(
          color: AppColors.dustyCoral.withOpacity(.20),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.dustyCoral,
            size: 16,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              error!,
              style: const TextStyle(
                color: AppColors.dustyCoral,
                fontSize: 9.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _orDivider() {
    return const Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.border,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 10,
          ),
          child: Text(
            'OR CONTINUE WITH',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 7,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.border,
          ),
        ),
      ],
    );
  }
}
