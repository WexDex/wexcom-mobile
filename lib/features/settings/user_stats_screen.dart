import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/money.dart';

class UserStatsScreen extends ConsumerStatefulWidget {
  const UserStatsScreen({super.key});

  @override
  ConsumerState<UserStatsScreen> createState() => _UserStatsScreenState();
}

class _UserStatsScreenState extends ConsumerState<UserStatsScreen> {
  final _nameController = TextEditingController();
  bool _loadingName = true;
  bool _savingName = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final name = await ref.read(ledgerRepositoryProvider).profileName();
      if (!mounted) return;
      setState(() {
        _nameController.text = name ?? '';
        _loadingName = false;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalsAsync = ref.watch(lifetimeTotalsProvider);
    final currencyAsync = ref.watch(defaultCurrencyProvider);
    final code = currencyAsync.valueOrNull ?? 'DZD';

    return Scaffold(
      appBar: AppBar(
        title: const Text('User stats'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Lifetime transaction totals',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          totalsAsync.when(
            data: (totals) => Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total debts',
                    value: MoneyFormat.formatMinor(totals.totalDebtsMinor, code),
                    color: AppTheme.ledgerDebt,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    title: 'Total payments',
                    value: MoneyFormat.formatMinor(
                      totals.totalPaymentsMinor,
                      code,
                    ),
                    color: AppTheme.ledgerPayment,
                  ),
                ),
              ],
            ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('Unable to load totals: $e'),
          ),
          const SizedBox(height: 28),
          Text(
            'Profile',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Set your display name for this device.',
            style: TextStyle(color: AppTheme.mutedFg, fontSize: 13),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _nameController,
            enabled: !_loadingName && !_savingName,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Your name',
              hintText: 'e.g. Mohamed',
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: _loadingName || _savingName
                ? null
                : () async {
                    setState(() => _savingName = true);
                    try {
                      await ref
                          .read(ledgerRepositoryProvider)
                          .setProfileName(_nameController.text);
                      ref.invalidate(profileNameProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile updated')),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _savingName = false);
                    }
                  },
            child: _savingName
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save name'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: color.withValues(alpha: 0.42)),
        color: color.withValues(alpha: 0.12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: text.labelMedium?.copyWith(color: AppTheme.mutedFg),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: text.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
