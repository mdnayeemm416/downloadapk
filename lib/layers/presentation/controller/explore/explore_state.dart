part of 'explore_bloc.dart';

enum ExploreStatus { initial, loading, loaded, error }

class ExploreState extends Equatable {
  final ExploreStatus status;
  final List<UserModel> users;
  final int currentPage;
  final bool hasMore;
  final String errorMessage;

  const ExploreState({
    this.status = ExploreStatus.initial,
    this.users = const [],
    this.currentPage = 1,
    this.hasMore = false,
    this.errorMessage = '',
  });

  ExploreState copyWith({
    ExploreStatus? status,
    List<UserModel>? users,
    int? currentPage,
    bool? hasMore,
    String? errorMessage,
  }) {
    return ExploreState(
      status: status ?? this.status,
      users: users ?? this.users,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, users, currentPage, hasMore, errorMessage];
}
