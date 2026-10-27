import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedJobsService {
  static const String _storageKey = 'saved_jobs';

  // متابعة أي تغيير في الوظائف المحفوظة.
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  // جلب الوظائف المحفوظة.
  Future<List<Map<String, dynamic>>> getSavedJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getStringList(_storageKey) ?? [];

    return savedData.map((item) {
      final decoded = jsonDecode(item);

      return Map<String, dynamic>.from(decoded as Map);
    }).toList();
  }

  // التحقق من حالة حفظ الوظيفة.
  Future<bool> isSaved(String jobId) async {
    final jobs = await getSavedJobs();

    return jobs.any(
      (job) => job['id']?.toString() == jobId,
    );
  }

  // حفظ الوظيفة.
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

    jobs.add(job);

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

    // تحديث الكروت وشاشة المحفوظات.
    changes.value++;
  }

  // إزالة الوظيفة.
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

    // إبلاغ باقي الشاشات بالتغيير.
    changes.value++;
  }
}