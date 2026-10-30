import 'package:flutter/material.dart';

import 'package:job_finder/core/theme/locale_controller.dart';

import '../../../data/saved_jobs_service.dart';

const Color _primaryBlue = Color(0xFF385CF2);

class SavedJobsScreen extends StatefulWidget {
  final bool showBackButton;

  const SavedJobsScreen({super.key, this.showBackButton = true});

  @override
  State<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen> {
  final SavedJobsService _service = SavedJobsService();

  List<Map<String, dynamic>> _jobs = [];

  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

  bool get _isArabic => LocaleController.instance.locale.languageCode == 'ar';

  String _text(String english, String arabic) {
    return _isArabic ? arabic : english;
  }

  @override
  void initState() {
    super.initState();

    _loadJobs();

    SavedJobsService.changes.addListener(_onSavedJobsChanged);
  }

  void _onSavedJobsChanged() {
    _loadJobs();
  }

  @override
  void dispose() {
    SavedJobsService.changes.removeListener(_onSavedJobsChanged);
    super.dispose();
  }

  Future<void> _loadJobs() async {
    try {
      final jobs = await _service.getSavedJobs();

      if (!mounted) return;

      setState(() {
        _jobs = jobs;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _removeJob(Map<String, dynamic> job) async {
    final jobId = job['id']?.toString();

    if (jobId == null || jobId.isEmpty) {
      return;
    }

    try {
      await _service.removeJob(jobId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text(
              'Job removed from saved jobs',
              'تم حذف الوظيفة من الوظائف المحفوظة',
            ),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text('Could not remove job: $e', 'تعذر حذف الوظيفة: $e'),
          ),
        ),
      );
    }
  }

  String _value(
    Map<String, dynamic> job,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = job[key]?.toString().trim();

      if (value != null && value.isNotEmpty && value != 'null') {
        return value;
      }
    }

    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final query = _searchQuery.trim().toLowerCase();

    final filteredJobs = _jobs.where((job) {
      final title = _value(job, ['title', 'job_title']);

      final company = _value(job, ['companyName', 'company_name', 'company']);

      return title.toLowerCase().contains(query) ||
          company.toLowerCase().contains(query);
    }).toList();

    return AnimatedBuilder(
      animation: LocaleController.instance,
      builder: (context, child) {
        return Directionality(
          textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              leading: widget.showBackButton
                  ? IconButton(
                      tooltip: _text('Back', 'رجوع'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: colors.onSurface,
                      ),
                    )
                  : null,
              backgroundColor: theme.appBarTheme.backgroundColor,
              foregroundColor: colors.onSurface,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              title: Text(
                _text('Saved Jobs', 'الوظائف المحفوظة'),
                style: TextStyle(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: _loadJobs,
                  icon: const Icon(Icons.refresh_rounded),
                  color: colors.primary,
                  tooltip: _text('Refresh', 'تحديث'),
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      style: TextStyle(color: colors.onSurface),
                      decoration: InputDecoration(
                        hintText: _text(
                          'Search saved jobs...',
                          'ابحث في الوظائف المحفوظة...',
                        ),
                        hintStyle: TextStyle(color: colors.onSurfaceVariant),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: colors.onSurfaceVariant,
                        ),
                        filled: true,
                        fillColor: theme.cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: colors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: _buildBody(filteredJobs)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(List<Map<String, dynamic>> filteredJobs) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _primaryBlue),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),
              Text(
                _text(
                  'Could not load saved jobs',
                  'تعذر تحميل الوظائف المحفوظة',
                ),
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadJobs,
                child: Text(_text('Try again', 'حاول مرة أخرى')),
              ),
            ],
          ),
        ),
      );
    }

    if (_jobs.isEmpty) {
      return _emptyState(
        icon: Icons.bookmark_border_rounded,
        title: _text('No saved jobs yet', 'لا توجد وظائف محفوظة'),
        message: _text(
          'Jobs you bookmark will appear here.',
          'الوظائف التي تحفظها ستظهر هنا.',
        ),
      );
    }

    if (filteredJobs.isEmpty) {
      return _emptyState(
        icon: Icons.search_off_rounded,
        title: _text('No jobs found', 'لم يتم العثور على وظائف'),
        message: _text(
          'Try searching with another keyword.',
          'جرّب البحث باستخدام كلمة أخرى.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadJobs,
      color: colors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: filteredJobs.length,
        separatorBuilder: (context, index) {
          return const SizedBox(height: 12);
        },
        itemBuilder: (context, index) {
          final job = filteredJobs[index];

          final title = _value(job, [
            'title',
            'job_title',
          ], fallback: _text('Untitled job', 'وظيفة بدون عنوان'));

          final company = _value(job, [
            'companyName',
            'company_name',
            'company',
          ], fallback: _text('Company not specified', 'الشركة غير محددة'));

          final location = _value(job, [
            'location',
            'candidate_required_location',
          ], fallback: _text('Location not specified', 'الموقع غير محدد'));

          final logoUrl = _value(job, [
            'logoUrl',
            'company_logo',
            'logo_url',
            'logo',
          ]);

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: theme.dividerColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: theme.brightness == Brightness.dark ? 0.08 : 0.035,
                  ),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark
                        ? const Color(0xFF263755)
                        : const Color(0xFFEDF1FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: logoUrl.isEmpty
                      ? Icon(
                          Icons.business_rounded,
                          color: theme.brightness == Brightness.dark
                              ? const Color(0xFFBBD0FF)
                              : _primaryBlue,
                          size: 27,
                        )
                      : Image.network(
                          logoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.business_rounded,
                              color: theme.brightness == Brightness.dark
                                  ? const Color(0xFFBBD0FF)
                                  : _primaryBlue,
                            );
                          },
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        company,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 15,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: _text('Remove saved job', 'حذف الوظيفة المحفوظة'),
                  onPressed: () => _removeJob(job),
                  icon: const Icon(Icons.bookmark_remove_rounded),
                  color: colors.primary,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 68,
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF7189D9)
                  : const Color(0xFFB8C5F9),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
