import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:job_finder/core/routes/theme/locale_controller.dart';
import 'package:job_finder/features/jobs/data/api/job_api.dart';

import '../../view_model/home_cubit.dart';
import '../../view_model/home_state.dart';
import '../widget/job_card.dart';
import 'job_details_screen.dart';

const Color _primaryBlue = Color(0xFF2457D6);

class HomeScreen extends StatelessWidget {
final HomeCubit Function()? createCubit;

const HomeScreen({
super.key,
this.createCubit,
});

@override
Widget build(BuildContext context) {
return BlocProvider(
create: (_) =>
(createCubit ?? () => HomeCubit(JobApi()))()..fetchJobs(),
child: const _HomeView(),
);
}
}

class _HomeView extends StatefulWidget {
const _HomeView();

@override
State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
String? _selectedCategory;

bool get _isArabic =>
LocaleController.instance.locale.languageCode == 'ar';

String _text(String english, String arabic) {
return _isArabic ? arabic : english;
}

void _selectCategory(String category) {
setState(() {
_selectedCategory = category;
});
context.read<HomeCubit>().fetchJobs(category: category);
}

void _clearCategory() {
setState(() {
_selectedCategory = null;
});
context.read<HomeCubit>().fetchJobs();
}

String _categoryTitle(String category) {
switch (category) {
case 'design':
return _text('Design jobs', 'وظائف التصميم');
case 'technology':
return _text('Technology jobs', 'وظائف التكنولوجيا');
case 'marketing':
return _text('Marketing jobs', 'وظائف التسويق');
case 'finance':
return _text('Finance jobs', 'وظائف المالية');
default:
return _text('Recommended for you', 'وظائف مقترحة لك');
}
}

@override
Widget build(BuildContext context) {
return AnimatedBuilder(
animation: LocaleController.instance,
builder: (context, child) {
final theme = Theme.of(context);
final colors = theme.colorScheme;
    final textDark = colors.onSurface;
    final textMuted = colors.onSurfaceVariant;
    final surfaceColor = theme.cardColor;
    final borderColor = theme.dividerColor;

    return Directionality(
      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
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
                              _text(
                                'Good morning, Alex 👋',
                                'صباح الخير، Alex 👋',
                              ),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: textDark,
                                fontWeight: FontWeight.w800,
                                fontSize: 23,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              _text(
                                "Find a role you'll love.",
                                'اعثر على الوظيفة التي تحبها.',
                              ),
                              style: TextStyle(
                                color: textMuted,
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
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: borderColor),
                        ),
                        child: IconButton(
                          tooltip: _text('Notifications', 'الإشعارات'),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _text(
                                    'Notifications coming soon.',
                                    'الإشعارات ستكون متاحة قريبًا.',
                                  ),
                                ),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.notifications_none_rounded,
                            color: textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Search shortcut
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                sliver: SliverToBoxAdapter(
                  child: Material(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _text(
                                'Open the Search tab to find jobs.',
                                'افتح تبويب البحث للعثور على الوظائف.',
                              ),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search_rounded,
                              color: textMuted,
                              size: 23,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _text(
                                  'Job title, skill, or company',
                                  'المسمى الوظيفي أو المهارة أو الشركة',
                                ),
                                style: TextStyle(
                                  color: textMuted,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Popular categories
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: _SectionHeader(
                    title: _text(
                      'Popular categories',
                      'التصنيفات الشائعة',
                    ),
                    action: _text('See all', 'عرض الكل'),
                    onAction: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _text(
                              'Choose a category to view related jobs.',
                              'اختر تصنيفًا لعرض الوظائف المتعلقة به.',
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(
                        child: _CategoryCard(
                          title: _text('Design', 'التصميم'),
                          icon: Icons.auto_awesome_rounded,
                          selected: _selectedCategory == 'design',
                          onTap: () => _selectCategory('design'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _CategoryCard(
                          title: _text('Technology', 'التكنولوجيا'),
                          icon: Icons.code_rounded,
                          selected: _selectedCategory == 'technology',
                          onTap: () => _selectCategory('software'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _CategoryCard(
                          title: _text('Marketing', 'التسويق'),
                          icon: Icons.campaign_outlined,
                          selected: _selectedCategory == 'marketing',
                          onTap: () => _selectCategory('marketing'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _CategoryCard(
                          title: _text('Finance', 'المالية'),
                          icon: Icons.account_balance_wallet_outlined,
                          selected: _selectedCategory == 'finance',
                          onTap: () => _selectCategory('finance'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Jobs section title
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedCategory == null
                              ? _text(
                                  'Recommended for you',
                                  'وظائف مقترحة لك',
                                )
                              : _categoryTitle(_selectedCategory!),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: textDark,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      if (_selectedCategory != null)
                        TextButton(
                          onPressed: _clearCategory,
                          child: Text(
                            _text('Show all', 'عرض الكل'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Jobs list
              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state.status == HomeStatus.initial ||
                      state.status == HomeStatus.loading) {
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
                          message: state.errorMessage ??
                              _text(
                                'Unable to load jobs.',
                                'تعذر تحميل الوظائف.',
                              ),
                          retryText: _text('Try again', 'إعادة المحاولة'),
                          onRetry: () {
                            context.read<HomeCubit>().fetchJobs(
                                  category: _selectedCategory,
                                );
                          },
                        ),
                      ),
                    );
                  }

                  if (state.jobs.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            _text(
                              'No jobs found for this category.',
                              'لم يتم العثور على وظائف لهذا التصنيف.',
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: textDark),
                          ),
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

              // Career tip
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? const Color(0xFF202D4A)
                          : const Color(0xFF111A2E),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _text('CAREER TIP', 'نصيحة مهنية'),
                          style: const TextStyle(
                            color: Color(0xFF9DBAFF),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _text(
                            'A tailored profile gets noticed 2× more.',
                            'الملف الشخصي المميز يزيد فرص لفت الانتباه للضعف.',
                          ),
                          style: const TextStyle(
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
      ),
    );
  },
);
}
}

class _SectionHeader extends StatelessWidget {
final String title;
final String action;
final VoidCallback onAction;

const _SectionHeader({required this.title,required this.action,required this.onAction,});
@override
Widget build(BuildContext context) {
final theme = Theme.of(context);
return Row(
  children: [
    Expanded(
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w800,
          fontSize: 17,
        ),
      ),
    ),
    TextButton(
      onPressed: onAction,
      style: TextButton.styleFrom(
        foregroundColor: theme.colorScheme.primary,
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
final VoidCallback onTap;
final bool selected;

const _CategoryCard({required this.title,required this.icon,required this.onTap,this.selected = false,});
@override
Widget build(BuildContext context) {
final theme = Theme.of(context);
return Material(
  color: selected
      ? theme.colorScheme.primary.withValues(alpha: 0.10)
      : theme.cardColor,
  borderRadius: BorderRadius.circular(16),
  child: InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      height: 94,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected
              ? theme.colorScheme.primary
              : theme.dividerColor,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 23,
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);
}
}

class _ErrorPanel extends StatelessWidget {
final String message;
final String retryText;
final VoidCallback onRetry;

const _ErrorPanel({
required this.message,
required this.retryText,
required this.onRetry,
});

@override
Widget build(BuildContext context) {
final theme = Theme.of(context);

return Column(
  children: [
    Icon(
      Icons.cloud_off_outlined,
      color: theme.colorScheme.onSurfaceVariant,
      size: 42,
    ),
    const SizedBox(height: 10),
    Text(
      message,
      textAlign: TextAlign.center,
      style: TextStyle(color: theme.colorScheme.onSurface),
    ),
    const SizedBox(height: 12),
    ElevatedButton(
      onPressed: onRetry,
      child: Text(retryText),
    ),
  ],
);

}
}
