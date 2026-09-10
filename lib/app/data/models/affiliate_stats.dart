class AffiliateStats {
  final bool isActive;
  final String? planStatus;
  final String commissionEarned;
  final int referralsCount;
  final List<AffiliateTableItem> affiliateTable;

  AffiliateStats({
    required this.isActive,
    this.planStatus,
    required this.commissionEarned,
    required this.referralsCount,
    required this.affiliateTable,
  });

  factory AffiliateStats.fromJson(Map<String, dynamic> json) {
    var list = json['affiliate_table'] as List? ?? [];
    List<AffiliateTableItem> tableList =
        list.map((i) => AffiliateTableItem.fromJson(i)).toList();

    return AffiliateStats(
      isActive: json['is_active'] ?? false,
      planStatus: json['plan_status'],
      commissionEarned: json['commission_earned']?.toString() ?? '0.00',
      referralsCount: json['referrals_count'] ?? 0,
      affiliateTable: tableList,
    );
  }
}

class AffiliateTableItem {
  final int id;
  final String companyName;
  final String campaignName;
  final String commission;

  AffiliateTableItem({
    required this.id,
    required this.companyName,
    required this.campaignName,
    required this.commission,
  });

  factory AffiliateTableItem.fromJson(Map<String, dynamic> json) {
    return AffiliateTableItem(
      id: json['id'] ?? 0,
      companyName: json['company_name'] ?? 'Unknown',
      campaignName: json['campaign_name'] ?? 'Unknown',
      commission: json['commission']?.toString() ?? '0.00',
    );
  }
}
