import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../theme/app_theme.dart';

class TaskCard extends StatefulWidget {
  final TaskModel task;
  final VoidCallback onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isHighlighted;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
    this.isHighlighted = false,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _isHovered = false;

  Widget _buildPriorityBadge(bool isDark) {
    Color bg;
    Color text;
    Color dot;
    String label;

    switch (widget.task.priority) {
      case TaskPriority.high:
        bg = isDark
            ? AppColors.highPriority.withValues(alpha: 0.18)
            : AppColors.highPriorityBg;
        text = isDark ? const Color(0xFFF87171) : AppColors.highPriorityText;
        dot = AppColors.highPriority;
        label = 'High';
        break;
      case TaskPriority.medium:
        bg = isDark
            ? AppColors.mediumPriority.withValues(alpha: 0.18)
            : AppColors.mediumPriorityBg;
        text = isDark ? const Color(0xFFFBBF24) : AppColors.mediumPriorityText;
        dot = AppColors.mediumPriority;
        label = 'Medium';
        break;
      case TaskPriority.low:
        bg = isDark
            ? AppColors.lowPriority.withValues(alpha: 0.18)
            : AppColors.lowPriorityBg;
        text = isDark ? const Color(0xFF34D399) : AppColors.lowPriorityText;
        dot = AppColors.lowPriority;
        label = 'Low';
        break;
    }

    if (widget.task.isCompleted) {
      bg = bg.withValues(alpha: 0.5);
      text = text.withValues(alpha: 0.6);
      dot = dot.withValues(alpha: 0.6);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dot,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: text,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoneBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF064E3B).withValues(alpha: 0.45)
            : const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Done',
        style: TextStyle(
          color: isDark ? const Color(0xFF34D399) : const Color(0xFF16A34A),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(String category, bool isCompleted, bool isDark) {
    Color bg;
    Color text;
    Color border;

    switch (category.toLowerCase().trim()) {
      case 'personal':
        bg = isDark
            ? const Color(0xFF0284C7).withValues(alpha: 0.18)
            : AppColors.categoryPersonalBg;
        text = isDark ? const Color(0xFF38BDF8) : AppColors.categoryPersonalText;
        border = isDark
            ? const Color(0xFF0284C7).withValues(alpha: 0.35)
            : AppColors.categoryPersonalBorder;
        break;
      case 'educational':
        bg = isDark
            ? const Color(0xFF7E22CE).withValues(alpha: 0.18)
            : AppColors.categoryEducationalBg;
        text = isDark ? const Color(0xFFC084FC) : AppColors.categoryEducationalText;
        border = isDark
            ? const Color(0xFF7E22CE).withValues(alpha: 0.35)
            : AppColors.categoryEducationalBorder;
        break;
      case 'work':
        bg = isDark
            ? const Color(0xFF059669).withValues(alpha: 0.18)
            : AppColors.categoryWorkBg;
        text = isDark ? const Color(0xFF34D399) : AppColors.categoryWorkText;
        border = isDark
            ? const Color(0xFF059669).withValues(alpha: 0.35)
            : AppColors.categoryWorkBorder;
        break;
      default:
        bg = isDark ? const Color(0xFF1E212B) : const Color(0xFFF3F4F6);
        text = isDark ? AppColors.darkTextSecondary : const Color(0xFF4B5563);
        border = isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB);
    }

    if (isCompleted) {
      bg = bg.withValues(alpha: 0.4);
      text = text.withValues(alpha: 0.5);
      border = border.withValues(alpha: 0.4);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 1),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 10,
          color: text,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.task.isCompleted;
    final isDark = AppColors.isDark(context);
    final dateFormat = DateFormat('MMM d');
    final timeFormat = DateFormat('h:mm a');
    final formattedDate = 'Due ${dateFormat.format(widget.task.dueDate)}';
    final formattedTime = timeFormat.format(widget.task.dueDate);

    // Card background for Deep Black OLED
    final cardBg = isDark
        ? (isCompleted ? const Color(0xFF08090D) : AppColors.darkSurface)
        : (isCompleted ? const Color(0xFFF9FAFB) : Colors.white);

    // Card border
    final cardBorder = widget.isHighlighted
        ? (isDark ? Colors.white : Colors.black)
        : (isDark
            ? AppColors.darkBorder
            : (isCompleted
                ? const Color(0xFFE5E7EB).withValues(alpha: 0.7)
                : AppColors.border));

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: cardBorder,
            width: widget.isHighlighted ? 2.2 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.isHighlighted
                  ? (isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.black.withValues(alpha: 0.12))
                  : (_isHovered
                      ? Colors.black.withValues(alpha: isDark ? 0.3 : 0.05)
                      : (isCompleted
                          ? Colors.transparent
                          : Colors.black.withValues(alpha: isDark ? 0.2 : 0.02))),
              blurRadius: widget.isHighlighted ? 12 : (_isHovered ? 8 : 4),
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: widget.onEdit,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Completion Checkbox Circle
                  GestureDetector(
                    onTap: widget.onToggleComplete,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2, right: 12),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted
                              ? (isDark ? AppColors.darkPrimary : const Color(0xFF4B5563))
                              : (isDark ? AppColors.darkSurfaceElevated : Colors.white),
                          border: Border.all(
                            color: isCompleted
                                ? (isDark ? AppColors.darkPrimary : const Color(0xFF4B5563))
                                : (isDark ? const Color(0xFF374151) : const Color(0xFFD1D5DB)),
                            width: 1.8,
                          ),
                        ),
                        child: isCompleted
                            ? const Icon(
                                Icons.check_rounded,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  ),

                  // Main Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Priority Badge + Done Badge + Action Icons
                        Row(
                          children: [
                            _buildPriorityBadge(isDark),
                            if (isCompleted) ...[
                              const SizedBox(width: 6),
                              _buildDoneBadge(isDark),
                            ],
                            const Spacer(),
                            // Action Icons
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  borderRadius: BorderRadius.circular(6),
                                  onTap: widget.onEdit,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.edit_outlined,
                                      size: 16,
                                      color: isCompleted
                                          ? (isDark ? const Color(0xFF4B5563) : const Color(0xFFCBD5E1))
                                          : (isDark ? AppColors.darkTextMuted : const Color(0xFF9CA3AF)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  borderRadius: BorderRadius.circular(6),
                                  onTap: widget.onDelete,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.delete_outline_rounded,
                                      size: 16,
                                      color: isCompleted
                                          ? (isDark ? const Color(0xFF4B5563) : const Color(0xFFCBD5E1))
                                          : (isDark ? AppColors.darkTextMuted : const Color(0xFF9CA3AF)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Title
                        Text(
                          widget.task.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isCompleted
                                ? (isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF))
                                : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationColor: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                          ),
                        ),
                        if (widget.task.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.task.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: isCompleted
                                  ? (isDark
                                      ? const Color(0xFF6B7280).withValues(alpha: 0.8)
                                      : const Color(0xFF9CA3AF).withValues(alpha: 0.8))
                                  : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                              height: 1.3,
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),

                        // Footer: Due Date, Due Time, and Category
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Due Date
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isCompleted
                                      ? Icons.check_circle_outline_rounded
                                      : Icons.calendar_today_outlined,
                                  size: 13,
                                  color: isCompleted
                                      ? (isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF))
                                      : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isCompleted
                                        ? (isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF))
                                        : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            // Due Time
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 13,
                                  color: isCompleted
                                      ? (isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF))
                                      : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  formattedTime,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isCompleted
                                        ? (isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF))
                                        : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            // Category Badge
                            _buildCategoryBadge(
                              widget.task.courseBucket,
                              isCompleted,
                              isDark,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
