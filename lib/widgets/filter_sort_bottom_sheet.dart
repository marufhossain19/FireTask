import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';

class FilterSortBottomSheet extends StatefulWidget {
  const FilterSortBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FilterSortBottomSheet(),
    );
  }

  @override
  State<FilterSortBottomSheet> createState() => _FilterSortBottomSheetState();
}

class _FilterSortBottomSheetState extends State<FilterSortBottomSheet> {
  String? _tempCategory;
  TaskSortOption _tempSort = TaskSortOption.newest;
  TaskPriority? _tempPriority;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<TaskProvider>(context, listen: false);
    _tempCategory = provider.selectedCategory;
    _tempSort = provider.sortOption;
    _tempPriority = provider.selectedPriorityFilter;
  }

  final List<Map<String, dynamic>> _categories = [
    {
      'label': 'Personal',
      'value': 'Personal',
      'icon': Icons.person_rounded,
    },
    {
      'label': 'Educational',
      'value': 'Educational',
      'icon': Icons.school_rounded,
    },
    {
      'label': 'Work',
      'value': 'Work',
      'icon': Icons.business_center_rounded,
    },
  ];

  final List<Map<String, dynamic>> _sortOptions = [
    {
      'label': 'Newest',
      'subtitle': 'Recently created',
      'value': TaskSortOption.newest,
      'icon': Icons.access_time_rounded,
    },
    {
      'label': 'Priority',
      'subtitle': 'High to Low',
      'value': TaskSortOption.priority,
      'icon': Icons.bolt_rounded,
    },
    {
      'label': 'Due Date',
      'subtitle': 'Earliest first',
      'value': TaskSortOption.dueDate,
      'icon': Icons.calendar_today_rounded,
    },
  ];

  Widget _buildCategoryTile(
    Map<String, dynamic> item,
    int count,
  ) {
    final isSelected = _tempCategory == item['value'];

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            // Tap selected to toggle back to all, or select this category
            _tempCategory = isSelected ? null : item['value'];
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.darkButton : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.darkButton : AppColors.border,
              width: isSelected ? 1.6 : 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item['icon'] as IconData,
                size: 20,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(height: 6),
              Text(
                item['label'] as String,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortTile(Map<String, dynamic> item) {
    final isSelected = _tempSort == item['value'];

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _tempSort = item['value'] as TaskSortOption;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.08)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.6 : 1.2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                item['icon'] as IconData,
                size: 20,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
              ),
              const SizedBox(height: 6),
              Text(
                item['label'] as String,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item['subtitle'] as String,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.8)
                      : AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityTile(TaskPriority? priority, String label, Color color) {
    final isSelected = _tempPriority == priority;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _tempPriority = priority;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.12) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : AppColors.border,
              width: isSelected ? 1.6 : 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (priority != null) ...[
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? color : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);

    final hasActiveFilters = _tempCategory != null ||
        _tempPriority != null ||
        _tempSort != TaskSortOption.newest;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Grab Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header Row: Icon, Title, Subtitle, Reset Button
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filter & Sort',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Customize your task view',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasActiveFilters)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () {
                      setState(() {
                        _tempCategory = null;
                        _tempPriority = null;
                        _tempSort = TaskSortOption.newest;
                      });
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 14, color: AppColors.danger),
                    label: const Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.danger,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 22),

            // 1. Category Section: Header with "All" toggle + 3 categories in 1 row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CATEGORY',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                      ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _tempCategory = null;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: _tempCategory == null ? AppColors.darkButton : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'All (${provider.totalCount})',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _tempCategory == null ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Exactly 3 in 1 row!
            Row(
              children: [
                _buildCategoryTile(_categories[0], provider.countForCategory('Personal')),
                const SizedBox(width: 8),
                _buildCategoryTile(_categories[1], provider.countForCategory('Educational')),
                const SizedBox(width: 8),
                _buildCategoryTile(_categories[2], provider.countForCategory('Work')),
              ],
            ),
            const SizedBox(height: 22),

            // 2. Sort By Section (3 in 1 row)
            Text(
              'SORT BY',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildSortTile(_sortOptions[0]),
                const SizedBox(width: 8),
                _buildSortTile(_sortOptions[1]),
                const SizedBox(width: 8),
                _buildSortTile(_sortOptions[2]),
              ],
            ),
            const SizedBox(height: 22),

            // 3. Priority Filter Section
            Text(
              'PRIORITY',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildPriorityTile(null, 'All', AppColors.primary),
                const SizedBox(width: 6),
                _buildPriorityTile(TaskPriority.high, 'High', AppColors.highPriority),
                const SizedBox(width: 6),
                _buildPriorityTile(TaskPriority.medium, 'Medium', AppColors.mediumPriority),
                const SizedBox(width: 6),
                _buildPriorityTile(TaskPriority.low, 'Low', AppColors.lowPriority),
              ],
            ),
            const SizedBox(height: 28),

            // Apply Button
            SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkButton,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  provider.setCategoryFilter(_tempCategory);
                  provider.setSortOption(_tempSort);
                  provider.setPriorityFilter(_tempPriority);
                  Navigator.pop(context);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_rounded, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
