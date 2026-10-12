import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/delete_confirmation_dialog.dart';
import '../widgets/task_card.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';
import 'profile_screen.dart';
import '../widgets/filter_sort_bottom_sheet.dart';

class TaskListScreen extends StatefulWidget {
  final String? highlightedTaskId;
  const TaskListScreen({super.key, this.highlightedTaskId});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.highlightedTaskId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final taskProvider = Provider.of<TaskProvider>(
            context,
            listen: false,
          );
          taskProvider.resetFilters();
          taskProvider.setFilter(TaskFilter.all);
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSortFilterModal() {
    FilterSortBottomSheet.show(context);
  }

  Widget _buildFilterTab(
    BuildContext context,
    String label,
    int count,
    TaskFilter filter,
    TaskFilter activeFilter,
    VoidCallback onTap,
  ) {
    final isSelected = activeFilter == filter;
    final isDark = AppColors.isDark(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.darkPrimary : AppColors.darkButton)
              : (isDark ? AppColors.darkSurface : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.darkPrimary : AppColors.darkButton)
                : (isDark ? AppColors.darkBorder : Colors.transparent),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (isDark ? AppColors.darkPrimary : AppColors.darkButton)
                        .withValues(alpha: isDark ? 0.35 : 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
              ),
              child: Text(label),
            ),
            const SizedBox(width: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : (isDark ? const Color(0xFF222634) : const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                ),
                child: Text('$count'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = AppColors.isDark(context);
    final todayFormatted = DateFormat('EEEE, MMM d').format(DateTime.now());

    final filteredTasks = taskProvider.filteredTasks;

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: AppBar(
        titleSpacing: 24,
        toolbarHeight: 70,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Tasks',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimaryOf(context),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E212B)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${taskProvider.totalCount} TOTAL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Today • $todayFormatted',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMutedOf(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearchOpen ? Icons.close_rounded : Icons.search_rounded,
              color: AppColors.textSecondaryOf(context),
            ),
            onPressed: () {
              setState(() {
                _isSearchOpen = !_isSearchOpen;
                if (!_isSearchOpen) {
                  _searchController.clear();
                  taskProvider.setSearchQuery('');
                }
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.tune_rounded,
              color: AppColors.textSecondaryOf(context),
            ),
            onPressed: _showSortFilterModal,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 4),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E1B4B)
                        : const Color(0xFFEEF2FF),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: (isDark ? AppColors.darkPrimary : AppColors.primary)
                          .withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      authProvider.userEmail.isNotEmpty
                          ? authProvider.userEmail[0].toUpperCase()
                          : 'U',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? const Color(0xFFA5B4FC)
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [

            // Expandable Search Bar
            if (_isSearchOpen)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: TextStyle(
                    color: AppColors.textPrimaryOf(context),
                    fontSize: 14,
                  ),
                  onChanged: (val) => taskProvider.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Search tasks by title, note, or course...',
                    prefixIcon: Icon(
                      Icons.search,
                      size: 20,
                      color: AppColors.textMutedOf(context),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              size: 18,
                              color: AppColors.textMutedOf(context),
                            ),
                            onPressed: () {
                              _searchController.clear();
                              taskProvider.setSearchQuery('');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),

            // Filter Tabs (All, Pending, Completed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterTab(
                      context,
                      'All',
                      taskProvider.totalCount,
                      TaskFilter.all,
                      taskProvider.currentFilter,
                      () => taskProvider.setFilter(TaskFilter.all),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterTab(
                      context,
                      'Pending',
                      taskProvider.pendingCount,
                      TaskFilter.pending,
                      taskProvider.currentFilter,
                      () => taskProvider.setFilter(TaskFilter.pending),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterTab(
                      context,
                      'Completed',
                      taskProvider.completedCount,
                      TaskFilter.completed,
                      taskProvider.currentFilter,
                      () => taskProvider.setFilter(TaskFilter.completed),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),

            // Tasks List
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: filteredTasks.isEmpty
                    ? Align(
                        key: ValueKey('empty_${taskProvider.currentFilter.name}_${taskProvider.searchQuery}'),
                        alignment: const Alignment(0, -0.35),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Lottie.asset(
                                'assets/jurupoles - Login.json',
                                width: 200,
                                height: 200,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No tasks found',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMutedOf(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        key: ValueKey('list_${taskProvider.currentFilter.name}'),
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        return Dismissible(
                          key: ValueKey(task.id),
                          direction: DismissDirection.horizontal,
                          // Swipe Right Background (Complete)
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Complete',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Swipe Left Background (Delete)
                          secondaryBackground: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              // Swipe Right: Mark as completed
                              final willBeCompleted = !task.isCompleted;
                              Future.microtask(() =>
                                  taskProvider.toggleTaskCompletion(task.id));
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(willBeCompleted
                                      ? 'Task marked as completed!'
                                      : 'Task marked as pending'),
                                  backgroundColor: AppColors.success,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                              return false;
                            } else if (direction ==
                                DismissDirection.endToStart) {
                              // Swipe Left: Delete confirmation
                              final messenger = ScaffoldMessenger.of(context);
                              bool confirmed = false;
                              await DeleteConfirmationDialog.show(
                                context,
                                task,
                                () {
                                  confirmed = true;
                                },
                              );
                              if (confirmed) {
                                taskProvider.deleteTask(task.id);
                                messenger.hideCurrentSnackBar();
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Task deleted'),
                                    backgroundColor: Color(0xFFDC2626),
                                  ),
                                );
                                return true;
                              }
                              return false;
                            }
                            return false;
                          },
                          child: TaskCard(
                            task: task,
                            isHighlighted: widget.highlightedTaskId == task.id,
                            onToggleComplete: () {
                              final willBeCompleted = !task.isCompleted;
                              taskProvider.toggleTaskCompletion(task.id);
                              if (willBeCompleted) {
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Task marked as completed!'),
                                    backgroundColor: AppColors.success,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            onEdit: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditTaskScreen(task: task),
                                ),
                              );
                            },
                            onDelete: () {
                              DeleteConfirmationDialog.show(context, task, () {
                                taskProvider.deleteTask(task.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Task deleted'),
                                    backgroundColor: Color(0xFFDC2626),
                                  ),
                                );
                              });
                            },
                          ),
                        );
                      },
                    ),
              ),
            ),
          ],
        ),
      ),
      // Floating Action Button matching Figma "+ New Task"
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: isDark ? AppColors.darkPrimary : AppColors.darkButton,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskScreen()),
          );
        },
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          'New Task',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
