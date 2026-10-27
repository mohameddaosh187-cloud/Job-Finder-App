import 'package:flutter/material.dart';
import 'package:job_finder/features/profile/data/saved_jobs_service.dart';

import '../../../data/model/job_model.dart';
class JobCard extends StatefulWidget {
  final JobModel job;
  final VoidCallback? onTap;

  const JobCard({
    super.key,
    required this.job,
    this.onTap,
  });

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  final SavedJobsService _service = SavedJobsService();

  bool _isSaved = false;
  bool _isSaving = false;

  static const Color _primaryBlue = Color(0xFF2457D6);

  @override
  void initState() {
    super.initState();

    _loadSavedState();

    SavedJobsService.changes.addListener(_onSavedJobsChanged);
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
    super.dispose();
  }

  Future<void> _loadSavedState() async {
    try {
      final saved = await _service.isSaved(widget.job.id);

      if (!mounted) return;

      setState(() {
        _isSaved = saved;
      });
    } catch (_) {
      // نحتفظ بحالة الكارت الحالية لو تعذرت قراءة البيانات.
    }
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
                ? 'Job removed from saved jobs'
                : 'Job saved successfully',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not update saved job: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCompanyLogo(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.job.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.job.companyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.job.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (widget.job.jobType.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.job.jobType,
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (widget.job.salary != null &&
                        widget.job.salary!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.job.salary!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: _isSaved ? 'Remove saved job' : 'Save job',
                onPressed: _isSaving ? null : _toggleSaved,
                icon: _isSaving
                    ? const SizedBox(
                        width: 21,
                        height: 21,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        _isSaved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                      ),
                color: _isSaved
                    ? _primaryBlue
                    : Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyLogo() {
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
            return _logoPlaceholder();
          },
        ),
      );
    }

    return _logoPlaceholder();
  }

  Widget _logoPlaceholder() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.business_outlined,
        color: Colors.blue.shade700,
        size: 28,
      ),
    );
  }
}
