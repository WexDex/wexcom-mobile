import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:url_launcher/url_launcher.dart';

import '../../data/db/app_database.dart';
import '../../data/ledger_types.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/balance_display.dart';
import '../../utils/money.dart';
import '../transactions/transaction_editor_sheet.dart';
import 'client_editor_sheet.dart';
import 'client_transactions_list.dart';

Color _tagColor(String hex) {
  final cleaned = hex.replaceAll('#', '');
  if (cleaned.length != 6) return AppTheme.receivableAccent;
  final value = int.tryParse(cleaned, radix: 16);
  if (value == null) return AppTheme.receivableAccent;
  return Color(0xFF000000 | value);
}

class ClientDetailScreen extends ConsumerStatefulWidget {
  const ClientDetailScreen({super.key, required this.clientId});

  final String clientId;

  @override
  ConsumerState<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends ConsumerState<ClientDetailScreen> {
  bool _compactHeader = false;

  void _onTransactionsScrollOffset(double offset) {
    final next = offset > 24;
    if (next == _compactHeader) return;
    setState(() => _compactHeader = next);
  }

  @override
  Widget build(BuildContext context) {
    final clientId = widget.clientId;
    final clientAsync = ref.watch(clientProvider(clientId));
    final txsAsync = ref.watch(clientTransactionsProvider(clientId));
    final currencyAsync = ref.watch(defaultCurrencyProvider);

    return clientAsync.when(
      data: (client) {
        if (client == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Client')),
            body: const Center(child: Text('Client not found')),
          );
        }
        final archived = client.archivedAt != null;
        final code = currencyAsync.valueOrNull ?? 'DZD';
        final clientTagsAsync = ref.watch(clientTagsProvider(client.id));

        return Scaffold(
          appBar: AppBar(
            title: Text(
              client.fullName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Export client summary PDF',
                icon: const Icon(Icons.picture_as_pdf_outlined),
                onPressed: () => _exportClientSummaryPdf(
                  context,
                  client: client,
                  currencyCode: code,
                  txCount: txsAsync.valueOrNull?.length ?? 0,
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  final repo = ref.read(ledgerRepositoryProvider);
                  switch (value) {
                    case 'edit':
                      final clientTags = await ref.read(
                        clientTagsProvider(client.id).future,
                      );
                      final availableTags = await ref.read(
                        clientScopeTagsProvider.future,
                      );
                      await showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: AppTheme.surface,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(AppTheme.radius),
                          ),
                        ),
                        builder: (ctx) => Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.viewInsetsOf(ctx).bottom,
                          ),
                          child: ClientEditorSheet(
                            title: 'Edit client',
                            submitLabel: 'Update',
                            initialName: client.fullName,
                            initialPhone: client.phone,
                            initialNote: client.note,
                            availableTags: availableTags,
                            initialTagIds: clientTags.map((e) => e.id).toList(),
                            onSaved: (fullName, phone, note, tagIds) async {
                              await repo.updateClient(
                                id: client.id,
                                fullName: fullName,
                                phone: phone,
                                note: note,
                              );
                              await repo.setClientTags(client.id, tagIds);
                              if (context.mounted) Navigator.pop(ctx);
                            },
                          ),
                        ),
                      );
                    case 'archive':
                      await repo.setClientArchived(client.id, true);
                      if (context.mounted) context.pop();
                    case 'restore':
                      await repo.setClientArchived(client.id, false);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  if (!archived)
                    const PopupMenuItem(
                      value: 'archive',
                      child: Text('Archive'),
                    ),
                  if (archived)
                    const PopupMenuItem(
                      value: 'restore',
                      child: Text('Restore'),
                    ),
                ],
              ),
            ],
          ),
          body: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.axis == Axis.vertical) {
                _onTransactionsScrollOffset(notification.metrics.pixels);
              }
              return false;
            },
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: 96,
                    top: _compactHeader ? 76 : 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          _compactHeader ? 8 : 16,
                          20,
                          12,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOutCubic,
                          padding: EdgeInsets.all(_compactHeader ? 10 : 12),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusLg,
                            ),
                            border: Border.all(
                              color: balanceColor(
                                client.balanceMinor,
                              ).withValues(alpha: 0.35),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: balanceColor(
                                        client.balanceMinor,
                                      ).withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      balanceSemanticsLine(client.balanceMinor),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            color: balanceColor(
                                              client.balanceMinor,
                                            ),
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          (archived
                                                  ? AppTheme.ledgerCancel
                                                  : AppTheme.ledgerPayment)
                                              .withValues(alpha: 0.16),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      archived ? 'ARCHIVED' : 'ACTIVE',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            color: archived
                                                ? AppTheme.ledgerCancel
                                                : AppTheme.ledgerPayment,
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: _compactHeader ? 6 : 10),
                              Text(
                                MoneyFormat.formatMinor(
                                  client.balanceMinor,
                                  code,
                                ),
                                style:
                                    (_compactHeader
                                            ? Theme.of(
                                                context,
                                              ).textTheme.titleLarge
                                            : Theme.of(
                                                context,
                                              ).textTheme.headlineMedium)
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: balanceColor(
                                            client.balanceMinor,
                                          ),
                                          fontFeatures: const [
                                            FontFeature.tabularFigures(),
                                          ],
                                        ),
                              ),
                              SizedBox(height: _compactHeader ? 6 : 8),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: FilledButton.icon(
                                  onPressed:
                                      archived || client.balanceMinor <= 0
                                      ? null
                                      : () => _confirmSettleAllDebt(
                                          context,
                                          ref,
                                          clientId: client.id,
                                          currencyCode: code,
                                          beforeBalanceMinor:
                                              client.balanceMinor,
                                        ),
                                  icon: const Icon(Icons.done_all_rounded),
                                  label: const Text('Settle all debt'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppTheme.ledgerPayment,
                                    foregroundColor: Colors.black87,
                                  ),
                                ),
                              ),
                              if (!_compactHeader) ...[
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_outlined,
                                      size: 18,
                                      color: AppTheme.mutedFg,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Added ${MoneyFormat.formatDate(client.createdAt)}',
                                      style: TextStyle(color: AppTheme.mutedFg),
                                    ),
                                  ],
                                ),
                                if (client.phone != null &&
                                    client.phone!.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () => _callClient(
                                      context,
                                      phoneNumber: client.phone!,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 2,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.phone_outlined,
                                            size: 18,
                                            color: AppTheme.ledgerPayment,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              client.phone!,
                                              style: TextStyle(
                                                color: AppTheme.ledgerPayment,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.open_in_new,
                                            size: 16,
                                            color: AppTheme.mutedFg,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                                if (client.note != null &&
                                    client.note!.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    client.note!,
                                    style: TextStyle(
                                      color: AppTheme.mutedFg,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ],
                              ...clientTagsAsync.when(
                                data: (tags) {
                                  if (tags.isEmpty) return const <Widget>[];
                                  return [
                                    SizedBox(height: _compactHeader ? 6 : 10),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: tags
                                          .map(
                                            (t) => Chip(
                                              label: Text(t.name),
                                              avatar: CircleAvatar(
                                                radius: 4,
                                                backgroundColor: _tagColor(
                                                  t.colorHex,
                                                ),
                                              ),
                                              backgroundColor: _tagColor(
                                                t.colorHex,
                                              ).withValues(alpha: 0.18),
                                              side: BorderSide(
                                                color: _tagColor(
                                                  t.colorHex,
                                                ).withValues(alpha: 0.75),
                                              ),
                                              shape: const StadiumBorder(),
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ];
                                },
                                loading: () => const <Widget>[],
                                error: (_, __) => const <Widget>[],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                        child: Row(
                          children: [
                            Text(
                              'Transactions',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: AppTheme.mutedFg,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(width: 8),
                            txsAsync.when(
                              data: (txs) {
                                final lastActivity = txs.isNotEmpty
                                    ? ' • Last: ${MoneyFormat.formatDate(txs.first.effectiveAt ?? txs.first.createdAt)}'
                                    : '';
                                return Text(
                                  '(${txs.length})$lastActivity',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(color: AppTheme.mutedFg),
                                );
                              },
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                      if (!archived)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                          child: ref
                              .watch(quickAddSuggestionsProvider)
                              .when(
                                data: (items) {
                                  if (items.isEmpty) return const SizedBox.shrink();
                                  return SizedBox(
                                    height: _compactHeader ? 36 : 42,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: items.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(width: 8),
                                      itemBuilder: (_, i) {
                                        final it = items[i];
                                        final label =
                                            '${it.type == LedgerTxType.debt ? 'Add debt' : 'Add payment'} ${it.amountMinor}';
                                        return ActionChip(
                                          visualDensity: _compactHeader
                                              ? VisualDensity.compact
                                              : VisualDensity.standard,
                                          label: Text(label),
                                          onPressed: () async {
                                            final txTags = await ref.read(
                                              transactionScopeTagsProvider.future,
                                            );
                                            if (!context.mounted) return;
                                            await showModalBottomSheet<void>(
                                              context: context,
                                              isScrollControlled: true,
                                              backgroundColor: AppTheme.surface,
                                              shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.vertical(
                                                  top: Radius.circular(
                                                    AppTheme.radius,
                                                  ),
                                                ),
                                              ),
                                              builder: (ctx) => Padding(
                                                padding: EdgeInsets.only(
                                                  bottom:
                                                      MediaQuery.viewInsetsOf(ctx)
                                                          .bottom,
                                                ),
                                                child: TransactionEditorSheet(
                                                  title: 'New transaction',
                                                  currencyCode: code,
                                                  initialAmountMinor: it.amountMinor,
                                                  initialType: it.type,
                                                  currentBalanceMinor:
                                                      client.balanceMinor,
                                                  availableTags: txTags,
                                                  onSubmit:
                                                      (
                                                        amountMinor,
                                                        type,
                                                        note,
                                                        tagIds,
                                                        effectiveAt,
                                                      ) async {
                                                        await ref
                                                            .read(
                                                              ledgerRepositoryProvider,
                                                            )
                                                            .insertTransaction(
                                                              clientId: client.id,
                                                              amountMinor:
                                                                  amountMinor,
                                                              type: type,
                                                              currencyCode: code,
                                                              note: note,
                                                              tagIds: tagIds,
                                                              effectiveAt:
                                                                  effectiveAt,
                                                            );
                                                        if (context.mounted) {
                                                          Navigator.pop(ctx);
                                                        }
                                                      },
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  );
                                },
                                loading: () => const SizedBox.shrink(),
                                error: (_, __) => const SizedBox.shrink(),
                              ),
                        ),
                      txsAsync.when(
                        data: (txs) {
                          return ClientTransactionsList(
                            transactions: txs,
                            currencyCode: code,
                            onEditActive: (t) => _openEditTx(context, ref, t),
                            onCancelActive: (id) =>
                                _confirmCancel(context, ref, id),
                            embeddedInParentScroll: true,
                            compactControls: _compactHeader,
                          );
                        },
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 48),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (e, _) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 48),
                          child: Center(child: Text('Error: $e')),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_compactHeader)
                  Positioned(
                    left: 16,
                    right: 16,
                    top: 8,
                    child: _PinnedCompactSummaryBar(
                      client: client,
                      currencyCode: code,
                      archived: archived,
                    ),
                  ),
              ],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: archived ? null : AppTheme.ledgerPayment,
            foregroundColor: archived ? null : Colors.black87,
            onPressed: archived
                ? null
                : () async {
                    final txTags = await ref.read(
                      transactionScopeTagsProvider.future,
                    );
                    await showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: AppTheme.surface,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(AppTheme.radius),
                        ),
                      ),
                      builder: (ctx) => Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.viewInsetsOf(ctx).bottom,
                        ),
                        child: TransactionEditorSheet(
                          title: 'New transaction',
                          currencyCode: code,
                          currentBalanceMinor: client.balanceMinor,
                          availableTags: txTags,
                          onSubmit:
                              (
                                amountMinor,
                                type,
                                note,
                                tagIds,
                                effectiveAt,
                              ) async {
                                await ref
                                    .read(ledgerRepositoryProvider)
                                    .insertTransaction(
                                      clientId: client.id,
                                      amountMinor: amountMinor,
                                      type: type,
                                      currencyCode: code,
                                      note: note,
                                      tagIds: tagIds,
                                      effectiveAt: effectiveAt,
                                    );
                                if (context.mounted) Navigator.pop(ctx);
                              },
                        ),
                      ),
                    );
                  },
            icon: const Icon(Icons.add),
            label: const Text('Transaction'),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Client')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Client')),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _openEditTx(
    BuildContext context,
    WidgetRef ref,
    LedgerTransaction t,
  ) async {
    final txTags = await ref.read(transactionScopeTagsProvider.future);
    final selectedTags = await ref.read(transactionTagsProvider(t.id).future);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radius),
        ),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: TransactionEditorSheet(
          title: 'Edit transaction',
          currencyCode: t.currencyCode,
          initialAmountMinor: t.amountMinor,
          initialType: LedgerTxType.fromInt(t.txType),
          initialNote: t.note,
          currentBalanceMinor: t.postedBalanceBeforeMinor,
          initialEffectiveAt: t.effectiveAt ?? t.createdAt,
          availableTags: txTags,
          initialTagIds: selectedTags.map((e) => e.id).toList(),
          onSubmit: (amountMinor, type, note, tagIds, effectiveAt) async {
            await ref
                .read(ledgerRepositoryProvider)
                .updateTransaction(
                  id: t.id,
                  amountMinor: amountMinor,
                  type: type,
                  note: note,
                  tagIds: tagIds,
                  effectiveAt: effectiveAt,
                );
            if (context.mounted) Navigator.pop(ctx);
          },
        ),
      ),
    );
  }

  Future<void> _confirmCancel(
    BuildContext context,
    WidgetRef ref,
    String txId,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel transaction?'),
        content: const Text(
          'It will stay in the list as cancelled and no longer affect balance.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.ledgerCancel,
              foregroundColor: Colors.black87,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancel transaction'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await ref.read(ledgerRepositoryProvider).cancelTransaction(txId);
    }
  }

  Future<void> _confirmSettleAllDebt(
    BuildContext context,
    WidgetRef ref, {
    required String clientId,
    required String currencyCode,
    required int beforeBalanceMinor,
  }) async {
    final afterBalanceMinor = 0;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Settle all debt?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This will create one payment transaction.'),
            const SizedBox(height: 10),
            Text(
              'Before: ${MoneyFormat.formatMinor(beforeBalanceMinor, currencyCode)} (${balanceSemanticsLine(beforeBalanceMinor)})',
            ),
            const SizedBox(height: 6),
            Text(
              'After: ${MoneyFormat.formatMinor(afterBalanceMinor, currencyCode)} (${balanceSemanticsLine(afterBalanceMinor)})',
              style: TextStyle(
                color: AppTheme.ledgerPayment.withValues(alpha: 0.95),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.ledgerPayment,
              foregroundColor: Colors.black87,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Settle all'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await ref.read(ledgerRepositoryProvider).settleFullDebt(clientId);
    }
  }

  Future<void> _callClient(
    BuildContext context, {
    required String phoneNumber,
  }) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    await Clipboard.setData(ClipboardData(text: phoneNumber));
    if (!context.mounted) return;
    final message = launched
        ? 'Opening phone app. Number copied: $phoneNumber'
        : 'Could not open phone app. Number copied: $phoneNumber';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _exportClientSummaryPdf(
    BuildContext context, {
    required Client client,
    required String currencyCode,
    required int txCount,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final balanceText = MoneyFormat.formatMinor(
      client.balanceMinor,
      currencyCode,
    );
    final createdText = MoneyFormat.formatDate(client.createdAt);
    final lastText = MoneyFormat.formatDate(
      client.lastInteractionAt ?? client.createdAt,
    );
    final statusText = client.archivedAt == null ? 'Active' : 'Archived';
    pdf.addPage(
      pw.Page(
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Client Summary',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 12),
            pw.Text('Generated: ${MoneyFormat.formatDate(now)}'),
            pw.SizedBox(height: 14),
            pw.Text('Name: ${client.fullName}'),
            pw.Text('Status: $statusText'),
            pw.Text('Phone: ${client.phone ?? '-'}'),
            pw.SizedBox(height: 8),
            pw.Text('Current balance: $balanceText'),
            pw.Text(
              'Balance meaning: ${balanceSemanticsLine(client.balanceMinor)}',
            ),
            pw.SizedBox(height: 8),
            pw.Text('Created date: $createdText'),
            pw.Text('Last activity date: $lastText'),
            pw.Text('Transactions count: $txCount'),
          ],
        ),
      ),
    );
    final bytes = await pdf.save();
    if (!context.mounted) return;
    final location = await getSaveLocation(
      suggestedName:
          'client_${client.fullName.replaceAll(' ', '_')}_summary_${DateTime.now().millisecondsSinceEpoch}.pdf',
      acceptedTypeGroups: const [
        XTypeGroup(label: 'pdf', extensions: ['pdf']),
      ],
    );
    if (location == null) return;
    final file = XFile.fromData(
      Uint8List.fromList(bytes),
      mimeType: 'application/pdf',
      name: 'client_summary.pdf',
    );
    await file.saveTo(location.path);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Client summary PDF exported')),
    );
  }
}

class _PinnedCompactSummaryBar extends StatelessWidget {
  const _PinnedCompactSummaryBar({
    required this.client,
    required this.currencyCode,
    required this.archived,
  });

  final Client client;
  final String currencyCode;
  final bool archived;

  @override
  Widget build(BuildContext context) {
    final color = balanceColor(client.balanceMinor);
    return Material(
      elevation: 3,
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                balanceSemanticsLine(client.balanceMinor),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: balanceColor(client.balanceMinor),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                MoneyFormat.formatMinor(client.balanceMinor, currencyCode),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
