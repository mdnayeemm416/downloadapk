/// Centralized API endpoint paths.
/// All endpoint strings are relative to [EnvConfig.baseUrl].
class ApiEndpoints {
  ApiEndpoints._();

  // ──────────────────────────── Auth ────────────────────────────
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String forgotPassword = '/api/auth/forgot-password';

  // ──────────────────────────── Users ───────────────────────────
  static const String myScore = '/api/users/me/score';
  static const String myStats = '/api/users/me/stats';
  static const String myActivityStats = '/api/users/me/activity-stats';
  static String userProfile(String id) => '/api/users/$id';
  static const String exploreUsers = '/api/users/explore';
  static String toggleFollow(String id) => '/api/users/$id/follow';
  static String followers(String id) => '/api/users/$id/followers';
  static String following(String id) => '/api/users/$id/following';

  // ──────────────────────────── Links ───────────────────────────
  static const String links = '/api/links';
  static const String myLinks = '/api/mylinks';
  static String linkById(String id) => '/api/links/$id';
  static String toggleLike(String id) => '/api/links/$id/like';
  static String addComment(String id) => '/api/links/$id/comment';
  static String linkComments(String id) => '/api/links/$id/comments';

  // ──────────────────────────── Admin ───────────────────────────
  static const String adminUsers = '/api/admin/users';
  static const String adminPending = '/api/admin/users/pending';
  static String adminApprove(String id) => '/api/admin/users/$id/approve';
  static String adminReject(String id) => '/api/admin/users/$id/reject';
  static String adminBlock(String id) => '/api/admin/users/$id/block';
  static String adminUnblock(String id) => '/api/admin/users/$id/unblock';
  static String adminMakeAdmin(String id) => '/api/admin/users/$id/make-admin';
  static String adminRemoveAdmin(String id) =>
      '/api/admin/users/$id/remove-admin';
  static String adminMakeModerator(String id) =>
      '/api/admin/users/$id/make-moderator';
  static String adminRemoveModerator(String id) =>
      '/api/admin/users/$id/remove-moderator';
  static String adminResetPassword(String id) =>
      '/api/admin/users/$id/reset-password';
  static const String adminResetRequests = '/api/admin/users/reset-requests';

  // ──────────────────────────── Notices ───────────────────────────
  static const String notices = '/api/notices';
  static String noticeById(String id) => '/api/notices/$id';
}
