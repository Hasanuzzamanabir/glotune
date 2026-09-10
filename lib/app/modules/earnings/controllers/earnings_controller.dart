import 'package:get/get.dart';

class EarningsController extends GetxController {
  final totalEarnings = 40000.00.obs;

  final recentEarnings = [
    {
      'category': 'Live gifts',
      'amount': 12140.00,
      'time': 'Today | 10:30 AM',
      'status': 'Pending',
    },
    {
      'category': 'Ad Revenue',
      'amount': 120.00,
      'time': 'Today | 10:30 AM',
      'status': 'Pending',
    },
    {
      'category': 'Tips',
      'amount': 39.00,
      'time': 'Today | 10:30 AM',
      'status': 'Pending',
    },
    {
      'category': 'Partnership program',
      'amount': 39.00,
      'time': 'Today | 10:30 AM',
      'status': 'Pending',
    },
    {
      'category': 'Watch Earnings',
      'amount': 750.00,
      'time': 'Today | 10:30 AM',
      'status': 'Pending',
    },
    {
      'category': 'Channel Membership',
      'amount': 300.00,
      'time': 'Today | 10:30 AM',
      'status': 'Pending',
    },
  ].obs;
  final earningDetails = {
    'Partnership program': [
      {
        'sectionTitle': 'Affiliate commission',
        'balance': 23.0,
        'columns': ['Affiliate Company', 'Date', 'Time', 'Commission'],
        'rows': [
          ['TechNova', '15/12/2025', '11:56 AM', '\$8'],
          ['StyleEra', '16/09/2025', '17:16 PM', '\$10'],
          ['FitLifeCo', '20/07/2025', '14:10 PM', '\$5'],
        ]
      },
      {
        'sectionTitle': 'Sponsorship deals',
        'balance': 1200.0,
        'columns': ['Sponsor', 'Date', 'Time', 'Amount Earned'],
        'rows': [
          ['Pepsi London', '15/12/2025', '11:56 AM', '\$800'],
          ['Nike New York', '16/09/2025', '17:16 PM', '\$100'],
          ['Ewa Beauty', '20/07/2025', '14:10 PM', '\$500'],
        ]
      }
    ],
    'Live gifts': [
      {
        'sectionTitle': 'Recent gifts',
        'balance': 12140.0,
        'columns': ['Sender', 'Gift', 'Date', 'Amount'],
        'rows': [
          ['@user123', 'Rose', 'Today', '\$10'],
          ['@fan456', 'Diamond', 'Today', '\$50'],
          ['@cool_guy', 'Car', 'Yesterday', '\$100'],
        ]
      }
    ],
    'Ad Revenue': [
      {
        'sectionTitle': 'Video Ads',
        'balance': 80.0,
        'columns': ['Video Title', 'Views', 'Date', 'Revenue'],
        'rows': [
          ['My Vlog 1', '10.5K', 'Today', '\$50'],
          ['Setup Tour', '5K', 'Yesterday', '\$30'],
        ]
      },
      {
        'sectionTitle': 'Banner Ads',
        'balance': 40.0,
        'columns': ['Placement', 'Clicks', 'Date', 'Revenue'],
        'rows': [
          ['Homepage', '150', 'Today', '\$25'],
          ['Profile', '90', 'Yesterday', '\$15'],
        ]
      }
    ],
    'Tips': [
      {
        'sectionTitle': 'Direct Tips',
        'balance': 39.0,
        'columns': ['Supporter', 'Message', 'Date', 'Amount'],
        'rows': [
          ['@alice', 'Keep it up!', 'Today', '\$9'],
          ['@bob', 'Great content', 'Today', '\$10'],
          ['@charlie', 'Thanks!', 'Yesterday', '\$20'],
        ]
      }
    ],
    'Watch Earnings': [
      {
        'sectionTitle': 'Premium Views',
        'balance': 750.0,
        'columns': ['Video', 'Watch Time', 'Date', 'Earned'],
        'rows': [
          ['Review 2025', '500 hrs', 'Today', '\$450'],
          ['Unboxing', '300 hrs', 'Yesterday', '\$300'],
        ]
      }
    ],
    'Channel Membership': [
      {
        'sectionTitle': 'New Members',
        'balance': 300.0,
        'columns': ['Member', 'Tier', 'Date', 'Amount'],
        'rows': [
          ['@john_doe', 'Gold', 'Today', '\$100'],
          ['@sarah_m', 'Silver', 'Today', '\$50'],
          ['@mike_w', 'Gold', 'Yesterday', '\$100'],
          ['@emily_r', 'Silver', 'Yesterday', '\$50'],
        ]
      }
    ]
  };

  void withdraw() {
    // Logic for withdrawal
  }

  void refreshEarnings() {
    // Logic for refreshing earnings
  }
}
