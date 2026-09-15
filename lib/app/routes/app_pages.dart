import 'package:get/get.dart';

import '../modules/active_listings/bindings/active_listings_binding.dart';
import '../modules/active_listings/views/active_listings_view.dart';
import '../modules/add_creator/bindings/add_creator_binding.dart';
import '../modules/add_creator/views/add_creator_view.dart';
import '../modules/add_new_product/bindings/add_new_product_binding.dart';
import '../modules/add_new_product/views/add_new_product_view.dart';
import '../modules/ads_campaign/bindings/ads_campaign_binding.dart';
import '../modules/ads_campaign/views/ads_campaign_view.dart';
import '../modules/affiliate_program/bindings/affiliate_program_binding.dart';
import '../modules/affiliate_program/views/affiliate_program_view.dart';
import '../modules/affiliate_tools/bindings/affiliate_tools_binding.dart';
import '../modules/affiliate_tools/views/affiliate_tools_view.dart';
import '../modules/auth/create_password/bindings/create_password_binding.dart';
import '../modules/auth/create_password/views/create_password_view.dart';
import '../modules/auth/forgot_password/bindings/forgot_password_binding.dart';
import '../modules/auth/forgot_password/views/forgot_password_view.dart';
import '../modules/auth/login/bindings/login_binding.dart';
import '../modules/auth/login/views/login_view.dart';
import '../modules/auth/login_options/bindings/login_options_binding.dart';
import '../modules/auth/login_options/views/login_options_view.dart';
import '../modules/auth/onboarding/bindings/onboarding_binding.dart';
import '../modules/auth/onboarding/views/onboarding_view.dart';
import '../modules/auth/otp/bindings/otp_binding.dart';
import '../modules/auth/otp/views/otp_view.dart';
import '../modules/auth/register/bindings/register_binding.dart';
import '../modules/auth/register/views/register_view.dart';
import '../modules/auth/success/bindings/success_binding.dart';
import '../modules/auth/success/views/success_view.dart';
import '../modules/become_partner/bindings/become_partner_binding.dart';
import '../modules/become_partner/views/become_partner_view.dart';
import '../modules/campaign_management/bindings/campaign_management_binding.dart';
import '../modules/campaign_management/views/campaign_management_view.dart';
import '../modules/chat/bindings/chat_binding.dart';
import '../modules/chat/views/chat_view.dart';
import '../modules/comments_made/bindings/comments_made_binding.dart';
import '../modules/comments_made/views/comments_made_view.dart';
import '../modules/community/bindings/community_binding.dart';
import '../modules/community/views/community_view.dart';
import '../modules/competition_form/bindings/competition_form_binding.dart';
import '../modules/competition_form/views/competition_form_view.dart';
import '../modules/content_creator_profile/bindings/content_creator_profile_binding.dart';
import '../modules/content_creator_profile/views/content_creator_profile_view.dart';
import '../modules/create/bindings/create_binding.dart';
import '../modules/create/views/create_view.dart';
import '../modules/create_deal/bindings/create_deal_binding.dart';
import '../modules/create_deal/views/create_deal_view.dart';
import '../modules/create_group/bindings/create_group_binding.dart';
import '../modules/create_group/views/create_group_view.dart';
import '../modules/create_new_campaign/bindings/create_new_campaign_binding.dart';
import '../modules/create_new_campaign/views/create_new_campaign_view.dart';
import '../modules/create_proposal/bindings/create_proposal_binding.dart';
import '../modules/create_proposal/views/create_proposal_view.dart';
import '../modules/creator_channel/bindings/creator_channel_binding.dart';
import '../modules/creator_channel/views/creator_channel_view.dart';
import '../modules/creator_deals/bindings/creator_deals_binding.dart';
import '../modules/creator_deals/views/creator_deals_view.dart';
import '../modules/customize_membership/bindings/customize_membership_binding.dart';
import '../modules/customize_membership/views/customize_membership_view.dart';
import '../modules/deals_management/bindings/deals_management_binding.dart';
import '../modules/deals_management/views/deals_management_view.dart';
import '../modules/donations/bindings/donations_binding.dart';
import '../modules/donations/views/donations_view.dart';
import '../modules/downloads/bindings/downloads_binding.dart';
import '../modules/downloads/views/downloads_view.dart';
import '../modules/earnings/bindings/earnings_binding.dart';
import '../modules/earnings/views/earnings_view.dart';
import '../modules/engagement_history/bindings/engagement_history_binding.dart';
import '../modules/engagement_history/views/engagement_history_view.dart';
import '../modules/favorite_videos/bindings/favorite_videos_binding.dart';
import '../modules/favorite_videos/views/favorite_videos_view.dart';
import '../modules/group_details/bindings/group_details_binding.dart';
import '../modules/group_details/views/group_details_view.dart';
import '../modules/groups/bindings/groups_binding.dart';
import '../modules/groups/views/groups_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/information_center/bindings/information_center_binding.dart';
import '../modules/information_center/views/information_center_view.dart';
import '../modules/inventory_management/bindings/inventory_management_binding.dart';
import '../modules/inventory_management/views/inventory_management_view.dart';
import '../modules/likes_dislikes/bindings/likes_dislikes_binding.dart';
import '../modules/likes_dislikes/views/likes_dislikes_view.dart';
import '../modules/live_player/bindings/live_player_binding.dart';
import '../modules/live_player/views/live_player_view.dart';
import '../modules/location_settings/bindings/location_settings_binding.dart';
import '../modules/location_settings/views/location_settings_view.dart';
import '../modules/make_donation/bindings/make_donation_binding.dart';
import '../modules/make_donation/views/make_donation_view.dart';
import '../modules/manage_creators/bindings/manage_creators_binding.dart';
import '../modules/manage_creators/views/manage_creators_view.dart';
import '../modules/manager_verification/bindings/manager_verification_binding.dart';
import '../modules/manager_verification/views/manager_verification_view.dart';
import '../modules/matching_system/bindings/matching_system_binding.dart';
import '../modules/matching_system/views/matching_system_view.dart';
import '../modules/media_collaboration/bindings/media_collaboration_binding.dart';
import '../modules/media_collaboration/views/media_collaboration_view.dart';
import '../modules/media_network_profile/bindings/media_network_profile_binding.dart';
import '../modules/media_network_profile/views/media_network_profile_view.dart';
import '../modules/merchant_profile/bindings/merchant_profile_binding.dart';
import '../modules/merchant_profile/views/merchant_profile_view.dart';
import '../modules/my_channel/bindings/my_channel_binding.dart';
import '../modules/my_channel/views/my_channel_view.dart';
import '../modules/notification_settings/bindings/notification_settings_binding.dart';
import '../modules/notification_settings/views/notification_settings_view.dart';
import '../modules/notifications/bindings/notifications_binding.dart';
import '../modules/notifications/views/notifications_view.dart';
import '../modules/order_details/bindings/order_details_binding.dart';
import '../modules/order_details/views/order_details_view.dart';
import '../modules/order_list/bindings/order_list_binding.dart';
import '../modules/order_list/views/order_list_view.dart';
import '../modules/order_management/bindings/order_management_binding.dart';
import '../modules/order_management/views/order_management_view.dart';
import '../modules/other_profile/bindings/other_profile_binding.dart';
import '../modules/other_profile/views/other_profile_view.dart';
import '../modules/performance_log/bindings/performance_log_binding.dart';
import '../modules/performance_log/views/performance_log_view.dart';
import '../modules/performance_metrics/bindings/performance_metrics_binding.dart';
import '../modules/performance_metrics/views/performance_metrics_view.dart';
import '../modules/playlist/bindings/playlist_binding.dart';
import '../modules/playlist/views/playlist_view.dart';
import '../modules/playlist_details/bindings/playlist_details_binding.dart';
import '../modules/playlist_details/views/playlist_details_view.dart';
import '../modules/premium_sub_reselling/bindings/premium_sub_reselling_binding.dart';
import '../modules/premium_sub_reselling/views/premium_sub_reselling_view.dart';
import '../modules/premium_subscription/bindings/premium_subscription_binding.dart';
import '../modules/premium_subscription/views/premium_subscription_view.dart';
import '../modules/premium_subscription_invitation/bindings/premium_subscription_invitation_binding.dart';
import '../modules/premium_subscription_invitation/views/premium_subscription_invitation_view.dart';
import '../modules/product_details/bindings/product_details_binding.dart';
import '../modules/product_details/views/product_details_view.dart';
import '../modules/proposal_details/bindings/proposal_details_binding.dart';
import '../modules/proposal_details/views/proposal_details_view.dart';
import '../modules/public_profile/bindings/public_profile_binding.dart';
import '../modules/public_profile/views/public_profile_view.dart';
import '../modules/purchases/bindings/purchases_binding.dart';
import '../modules/purchases/views/purchases_view.dart';
import '../modules/reselling_analytics/bindings/reselling_analytics_binding.dart';
import '../modules/reselling_analytics/views/reselling_analytics_view.dart';
import '../modules/scouting_tools/bindings/scouting_tools_binding.dart';
import '../modules/scouting_tools/views/scouting_tools_view.dart';
import '../modules/search/bindings/search_binding.dart';
import '../modules/search/views/search_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/shorts_player/bindings/shorts_player_binding.dart';
import '../modules/shorts_player/views/shorts_player_view.dart';
import '../modules/sold_products/bindings/sold_products_binding.dart';
import '../modules/sold_products/views/sold_products_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/sponsorship_center/bindings/sponsorship_center_binding.dart';
import '../modules/sponsorship_center/views/sponsorship_center_view.dart';
import '../modules/studio/bindings/studio_binding.dart';
import '../modules/studio/views/studio_view.dart';
import '../modules/subscribers/bindings/subscribers_binding.dart';
import '../modules/subscribers/views/subscribers_view.dart';
import '../modules/support/bindings/support_binding.dart';
import '../modules/support/views/support_view.dart';
import '../modules/talent_manager_profile/bindings/talent_manager_profile_binding.dart';
import '../modules/talent_manager_profile/views/talent_manager_profile_view.dart';
import '../modules/terms_of_service/bindings/terms_of_service_binding.dart';
import '../modules/terms_of_service/views/terms_of_service_view.dart';
import '../modules/total_products/bindings/total_products_binding.dart';
import '../modules/total_products/views/total_products_view.dart';
import '../modules/video_player/bindings/video_player_binding.dart';
import '../modules/video_player/views/video_player_view.dart';
import '../modules/video_shared/bindings/video_shared_binding.dart';
import '../modules/video_shared/views/video_shared_view.dart';
import '../modules/video_statistics/bindings/video_statistics_binding.dart';
import '../modules/video_statistics/views/video_statistics_view.dart';
import '../modules/videos_watched/bindings/videos_watched_binding.dart';
import '../modules/videos_watched/views/videos_watched_view.dart';
import '../modules/viewer_profile/bindings/viewer_profile_binding.dart';
import '../modules/viewer_profile/views/viewer_profile_view.dart';

// Removed content_creators_list

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN_OPTIONS,
      page: () => const LoginOptionsView(),
      binding: LoginOptionsBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.FORGOT_PASSWORD,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: _Paths.OTP,
      page: () => const OtpView(),
      binding: OtpBinding(),
    ),
    GetPage(
      name: _Paths.CREATE_PASSWORD,
      page: () => const CreatePasswordView(),
      binding: CreatePasswordBinding(),
    ),
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: _Paths.SUCCESS,
      page: () => const SuccessView(),
      binding: SuccessBinding(),
    ),
    GetPage(
      name: _Paths.SEARCH,
      page: () => const SearchView(),
      binding: SearchBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATIONS,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
    ),
    GetPage(
      name: _Paths.VIDEO_PLAYER,
      page: () => const VideoPlayerView(),
      binding: VideoPlayerBinding(),
    ),
    GetPage(
      name: _Paths.CREATOR_CHANNEL,
      page: () => const CreatorChannelView(),
      binding: CreatorChannelBinding(),
    ),
    GetPage(
      name: _Paths.CREATE,
      page: () => const CreateView(),
      binding: CreateBinding(),
    ),
    GetPage(
      name: _Paths.COMMUNITY,
      page: () => const CommunityView(),
      binding: CommunityBinding(),
    ),
    GetPage(
      name: _Paths.CHAT,
      page: () => const ChatView(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: _Paths.MY_CHANNEL,
      page: () => const MyChannelView(),
      binding: MyChannelBinding(),
    ),
    GetPage(
      name: _Paths.STUDIO,
      page: () => const StudioView(),
      binding: StudioBinding(),
    ),
    GetPage(
      name: _Paths.VIEWER_PROFILE,
      page: () => const ViewerProfileView(),
      binding: ViewerProfileBinding(),
    ),
    GetPage(
      name: _Paths.PUBLIC_PROFILE,
      page: () => const PublicProfileView(),
      binding: PublicProfileBinding(),
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: _Paths.PURCHASES,
      page: () => const PurchasesView(),
      binding: PurchasesBinding(),
    ),
    GetPage(
      name: _Paths.EARNINGS,
      page: () => const EarningsView(),
      binding: EarningsBinding(),
    ),
    GetPage(
      name: _Paths.DONATIONS,
      page: () => const DonationsView(),
      binding: DonationsBinding(),
    ),
    GetPage(
      name: _Paths.MATCHING_SYSTEM,
      page: () => const MatchingSystemView(),
      binding: MatchingSystemBinding(),
    ),
    GetPage(
      name: _Paths.ENGAGEMENT_HISTORY,
      page: () => const EngagementHistoryView(),
      binding: EngagementHistoryBinding(),
    ),
    GetPage(
      name: _Paths.MERCHANT_PROFILE,
      page: () => const MerchantProfileView(),
      binding: MerchantProfileBinding(),
    ),
    GetPage(
      name: _Paths.TALENT_MANAGER_PROFILE,
      page: () => const TalentManagerProfileView(),
      binding: TalentManagerProfileBinding(),
    ),
    GetPage(
      name: _Paths.CONTENT_CREATOR_PROFILE,
      page: () => const ContentCreatorProfileView(),
      binding: ContentCreatorProfileBinding(),
    ),
    GetPage(
      name: _Paths.DOWNLOADS,
      page: () => const DownloadsView(),
      binding: DownloadsBinding(),
    ),
    GetPage(
      name: _Paths.PLAYLIST,
      page: () => const PlaylistView(),
      binding: PlaylistBinding(),
    ),
    GetPage(
      name: _Paths.VIDEOS_WATCHED,
      page: () => const VideosWatchedView(),
      binding: VideosWatchedBinding(),
    ),
    GetPage(
      name: _Paths.LIKES_DISLIKES,
      page: () => const LikesDislikesView(),
      binding: LikesDislikesBinding(),
    ),
    GetPage(
      name: _Paths.COMMENTS_MADE,
      page: () => const CommentsMadeView(),
      binding: CommentsMadeBinding(),
    ),
    GetPage(
      name: _Paths.FAVORITE_VIDEOS,
      page: () => const FavoriteVideosView(),
      binding: FavoriteVideosBinding(),
    ),
    GetPage(
      name: _Paths.VIDEO_SHARED,
      page: () => const VideoSharedView(),
      binding: VideoSharedBinding(),
    ),
    GetPage(
      name: _Paths.PRODUCT_DETAILS,
      page: () => const ProductDetailsView(),
      binding: ProductDetailsBinding(),
    ),
    GetPage(
      name: _Paths.PLAYLIST_DETAILS,
      page: () => const PlaylistDetailsView(),
      binding: PlaylistDetailsBinding(),
    ),
    GetPage(
      name: _Paths.MANAGE_CREATORS,
      page: () => const ManageCreatorsView(),
      binding: ManageCreatorsBinding(),
    ),
    GetPage(
      name: _Paths.ADD_CREATOR,
      page: () => const AddCreatorView(),
      binding: AddCreatorBinding(),
      children: [
        GetPage(
          name: _Paths.ADD_CREATOR,
          page: () => const AddCreatorView(),
          binding: AddCreatorBinding(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.MEDIA_NETWORK_PROFILE,
      page: () => const MediaNetworkProfileView(),
      binding: MediaNetworkProfileBinding(),
    ),
    GetPage(
      name: _Paths.CREATE_PROPOSAL,
      page: () => const CreateProposalView(),
      binding: CreateProposalBinding(),
    ),
    GetPage(
      name: _Paths.MEDIA_COLLABORATION,
      page: () => const MediaCollaborationView(),
      binding: MediaCollaborationBinding(),
    ),
    GetPage(
      name: _Paths.PERFORMANCE_LOG,
      page: () => const PerformanceLogView(),
      binding: PerformanceLogBinding(),
    ),
    GetPage(
      name: _Paths.MANAGER_VERIFICATION,
      page: () => const ManagerVerificationView(),
      binding: ManagerVerificationBinding(),
    ),
    GetPage(
      name: _Paths.AFFILIATE_PROGRAM,
      page: () => const AffiliateProgramView(),
      binding: AffiliateProgramBinding(),
    ),
    GetPage(
      name: _Paths.AFFILIATE_TOOLS,
      page: () => const AffiliateToolsView(),
      binding: AffiliateToolsBinding(),
    ),
    GetPage(
      name: _Paths.PERFORMANCE_METRICS,
      page: () => const PerformanceMetricsView(),
      binding: PerformanceMetricsBinding(),
    ),
    GetPage(
      name: _Paths.VIDEO_STATISTICS,
      page: () => const VideoStatisticsView(),
      binding: VideoStatisticsBinding(),
    ),
    GetPage(
      name: _Paths.INFORMATION_CENTER,
      page: () => const InformationCenterView(),
      binding: InformationCenterBinding(),
    ),
    GetPage(
      name: _Paths.PROPOSAL_DETAILS,
      page: () => const ProposalDetailsView(),
      binding: ProposalDetailsBinding(),
    ),
    GetPage(
      name: _Paths.SCOUTING_TOOLS,
      page: () => const ScoutingToolsView(),
      binding: ScoutingToolsBinding(),
    ),
    GetPage(
      name: _Paths.SPONSORSHIP_CENTER,
      page: () => const SponsorshipCenterView(),
      binding: SponsorshipCenterBinding(),
    ),
    GetPage(
      name: _Paths.DEALS_MANAGEMENT,
      page: () => const DealsManagementView(),
      binding: DealsManagementBinding(),
    ),
    GetPage(
      name: _Paths.CREATOR_DEALS,
      page: () => const CreatorDealsView(),
      binding: CreatorDealsBinding(),
    ),
    GetPage(
      name: _Paths.CREATE_DEAL,
      page: () => const CreateDealView(),
      binding: CreateDealBinding(),
    ),
    GetPage(
      name: _Paths.ADS_CAMPAIGN,
      page: () => const AdsCampaignView(),
      binding: AdsCampaignBinding(),
    ),
    GetPage(
      name: _Paths.LOCATION_SETTINGS,
      page: () => const LocationSettingsView(),
      binding: LocationSettingsBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATION_SETTINGS,
      page: () => const NotificationSettingsView(),
      binding: NotificationSettingsBinding(),
    ),
    GetPage(
      name: _Paths.PREMIUM_SUBSCRIPTION,
      page: () => const PremiumSubscriptionView(),
      binding: PremiumSubscriptionBinding(),
    ),
    GetPage(
      name: _Paths.CUSTOMIZE_MEMBERSHIP,
      page: () => const CustomizeMembershipView(),
      binding: CustomizeMembershipBinding(),
    ),
    GetPage(
      name: _Paths.MAKE_DONATION,
      page: () => const MakeDonationView(),
      binding: MakeDonationBinding(),
    ),
    GetPage(
      name: _Paths.BECOME_PARTNER,
      page: () => const BecomePartnerView(),
      binding: BecomePartnerBinding(),
    ),
    GetPage(
      name: _Paths.INVENTORY_MANAGEMENT,
      page: () => const InventoryManagementView(),
      binding: InventoryManagementBinding(),
    ),
    GetPage(
      name: _Paths.ADD_NEW_PRODUCT,
      page: () => const AddNewProductView(),
      binding: AddNewProductBinding(),
    ),
    GetPage(
      name: _Paths.TOTAL_PRODUCTS,
      page: () => const TotalProductsView(),
      binding: TotalProductsBinding(),
    ),
    GetPage(
      name: _Paths.SOLD_PRODUCTS,
      page: () => const SoldProductsView(),
      binding: SoldProductsBinding(),
    ),
    GetPage(
      name: _Paths.ACTIVE_LISTINGS,
      page: () => const ActiveListingsView(),
      binding: ActiveListingsBinding(),
    ),
    GetPage(
      name: _Paths.CAMPAIGN_MANAGEMENT,
      page: () => const CampaignManagementView(),
      binding: CampaignManagementBinding(),
    ),
    GetPage(
      name: _Paths.CREATE_NEW_CAMPAIGN,
      page: () => const CreateNewCampaignView(),
      binding: CreateNewCampaignBinding(),
    ),
    GetPage(
      name: _Paths.ORDER_MANAGEMENT,
      page: () => const OrderManagementView(),
      binding: OrderManagementBinding(),
    ),
    GetPage(
      name: _Paths.ORDER_LIST,
      page: () => const OrderListView(),
      binding: OrderListBinding(),
    ),
    GetPage(
      name: _Paths.ORDER_DETAILS,
      page: () => const OrderDetailsView(),
      binding: OrderDetailsBinding(),
    ),
    GetPage(
      name: _Paths.TERMS_OF_SERVICE,
      page: () => const TermsOfServiceView(),
      binding: TermsOfServiceBinding(),
    ),
    GetPage(
      name: _Paths.PREMIUM_SUB_RESELLING,
      page: () => const PremiumSubResellingView(),
      binding: PremiumSubResellingBinding(),
    ),
    GetPage(
      name: _Paths.PREMIUM_SUBSCRIPTION_INVITATION,
      page: () => const PremiumSubscriptionInvitationView(),
      binding: PremiumSubscriptionInvitationBinding(),
    ),
    GetPage(
      name: _Paths.COMPETITION_FORM,
      page: () => const CompetitionFormView(),
      binding: CompetitionFormBinding(),
    ),
    GetPage(
      name: _Paths.SUBSCRIBERS,
      page: () => const SubscribersView(),
      binding: SubscribersBinding(),
    ),
    GetPage(
      name: _Paths.SUPPORT,
      page: () => const SupportView(),
      binding: SupportBinding(),
    ),
    GetPage(
      name: _Paths.RESELLING_ANALYTICS,
      page: () => const ResellingAnalyticsView(),
      binding: ResellingAnalyticsBinding(),
    ),
    GetPage(
      name: _Paths.GROUPS,
      page: () => const GroupsView(),
      binding: GroupsBinding(),
    ),
    GetPage(
      name: _Paths.CREATE_GROUP,
      page: () => const CreateGroupView(),
      binding: CreateGroupBinding(),
    ),
    GetPage(
      name: _Paths.GROUP_DETAILS,
      page: () => const GroupDetailsView(),
      binding: GroupDetailsBinding(),
    ),
    GetPage(
      name: _Paths.SHORTS_PLAYER,
      page: () => const ShortsPlayerView(),
      binding: ShortsPlayerBinding(),
    ),
    GetPage(
      name: _Paths.LIVE_PLAYER,
      page: () => const LivePlayerView(),
      binding: LivePlayerBinding(),
    ),
    GetPage(
      name: _Paths.OTHER_PROFILE,
      page: () => const OtherProfileView(),
      binding: OtherProfileBinding(),
    ),
  ];
}
