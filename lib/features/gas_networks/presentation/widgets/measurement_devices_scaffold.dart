import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/injection.dart';
import '../../../../core/common/words.dart';
import '../../../../core/enums/status.dart';
import '../../../../core/extension/navigator_extension.dart';
import '../../../../global_widget/app_tools.dart';
import '../../../../ui/home/measurement_devices/grs_measurement_devices/subpage/detail.dart';
import '../../../../ui/home/measurement_devices/technological-measuring/sub_page/teach_measure_detail_screen.dart';
import '../../domain/entities/measurement_device_type.dart';
import '../../domain/entities/measuring_device_document.dart';
import '../bloc/measurement_devices_bloc.dart';
import 'measuring_device_card.dart';

/// Shared scaffold for the three gas-network list pages. Owns the
/// [MeasurementDevicesBloc] (seeded for [type]) and renders the loading / empty
/// / error / list states with pull-to-refresh and infinite scroll.
class MeasurementDevicesScaffold extends StatelessWidget {
  const MeasurementDevicesScaffold({
    super.key,
    required this.title,
    required this.type,
  });

  final String title;
  final MeasurementDeviceType type;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<MeasurementDevicesBloc>()..add(LoadMeasurementDevices(type)),
      child: _MeasurementDevicesView(title: title, type: type),
    );
  }
}

class _MeasurementDevicesView extends StatefulWidget {
  const _MeasurementDevicesView({required this.title, required this.type});

  final String title;
  final MeasurementDeviceType type;

  @override
  State<_MeasurementDevicesView> createState() =>
      _MeasurementDevicesViewState();
}

class _MeasurementDevicesViewState extends State<_MeasurementDevicesView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<MeasurementDevicesBloc>().add(
            const LoadMoreMeasurementDevices(),
          );
    }
  }

  Future<void> _onRefresh() async {
    context.read<MeasurementDevicesBloc>().add(
          LoadMeasurementDevices(widget.type),
        );
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCFCFC),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: AppTools.svg(AppTools.icChervonLeft),
        ),
        title: Text(
          widget.title,
          style: GoogleFonts.manrope(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A1D2E),
          ),
        ),
      ),
      body: BlocBuilder<MeasurementDevicesBloc, MeasurementDevicesState>(
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _buildBody(state),
          );
        },
      ),
    );
  }

  Widget _buildBody(MeasurementDevicesState state) {
    switch (state.status) {
      case Status.initial:
      case Status.loading:
        if (state.items.isEmpty) return const _LoadingList();
        return _buildList(state);
      case Status.error:
        if (state.items.isEmpty) {
          return _ErrorView(
            message: state.errorMessage ?? Words.errorOccurred.tr(),
            onRetry: () => context.read<MeasurementDevicesBloc>().add(
                  LoadMeasurementDevices(widget.type),
                ),
          );
        }
        return _buildList(state);
      case Status.empty:
        return const _EmptyView();
      case Status.success:
      case Status.offline:
        if (state.items.isEmpty) return const _EmptyView();
        return _buildList(state);
    }
  }

  Widget _buildList(MeasurementDevicesState state) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: const Color(0xFF1A1D2E),
      child: ListView.separated(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (index >= state.items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              ),
            );
          }
          final document = state.items[index];
          return MeasuringDeviceCard(
            document: document,
            onTap: () => _openDetail(document),
          );
        },
      ),
    );
  }

  /// Navigates to the existing (legacy) detail screen for the active type.
  /// The detail screens read their data from the globally-provided legacy
  /// BLoCs (`GrsMeasurementDevicesBloc` / `TechMeasuresBloc`). Industrial
  /// collectors reuse the technological detail screen, matching prior behavior.
  void _openDetail(MeasuringDeviceDocument document) {
    switch (widget.type) {
      case MeasurementDeviceType.gts:
        push(GrsDetailScreen(grsId: document.id));
      case MeasurementDeviceType.industrialCollectors:
      case MeasurementDeviceType.technological:
        push(TechMeasureDetailScreen(documentId: document.id));
    }
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, __) => Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFFF0F0F0),
        ),
        child: const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_rounded, size: 88, color: Color(0xFFBBBBBB)),
            const SizedBox(height: 16),
            Text(
              Words.documentsNotFound.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF202020),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              Words.noData.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFBBBBBB),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: Color(0xFFE5484D),
            ),
            const SizedBox(height: 16),
            Text(
              Words.errorOccurred.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF202020),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFBBBBBB),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text(Words.retry.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1D2E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
