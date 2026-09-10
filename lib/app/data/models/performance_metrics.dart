class PerformanceMetrics {
  final int totalClicks;
  final String totalConversions;
  final String commissionEarned;
  final double earningPerClicks;
  final double ctr;
  final String totalPayouts;
  final List<PerformanceMetricItem> detailsTable;

  PerformanceMetrics({
    required this.totalClicks,
    required this.totalConversions,
    required this.commissionEarned,
    required this.earningPerClicks,
    required this.ctr,
    required this.totalPayouts,
    required this.detailsTable,
  });

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) {
    var list = json['details_table'] as List? ?? [];
    List<PerformanceMetricItem> detailsList =
        list.map((i) => PerformanceMetricItem.fromJson(i)).toList();

    return PerformanceMetrics(
      totalClicks: json['total_clicks'] ?? 0,
      totalConversions: json['total_conversions']?.toString() ?? '0',
      commissionEarned: json['commission_earned']?.toString() ?? '0.00',
      earningPerClicks: (json['earning_per_clicks'] ?? 0.0).toDouble(),
      ctr: (json['ctr'] ?? 0.0).toDouble(),
      totalPayouts: json['total_payouts']?.toString() ?? '0.00',
      detailsTable: detailsList,
    );
  }
}

class PerformanceMetricItem {
  final int contentId;
  final String title;
  final int clicks;
  final int conversions;
  final String commissionEarned;

  PerformanceMetricItem({
    required this.contentId,
    required this.title,
    required this.clicks,
    required this.conversions,
    required this.commissionEarned,
  });

  factory PerformanceMetricItem.fromJson(Map<String, dynamic> json) {
    return PerformanceMetricItem(
      contentId: json['content_id'] ?? 0,
      title: json['title'] ?? '',
      clicks: json['clicks'] ?? 0,
      conversions: json['conversions'] ?? 0,
      commissionEarned: json['commission_earned']?.toString() ?? '0.00',
    );
  }
}
