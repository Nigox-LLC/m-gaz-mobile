import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:m_gaz/ui/home/working-with-stamps/bloc/working_with_stamps_bloc.dart';
import 'package:m_gaz/ui/home/working-with-stamps/bloc/working_with_stamps_event.dart';
import '../../../../../core/models/working-with-stamps/detail/workign_with_stamp_detail.dart';
import '../../../../../core/models/working-with-stamps/detail/working_with_stamp_real.dart';
import '../../bloc/working_with_stamps_state.dart';
import '../../../../../core/common/words.dart';

class WorkingWithStampsDetailScreen extends StatefulWidget {
  final int id;

  const WorkingWithStampsDetailScreen({super.key, required this.id});

  @override
  State<WorkingWithStampsDetailScreen> createState() =>
      _WorkingWithStampsDetailScreenState();
}

class _WorkingWithStampsDetailScreenState
    extends State<WorkingWithStampsDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<WorkingWithStampBloc>().add(
      WorkingWithStampDocumentFetched(widget.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildModernAppBar(),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        color: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).padding.top + kToolbarHeight,
              ),
            ),
            BlocBuilder<WorkingWithStampBloc, WorkingWithStampState>(
              builder: (context, state) {
                return switch (state.status) {
                  WorkingWithStampStatus.loading => const _LoadingState(),
                  WorkingWithStampStatus.fail => _ErrorState(
                    message: state.errorMessage,
                    onRetry: _loadData,
                  ),
                  WorkingWithStampStatus.success
                      when state.selectedDocument == null =>
                    const _EmptyState(),
                  WorkingWithStampStatus.success => _SuccessState(
                    model: state.selectedDocument!,
                  ),
                  _ => const SliverFillRemaining(),
                };
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loadData,
        icon: const Icon(Icons.refresh_rounded),
        label: Text(Words.update.tr()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  AppBar _buildModernAppBar() {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Text(
        Words.eghuDetails.tr(),
        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primaryContainer,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      elevation: 0,
      scrolledUnderElevation: 0,
    );
  }
}

// ============================================================
// STATE WIDGETS (loading, error, empty, success)
// ============================================================

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            period: const Duration(seconds: 2),
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          childCount: 5,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                Words.errorOccurred.tr(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message ?? Words.unknown.tr(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(Words.retry.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 120,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 24),
              Text(
                Words.noData.tr(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                Words.noData.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessState extends StatelessWidget {
  final WorkingWithStampsDetailModel model;

  const _SuccessState({required this.model});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _MainInfoCard(model: model),
          const SizedBox(height: 24),
          _RealsCard(reals: model.reals),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }
}

// ============================================================
// INFO CARDS - MODERN DESIGN
// ============================================================

class _MainInfoCard extends StatelessWidget {
  final WorkingWithStampsDetailModel model;

  const _MainInfoCard({required this.model});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(Words.mainInfo.tr(), icon: Icons.info_outline),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.category_outlined,
            label: Words.eghuType.tr(),
            value: model.egxuType,
          ),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: Words.startDate.tr(),
            value: model.fromDate.formatDate(),
          ),
          _InfoRow(
            icon: Icons.event_available_outlined,
            label: Words.endDate.tr(),
            value: model.toDate.formatDate(),
          ),
          _InfoRow(
            icon: Icons.factory_outlined,
            label: Words.factoryOne.tr(),
            value: model.oneFactory,
          ),
          _InfoRow(
            icon: Icons.factory_outlined,
            label: Words.factoryTwo.tr(),
            value: model.twoFactory,
          ),
        ],
      ),
    );
  }
}

class _RealsCard extends StatelessWidget {
  final List<WorkingWithStampReals> reals;

  const _RealsCard({required this.reals});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          Words.realDevices.tr(),
          icon: Icons.devices_outlined,
          trailing: _CountChip(count: reals.length),
        ),
        const SizedBox(height: 16),
        if (reals.isEmpty)
          _GlassCard(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  Words.noRealDevices.tr(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          )
        else
          ...reals.asMap().entries.map((entry) {
            final index = entry.key;
            final real = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _RealItem(real: real, index: index),
            );
          }),
      ],
    );
  }
}

class _RealItem extends StatelessWidget {
  final WorkingWithStampReals real;
  final int index;

  const _RealItem({required this.real, required this.index});

  @override
  Widget build(BuildContext context) {
    final isSealRemoved = real.removeSeal ?? false;

    return _GlassCard(
      border: Border(
        left: BorderSide(
          color: isSealRemoved
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.primary,
          width: 4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatusChip(
                label: isSealRemoved ? Words.sealRemoved.tr() : Words.active.tr(),
                isActive: !isSealRemoved,
              ),
              const Spacer(),
              _NumberChip(number: real.realNumber),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.calendar_month_outlined,
            label: Words.installed.tr(),
            value: real.installedDate.formatDate(),
          ),
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: Words.sealLocation.tr(),
            value: real.sealInstalledLocation,
          ),
          if (real.qrCode != null) ...[
            const SizedBox(height: 8),
            _QRCodeTile(qrCode: real.qrCode!),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// REUSABLE MODERN WIDGETS
// ============================================================

class _GlassCard extends StatelessWidget {
  final Widget child;
  final Border? border;

  const _GlassCard({required this.child, this.border});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final IconData icon;
  final Widget? trailing;

  const _SectionTitle(this.text, {required this.icon, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          text,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final bool isInteractive;
  final VoidCallback? onTap;

  const _InfoRow({
    required this.icon,
    required this.label,
    this.value,
    this.isInteractive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isInteractive ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: Text(
                  value ?? "-",
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool isActive;

  const _StatusChip({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: isActive
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : Theme.of(context).colorScheme.onErrorContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final int count;

  const _CountChip({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "$count",
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _NumberChip extends StatelessWidget {
  final String number;

  const _NumberChip({required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        number,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _QRCodeTile extends StatelessWidget {
  final String qrCode;

  const _QRCodeTile({required this.qrCode});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: ListTile(
        leading: Icon(
          Icons.qr_code_rounded,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          qrCode,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          Words.clickToViewQr.tr(),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.copy_rounded),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: qrCode));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("${Words.qrCodeCopied.tr()}: $qrCode"),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
        ),
        onTap: () => _showQRDialog(context, qrCode),
      ),
    );
  }

  void _showQRDialog(BuildContext context, String qrCode) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.qr_code_2_rounded,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "QR Kod",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SelectableText(
                qrCode,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: qrCode));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(Words.qrCodeCopied.tr()),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded),
                label: Text(Words.copy.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// EXTENSIONS
// ============================================================

extension DateFormatting on String? {
  String formatDate() {
    if (this == null || this!.isEmpty) return "-";
    try {
      final date = DateTime.parse(this!);
      return "${date.day.toString().padLeft(2, '0')}"
          ".${date.month.toString().padLeft(2, '0')}"
          ".${date.year}";
    } catch (_) {
      return this!;
    }
  }

  String formatDateTime() {
    if (this == null || this!.isEmpty) return "-";
    try {
      final date = DateTime.parse(this!);
      return "${date.day.toString().padLeft(2, '0')}"
          ".${date.month.toString().padLeft(2, '0')}"
          ".${date.year} "
          "${date.hour.toString().padLeft(2, '0')}:"
          "${date.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return this!;
    }
  }
}
