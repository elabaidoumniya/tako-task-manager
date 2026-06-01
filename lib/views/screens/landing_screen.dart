// lib/views/screens/landing_screen.dart

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_router.dart';
import 'login_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});
  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(
            begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w > 700;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          Positioned(
            top: -200,
            left: w / 2 - 200,
            child: _Glow(size: 500, color: AppTheme.primary, opacity: 0.15),
          ),
          Positioned(
            top: 300,
            right: -100,
            child: _Glow(size: 300, color: AppTheme.primaryLight, opacity: 0.08),
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: _NavBar(
              onLogin: () {
                // Navigation simple qui fonctionne à coup sûr
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ),
          SingleChildScrollView(
            controller: _scroll,
            child: Column(
              children: [
                const SizedBox(height: 80),
                FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: _HeroSection(isWide: isWide),
                  ),
                ),
                const SizedBox(height: 80),
                _FeaturesSection(isWide: isWide),
                const SizedBox(height: 80),
                _WorkflowSection(),
                const SizedBox(height: 80),
                _CtaSection(),
                const SizedBox(height: 40),
                _Footer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  final VoidCallback onLogin;
  const _NavBar({required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.bg.withOpacity(0.85),
        border: const Border(bottom: BorderSide(color: AppTheme.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.checklist_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          const Text('Tako',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.text, letterSpacing: -0.5)),
          const Spacer(),
          // Bouton Se connecter
          ElevatedButton(
            onPressed: onLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            ),
            child: const Text('Se connecter',
                style: TextStyle(color: AppTheme.text2, fontSize: 14)),
          ),
          const SizedBox(width: 8),
          // Bouton Essayer gratuitement
          ElevatedButton(
            onPressed: onLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            ),
            child: const Text('Essayer gratuitement',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final bool isWide;
  const _HeroSection({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('✦ ', style: TextStyle(color: AppTheme.primaryLight)),
                    Text('Nouveau · ',
                        style: TextStyle(color: AppTheme.primaryLight, fontWeight: FontWeight.w700, fontSize: 13)),
                    Text('Suggestions intelligentes de priorité',
                        style: TextStyle(color: AppTheme.text2, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(fontSize: 52, fontWeight: FontWeight.w900, height: 1.1, letterSpacing: -2, color: AppTheme.text),
                  children: [
                    TextSpan(text: "L'espace de "),
                    TextSpan(text: 'travail', style: TextStyle(color: AppTheme.primaryLight)),
                    TextSpan(text: '\nqui termine vos tâches.'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Tâches, priorités, calendrier et stats — réunis dans une interface claire, rapide, pensée pour les équipes qui livrent.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, color: AppTheme.text2, height: 1.6),
              ),
              const SizedBox(height: 40),
              Wrap(
                spacing: 14,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    ),
                    child: const Text('Commencer — c\'est gratuit  →',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Features ───────────────────────────────────────────────────────────────────

class _FeaturesSection extends StatelessWidget {
  final bool isWide;
  const _FeaturesSection({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
      decoration: const BoxDecoration(color: AppTheme.bg2),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('TOUT EN UN SEUL ENDROIT',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 2, color: AppTheme.primaryLight)),
              const SizedBox(height: 12),
              const Text(
                'Une boîte à outils complète\npour faire avancer vos projets.',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppTheme.text, height: 1.2, letterSpacing: -1),
              ),
              const SizedBox(height: 48),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  _TasksCard(),
                  _PriorityCard(),
                  _NotifCard(),
                  _CatCard(),
                  _StatsCard(),
                  _CalCard(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final Widget child;
  final double width;
  const _FeatureCard({required this.child, this.width = 280});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final cardW = w < 700 ? w - 64 : width;
    return Container(
      width: cardW,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: child,
    );
  }
}

class _CardHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool showAdd;
  const _CardHeader({required this.icon, required this.label, this.showAdd = false});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppTheme.primaryLight, size: 18),
      ),
      const SizedBox(width: 10),
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.text2)),
      if (showAdd) ...[
        const Spacer(),
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(gradient: AppTheme.primaryGradient, shape: BoxShape.circle),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 16),
        ),
      ],
    ]);
  }
}

class _TasksCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tasks = [
      ('Préparer le brief client', true),
      ('Revue du design system', false),
      ('Publier la newsletter', false),
      ('Appel équipe produit', false),
    ];
    return _FeatureCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _CardHeader(icon: Icons.checklist_rounded, label: 'Mes tâches du jour', showAdd: true),
        const SizedBox(height: 16),
        const Text('Ajout & suppression en un clic',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.text)),
        const SizedBox(height: 6),
        const Text('Capturez une idée en deux secondes, glissez-la dans le bon projet.',
            style: TextStyle(fontSize: 13, color: AppTheme.text2, height: 1.5)),
        const SizedBox(height: 16),
        ...tasks.map((t) => _TaskRow(label: t.$1, done: t.$2)),
      ]),
    );
  }
}

class _TaskRow extends StatelessWidget {
  final String label;
  final bool done;
  const _TaskRow({required this.label, required this.done});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.border))),
      child: Row(children: [
        Container(
          width: 20, height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? AppTheme.green : Colors.transparent,
            border: done ? null : Border.all(color: AppTheme.text3, width: 1.5),
          ),
          child: done ? const Icon(Icons.check_rounded, size: 12, color: Colors.white) : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: done ? AppTheme.text3 : AppTheme.text2,
                  decoration: done ? TextDecoration.lineThrough : null)),
        ),
        if (done)
          Container(width: 20, height: 4, decoration: BoxDecoration(color: AppTheme.red, borderRadius: BorderRadius.circular(2))),
      ]),
    );
  }
}

class _PriorityCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      ('Haute', AppTheme.red, 4),
      ('Moyenne', AppTheme.orange, 7),
      ('Basse', AppTheme.green, 12),
    ];
    return _FeatureCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _CardHeader(icon: Icons.flag_rounded, label: 'Priorités'),
        const SizedBox(height: 16),
        const Text('3 niveaux clairs.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.text)),
        const SizedBox(height: 6),
        const Text('Haute, Moyenne, Basse — toujours visible, jamais ambigu.',
            style: TextStyle(fontSize: 13, color: AppTheme.text2, height: 1.5)),
        const SizedBox(height: 16),
        ...items.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: item.$2.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: item.$2.withOpacity(0.15)),
              ),
              child: Row(children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: item.$2, shape: BoxShape.circle)),
                const SizedBox(width: 10),
                Text(item.$1, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: item.$2)),
                const Spacer(),
                Text('${item.$3}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: item.$2)),
              ]),
            )),
      ]),
    );
  }
}

class _NotifCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notifs = [
      ('Brief client — échéance dans 1h', '09:00', AppTheme.red),
      ('Revue design — aujourd\'hui', '14:00', AppTheme.orange),
      ('Newsletter — demain matin', '08:30', AppTheme.primaryLight),
    ];
    return _FeatureCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _CardHeader(icon: Icons.notifications_outlined, label: 'Notifications'),
        const SizedBox(height: 16),
        const Text('Alerté juste à temps,\nsans bruit.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.text, height: 1.3)),
        const SizedBox(height: 6),
        const Text('Rappels intelligents selon vos habitudes.',
            style: TextStyle(fontSize: 13, color: AppTheme.text2, height: 1.5)),
        const SizedBox(height: 16),
        ...notifs.map((n) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.bg2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: n.$3, shape: BoxShape.circle)),
                const SizedBox(width: 10),
                Expanded(child: Text(n.$1, style: const TextStyle(fontSize: 12, color: AppTheme.text2))),
                Text(n.$2, style: const TextStyle(fontSize: 11, color: AppTheme.text3)),
              ]),
            )),
      ]),
    );
  }
}

class _CatCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cats = [
      ('Design', AppTheme.primaryLight),
      ('Dev', const Color(0xFF60A5FA)),
      ('Client', AppTheme.green),
      ('Perso', AppTheme.orange),
      ('Marketing', const Color(0xFFF472B6)),
    ];
    return _FeatureCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _CardHeader(icon: Icons.label_outline_rounded, label: 'Catégories'),
        const SizedBox(height: 16),
        const Text('Tout organisé,\nau premier coup d\'œil.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.text, height: 1.3)),
        const SizedBox(height: 6),
        const Text('Créez vos propres étiquettes colorées.',
            style: TextStyle(fontSize: 13, color: AppTheme.text2, height: 1.5)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: cats.map((c) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: c.$2.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: c.$2.withOpacity(0.3)),
                ),
                child: Text(c.$1, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.$2)),
              )).toList(),
        ),
      ]),
    );
  }
}

class _StatsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bars = [0.45, 0.60, 0.50, 0.75, 0.65, 0.90, 0.70];
    return _FeatureCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.bar_chart_rounded, color: AppTheme.text2, size: 18),
          const SizedBox(width: 8),
          const Text('Cette semaine', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.text2)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.green.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('+24%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.green)),
          ),
        ]),
        const SizedBox(height: 8),
        const Text('87', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: AppTheme.text, letterSpacing: -2)),
        const Text('tâches complétées', style: TextStyle(fontSize: 13, color: AppTheme.text2)),
        const SizedBox(height: 20),
        SizedBox(
          height: 70,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: bars.map((h) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Container(
                  height: 70 * h,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            )).toList(),
          ),
        ),
      ]),
    );
  }
}

class _CalCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final days = List.generate(28, (i) => i + 1);
    final hasTasks = {2, 4, 9, 15, 18, 24};
    return _FeatureCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: const [
          Icon(Icons.calendar_today_outlined, color: AppTheme.text2, size: 16),
          SizedBox(width: 8),
          Text('Calendrier · Juin 2026', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.text2)),
        ]),
        const SizedBox(height: 16),
        Row(
          children: ['L', 'M', 'M', 'J', 'V', 'S', 'D']
              .map((d) => Expanded(
                    child: Text(d, textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.text3)),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 1,
          ),
          itemCount: 28,
          itemBuilder: (ctx, i) {
            final day = days[i];
            final isToday = day == 13;
            final hasTask = hasTasks.contains(day);
            return Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: isToday ? AppTheme.primaryGradient : null,
                    color: isToday ? null : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text('$day',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                            color: isToday ? Colors.white : AppTheme.text2)),
                  ),
                ),
                if (hasTask && !isToday)
                  Positioned(
                    bottom: 2,
                    child: Container(width: 4, height: 4,
                        decoration: const BoxDecoration(color: AppTheme.primaryLight, shape: BoxShape.circle)),
                  ),
              ],
            );
          },
        ),
      ]),
    );
  }
}

class _WorkflowSection extends StatelessWidget {
  final steps = const [
    ('⌨️', 'Étape 1', 'Capturez', 'Notez l\'idée dès qu\'elle arrive — clavier, mobile, ou via raccourci.'),
    ('🚦', 'Étape 2', 'Priorisez', 'Trois niveaux et des étiquettes : zéro confusion sur l\'ordre.'),
    ('🎯', 'Étape 3', 'Exécutez', 'Focus mode, sous-tâches, calendrier intégré. Plus rien ne traîne.'),
  ];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w > 700;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('WORKFLOW',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 2, color: AppTheme.primaryLight)),
              const SizedBox(height: 12),
              const Text('Trois étapes. Zéro friction.',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppTheme.text, letterSpacing: -1)),
              const SizedBox(height: 40),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: steps.map((s) {
                  final cardW = isWide ? 280.0 : w - 64;
                  return Container(
                    width: cardW,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.$1, style: const TextStyle(fontSize: 32)),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(s.$2,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1, color: AppTheme.primaryLight)),
                        ),
                        const SizedBox(height: 10),
                        Text(s.$3, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.text)),
                        const SizedBox(height: 8),
                        Text(s.$4, style: const TextStyle(fontSize: 14, color: AppTheme.text2, height: 1.6)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CtaSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
      decoration: const BoxDecoration(color: AppTheme.bg2),
      child: Column(children: [
        const Text('Reprenez le contrôle\nde votre temps.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppTheme.text, height: 1.15, letterSpacing: -1)),
        const SizedBox(height: 16),
        const Text('Essai 14 jours, sans carte bancaire.',
            style: TextStyle(fontSize: 15, color: AppTheme.text2)),
        const SizedBox(height: 6),
        const Text('Plan gratuit à vie pour un usage personnel.',
            style: TextStyle(fontSize: 13, color: AppTheme.text3)),
        const SizedBox(height: 36),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          ),
          child: const Text('Commencer maintenant',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ]),
    );
  }
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTheme.border))),
      child: Row(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.checklist_rounded, color: Colors.white, size: 14),
        ),
        const SizedBox(width: 8),
        const Text('Tako', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.text)),
        const Spacer(),
        const Text('© 2026', style: TextStyle(fontSize: 13, color: AppTheme.text3)),
      ]),
    );
  }
}

class _Glow extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
  const _Glow({required this.size, required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color.withOpacity(opacity), Colors.transparent]),
      ),
    );
  }
}