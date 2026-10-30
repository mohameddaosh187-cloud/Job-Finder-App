import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:job_finder/core/theme/locale_controller.dart';

import '../../../data/api/job_api.dart';
import '../../view_model/home_cubit.dart';
import '../../view_model/home_state.dart';
import '../widget/job_card.dart';
import 'job_details_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(JobApi())..fetchJobs(),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;
  String _query = '';

  static const Color primaryBlue = Color(0xFF385CF2);

  bool get _isArabic => LocaleController.instance.locale.languageCode == 'ar';

  String _text(String english, String arabic) {
    return _isArabic ? arabic : english;
  }

  @override
  void initState() {
    super.initState();
    LocaleController.instance.addListener(_onLocaleChanged);
  }

  void _onLocaleChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    setState(() {
      _query = value.trim();
    });

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      context.read<HomeCubit>().fetchJobs(search: _query);
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();

    setState(() {
      _query = '';
    });

    context.read<HomeCubit>().fetchJobs();
  }

  void _submitSearch(String value) {
    _debounce?.cancel();

    setState(() {
      _query = value.trim();
    });

    context.read<HomeCubit>().fetchJobs(search: _query);
  }

  @override
  void dispose() {
    LocaleController.instance.removeListener(_onLocaleChanged);
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final backgroundColor = theme.scaffoldBackgroundColor;
    final surfaceColor = theme.cardColor;
    final textColor = colors.onSurface;
    final mutedColor = colors.onSurfaceVariant;
    final borderColor = theme.dividerColor;

    return Directionality(
      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor ?? backgroundColor,
          foregroundColor: textColor,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            _text('Search Jobs', 'البحث عن وظائف'),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    onSubmitted: _submitSearch,
                    textInputAction: TextInputAction.search,
                    textAlign: TextAlign.start,
                    style: TextStyle(color: textColor, fontSize: 14),
                    cursorColor: primaryBlue,
                    decoration: InputDecoration(
                      hintText: _text(
                        'Job title, skill, or company',
                        'المسمى الوظيفي أو المهارة أو الشركة',
                      ),
                      hintStyle: TextStyle(color: mutedColor, fontSize: 14),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: primaryBlue,
                      ),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: _text('Clear search', 'مسح البحث'),
                              onPressed: _clearSearch,
                              icon: Icon(
                                Icons.close_rounded,
                                color: mutedColor,
                              ),
                            ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 17),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder<HomeCubit, HomeState>(
                  builder: (context, state) {
                    if (state.status == HomeStatus.initial ||
                        state.status == HomeStatus.loading) {
                      return const Center(
                        child: CircularProgressIndicator(color: primaryBlue),
                      );
                    }

                    if (state.status == HomeStatus.failure) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.cloud_off_outlined,
                                size: 48,
                                color: mutedColor,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _text(
                                  'Could not load jobs',
                                  'تعذر تحميل الوظائف',
                                ),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                state.errorMessage ??
                                    _text(
                                      'Please check your connection and try again.',
                                      'تأكد من اتصالك بالإنترنت وحاول مرة أخرى.',
                                    ),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: mutedColor),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<HomeCubit>().fetchJobs(
                                    search: _query,
                                  );
                                },
                                child: Text(
                                  _text('Try again', 'إعادة المحاولة'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final jobs = state.jobs;

                    if (jobs.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 54,
                                color: mutedColor,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                _query.isEmpty
                                    ? _text(
                                        'No jobs available right now',
                                        'لا توجد وظائف متاحة حاليًا',
                                      )
                                    : _text(
                                        'No jobs found for "$_query"',
                                        'لم يتم العثور على وظائف تطابق "$_query"',
                                      ),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _text(
                                  'Try another job title, skill, or company.',
                                  'جرّب البحث باسم وظيفة أو مهارة أو شركة أخرى.',
                                ),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: mutedColor),
                              ),
                              if (_query.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: _clearSearch,
                                  child: Text(
                                    _text('Clear search', 'مسح البحث'),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                          child: Text(
                            _query.isEmpty
                                ? _text('Recommended jobs', 'وظائف مقترحة')
                                : _text('Search results', 'نتائج البحث'),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                              color: textColor,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            itemCount: jobs.length,
                            itemBuilder: (context, index) {
                              final job = jobs[index];

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: JobCard(
                                  job: job,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            JobDetailsScreen(job: job),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
