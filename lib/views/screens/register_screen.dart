// lib/views/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_router.dart';
import '../../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = Provider.of<AuthController>(context, listen: false);
    final ok = await auth.register(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text);
    if (ok && mounted) context.go(AppRouter.home);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFF080716),
      body: Stack(
        children: [
          // Glow violet haut-droite
          Positioned(
            top: -120,
            right: -100,
            child: Container(
              width: 360,
              height: 360,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  Color(0x28B06CF5),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          // Glow bleu bas-gauche
          Positioned(
            bottom: -180,
            left: -80,
            child: Container(
              width: 400,
              height: 400,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  Color(0x207B6EF6),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 20),
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Bouton retour
                        Align(
                          alignment: Alignment.topLeft,
                          child: GestureDetector(
                            onTap: () => context.go(AppRouter.login),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xFF111027),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: const Color(0xFF1E1C38), width: 1),
                              ),
                              child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 15,
                                  color: Colors.white),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        const Text(
                          'Créer un compte ✨',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Rejoignez Tako aujourd\'hui',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF8A87A8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Card formulaire
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111027),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: const Color(0xFF1E1C38), width: 1),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _FieldLabel('Nom complet'),
                                const SizedBox(height: 8),
                                _TakoTextField(
                                  controller: _nameCtrl,
                                  hintText: 'Votre nom',
                                  textCapitalization:
                                      TextCapitalization.words,
                                  prefixIcon: Icons.person_outline_rounded,
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? 'Nom requis'
                                          : null,
                                ),
                                const SizedBox(height: 16),
                                const _FieldLabel('Email'),
                                const SizedBox(height: 8),
                                _TakoTextField(
                                  controller: _emailCtrl,
                                  hintText: 'vous@exemple.com',
                                  keyboardType: TextInputType.emailAddress,
                                  prefixIcon: Icons.email_outlined,
                                  validator: (v) {
                                    if (v == null || v.isEmpty)
                                      return 'Email requis';
                                    if (!v.contains('@'))
                                      return 'Email invalide';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                const _FieldLabel('Mot de passe'),
                                const SizedBox(height: 8),
                                _TakoTextField(
                                  controller: _passCtrl,
                                  hintText: '••••••••',
                                  obscureText: _obscure,
                                  prefixIcon: Icons.lock_outline_rounded,
                                  suffixIcon: GestureDetector(
                                    onTap: () => setState(
                                        () => _obscure = !_obscure),
                                    child: Icon(
                                      _obscure
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: const Color(0xFF4A4768),
                                      size: 18,
                                    ),
                                  ),
                                  validator: (v) =>
                                      (v == null || v.length < 6)
                                          ? 'Minimum 6 caractères'
                                          : null,
                                ),
                                const SizedBox(height: 16),
                                const _FieldLabel('Confirmer le mot de passe'),
                                const SizedBox(height: 8),
                                _TakoTextField(
                                  controller: _confirmCtrl,
                                  hintText: '••••••••',
                                  obscureText: _obscure,
                                  prefixIcon: Icons.lock_outline_rounded,
                                  validator: (v) =>
                                      v != _passCtrl.text
                                          ? 'Les mots de passe ne correspondent pas'
                                          : null,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Erreur
                        if (auth.errorMessage != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF4B4B).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: const Color(0xFFFF4B4B)
                                      .withOpacity(0.3),
                                  width: 1),
                            ),
                            child: Row(children: [
                              const Icon(Icons.error_outline_rounded,
                                  color: Color(0xFFFF4B4B), size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(auth.errorMessage!,
                                    style: const TextStyle(
                                        color: Color(0xFFFF4B4B),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ]),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Bouton créer
                        SizedBox(
                          height: 56,
                          child: auth.isLoading
                              ? Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF7B6EF6),
                                        Color(0xFFB06CF5)
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2.5),
                                  ),
                                )
                              : DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF7B6EF6),
                                        Color(0xFFB06CF5)
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF7B6EF6)
                                            .withOpacity(0.45),
                                        blurRadius: 24,
                                        offset: const Offset(0, 8),
                                      )
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _register,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18)),
                                    ),
                                    child: const Text('Créer mon compte',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white)),
                                  ),
                                ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Déjà un compte ? ',
                                style: TextStyle(
                                    color: Color(0xFF8A87A8),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14)),
                            GestureDetector(
                              onTap: () => context.go(AppRouter.login),
                              child: const Text('Se connecter',
                                  style: TextStyle(
                                      color: Color(0xFF9B8FF8),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14)),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets helper ─────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
      );
}

class _TakoTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _TakoTextField({
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style: const TextStyle(
          color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.22),
            fontSize: 14,
            fontWeight: FontWeight.w400),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: const Color(0xFF4A4768), size: 18)
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFF0D0B1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFF7B6EF6), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFFF4B4B), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFFF4B4B), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}