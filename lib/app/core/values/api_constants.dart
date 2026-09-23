class ApiConstants {
  static const String baseUrl =
      'https://patronage-esquire-everyday.ngrok-free.dev/api/';
  static const String contentCreatorsList = 'profile/content-creators-list/';
  static const String agoraAppId = '78efdfdb60244b2f918476a28401a960';

  // Live Games & Matchmaking
  static const String liveGamesMatchmakingJoin = 'live-games/matchmaking/join/';
  static const String liveGamesMatchmakingStatus = 'live-games/matchmaking/status/';
  static const String liveGamesMatchmakingCancel = 'live-games/matchmaking/cancel/';
  static const String liveGamesMatchmakingHeartbeat = 'live-games/matchmaking/heartbeat/';

  // Live Games Lobbies
  static const String liveGamesLobbies = 'live-games/lobbies/';
  static const String liveGamesLobbiesInvitationsPending = 'live-games/lobbies/invitations/pending/';

  // Live Games Matches
  static const String liveGamesMatches = 'live-games/matches/';

  // Users & Friends for Challenge
  static const String authUserList = 'auth/user-list/';
  static const String friendsList = 'friends/list/';
}
