import 'package:adnetwork/layers/data/model/link_model.dart';
import 'package:adnetwork/layers/data/model/user_model.dart';

class MockData {
  static final UserModel currentUser = UserModel(
    id: 'u0', username: 'nayeem_dev', bio: 'Flutter Developer | Ad Network Enthusiast',
    followersCount: 128, followingCount: 64,
  );

  static final List<UserModel> users = [
    UserModel(id: 'u1', username: 'sarah_design', bio: 'UI/UX Designer at Google', followersCount: 342, followingCount: 89, isFollowing: true),
    UserModel(id: 'u2', username: 'alex_code', bio: 'Full-stack Developer', followersCount: 567, followingCount: 120, isFollowing: true),
    UserModel(id: 'u3', username: 'maria_market', bio: 'Digital Marketing Expert', followersCount: 1204, followingCount: 340, isFollowing: false),
    UserModel(id: 'u4', username: 'john_ads', bio: 'Ad Network Specialist', followersCount: 890, followingCount: 200, isFollowing: false),
    UserModel(id: 'u5', username: 'emma_growth', bio: 'Growth Hacker & Analyst', followersCount: 456, followingCount: 78, isFollowing: true),
    UserModel(id: 'u6', username: 'dev_ryan', bio: 'Mobile App Developer', followersCount: 234, followingCount: 156, isFollowing: false),
    UserModel(id: 'u7', username: 'lisa_creative', bio: 'Creative Director', followersCount: 789, followingCount: 45, isFollowing: false),
    UserModel(id: 'u8', username: 'mark_seo', bio: 'SEO & Analytics Guru', followersCount: 321, followingCount: 210, isFollowing: false),
  ];

  static List<UserModel> get followers => users.where((u) => u.isFollowing || u.id == 'u1' || u.id == 'u2').toList();
  static List<UserModel> get following => users.where((u) => u.isFollowing).toList();

  static final List<LinkModel> feedLinks = [
    LinkModel(id: 'CA266', userId: 'u1', username: 'sarah_design', title: 'Best UI Patterns for 2026', url: 'https://example.com/ui-patterns', description: 'A comprehensive guide to modern UI design patterns that every designer should know.', publishedDate: DateTime.now().subtract(const Duration(hours: 2)), likesCount: 42, isLiked: true, status: 'Published'),
    LinkModel(id: 'CA178', userId: 'u2', username: 'alex_code', title: 'Flutter Performance Tips', url: 'https://example.com/flutter-perf', description: 'Top 10 tips to optimize your Flutter app for maximum performance.', publishedDate: DateTime.now().subtract(const Duration(hours: 5)), likesCount: 87, status: 'Published'),
    LinkModel(id: 'CA312', userId: 'u3', username: 'maria_market', title: 'Ad Revenue Optimization', url: 'https://example.com/ad-revenue', description: 'How to maximize your ad network revenue with smart placement strategies.', publishedDate: DateTime.now().subtract(const Duration(days: 1)), likesCount: 156, status: 'Unfollowed'),
    LinkModel(id: 'CA099', userId: 'u4', username: 'john_ads', title: 'Programmatic Advertising 101', url: 'https://example.com/programmatic', description: 'Everything you need to know about programmatic advertising in the modern era.', publishedDate: DateTime.now().subtract(const Duration(days: 1, hours: 6)), likesCount: 23, status: 'Published'),
    LinkModel(id: 'CA455', userId: 'u5', username: 'emma_growth', title: 'User Acquisition Strategies', url: 'https://example.com/user-acq', description: 'Proven strategies for acquiring and retaining users for your mobile apps.', publishedDate: DateTime.now().subtract(const Duration(days: 2)), likesCount: 198, isLiked: true, status: 'Unfollowed'),
    LinkModel(id: 'CA567', userId: 'u1', username: 'sarah_design', title: 'Color Theory for Ads', url: 'https://example.com/color-theory', description: 'How color psychology impacts ad performance and user engagement.', publishedDate: DateTime.now().subtract(const Duration(days: 3)), likesCount: 67, status: 'Published'),
    LinkModel(id: 'CA890', userId: 'u6', username: 'dev_ryan', title: 'Building Ad SDKs', url: 'https://example.com/ad-sdk', description: 'A developer guide to building robust advertising SDKs.', publishedDate: DateTime.now().subtract(const Duration(days: 3)), likesCount: 34, status: 'Unfollowed'),
    LinkModel(id: 'CA721', userId: 'u7', username: 'lisa_creative', title: 'Creative Ad Formats', url: 'https://example.com/creative-ads', description: 'Exploring innovative ad formats that drive higher engagement rates.', publishedDate: DateTime.now().subtract(const Duration(days: 4)), likesCount: 112, status: 'Published'),
  ];

  /// My links — URL only, no title/description
  static final List<LinkModel> myLinks = [
    LinkModel(id: 'ml1', userId: 'u0', username: 'nayeem_dev', title: 'https://flutter.dev/docs/cookbook', url: 'https://flutter.dev/docs/cookbook', publishedDate: DateTime.now().subtract(const Duration(days: 1)), likesCount: 15, status: 'Published'),
    LinkModel(id: 'ml2', userId: 'u0', username: 'nayeem_dev', title: 'https://medium.com/@dev/flutter-ads-guide', url: 'https://medium.com/@dev/flutter-ads-guide', publishedDate: DateTime.now().subtract(const Duration(days: 3)), likesCount: 28, status: 'Published'),
    LinkModel(id: 'ml3', userId: 'u0', username: 'nayeem_dev', title: 'https://github.com/nayeem/monetize-toolkit', url: 'https://github.com/nayeem/monetize-toolkit', publishedDate: DateTime.now().subtract(const Duration(days: 7)), likesCount: 45, status: 'Published'),
  ];
}
