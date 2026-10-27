import 'package:flutter/material.dart';

import '../../../data/saved_jobs_service.dart';

const Color _primaryBlue = Color(0xFF385CF2);
const Color _pageBackground = Color(0xFFF6F8FC);
const Color _textDark = Color(0xFF172033);
const Color _textMuted = Color(0xFF7B8497);

class SavedJobsScreen extends StatefulWidget {
  final bool showBackButton;

  const SavedJobsScreen({
    super.key,
    this.showBackButton = true,
  });

  @override
  State<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen> {
  final SavedJobsService _service = SavedJobsService();

  List<Map<String, dynamic>> _jobs = [];

  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

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
        const SnackBar(
          content: Text('Job removed from saved jobs'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not remove job: $e'),
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
    final query = _searchQuery.trim().toLowerCase();

    final filteredJobs = _jobs.where((job) {
      final title = _value(job, ['title', 'job_title']);

      final company = _value(
        job,
        ['companyName', 'company_name', 'company'],
      );

      return title.toLowerCase().contains(query) ||
          company.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: widget.showBackButton
            ? IconButton(
                tooltip: 'Back',
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: _textDark,
                ),
              )
            : null,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Saved Jobs',
          style: TextStyle(
            color: _textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadJobs,
            icon: const Icon(Icons.refresh_rounded),
            color: _primaryBlue,
            tooltip: 'Refresh',
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
                decoration: InputDecoration(
                  hintText: 'Search saved jobs...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _buildBody(filteredJobs),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    List<Map<String, dynamic>> filteredJobs,
  ) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: _primaryBlue,
        ),
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
              const Text(
                'Could not load saved jobs',
                style: TextStyle(
                  color: _textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _textMuted,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadJobs,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_jobs.isEmpty) {
      return _emptyState(
        icon: Icons.bookmark_border_rounded,
        title: 'No saved jobs yet',
        message: 'Jobs you bookmark will appear here.',
      );
    }

    if (filteredJobs.isEmpty) {
      return _emptyState(
        icon: Icons.search_off_rounded,
        title: 'No jobs found',
        message: 'Try searching with another keyword.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadJobs,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: filteredJobs.length,
        separatorBuilder: (context, index) {
          return const SizedBox(height: 12);
        },
        itemBuilder: (context, index) {
          final job = filteredJobs[index];

          final title = _value(
            job,
            ['title', 'job_title'],
            fallback: 'Untitled job',
          );

          final company = _value(
            job,
            ['companyName', 'company_name', 'company'],
            fallback: 'Company not specified',
          );

          final location = _value(
            job,
            ['location', 'candidate_required_location'],
            fallback: 'Location not specified',
          );

          final logoUrl = _value(
            job,
            ['logoUrl', 'company_logo', 'logo_url', 'logo'],
          );

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.035),
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
                    color: const Color(0xFFEDF1FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: logoUrl.isEmpty
                      ? const Icon(
                          Icons.business_rounded,
                          color: _primaryBlue,
                          size: 27,
                        )
                      : Image.network(
                          logoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.business_rounded,
                              color: _primaryBlue,
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
                        style: const TextStyle(
                          color: _textDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        company,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _textMuted,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 15,
                            color: _textMuted,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _textMuted,
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
                  tooltip: 'Remove saved job',
                  onPressed: () => _removeJob(job),
                  icon: const Icon(
                    Icons.bookmark_remove_rounded,
                  ),
                  color: _primaryBlue,
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 68,
              color: const Color(0xFFB8C5F9),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: _textDark,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}