import '../../data/model/job_model.dart';

enum HomeStatus {
  initial,
  loading,
  success,
  failure,
}

class HomeState {
  final HomeStatus status;
  final List<JobModel> jobs;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.jobs = const [],
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<JobModel>? jobs,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      jobs: jobs ?? this.jobs,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}