// lib/views/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_router.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = Provider.of<AuthController>(context, listen: false);
    final ok = await auth.login(
        email: _emailCtrl.text.trim(), password: _passCtrl.text);
    if (ok && mounted) context.go(AppRouter.home);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          // Glow violet haut-gauche
          Positioned(
            top: -160,
            left: -120,
            child: Container(
              width: 420,
              height: 420,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  Color(0x337B6EF6),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          // Glow bleu bas-droite
          Positioned(
            bottom: -180,
            right: -100,
            child: Container(
              width: 380,
              height: 380,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  Color(0x224B6BF5),
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
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                  child: FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),

                          // Logo Tako
                          Row(children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF7B6EF6), Color(0xFFB06CF5)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.checklist_rounded,
                                  color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 10),
                            const Text('Tako',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.text,
                                    letterSpacing: -0.3)),
                          ]),

                          const SizedBox(height: 52),

                          // Titre
                          const Text(
                            'Content de vous\nrevoir 👋',
                            style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.text,
                                letterSpacing: -1,
                                height: 1.1),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Connectez-vous pour reprendre\nlà où vous en étiez.',
                            style: TextStyle(
                                fontSize: 15,
                                color: AppTheme.text2,
                                fontWeight: FontWeight.w500,
                                height: 1.4),
                          ),

                          const SizedBox(height: 40),

                          // Formulaire
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppTheme.card,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppTheme.border, width: 1),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Email',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.text)),
                                  const SizedBox(height: 8),
                                  _TakoTextField(
                                    controller: _emailCtrl,
                                    hintText: 'vous@entreprise.com',
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (v) {
                                      if (v == null || v.isEmpty)
                                        return 'Email requis';
                                      if (!v.contains('@')) return 'Email invalide';
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 20),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Mot de passe',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.text)),
                                      
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  _TakoTextField(
                                    controller: _passCtrl,
                                    hintText: '••••••••',
                                    obscureText: _obscure,
                                    suffixIcon: GestureDetector(
                                      onTap: () => setState(() => _obscure = !_obscure),
                                      child: Icon(
                                        _obscure
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: AppTheme.text3,
                                        size: 18,
                                      ),
                                    ),
                                    validator: (v) => (v == null || v.length < 6)
                                        ? 'Minimum 6 caractères'
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
                                color: AppTheme.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppTheme.red.withOpacity(0.3), width: 1),
                              ),
                              child: Row(children: [
                                const Icon(Icons.error_outline_rounded,
                                    color: AppTheme.red, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(auth.errorMessage!,
                                      style: TextStyle(
                                          color: AppTheme.red,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500)),
                                ),
                              ]),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Bouton Se connecter
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: auth.isLoading
                                ? Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF7B6EF6), Color(0xFFB06CF5)],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2),
                                    ),
                                  )
                                : DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF7B6EF6), Color(0xFFB06CF5)],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(50),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF7B6EF6).withOpacity(0.45),
                                          blurRadius: 24,
                                          offset: const Offset(0, 8),
                                        )
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: const StadiumBorder(),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text('Se connecter',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white)),
                                          SizedBox(width: 8),
                                          Text('→',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white)),
                                        ],
                                      ),
                                    ),
                              ),
                          ),

                          const SizedBox(height: 28),

                          // Divider OU
                          Row(children: [
                            Expanded(child: Divider(color: AppTheme.border)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text('OU',
                                  style: TextStyle(
                                      color: AppTheme.text3,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700)),
                            ),
                            Expanded(child: Divider(color: AppTheme.border)),
                          ]),

                          const SizedBox(height: 28),

                          // Lien inscription
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Pas encore de compte ? ",
                                  style: TextStyle(
                                      color: AppTheme.text2,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                              GestureDetector(
                                onTap: () => context.go(AppRouter.register),
                                child: const Text("S'inscrire",
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
          ),
        ],
      ),
    );
  }
}

// ── Champ de saisie Tako ───────────────────────────────────────────────────

class _TakoTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _TakoTextField({
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(
          color: AppTheme.text, fontSize: 14, fontWeight: FontWeight.w500),
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppTheme.text3, fontSize: 14, fontWeight: FontWeight.w400),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppTheme.bg2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF7B6EF6), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFF4B4B), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFF4B4B), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}