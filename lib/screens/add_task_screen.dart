import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay(
    hour: (DateTime.now().hour + 1) % 24,
    minute: DateTime.now().minute,
  );
  String _selectedBucket = 'Personal';
  TaskPriority _selectedPriority = TaskPriority.medium;
  bool _isSaving = false;

  final List<String> _courseBuckets = ['Personal', 'Educational', 'Work'];

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final isDark = AppColors.isDark(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppColors.darkPrimary,
                    onPrimary: Colors.white,
                    surface: AppColors.darkSurface,
                    onSurface: AppColors.darkTextPrimary,
                  )
                : const ColorScheme.light(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: AppColors.textPrimary,
                  ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final isDark = AppColors.isDark(context);
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppColors.darkPrimary,
                    onPrimary: Colors.white,
                    surface: AppColors.darkSurface,
                    onSurface: AppColors.darkTextPrimary,
                  )
                : const ColorScheme.light(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: AppColors.textPrimary,
                  ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveTask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task title'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final dueDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final newTask = TaskModel(
      id: '',
      title: title,
      description: _notesController.text.trim(),
      dueDate: dueDateTime,
      courseBucket: _selectedBucket,
      priority: _selectedPriority,
      isCompleted: false,
      userId: authProvider.effectiveUserId ?? 'local_user',
    );

    await taskProvider.addTask(newTask);

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task created successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context);
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return AppColors.highPriority;
      case TaskPriority.medium:
        return AppColors.mediumPriority;
      case TaskPriority.low:
        return AppColors.lowPriority;
    }
  }

  Widget _buildSlidingPrioritySelector(bool isDark) {
    final priorityColor = _getPriorityColor(_selectedPriority);
    final priorities = const [
      (TaskPriority.low, 'Low'),
      (TaskPriority.medium, 'Medium'),
      (TaskPriority.high, 'High'),
    ];
    final selectedIndex = _selectedPriority == TaskPriority.low
        ? 0
        : (_selectedPriority == TaskPriority.medium ? 1 : 2);

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E212B) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.borderSubtle,
          width: 1,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final tabWidth = totalWidth / 3;
          final indicatorLeft = selectedIndex * tabWidth;

          return Stack(
            children: [
              // Gliding Animated Indicator Pill
              AnimatedPositioned(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                left: indicatorLeft,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: [
                      BoxShadow(
                        color: priorityColor.withValues(alpha: isDark ? 0.45 : 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
              // Interactive Tab Labels
              Positioned.fill(
                child: Row(
                  children: priorities.map((entry) {
                    final priority = entry.$1;
                    final label = entry.$2;
                    final isSelected = _selectedPriority == priority;

                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          setState(() {
                            _selectedPriority = priority;
                          });
                        },
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOutCubic,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary),
                            ),
                            child: Text(label),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MM/dd/yyyy');
    final isDark = AppColors.isDark(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: AppColors.textPrimaryOf(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'New Task',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryOf(context),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title Field
              Text(
                'TITLE',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textMutedOf(context),
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimaryOf(context),
                ),
                decoration: const InputDecoration(
                  hintText: 'e.g. Complete Flutter Assignment',
                ),
              ),
              const SizedBox(height: 20),

              // Notes Field
              Text(
                'NOTES',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textMutedOf(context),
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 4,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimaryOf(context),
                ),
                decoration: const InputDecoration(
                  hintText: 'Add details, links, or notes...',
                ),
              ),
              const SizedBox(height: 20),

              // Due Date & Due Time Fields
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DUE DATE',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.textMutedOf(context),
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark ? AppColors.darkBorder : AppColors.border,
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  dateFormat.format(_selectedDate),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimaryOf(context),
                                  ),
                                ),
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 18,
                                  color: AppColors.textMutedOf(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DUE TIME',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.textMutedOf(context),
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _pickTime,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark ? AppColors.darkBorder : AppColors.border,
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _selectedTime.format(context),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimaryOf(context),
                                  ),
                                ),
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 18,
                                  color: AppColors.textMutedOf(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Course Bucket
              Text(
                'CATEGORY',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textMutedOf(context),
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                    width: 1.2,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedBucket,
                    dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                    isExpanded: true,
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMutedOf(context)),
                    items: _courseBuckets.map((bucket) {
                      return DropdownMenuItem<String>(
                        value: bucket,
                        child: Text(
                          bucket,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimaryOf(context),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedBucket = val;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Priority
              Text(
                'PRIORITY',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textMutedOf(context),
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 10),
              _buildSlidingPrioritySelector(isDark),
              const SizedBox(height: 36),

              // Save Task Button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _isSaving ? null : _saveTask,
                  child: const Text(
                    'Save Task',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Cancel Button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondaryOf(context),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
