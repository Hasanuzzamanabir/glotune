class Campaign {
  final int id;
  final String title;
  final String campaignStatus;
  final String startTime;
  final String endTime;
  final String campaignCost;
  final String paymentMethod;
  final String? frequency;
  final String campaignType;
  final String? creatorName;
  final String? createdAt;
  final String? updatedAt;
  final CampaignAnalytics? analytics;

  Campaign({
    required this.id,
    required this.title,
    required this.campaignStatus,
    required this.startTime,
    required this.endTime,
    required this.campaignCost,
    required this.paymentMethod,
    this.frequency,
    required this.campaignType,
    this.creatorName,
    this.createdAt,
    this.updatedAt,
    this.analytics,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      campaignStatus: json['campaign_status'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      campaignCost: json['campain_cost']?.toString() ?? '0.0', // Handled typo in backend
      paymentMethod: json['paytment_method'] ?? '', // Handled typo in backend
      frequency: json['frequency'],
      campaignType: json['campaign_type'] ?? '',
      creatorName: json['creator_name'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      analytics: json['analytics'] != null ? CampaignAnalytics.fromJson(json['analytics']) : null,
    );
  }
}

class CampaignAnalytics {
  final int id;
  final int impressions;
  final int clicks;
  final int conversions;
  final String revenue;
  final int reach;
  final String? ctr;
  final String? roi;
  final String? conversionRate;

  CampaignAnalytics({
    required this.id,
    required this.impressions,
    required this.clicks,
    required this.conversions,
    required this.revenue,
    required this.reach,
    this.ctr,
    this.roi,
    this.conversionRate,
  });

  factory CampaignAnalytics.fromJson(Map<String, dynamic> json) {
    return CampaignAnalytics(
      id: json['id'] ?? 0,
      impressions: json['impressions'] ?? 0,
      clicks: json['clicks'] ?? 0,
      conversions: json['conversions'] ?? 0,
      revenue: json['revenue']?.toString() ?? '0.0',
      reach: json['reach'] ?? 0,
      ctr: json['ctr']?.toString(),
      roi: json['roi']?.toString(),
      conversionRate: json['conversion_rate']?.toString(),
    );
  }
}
