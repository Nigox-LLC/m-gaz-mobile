import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:m_gaz/core/models/task/tasks_model.dart';
import 'package:m_gaz/core/utils/colors.dart';
import 'package:m_gaz/ui/home/tasks/widgets/task_action_modal.dart';
import 'package:m_gaz/ui/home/tasks/widgets/task_display_status.dart';
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
                  if (state.status == TaskStatus.loading) {
                    return _buildShimmerLoading();
                  }
                  if (state.status == TaskStatus.fail) {
                    return _buildErrorState(
                      state.errorMessage ?? Words.unknown.tr(),
                    );
                  }

                  if (state.status == TaskStatus.success) {
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
                          final displayStatus = TaskDisplayStatus.fromTask(
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
    TaskDisplayStatus displayStatus,
  ) {
    final mode = displayStatus == TaskDisplayStatus.pending
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
        ],
      ),
    );
  }
}

class _TaskSearchAndFilterBar extends StatelessWidget {
  const _TaskSearchAndFilterBar();

  @override
  Widget build(BuildContext context) {
    // TODO: Search va filter ishlashini TaskBloc/API bilan keyin ulash.
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            padding: const EdgeInsets.only(left: 12, right: 8),
            decoration: BoxDecoration(
              color: AppColors.cF9F9F9,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8E8E8)),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, size: 24, color: Color(0xFFBBBEC5)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    Words.search.tr().replaceAll('...', ''),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      height: 20 / 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFBBBBBB),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.cF9F9F9,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8E8E8)),
          ),
          child: const Icon(
            Icons.filter_alt_outlined,
            size: 20,
            color: Color(0xFFBBBBBB),
          ),
        ),
      ],
    );
  }
}
