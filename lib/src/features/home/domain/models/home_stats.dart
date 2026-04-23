/// Model for home screen statistics (job openings count, etc.)
class HomeStats {
  final int totalJobOpenings;
  final int newJobsToday;
  final int companiesHiring;
  final int applicationsProcessed;
  final DateTime? lastUpdated;

  const HomeStats({
    required this.totalJobOpenings,
    this.newJobsToday = 0,
    this.companiesHiring = 0,
    this.applicationsProcessed = 0,
    this.lastUpdated,
  });

  /// Create from JSON
  factory HomeStats.fromJson(Map<String, dynamic> json) {
    return HomeStats(
      totalJobOpenings: json['totalJobOpenings'] ??
                       json['total_job_openings'] ??
                       json['total'] ??
                       0,
      newJobsToday: json['newJobsToday'] ??
                   json['new_jobs_today'] ??
                   json['new_today'] ??
                   0,
      companiesHiring: json['companiesHiring'] ??
                      json['companies_hiring'] ??
                      json['companies'] ??
                      0,
      applicationsProcessed: json['applicationsProcessed'] ??
                            json['applications_processed'] ??
                            0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'].toString())
          : json['last_updated'] != null
              ? DateTime.parse(json['last_updated'].toString())
              : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'totalJobOpenings': totalJobOpenings,
      'newJobsToday': newJobsToday,
      'companiesHiring': companiesHiring,
      'applicationsProcessed': applicationsProcessed,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  HomeStats copyWith({
    int? totalJobOpenings,
    int? newJobsToday,
    int? companiesHiring,
    int? applicationsProcessed,
    DateTime? lastUpdated,
  }) {
    return HomeStats(
      totalJobOpenings: totalJobOpenings ?? this.totalJobOpenings,
      newJobsToday: newJobsToday ?? this.newJobsToday,
      companiesHiring: companiesHiring ?? this.companiesHiring,
      applicationsProcessed: applicationsProcessed ?? this.applicationsProcessed,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Create default stats for fallback
  factory HomeStats.defaultStats() {
    return HomeStats(
      totalJobOpenings: 3000,
      newJobsToday: 25,
      companiesHiring: 150,
      applicationsProcessed: 5000,
      lastUpdated: DateTime.now(),
    );
  }

  /// Format total job openings for display (e.g., "3000+", "5K+")
  String get formattedTotal {
    if (totalJobOpenings >= 10000) {
      return '${(totalJobOpenings / 1000).floor()}K+';
    } else if (totalJobOpenings >= 1000) {
      return '${(totalJobOpenings / 1000).toStringAsFixed(1)}K+';
    } else {
      return '$totalJobOpenings+';
    }
  }

  @override
  String toString() {
    return 'HomeStats(totalJobOpenings: $totalJobOpenings, newJobsToday: $newJobsToday, companiesHiring: $companiesHiring)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HomeStats &&
        other.totalJobOpenings == totalJobOpenings &&
        other.newJobsToday == newJobsToday &&
        other.companiesHiring == companiesHiring &&
        other.applicationsProcessed == applicationsProcessed;
  }

  @override
  int get hashCode {
    return Object.hash(
      totalJobOpenings,
      newJobsToday,
      companiesHiring,
      applicationsProcessed,
    );
  }
}
