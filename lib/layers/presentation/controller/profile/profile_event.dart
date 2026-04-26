part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

class ClearProfile extends ProfileEvent {
  const ClearProfile();
}

class LoadProfileStats extends ProfileEvent {
  const LoadProfileStats();
}

class LoadUserProfile extends ProfileEvent {
  final String userId;
  const LoadUserProfile(this.userId);
  @override
  List<Object?> get props => [userId];
}

class ToggleFollow extends ProfileEvent {
  final String userId;
  const ToggleFollow(this.userId);
  @override
  List<Object?> get props => [userId];
}

class LoadFollowers extends ProfileEvent {
  final String? userId;
  const LoadFollowers({this.userId});
  @override
  List<Object?> get props => [userId];
}

class LoadFollowing extends ProfileEvent {
  final String? userId;
  const LoadFollowing({this.userId});
  @override
  List<Object?> get props => [userId];
}

class ChangeFollowersPage extends ProfileEvent {
  final int page;
  final String? userId;
  const ChangeFollowersPage(this.page, {this.userId});
  @override
  List<Object?> get props => [page, userId];
}

class ChangeFollowingPage extends ProfileEvent {
  final int page;
  final String? userId;
  const ChangeFollowingPage(this.page, {this.userId});
  @override
  List<Object?> get props => [page, userId];
}
