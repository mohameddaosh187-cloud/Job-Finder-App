import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:job_finder/core/routes/theme/locale_controller.dart';

import '../../../data/model/job_model.dart';
import '../../../../profile/data/saved_jobs_service.dart';

class JobDetailsScreen extends StatefulWidget {
  final JobModel job;

  const JobDetailsScreen({
    super.key,
    required this.job,
  });

  static const Color primaryBlue = Color(0xFF3563E9);
  static const Color pageBackground = Color(0xFFF6F8FC);

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  final SavedJobsService _savedJobsService = SavedJobsService();

  bool _isSaved = false;
  bool _isCheckingSaved = true;
  bool _isSaving = false;

  JobModel get job => widget.job;

  bool get _isArabic =>
      LocaleController.instance.locale.languageCode == 'ar';

  String _text(String english, String arabic) {
    return _isArabic ? arabic : english;
  }

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
    SavedJobsService.changes.addListener(_onSavedJobsChanged);
  }

  @override
  void dispose() {
    SavedJobsService.changes.removeListener(_onSavedJobsChanged);
    super.dispose();
  }

  void _onSavedJobsChanged() {
    _checkIfSaved();
  }

  Future<void> _checkIfSaved() async {
    try {
      final saved = await _savedJobsService.isSaved(
        job.id.toString(),
      );

      if (!mounted) return;

      setState(() {
        _isSaved = saved;
        _isCheckingSaved = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isCheckingSaved = false;
      });
    }
  }

  Map<String, dynamic> _jobToMap() {
    return {
      'id': job.id.toString(),
      'title': job.title,
      'companyName': job.companyName,
      'location': job.location,
      'description': job.description,
      'jobType': job.jobType,
      'salary': job.salary,
      'logoUrl': job.logoUrl,
      'category': job.category,
      'jobUrl': job.jobUrl,
    };
  }

  Future<void> _toggleSaved() async {
    if (_isSaving || _isCheckingSaved) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final wasSaved = _isSaved;
      final jobId = job.id.toString();

      if (wasSaved) {
        await _savedJobsService.removeJob(jobId);
      } else {
        await _savedJobsService.saveJob(_jobToMap());
      }

      if (!mounted) return;

      setState(() {
        _isSaved = !wasSaved;
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isSaved
                ? _text(
                    'Job added to Saved Jobs.',
                    'تمت إضافة الوظيفة إلى الوظائف المحفوظة.',
                  )
                : _text(
                    'Job removed from Saved Jobs.',
                    'تمت إزالة الوظيفة من الوظائف المحفوظة.',
                  ),
          ),
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
              'تعذر تحديث الوظائف المحفوظة. حاول مرة أخرى.',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _applyForJob(BuildContext context) async {
    final url = job.jobUrl?.trim() ?? '';

    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text(
              'Application link is not available for this job.',
              'رابط التقديم غير متاح لهذه الوظيفة.',
            ),
          ),
        ),
      );
      return;
    }

    final uri = Uri.tryParse(url);

    if (uri == null ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        uri.host.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text(
              'The application link is invalid.',
              'رابط التقديم غير صالح.',
            ),
          ),
        ),
      );
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _text(
                'Could not open the application link.',
                'تعذر فتح رابط التقديم.',
              ),
            ),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _text(
                'Something went wrong while opening the link.',
                'حدث خطأ أثناء فتح الرابط.',
              ),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LocaleController.instance,
      builder: (context, child) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;

        final location = job.location.trim();
        final jobType = job.jobType.trim();
        final salary = job.salary?.trim() ?? '';
        final category = job.category?.trim() ?? '';
        final companyName = job.companyName.trim();

        return Directionality(
          textDirection:
              _isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              title: Text(
                _text('Job Details', 'تفاصيل الوظيفة'),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              centerTitle: true,
              backgroundColor: theme.appBarTheme.backgroundColor,
              foregroundColor: colors.onSurface,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  tooltip: _isSaved
                      ? _text('Remove saved job', 'إزالة من المحفوظات')
                      : _text('Save job', 'حفظ الوظيفة'),
                  onPressed: _isSaving || _isCheckingSaved
                      ? null
                      : _toggleSaved,
                  icon: _isSaving || _isCheckingSaved
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          _isSaved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          color: _isSaved
                              ? JobDetailsScreen.primaryBlue
                              : colors.onSurfaceVariant,
                        ),
                ),
              ],
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: _CompanyLogo(
                        logoUrl: job.logoUrl,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        job.title.trim().isEmpty
                            ? _text('Untitled Job', 'وظيفة بدون عنوان')
                            : job.title,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        companyName.isEmpty
                            ? _text(
                                'Company not specified',
                                'الشركة غير محددة',
                              )
                            : companyName,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoChip(
                          icon: Icons.location_on_outlined,
                          label: location.isEmpty
                              ? _text(
                                  'Remote / Not specified',
                                  'عن بُعد / غير محدد',
                                )
                              : location,
                        ),
                        if (jobType.isNotEmpty)
                          _InfoChip(
                            icon: Icons.work_outline_rounded,
                            label: _translateJobType(jobType),
                          ),
                        if (category.isNotEmpty)
                          _InfoChip(
                            icon: Icons.category_outlined,
                            label: _translateCategory(category),
                          ),
                      ],
                    ),
                    if (salary.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _SectionCard(
                        title: _text('Salary', 'الراتب'),
                        icon: Icons.payments_outlined,
                        child: Text(
                          salary,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: JobDetailsScreen.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Text(
                      _text('Job Description', 'الوصف الوظيفي'),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: theme.dividerColor,
                        ),
                      ),
                      child: SelectableText(
                        _plainDescription(job.description),
                        textAlign:
                            _isArabic ? TextAlign.right : TextAlign.left,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.7,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () => _applyForJob(context),
                        icon: const Icon(
                          Icons.open_in_new_rounded,
                        ),
                        label: Text(
                          _text('Apply Now', 'قدّم الآن'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: JobDetailsScreen.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        _text(
                          'You will be redirected to the original job posting.',
                          'سيتم توجيهك إلى صفحة الوظيفة الأصلية.',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _translateJobType(String value) {
    switch (value.toLowerCase()) {
      case 'full-time':
      case 'full time':
        return _text('Full-time', 'دوام كامل');
      case 'part-time':
      case 'part time':
        return _text('Part-time', 'دوام جزئي');
      case 'contract':
        return _text('Contract', 'تعاقد');
      case 'internship':
        return _text('Internship', 'تدريب');
      case 'remote':
        return _text('Remote', 'عن بُعد');
      default:
        return value;
    }
  }

  String _translateCategory(String value) {
    switch (value.toLowerCase()) {
      case 'design':
        return _text('Design', 'التصميم');
      case 'technology':
      case 'tech':
        return _text('Technology', 'التكنولوجيا');
      case 'marketing':
        return _text('Marketing', 'التسويق');
      case 'finance':
        return _text('Finance', 'المالية');
      case 'education':
        return _text('Education', 'التعليم');
      case 'health':
      case 'healthcare':
        return _text('Healthcare', 'الرعاية الصحية');
      case 'sales':
        return _text('Sales', 'المبيعات');
      case 'customer service':
        return _text('Customer Service', 'خدمة العملاء');
      default:
        return value;
    }
  }

  String _plainDescription(String description) {
    var result = description
        .replaceAll(
          RegExp(r'<br\s*/?>', caseSensitive: false),
          '\n',
        )
        .replaceAll(
          RegExp(
            r'</(p|div|li|h[1-6])\s*>',
            caseSensitive: false,
          ),
          '\n\n',
        )
        .replaceAll(
          RegExp(r'<li[^>]*>', caseSensitive: false),
          '• ',
        )
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&nbsp;', ' ');

    result = result.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();

    return result.isEmpty
        ? _text(
            'No description available for this job.',
            'لا يوجد وصف متاح لهذه الوظيفة.',
          )
        : result;
  }
}

class _CompanyLogo extends StatelessWidget {
  final String? logoUrl;

  const _CompanyLogo({
    required this.logoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = logoUrl?.trim() ?? '';

    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.dividerColor,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: url.isEmpty
          ? const _FallbackLogo()
          : Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const _FallbackLogo();
              },
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;

                return const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: JobDetailsScreen.primaryBlue,
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _FallbackLogo extends StatelessWidget {
  const _FallbackLogo();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.business_rounded,
      size: 42,
      color: JobDetailsScreen.primaryBlue,
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 17,
            color: JobDetailsScreen.primaryBlue,
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: JobDetailsScreen.primaryBlue,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
