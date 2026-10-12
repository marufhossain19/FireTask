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
      'label': 'Due Soon',
      'subtitle': 'Earliest deadline',
      'value': TaskSortOption.dueDate,
      'icon': Icons.event_rounded,
    },
    {
      'label': 'Priority',
      'subtitle': 'High to Low',
      'value': TaskSortOption.priority,
      'icon': Icons.flag_rounded,
    },
  ];

  Widget _buildCategoryTile(
    Map<String, dynamic> item,
    int count,
    bool isDark,
  ) {
    final isSelected = _tempCategory == item['value'];

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _tempCategory = isSelected ? null : item['value'];
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.darkPrimary : AppColors.darkButton)
                : (isDark ? AppColors.darkSurfaceElevated : Colors.white),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? (isDark ? AppColors.darkPrimary : AppColors.darkButton)
                  : (isDark ? AppColors.darkBorder : AppColors.border),
              width: isSelected ? 1.6 : 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
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
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                ),
                child: Text(
                  item['label'] as String,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : (isDark ? const Color(0xFF222634) : const Color(0xFFF3F4F6)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
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
      ),
    );
  }

  Widget _buildSortTile(Map<String, dynamic> item, bool isDark) {
    final isSelected = _tempSort == item['value'];
    final activeColor = isDark ? AppColors.darkPrimary : AppColors.primary;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _tempSort = item['value'] as TaskSortOption;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: isDark ? 0.2 : 0.08)
                : (isDark ? AppColors.darkSurfaceElevated : Colors.white),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? activeColor : (isDark ? AppColors.darkBorder : AppColors.border),
              width: isSelected ? 1.6 : 1.2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                item['icon'] as IconData,
                size: 20,
                color: isSelected
                    ? activeColor
                    : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
              ),
              const SizedBox(height: 6),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? activeColor
                      : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                ),
                child: Text(
                  item['label'] as String,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  color: isSelected
                      ? activeColor.withValues(alpha: 0.85)
                      : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                  fontWeight: FontWeight.w500,
                ),
                child: Text(
                  item['subtitle'] as String,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityTile(
    TaskPriority? priority,
    String label,
    Color color,
    bool isDark,
  ) {
    final isSelected = _tempPriority == priority;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _tempPriority = priority;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: isDark ? 0.22 : 0.12)
                : (isDark ? AppColors.darkSurfaceElevated : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : (isDark ? AppColors.darkBorder : AppColors.border),
              width: isSelected ? 1.6 : 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (priority != null) ...[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  width: isSelected ? 7 : 6,
                  height: isSelected ? 7 : 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected
                        ? (isDark ? (priority == null ? AppColors.darkPrimary : color) : color)
                        : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
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
    final isDark = AppColors.isDark(context);

    final hasActiveFilters = _tempCategory != null ||
        _tempPriority != null ||
        _tempSort != TaskSortOption.newest;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                  color: isDark ? const Color(0xFF2E3240) : const Color(0xFFE5E7EB),
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
                    color: isDark ? const Color(0xFF1E1B4B) : const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: isDark ? const Color(0xFFA5B4FC) : AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filter & Sort',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryOf(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Customize your task view',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMutedOf(context),
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

            // 1. Category Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CATEGORY',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMutedOf(context),
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
                      color: _tempCategory == null
                          ? (isDark ? AppColors.darkPrimary : AppColors.darkButton)
                          : (isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF3F4F6)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'All (${provider.totalCount})',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _tempCategory == null
                            ? Colors.white
                            : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildCategoryTile(_categories[0], provider.countForCategory('Personal'), isDark),
                const SizedBox(width: 8),
                _buildCategoryTile(_categories[1], provider.countForCategory('Educational'), isDark),
                const SizedBox(width: 8),
                _buildCategoryTile(_categories[2], provider.countForCategory('Work'), isDark),
              ],
            ),
            const SizedBox(height: 22),

            // 2. Sort By Section
            Text(
              'SORT BY',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMutedOf(context),
                  ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildSortTile(_sortOptions[0], isDark),
                const SizedBox(width: 8),
                _buildSortTile(_sortOptions[1], isDark),
                const SizedBox(width: 8),
                _buildSortTile(_sortOptions[2], isDark),
              ],
            ),
            const SizedBox(height: 22),

            // 3. Priority Filter Section
            Text(
              'PRIORITY',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMutedOf(context),
                  ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildPriorityTile(null, 'All', isDark ? AppColors.darkPrimary : AppColors.primary, isDark),
                const SizedBox(width: 6),
                _buildPriorityTile(TaskPriority.high, 'High', AppColors.highPriority, isDark),
                const SizedBox(width: 6),
                _buildPriorityTile(TaskPriority.medium, 'Medium', AppColors.mediumPriority, isDark),
                const SizedBox(width: 6),
                _buildPriorityTile(TaskPriority.low, 'Low', AppColors.lowPriority, isDark),
              ],
            ),
            const SizedBox(height: 28),

            // Apply Button
            SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.darkPrimary : AppColors.darkButton,
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
