import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  static const Color primaryBlue = Color(0xFF2457D6);
  static const Color pageBackground = Color(0xFFF6F8FC);

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    setState(() {
      _query = value.trim();
    });

    _debounce = Timer(
      const Duration(milliseconds: 500),
      () {
        if (!mounted) return;

        // تم تصحيح النداء هنا بإضافة "search:"
        context.read<HomeCubit>().fetchJobs(
              search: _query,
            );
      },
    );
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();

    setState(() {
      _query = '';
    });

    context.read<HomeCubit>().fetchJobs();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: pageBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'Search Jobs',
          style: TextStyle(
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE3E8F2),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) {
                    _debounce?.cancel();
                    setState(() {
                      _query = value.trim();
                    });
                    context.read<HomeCubit>().fetchJobs(
                          search: value.trim(),
                        );
                  },
                  decoration: InputDecoration(
                    hintText: 'Job title, skill, or company',
                    hintStyle: const TextStyle(
                      color: Color(0xFF929BAD),
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: primaryBlue,
                    ),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: _clearSearch,
                            icon: const Icon(Icons.close_rounded),
                          ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 17,
                    ),
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
                      child: CircularProgressIndicator(
                        color: primaryBlue,
                      ),
                    );
                  }

                  if (state.status == HomeStatus.failure) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cloud_off_outlined,
                              size: 48,
                              color: Color(0xFF929BAD),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Could not load jobs',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.errorMessage ??
                                  'Please check your connection and try again.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<HomeCubit>().fetchJobs(
                                      search: _query,
                                    );
                              },
                              child: const Text('Try again'),
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
                            const Icon(
                              Icons.search_off_rounded,
                              size: 54,
                              color: Color(0xFF929BAD),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _query.isEmpty
                                  ? 'No jobs available right now'
                                  : 'No jobs found for "$_query"',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Try another job title, skill, or company.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF7B8497),
                              ),
                            ),
                            if (_query.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: _clearSearch,
                                child: const Text('Clear search'),
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
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          0,
                          20,
                          12,
                        ),
                        child: Text(
                          _query.isEmpty
                              ? 'Recommended jobs'
                              : 'Search results',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            color: Color(0xFF172033),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            20,
                            0,
                            20,
                            20,
                          ),
                          itemCount: jobs.length,
                          itemBuilder: (context, index) {
                            final job = jobs[index];

                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: 14,
                              ),
                              child: JobCard(
                                job: job,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => JobDetailsScreen(
                                        job: job,
                                      ),
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
    );
  }
}