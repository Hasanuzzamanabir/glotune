class ContentCreator {
  final int author;
  final String? creatorUsername;
  final String creatorEmail;
  final String talentType;
  final String companyType;
  final DateTime managementStartDate;
  final String managementType;
  final String addComments;
  final String? attachment;

  ContentCreator({
    required this.author,
    this.creatorUsername,
    required this.creatorEmail,
    required this.talentType,
    required this.companyType,
    required this.managementStartDate,
    required this.managementType,
    required this.addComments,
    this.attachment,
  });

  factory ContentCreator.fromJson(Map<String, dynamic> json) {
    return ContentCreator(
      author: json['author'] as int,
      creatorUsername: json['creator_username']?.toString(),
      creatorEmail: json['creator_email']?.toString() ?? '',
      talentType: json['talent_type']?.toString() ?? '',
      companyType: json['company_type']?.toString() ?? '',
      managementStartDate: DateTime.parse(json['management_start_date']),
      managementType: json['management_type']?.toString() ?? '',
      addComments: json['add_comments']?.toString() ?? '',
      attachment: json['attachment']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'author': author,
      'creator_username': creatorUsername,
      'creator_email': creatorEmail,
      'talent_type': talentType,
      'company_type': companyType,
      'management_start_date': managementStartDate.toIso8601String(),
      'management_type': managementType,
      'add_comments': addComments,
      'attachment': attachment,
    };
  }
}
