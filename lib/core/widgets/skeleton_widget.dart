import 'package:flutter/material.dart';

/// Shimmer efektli skeleton widget base
/// Yükleme sırasında içerik yerine gösterilir
class SkeletonWidget extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final bool isCircle;

  const SkeletonWidget({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8,
    this.isCircle = false,
  });

  @override
  State<SkeletonWidget> createState() => _SkeletonWidgetState();
}

class _SkeletonWidgetState extends State<SkeletonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(
      begin: -2,
      end: 2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.isCircle ? widget.height : widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.isCircle
                ? null
                : BorderRadius.circular(widget.borderRadius),
            shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
            gradient: LinearGradient(
              begin: Alignment(_animation.value, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Harcama kartı skeleton
class ExpenseCardSkeleton extends StatelessWidget {
  const ExpenseCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // İkon placeholder
          const SkeletonWidget(width: 44, height: 44, borderRadius: 12),
          const SizedBox(width: 12),
          // İsim ve kategori
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonWidget(height: 16, width: 120, borderRadius: 4),
                SizedBox(height: 8),
                SkeletonWidget(height: 12, width: 80, borderRadius: 4),
              ],
            ),
          ),
          // Tutar
          const SkeletonWidget(height: 20, width: 70, borderRadius: 4),
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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Ay seçici
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SkeletonWidget(width: 30, height: 30, borderRadius: 8),
              SkeletonWidget(width: 120, height: 24, borderRadius: 8),
              SkeletonWidget(width: 30, height: 30, borderRadius: 8),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),
          // Toplam harcama satırı
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonWidget(width: 100, height: 14, borderRadius: 4),
                  SizedBox(height: 8),
                  SkeletonWidget(width: 150, height: 28, borderRadius: 4),
                ],
              ),
              const SkeletonWidget(width: 52, height: 52, borderRadius: 15),
            ],
          ),
          const SizedBox(height: 20),
          // Bütçe durumu
          const SkeletonWidget(height: 80, borderRadius: 12),
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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Üst satır
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SkeletonWidget(width: 80, height: 24, borderRadius: 12),
              SkeletonWidget(width: 24, height: 24, borderRadius: 6),
            ],
          ),
          // Kart numarası
          const SkeletonWidget(width: 200, height: 14, borderRadius: 4),
          // Alt satır
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonWidget(width: 100, height: 11, borderRadius: 4),
                  SizedBox(height: 4),
                  SkeletonWidget(width: 60, height: 10, borderRadius: 4),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  SkeletonWidget(width: 40, height: 10, borderRadius: 4),
                  SizedBox(height: 4),
                  SkeletonWidget(width: 80, height: 18, borderRadius: 4),
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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // İkon placeholder
          const SkeletonWidget(width: 44, height: 44, borderRadius: 12),
          const SizedBox(width: 12),
          // İsim ve kategori
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonWidget(height: 15, width: 100, borderRadius: 4),
                SizedBox(height: 8),
                SkeletonWidget(height: 12, width: 60, borderRadius: 4),
              ],
            ),
          ),
          // Tutar
          const SkeletonWidget(height: 16, width: 80, borderRadius: 4),
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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SkeletonWidget(width: 30, height: 30, borderRadius: 8),
              SkeletonWidget(width: 120, height: 24, borderRadius: 8),
              SkeletonWidget(width: 30, height: 30, borderRadius: 8),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonWidget(width: 100, height: 14, borderRadius: 4),
                  SizedBox(height: 8),
                  SkeletonWidget(width: 150, height: 28, borderRadius: 4),
                ],
              ),
              const SkeletonWidget(width: 52, height: 52, borderRadius: 15),
            ],
          ),
          const SizedBox(height: 16),
          const SkeletonWidget(height: 44, borderRadius: 12),
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
    return Column(
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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonWidget(width: 100, height: 14, borderRadius: 4),
                  SizedBox(height: 8),
                  SkeletonWidget(width: 150, height: 28, borderRadius: 4),
                ],
              ),
              const SkeletonWidget(width: 52, height: 52, borderRadius: 15),
            ],
          ),
          const SizedBox(height: 16),
          const SkeletonWidget(height: 44, borderRadius: 12),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const PaymentMethodsSummarySkeleton(),
          const SizedBox(height: 24),
          ...List.generate(3, (index) => const PaymentMethodSkeleton()),
        ],
      ),
    );
  }
}
