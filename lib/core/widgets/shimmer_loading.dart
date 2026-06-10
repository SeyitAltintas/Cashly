import 'package:flutter/material.dart';

/// Tüm alt widget'larına shimmer (parlama) efekti uygulayan ana sarmalayıcı.
class Shimmer extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  const Shimmer({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.duration = const Duration(milliseconds: 1500),
  });

  /// Dark mode için otomatik renkler
  factory Shimmer.dark({
    Key? key,
    required Widget child,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    return Shimmer(
      key: key,
      baseColor: const Color(0xFF2C2C2E),
      highlightColor: const Color(0xFF3A3A3C),
      duration: duration,
      child: child,
    );
  }

  /// Context üzerinden temaya (dark/light) göre otomatik renk alır.
  factory Shimmer.auto({
    Key? key,
    required BuildContext context,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Shimmer.dark(key: key, child: child)
        : Shimmer(key: key, child: child);
  }

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.1, 0.5, 0.9],
              begin: const Alignment(-1.0, -0.3),
              end: const Alignment(1.0, 0.3),
              transform: _SlidingGradientTransform(_controller.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform(this.slidePercent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      bounds.width * (slidePercent * 2 - 1),
      0.0,
      0.0,
    );
  }
}

/// Shimmer içinde kullanılacak standart kutu şekilli placeholder
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8.0,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Shimmer içinde kullanılacak dairesel placeholder (Avatar vs için)
class ShimmerCircle extends StatelessWidget {
  final double size;
  final EdgeInsetsGeometry? margin;

  const ShimmerCircle({super.key, required this.size, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      margin: margin,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}

BoxDecoration _skeletonContainerDecoration(BuildContext context) {
  return BoxDecoration(
    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
    borderRadius: BorderRadius.circular(16),
  );
}

/// Skeleton container için büyük kartlar dekorasyonu
BoxDecoration _skeletonCardDecoration(BuildContext context) {
  return BoxDecoration(
    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
    borderRadius: BorderRadius.circular(20),
  );
}

/// Harcama kartı skeleton
class ExpenseCardSkeleton extends StatelessWidget {
  const ExpenseCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: _skeletonContainerDecoration(context),
      child: const Row(
        children: [
          // İkon placeholder
          ShimmerBox(width: 44, height: 44, borderRadius: 12),
          SizedBox(width: 12),
          // İsim ve kategori
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(height: 16, width: 120, borderRadius: 4),
                SizedBox(height: 8),
                ShimmerBox(height: 12, width: 80, borderRadius: 4),
              ],
            ),
          ),
          // Tutar
          ShimmerBox(height: 20, width: 70, borderRadius: 4),
        ],
      ),
    );
  }
}

/// Harcama özet kartı skeleton
class ExpenseSummarySkeleton extends StatelessWidget {
  const ExpenseSummarySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: _skeletonCardDecoration(context),
      child: Column(
        children: [
          // Ay seçici
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(width: 30, height: 30, borderRadius: 8),
              ShimmerBox(width: 120, height: 24, borderRadius: 8),
              ShimmerBox(width: 30, height: 30, borderRadius: 8),
            ],
          ),
          SizedBox(height: 16),
          Divider(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.10)),
          SizedBox(height: 16),
          // Toplam harcama satırı
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 100, height: 14, borderRadius: 4),
                  SizedBox(height: 8),
                  ShimmerBox(width: 150, height: 28, borderRadius: 4),
                ],
              ),
              ShimmerBox(width: 52, height: 52, borderRadius: 15),
            ],
          ),
          SizedBox(height: 20),
          // Bütçe durumu
          ShimmerBox(height: 80, borderRadius: 12),
        ],
      ),
    );
  }
}

/// Ödeme yöntemi kartı skeleton
class PaymentMethodSkeleton extends StatelessWidget {
  const PaymentMethodSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: _skeletonCardDecoration(context),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Üst satır
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(width: 80, height: 24, borderRadius: 12),
              ShimmerBox(width: 24, height: 24, borderRadius: 6),
            ],
          ),
          // Kart numarası
          ShimmerBox(width: 200, height: 14, borderRadius: 4),
          // Alt satır
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 100, height: 11, borderRadius: 4),
                  SizedBox(height: 4),
                  ShimmerBox(width: 60, height: 10, borderRadius: 4),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ShimmerBox(width: 40, height: 10, borderRadius: 4),
                  SizedBox(height: 4),
                  ShimmerBox(width: 80, height: 18, borderRadius: 4),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Gelir kartı skeleton
class IncomeCardSkeleton extends StatelessWidget {
  const IncomeCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: _skeletonContainerDecoration(context),
      child: const Row(
        children: [
          // İkon placeholder
          ShimmerBox(width: 44, height: 44, borderRadius: 12),
          SizedBox(width: 12),
          // İsim ve kategori
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(height: 15, width: 100, borderRadius: 4),
                SizedBox(height: 8),
                ShimmerBox(height: 12, width: 60, borderRadius: 4),
              ],
            ),
          ),
          // Tutar
          ShimmerBox(height: 16, width: 80, borderRadius: 4),
        ],
      ),
    );
  }
}

/// Liste skeleton'ları oluşturan yardımcı
class SkeletonList extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;

  const SkeletonList({
    super.key,
    this.itemCount = 5,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}

/// Gelir özet kartı skeleton
class IncomeSummarySkeleton extends StatelessWidget {
  const IncomeSummarySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: _skeletonCardDecoration(context),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(width: 30, height: 30, borderRadius: 8),
              ShimmerBox(width: 120, height: 24, borderRadius: 8),
              ShimmerBox(width: 30, height: 30, borderRadius: 8),
            ],
          ),
          SizedBox(height: 16),
          Divider(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.10)),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 100, height: 14, borderRadius: 4),
                  SizedBox(height: 8),
                  ShimmerBox(width: 150, height: 28, borderRadius: 4),
                ],
              ),
              ShimmerBox(width: 52, height: 52, borderRadius: 15),
            ],
          ),
          SizedBox(height: 16),
          ShimmerBox(height: 44, borderRadius: 12),
        ],
      ),
    );
  }
}

/// Gelir sayfası tam skeleton
class IncomePageSkeleton extends StatelessWidget {
  const IncomePageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.auto(
      context: context,
      child: Column(
        children: [
          const IncomeSummarySkeleton(),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5,
              itemBuilder: (context, index) => const IncomeCardSkeleton(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ödeme yöntemleri özet skeleton
class PaymentMethodsSummarySkeleton extends StatelessWidget {
  const PaymentMethodsSummarySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: _skeletonCardDecoration(context),
      child: const Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 100, height: 14, borderRadius: 4),
                  SizedBox(height: 8),
                  ShimmerBox(width: 150, height: 28, borderRadius: 4),
                ],
              ),
              ShimmerBox(width: 52, height: 52, borderRadius: 15),
            ],
          ),
          SizedBox(height: 16),
          ShimmerBox(height: 44, borderRadius: 12),
        ],
      ),
    );
  }
}

/// Ödeme yöntemleri sayfası tam skeleton
class PaymentMethodsPageSkeleton extends StatelessWidget {
  const PaymentMethodsPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.auto(
      context: context,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const PaymentMethodsSummarySkeleton(),
            const SizedBox(height: 24),
            ...List.generate(3, (index) => const PaymentMethodSkeleton()),
          ],
        ),
      ),
    );
  }
}

/// Harcamalar sayfası tam skeleton
class ExpensesPageSkeleton extends StatelessWidget {
  const ExpensesPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.auto(
      context: context,
      child: Column(
        children: [
          const ExpenseSummarySkeleton(),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              itemCount: 5,
              itemBuilder: (context, index) => const ExpenseCardSkeleton(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Varlık kartı skeleton
class AssetCardSkeleton extends StatelessWidget {
  const AssetCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: _skeletonContainerDecoration(context),
      child: const Row(
        children: [
          // İkon placeholder
          ShimmerBox(width: 44, height: 44, borderRadius: 12),
          SizedBox(width: 12),
          // İsim ve kategori
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(height: 16, width: 120, borderRadius: 4),
                SizedBox(height: 8),
                ShimmerBox(height: 12, width: 80, borderRadius: 4),
              ],
            ),
          ),
          // Değer
          ShimmerBox(height: 20, width: 80, borderRadius: 4),
        ],
      ),
    );
  }
}

/// Varlık özet kartı skeleton
class AssetSummarySkeleton extends StatelessWidget {
  const AssetSummarySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: _skeletonCardDecoration(context),
      child: const Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 100, height: 14, borderRadius: 4),
                  SizedBox(height: 8),
                  ShimmerBox(width: 150, height: 28, borderRadius: 4),
                ],
              ),
              ShimmerBox(width: 52, height: 52, borderRadius: 15),
            ],
          ),
          SizedBox(height: 16),
          ShimmerBox(height: 44, borderRadius: 12),
        ],
      ),
    );
  }
}

/// Varlıklar sayfası tam skeleton
class AssetsPageSkeleton extends StatelessWidget {
  const AssetsPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.auto(
      context: context,
      child: Column(
        children: [
          const AssetSummarySkeleton(),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5,
              itemBuilder: (context, index) => const AssetCardSkeleton(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dashboard sayfasi tam skeleton
class DashboardPageSkeleton extends StatelessWidget {
  const DashboardPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.auto(
      context: context,
      child: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 120, height: 16, borderRadius: 4),
                    SizedBox(height: 8),
                    ShimmerBox(width: 180, height: 28, borderRadius: 6),
                  ],
                ),
                ShimmerBox(width: 50, height: 50, borderRadius: 25),
              ],
            ),
            SizedBox(height: 24),
            // Balance Card
            ShimmerBox(height: 140, borderRadius: 24),
            SizedBox(height: 12),
            // Credit Debt Card
            ShimmerBox(height: 80, borderRadius: 20),
            SizedBox(height: 20),
            // Monthly Summary Card
            ShimmerBox(height: 120, borderRadius: 20),
            SizedBox(height: 20),
            // Budget Status Card
            ShimmerBox(height: 180, borderRadius: 20),
          ],
        ),
      ),
    );
  }
}
