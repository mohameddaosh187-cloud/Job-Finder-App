import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../view_model/home_cubit.dart';
import '../../view_model/home_state.dart';
import '../widget/job_card.dart';
import 'job_details_screen.dart';

const Color _primaryBlue = Color(0xFF2457D6);
const Color _pageBackground = Color(0xFFF6F8FC);
const Color _textDark = Color(0xFF172033);
const Color _textMuted = Color(0xFF7B8497);

class HomeScreen extends StatelessWidget {
  final HomeCubit Function()? createCubit;

  const HomeScreen({
    super.key,
    this.createCubit,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => (createCubit ?? () => HomeCubit(context.read()))()..fetchJobs(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header Section
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good morning, Alex 👋',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: _textDark,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 23,
                                ),
                          ),
                          const SizedBox(height: 7),
                          const Text(
                            "Find a role you'll love.",
                            style: TextStyle(
                              color: _textMuted,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: IconButton(
                        tooltip: 'Notifications',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notifications coming soon.'),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          color: _textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search Field Placeholder
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              sliver: SliverToBoxAdapter(
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE8ECF3),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: _textMuted,
                        size: 23,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Job title, skill, or company',
                          style: TextStyle(
                            color: _textMuted,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Popular Categories
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'Popular categories',
                  action: 'See all',
                  onAction: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Categories coming soon.'),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 14, 20, 26),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: _CategoryCard(
                        title: 'Design',
                        icon: Icons.auto_awesome_rounded,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _CategoryCard(
                        title: 'Technology',
                        icon: Icons.code_rounded,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _CategoryCard(
                        title: 'Marketing',
                        icon: Icons.campaign_outlined,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _CategoryCard(
                        title: 'Finance',
                        icon: Icons.account_balance_wallet_outlined,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Recommended Jobs Heading
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'Recommended for you',
                  action: 'See all',
                  onAction: () {},
                ),
              ),
            ),

            // Jobs Stream / Cubit State
            BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                if (state.status == HomeStatus.initial || state.status == HomeStatus.loading) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: _primaryBlue,
                        ),
                      ),
                    ),
                  );
                }

                if (state.status == HomeStatus.failure) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _ErrorPanel(
                        message: state.errorMessage ?? 'Unable to load jobs.',
                        onRetry: () {
                          context.read<HomeCubit>().fetchJobs();
                        },
                      ),
                    ),
                  );
                }

                if (state.jobs.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text('No jobs found right now.'),
                      ),
                    ),
                  );
                }

                final jobs = state.jobs.take(5).toList();

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final job = jobs[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
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
                      childCount: jobs.length,
                    ),
                  ),
                );
              },
            ),

            // Career Tip Banner
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              sliver: SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111A2E),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CAREER TIP',
                        style: TextStyle(
                          color: Color(0xFF9DBAFF),
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'A tailored profile gets noticed 2× more.',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback onAction;

  const _SectionHeader({
    required this.title,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: _textDark,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
        ),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            foregroundColor: _primaryBlue,
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          child: Text(
            action,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;

  const _CategoryCard({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 94,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE9EDF5),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: _primaryBlue,
            size: 23,
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: const TextStyle(
                color: _textDark,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorPanel({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.cloud_off_outlined,
          color: _textMuted,
          size: 42,
        ),
        const SizedBox(height: 10),
        Text(
          message,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: onRetry,
          child: const Text('Try again'),
        ),
      ],
    );
  }
}