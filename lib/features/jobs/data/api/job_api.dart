import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/job_model.dart';

class JobApi {
  static const String _baseUrl = 'https://remotive.com/api/remote-jobs';

  final http.Client _client;

  JobApi({http.Client? client}) : _client = client ?? http.Client();

  Future<List<JobModel>> getJobs({
    String search = '',
    int limit = 20,
  }) async {
    final queryParameters = <String, String>{
      'limit': limit.toString(),
      if (search.trim().isNotEmpty) 'search': search.trim(),
    };

    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: queryParameters,
    );

    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load jobs. Status: ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid jobs response.');
      }

      final jobsJson = decoded['jobs'];

      if (jobsJson is! List) {
        throw const FormatException('Jobs list not found.');
      }

      return jobsJson
          .whereType<Map<String, dynamic>>()
          .map(JobModel.fromJson)
          .toList();
    } catch (e) {
      throw Exception('Unable to fetch jobs: $e');
    }
  }

  Future<JobModel?> getJobById(String id) async {
    final jobs = await getJobs(limit: 100);

    for (final job in jobs) {
      if (job.id == id) {
        return job;
      }
    }

    return null;
  }

  void dispose() {
    _client.close();
  }
}