import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class QuickHydrationBar extends StatelessWidget {
  final Function(int amountMl) onAddWater;

  const QuickHydrationBar({
    super.key,
    required this.onAddWater,
  });

  void _showCustomAmountDialog(BuildContext context) {
    final controller = TextEditingController(text: '250');
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Text('💧 ', style: TextStyle(fontSize: 22)),
              Text('Log Custom Water', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Amount (ml)',
              suffixText: 'ml',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryAqua,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final amount = int.tryParse(controller.text) ?? 0;
                if (amount > 0) {
                  onAddWater(amount);
                }
                Navigator.pop(ctx);
              },
              child: const Text('Add Water', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'QUICK HYDRATION',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                ),
              ),
              GestureDetector(
                onTap: () => _showCustomAmountDialog(context),
                child: const Text(
                  '+ Custom',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryAqua,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _QuickWaterButton(
                  icon: Icons.local_cafe_outlined,
                  amount: 200,
                  label: 'Glass',
                  onTap: () => onAddWater(200),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickWaterButton(
                  icon: Icons.emoji_food_beverage_outlined,
                  amount: 350,
                  label: 'Mug',
                  onTap: () => onAddWater(350),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickWaterButton(
                  icon: Icons.water_drop_outlined,
                  amount: 500,
                  label: 'Bottle',
                  isPrimary: true,
                  onTap: () => onAddWater(500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickWaterButton extends StatelessWidget {
  final IconData icon;
  final int amount;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _QuickWaterButton({
    required this.icon,
    required this.amount,
    required this.label,
    this.isPrimary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isPrimary
                ? AppTheme.primaryAqua.withValues(alpha: isDark ? 0.18 : 0.15)
                : (isDark ? const Color(0xFF1B263B) : const Color(0xFFEBF1F6)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPrimary
                  ? AppTheme.primaryAqua.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isPrimary
                    ? AppTheme.primaryAqua
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                '+$amount ml',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isPrimary
                      ? AppTheme.primaryAqua
                      : (isDark ? Colors.white : Colors.black),
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
