class JobModel {
  final String id;
  final String title;
  final String companyName;
  final String location;
  final String description;
  final String jobType;
  final String? salary;
  final String? logoUrl;
  final String? category;
  final String? jobUrl;

  const JobModel({
    required this.id,
    required this.title,
    required this.companyName,
    required this.location,
    required this.description,
    required this.jobType,
    this.salary,
    this.logoUrl,
    this.category,
    this.jobUrl,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: (json['id'] ?? json['job_id'] ?? '').toString(),
      title: (json['title'] ?? 'Untitled job').toString(),
      companyName: (
        json['company_name'] ??
        json['company'] ??
        ''
      ).toString(),
      location: (
        json['candidate_required_location'] ??
        json['location'] ??
        'Remote'
      ).toString(),
      description: (json['description'] ?? '').toString(),
      jobType: (
        json['job_type'] ??
        json['employment_type'] ??
        'Not specified'
      ).toString(),
      salary: _optionalString(json['salary']),
      logoUrl: _optionalString(
        json['company_logo'] ??
        json['logo_url'] ??
        json['logo'],
      ),
      category: _optionalString(json['category']),
      jobUrl: _optionalString(json['url']),
    );
  }

  static String? _optionalString(dynamic value) {
    if (value == null) return null;

    final result = value.toString().trim();
    return result.isEmpty ? null : result;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company_name': companyName,
      'candidate_required_location': location,
      'description': description,
      'job_type': jobType,
      'salary': salary,
      'company_logo': logoUrl,
      'category': category,
      'url': jobUrl,
    };
  }
}