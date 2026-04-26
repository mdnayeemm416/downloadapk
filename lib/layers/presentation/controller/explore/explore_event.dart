part of 'explore_bloc.dart';

abstract class ExploreEvent extends Equatable {
  const ExploreEvent();

  @override
  List<Object?> get props => [];
}

class LoadExplore extends ExploreEvent {
  const LoadExplore();
}

class RefreshExplore extends ExploreEvent {
  const RefreshExplore();
}

class ChangeExplorePage extends ExploreEvent {
  final int page;

  const ChangeExplorePage(this.page);

  @override
  List<Object?> get props => [page];
}

class ToggleExploreFollowState extends ExploreEvent {
  final String userId;
  final bool isFollowing;

  const ToggleExploreFollowState(this.userId, this.isFollowing);

  @override
  List<Object?> get props => [userId, isFollowing];
}
