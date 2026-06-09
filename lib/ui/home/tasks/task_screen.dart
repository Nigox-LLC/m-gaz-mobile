import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:m_gaz/core/models/task/tasks_model.dart';
import 'package:m_gaz/core/utils/colors.dart';
import 'package:m_gaz/core/enums/task_status_enum.dart';
import 'package:m_gaz/ui/home/tasks/widgets/task_action_modal.dart';
import 'package:m_gaz/ui/home/tasks/widgets/task_filter_bottom_sheet.dart';
import 'package:m_gaz/ui/home/tasks/widgets/task_item.dart';
import 'bloc/task_bloc.dart';
import 'bloc/task_event.dart';
import 'bloc/task_state.dart';
import '../../../core/common/words.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(TaskLoad());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      context.read<TaskBloc>().add(TaskLoadMore());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TaskHeader(),
            Expanded(
              child: BlocBuilder<TaskBloc, TaskState>(
                builder: (context, state) {
                  if (state.status == TaskLoadStatus.loading) {
                    return _buildShimmerLoading();
                  }
                  if (state.status == TaskLoadStatus.fail) {
                    return _buildErrorState(
                      state.errorMessage ?? Words.unknown.tr(),
                    );
                  }

                  if (state.status == TaskLoadStatus.success) {
                    if (state.tasks.isEmpty) {
                      return _buildEmptyState();
                    }

                    return RefreshIndicator(
                      color: AppColors.c181D27,
                      onRefresh: () async {
                        context.read<TaskBloc>().add(TaskLoad());
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.only(top: 18, bottom: 100),
                        itemCount:
                            state.tasks.length + (state.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == state.tasks.length) {
                            return _buildLoadMore();
                          }

                          final task = state.tasks[index];
                          final displayStatus = TaskStatus.fromTask(
                            task,
                          );

                          return TaskItemWidget(
                            task: task,
                            onTap: () => _showTaskBottomSheet(
                              context,
                              task,
                              displayStatus,
                            ),
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTaskBottomSheet(
    BuildContext context,
    TaskModel task,
    TaskStatus displayStatus,
  ) {
    final mode = displayStatus == TaskStatus.pending
        ? TaskActionModalMode.action
        : TaskActionModalMode.detail;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskActionModal(task: task, mode: mode),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 180,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEEF1F7)),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: AppColors.red.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 24),
            Text(
              Words.errorOccurred.tr(),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.read<TaskBloc>().add(TaskLoad());
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text(Words.retry.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.c181D27,
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 100,
              color: AppColors.black.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              Words.noTasks.tr(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              Words.noTasks.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMore() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      ),
    );
  }
}

class _TaskHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 36,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                Words.tasks.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  fontSize: 17,
                  height: 28 / 17,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1D2E),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const _TaskSearchAndFilterBar(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _TaskSearchAndFilterBar extends StatefulWidget {
  const _TaskSearchAndFilterBar();

  @override
  State<_TaskSearchAndFilterBar> createState() =>
      _TaskSearchAndFilterBarState();
}

class _TaskSearchAndFilterBarState extends State<_TaskSearchAndFilterBar> {
  static const Color _fieldColor = Color(0xFFF9F9F9);
  static const Color _strokeColor = Color(0xFFE8E8E8);
  static const Color _textSubColor = Color(0xFFBBBBBB);
  static const Color _textStrongColor = Color(0xFF202020);
  static const Color _primaryColor = Color(0xFF526ED3);

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = context.read<TaskBloc>().state.searchQuery;
    _searchController.addListener(_onSearchControllerChanged);
  }

  void _onSearchControllerChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchControllerChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = _searchController.text.isNotEmpty;

    return Row(
      children: [
        Expanded(child: _buildSearchTextField(context, hasQuery)),
        const SizedBox(width: 12),
        BlocSelector<TaskBloc, TaskState, String?>(
          selector: (state) => state.filterType,
          builder: (context, filterType) {
            return _buildFilterButton(context, filterType);
          },
        ),
      ],
    );
  }

  Widget _buildSearchTextField(BuildContext context, bool hasQuery) {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          context.read<TaskBloc>().add(TaskSearchChanged(value));
        },
        style: GoogleFonts.manrope(
          color: _textStrongColor,
          fontSize: 13,
          height: 20 / 13,
          fontWeight: FontWeight.w500,
        ),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: Words.search.tr(),
          hintStyle: GoogleFonts.manrope(
            color: _textSubColor,
            fontSize: 13,
            height: 20 / 13,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: _textSubColor,
            size: 24,
          ),
          suffixIcon: hasQuery
              ? IconButton(
                  icon: const Icon(Icons.close, color: _textSubColor),
                  onPressed: () {
                    _searchController.clear();
                    context.read<TaskBloc>().add(const TaskSearchChanged(''));
                  },
                )
              : null,
          filled: true,
          fillColor: _fieldColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _strokeColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _strokeColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _primaryColor, width: 1.2),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context, String? filterType) {
    final active = filterType != null;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: _fieldColor,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _openFilterSheet(context, filterType),
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: _strokeColor),
                borderRadius: BorderRadius.circular(16),
              ),
              child: SvgPicture.asset(
                'assets/icons/filter-funnel.svg',
                width: 16,
                colorFilter: ColorFilter.mode(
                  active ? _primaryColor : _textSubColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
        if (active)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _openFilterSheet(
    BuildContext context,
    String? filterType,
  ) async {
    final result = await showModalBottomSheet<FilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskFilterBottomSheet(initialType: filterType),
    );

    if (result == null || !context.mounted) return;

    if (result.cleared || result.type == null) {
      context.read<TaskBloc>().add(const TaskFilterChanged(clearFilter: true));
    } else {
      context.read<TaskBloc>().add(TaskFilterChanged(type: result.type));
    }
  }
}
