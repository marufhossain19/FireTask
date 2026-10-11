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

  Widget _buildPriorityBadge() {
    Color bg;
    Color text;
    Color dot;
    String label;

    switch (widget.task.priority) {
      case TaskPriority.high:
        bg = AppColors.highPriorityBg;
        text = AppColors.highPriorityText;
        dot = AppColors.highPriority;
        label = 'High';
        break;
      case TaskPriority.medium:
        bg = AppColors.mediumPriorityBg;
        text = AppColors.mediumPriorityText;
        dot = AppColors.mediumPriority;
        label = 'Medium';
        break;
      case TaskPriority.low:
        bg = AppColors.lowPriorityBg;
        text = AppColors.lowPriorityText;
        dot = AppColors.lowPriority;
        label = 'Low';
        break;
    }

    // Softer, muted priority styling when task is completed (as in Figma)
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

  Widget _buildDoneBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Done',
        style: TextStyle(
          color: Color(0xFF16A34A),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(String category, bool isCompleted) {
    Color bg;
    Color text;
    Color border;

    switch (category.toLowerCase().trim()) {
      case 'personal':
        // Cyan
        bg = AppColors.categoryPersonalBg;
        text = AppColors.categoryPersonalText;
        border = AppColors.categoryPersonalBorder;
        break;
      case 'educational':
        // Lavender
        bg = AppColors.categoryEducationalBg;
        text = AppColors.categoryEducationalText;
        border = AppColors.categoryEducationalBorder;
        break;
      case 'work':
        // Mint
        bg = AppColors.categoryWorkBg;
        text = AppColors.categoryWorkText;
        border = AppColors.categoryWorkBorder;
        break;
      default:
        bg = const Color(0xFFF3F4F6);
        text = const Color(0xFF4B5563);
        border = const Color(0xFFE5E7EB);
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
    final dateFormat = DateFormat('MMM d');
    final timeFormat = DateFormat('h:mm a');
    final formattedDate = 'Due ${dateFormat.format(widget.task.dueDate)}';
    final formattedTime = timeFormat.format(widget.task.dueDate);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          // Distinct background color for completed tasks matching Figma
          color: isCompleted ? const Color(0xFFF9FAFB) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isHighlighted
                ? Colors.black
                : (isCompleted
                    ? const Color(0xFFE5E7EB).withValues(alpha: 0.7)
                    : AppColors.border),
            width: widget.isHighlighted ? 2.5 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.isHighlighted
                  ? Colors.black.withValues(alpha: 0.12)
                  : (_isHovered
                      ? Colors.black.withValues(alpha: 0.05)
                      : (isCompleted
                          ? Colors.transparent
                          : Colors.black.withValues(alpha: 0.02))),
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
                          color: isCompleted ? const Color(0xFF4B5563) : Colors.white,
                          border: Border.all(
                            color: isCompleted
                                ? const Color(0xFF4B5563)
                                : const Color(0xFFD1D5DB),
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
                            _buildPriorityBadge(),
                            if (isCompleted) ...[
                              const SizedBox(width: 6),
                              _buildDoneBadge(),
                            ],
                            const Spacer(),
                            // Action Icons with faded color when completed
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
                                          ? const Color(0xFFCBD5E1)
                                          : const Color(0xFF9CA3AF),
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
                                          ? const Color(0xFFCBD5E1)
                                          : const Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Title: Faded strikethrough when completed
                        Text(
                          widget.task.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isCompleted
                                ? const Color(0xFF9CA3AF)
                                : AppColors.textPrimary,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationColor: const Color(0xFF9CA3AF),
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
                                  ? const Color(0xFF9CA3AF).withValues(alpha: 0.8)
                                  : AppColors.textSecondary,
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
                                      ? const Color(0xFF9CA3AF)
                                      : AppColors.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isCompleted
                                        ? const Color(0xFF9CA3AF)
                                        : AppColors.textMuted,
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
                                      ? const Color(0xFF9CA3AF)
                                      : AppColors.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  formattedTime,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isCompleted
                                        ? const Color(0xFF9CA3AF)
                                        : AppColors.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            // Category badge
                            if (widget.task.category.isNotEmpty)
                              _buildCategoryBadge(
                                widget.task.category,
                                isCompleted,
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
