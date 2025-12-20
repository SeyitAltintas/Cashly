import 'package:flutter/material.dart';

/// Harcamalar sayfası için AppBar widget'ı.
/// Arama modu, çöp kutusu, sesli giriş ve arama butonlarını içerir.
class ExpensesAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool aramaModu;
  final TextEditingController aramaController;
  final bool buAyMi;
  final VoidCallback onAramaModuDegistir;
  final VoidCallback onFiltrele;
  final VoidCallback onBuganeGit;
  final VoidCallback onCopKutusuAc;
  final VoidCallback onSesliGirisAc;

  const ExpensesAppBar({
    super.key,
    required this.aramaModu,
    required this.aramaController,
    required this.buAyMi,
    required this.onAramaModuDegistir,
    required this.onFiltrele,
    required this.onBuganeGit,
    required this.onCopKutusuAc,
    required this.onSesliGirisAc,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: aramaModu
          ? TextField(
              controller: aramaController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Harcama ara...",
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.54),
                ),
              ),
              onChanged: (val) => onFiltrele(),
            )
          : const Text("Harcamalarım"),
      centerTitle: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        if (!aramaModu && !buAyMi)
          TextButton(
            onPressed: onBuganeGit,
            child: Text(
              "Bugüne git",
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ),
        if (!aramaModu) ...[
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            tooltip: "Çöp Kutusu",
            onPressed: onCopKutusuAc,
          ),
          IconButton(
            icon: const Icon(Icons.mic, color: Colors.white),
            tooltip: "Sesli Giriş",
            onPressed: onSesliGirisAc,
          ),
        ],
        IconButton(
          icon: Icon(
            aramaModu ? Icons.close : Icons.search,
            color: Colors.white,
          ),
          onPressed: onAramaModuDegistir,
        ),
      ],
    );
  }
}

/// Gelirler sayfası için AppBar widget'ı.
/// Arama modu ve çöp kutusu butonlarını içerir.
class IncomesAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool aramaModu;
  final TextEditingController aramaController;
  final VoidCallback onAramaModuDegistir;
  final VoidCallback onAramaMetniDegisti;
  final VoidCallback onCopKutusuAc;

  const IncomesAppBar({
    super.key,
    required this.aramaModu,
    required this.aramaController,
    required this.onAramaModuDegistir,
    required this.onAramaMetniDegisti,
    required this.onCopKutusuAc,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: aramaModu
          ? TextField(
              controller: aramaController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Gelir ara...",
                hintStyle: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
              ),
              onChanged: (value) => onAramaMetniDegisti(),
            )
          : const Text("Gelirlerim"),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.white),
          tooltip: "Çöp Kutusu",
          onPressed: onCopKutusuAc,
        ),
        IconButton(
          icon: Icon(
            aramaModu ? Icons.close : Icons.search,
            color: Colors.white,
          ),
          onPressed: onAramaModuDegistir,
        ),
      ],
    );
  }
}

/// Tüm İşlemler sayfası için AppBar widget'ı.
class ToolsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ToolsAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: const Text("Tüm İşlemler"),
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }
}

/// Dashboard (Ana Sayfa) için AppBar widget'ı.
class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Image.asset(
        'assets/image/seffaflogo.png',
        height: 60,
        fit: BoxFit.contain,
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }
}

/// Profil sayfası için AppBar widget'ı.
class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ProfileAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: const Text("Profil"),
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }
}
