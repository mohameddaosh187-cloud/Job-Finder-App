import 'package:flutter/material.dart';
import 'package:job_finder/features/profile/data/saved_jobs_service.dart';
import 'package:job_finder/core/theme/locale_controller.dart';

import '../../../data/model/job_model.dart';

class JobCard extends StatefulWidget {
  final JobModel job;
  final VoidCallback? onTap;

  const JobCard({super.key, required this.job, this.onTap});

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  final SavedJobsService _service = SavedJobsService();

  bool _isSaved = false;
  bool _isSaving = false;

  static const Color _primaryBlue = Color(0xFF2457D6);

  bool get _isArabic => LocaleController.instance.locale.languageCode == 'ar';

  String _text(String english, String arabic) {
    return _isArabic ? arabic : english;
  }

  @override
  void initState() {
    super.initState();

    _loadSavedState();
    SavedJobsService.changes.addListener(_onSavedJobsChanged);
    LocaleController.instance.addListener(_onLocaleChanged);
  }

  @override
  void didUpdateWidget(covariant JobCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.job.id != widget.job.id) {
      _loadSavedState();
    }
  }

  @override
  void dispose() {
    SavedJobsService.changes.removeListener(_onSavedJobsChanged);
    LocaleController.instance.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadSavedState() async {
    try {
      final saved = await _service.isSaved(widget.job.id);

      if (!mounted) return;

      setState(() {
        _isSaved = saved;
      });
    } catch (_) {}
  }

  void _onSavedJobsChanged() {
    _loadSavedState();
  }

  Future<void> _toggleSaved() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final currentlySaved = await _service.isSaved(widget.job.id);

      if (currentlySaved) {
        await _service.removeJob(widget.job.id);
      } else {
        await _service.saveJob(widget.job.toJson());
      }

      if (!mounted) return;

      setState(() {
        _isSaved = !currentlySaved;
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            currentlySaved
                ? _text(
                    'Job removed from saved jobs',
                    'تمت إزالة الوظيفة من المحفوظات',
                  )
                : _text('Job saved successfully', 'تم حفظ الوظيفة بنجاح'),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text(
              'Could not update saved job. Please try again.',
              'تعذر تحديث الوظيفة المحفوظة. حاول مرة أخرى.',
            ),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = theme.cardColor;
    final borderColor = theme.dividerColor;
    final titleColor = colors.onSurface;
    final mutedColor = colors.onSurfaceVariant;

    final jobTypeBackground = isDark
        ? const Color(0xFF263755)
        : Colors.blue.shade50;

    final jobTypeTextColor = isDark
        ? const Color(0xFFBBD0FF)
        : Colors.blue.shade800;

    return Directionality(
      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor),
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCompanyLogo(isDark: isDark),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.job.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: _isArabic ? TextAlign.right : TextAlign.left,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: titleColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.job.companyName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: _isArabic ? TextAlign.right : TextAlign.left,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: mutedColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: mutedColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.job.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: _isArabic
                                  ? TextAlign.right
                                  : TextAlign.left,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: mutedColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (widget.job.jobType.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: jobTypeBackground,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.job.jobType,
                            style: TextStyle(
                              color: jobTypeTextColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      if (widget.job.salary != null &&
                          widget.job.salary!.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.job.salary!,
                          textAlign: _isArabic
                              ? TextAlign.right
                              : TextAlign.left,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: titleColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  tooltip: _isSaved
                      ? _text('Remove saved job', 'إزالة من المحفوظات')
                      : _text('Save job', 'حفظ الوظيفة'),
                  onPressed: _isSaving ? null : _toggleSaved,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 21,
                          height: 21,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          _isSaved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                        ),
                  color: _isSaved ? _primaryBlue : mutedColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyLogo({required bool isDark}) {
    final logo = widget.job.logoUrl;

    if (logo != null && logo.trim().isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          logo,
          width: 52,
          height: 52,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _logoPlaceholder(isDark: isDark);
          },
        ),
      );
    }

    return _logoPlaceholder(isDark: isDark);
  }

  Widget _logoPlaceholder({required bool isDark}) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF263755) : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.business_outlined,
        color: isDark ? const Color(0xFFBBD0FF) : Colors.blue.shade700,
        size: 28,
      ),
    );
  }
}
