part of 'profile_bloc.dart';

enum ProfileStatus { initial, loading, loaded }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserModel? currentUser;
  final UserModel? viewedUser;
  final UserStatsModel? stats;
  final List<UserModel> followers;
  final List<UserModel> following;
  final int followersPage;
  final int followingPage;
  final bool hasMoreFollowers;
  final bool hasMoreFollowing;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.currentUser,
    this.viewedUser,
    this.stats,
    this.followers = const [],
    this.following = const [],
    this.followersPage = 1,
    this.followingPage = 1,
    this.hasMoreFollowers = true,
    this.hasMoreFollowing = true,
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    UserModel? currentUser,
    UserModel? viewedUser,
    UserStatsModel? stats,
    List<UserModel>? followers,
    List<UserModel>? following,
    int? followersPage,
    int? followingPage,
    bool? hasMoreFollowers,
    bool? hasMoreFollowing,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      currentUser: currentUser ?? this.currentUser,
      viewedUser: viewedUser ?? this.viewedUser,
      stats: stats ?? this.stats,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      followersPage: followersPage ?? this.followersPage,
      followingPage: followingPage ?? this.followingPage,
      hasMoreFollowers: hasMoreFollowers ?? this.hasMoreFollowers,
      hasMoreFollowing: hasMoreFollowing ?? this.hasMoreFollowing,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentUser,
    viewedUser,
    stats,
    followers,
    following,
    followersPage,
    followingPage,
    hasMoreFollowers,
    hasMoreFollowing,
    errorMessage,
  ];
}
