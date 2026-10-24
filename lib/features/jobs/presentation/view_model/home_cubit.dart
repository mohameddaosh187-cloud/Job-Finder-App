import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/api/job_api.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final JobApi _jobApi;

  HomeCubit(this._jobApi) : super(const HomeState());

  Future<void> fetchJobs({String? search}) async {
    final query = search?.trim() ?? '';

    emit(
      state.copyWith(
        status: HomeStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      final jobs = await _jobApi.getJobs(
        search: query,
        limit: 50,
      );

      emit(
        state.copyWith(
          status: HomeStatus.success,
          jobs: jobs,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}