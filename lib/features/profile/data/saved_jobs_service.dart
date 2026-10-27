import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedJobsService {
  static const String _storageKey = 'saved_jobs';

  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  Future<List<Map<String, dynamic>>> getSavedJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getStringList(_storageKey) ?? [];

    final List<Map<String, dynamic>> jobs = [];

    for (final item in savedData) {
      try {
        final decoded = jsonDecode(item);

        if (decoded is Map) {
          jobs.add(Map<String, dynamic>.from(decoded));
        }
      } catch (_) {
        continue;
      }
    }

    return jobs;
  }

  Future<bool> isSaved(String jobId) async {
    final jobs = await getSavedJobs();

    return jobs.any(
      (job) => job['id']?.toString() == jobId,
    );
  }

  Future<void> saveJob(Map<String, dynamic> job) async {
    final jobId = job['id']?.toString();

    if (jobId == null || jobId.trim().isEmpty) {
      throw ArgumentError('The job must have a valid id.');
    }

    final prefs = await SharedPreferences.getInstance();
    final jobs = await getSavedJobs();

    final alreadySaved = jobs.any(
      (savedJob) => savedJob['id']?.toString() == jobId,
    );

    if (alreadySaved) return;

    jobs.add(Map<String, dynamic>.from(job));

    final savedData = jobs
        .map((item) => jsonEncode(item))
        .toList();

    final success = await prefs.setStringList(
      _storageKey,
      savedData,
    );

    if (!success) {
      throw Exception('Failed to save job.');
    }

    changes.value++;
  }

  Future<void> removeJob(String jobId) async {
    final prefs = await SharedPreferences.getInstance();
    final jobs = await getSavedJobs();
    final oldLength = jobs.length;

    jobs.removeWhere(
      (job) => job['id']?.toString() == jobId,
    );

    if (jobs.length == oldLength) return;

    final savedData = jobs
        .map((item) => jsonEncode(item))
        .toList();

    final success = await prefs.setStringList(
      _storageKey,
      savedData,
    );

    if (!success) {
      throw Exception('Failed to remove saved job.');
    }

    changes.value++;
  }
}
