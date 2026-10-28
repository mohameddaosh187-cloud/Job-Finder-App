import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/api/job_api.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
final JobApi _jobApi;

int _latestRequestId = 0;

HomeCubit(this._jobApi) : super(const HomeState());

Future<void> fetchJobs({
String? search,
String? category,
}) async {
if (isClosed) return;
final requestId = ++_latestRequestId;
final query = search?.trim() ?? '';
final selectedCategory = category?.trim() ?? '';

emit(
  state.copyWith(
    status: HomeStatus.loading,
    errorMessage: null,
  ),
);

try {
  final jobs = await _jobApi.getJobs(
    search: query.isNotEmpty ? query : selectedCategory,
    limit: 50,
  );

  if (isClosed || requestId != _latestRequestId) {
    return;
  }

  emit(
    state.copyWith(
      status: HomeStatus.success,
      jobs: jobs,
      errorMessage: null,
    ),
  );
} catch (e) {
  if (isClosed || requestId != _latestRequestId) {
    return;
  }

  emit(
    state.copyWith(
      status: HomeStatus.failure,
      errorMessage: e.toString(),
    ),
  );
}
}
}
