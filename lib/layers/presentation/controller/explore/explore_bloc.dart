import 'package:adnetwork/layers/data/model/user_model.dart';
import 'package:adnetwork/layers/data/repo/remote/user_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'explore_event.dart';
part 'explore_state.dart';

class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  final UserRepository userRepository;

  ExploreBloc({required this.userRepository}) : super(const ExploreState()) {
    on<LoadExplore>(_onLoadExplore);
    on<RefreshExplore>(_onRefreshExplore);
    on<ChangeExplorePage>(_onChangeExplorePage);
    on<ToggleExploreFollowState>(_onToggleExploreFollowState);
  }

  void _onToggleExploreFollowState(ToggleExploreFollowState event, Emitter<ExploreState> emit) {
    if (state.users.isEmpty) return;
    
    final updatedUsers = state.users.map((u) {
      if (u.id == event.userId) {
        return u.copyWith(isFollowing: event.isFollowing);
      }
      return u;
    }).toList();
    
    emit(state.copyWith(users: updatedUsers));
  }

  Future<void> _onLoadExplore(LoadExplore event, Emitter<ExploreState> emit) async {
    if (state.status != ExploreStatus.initial && state.users.isNotEmpty) return;
    emit(state.copyWith(status: ExploreStatus.loading));
    await _fetchData(1, emit);
  }

  Future<void> _onRefreshExplore(RefreshExplore event, Emitter<ExploreState> emit) async {
    emit(state.copyWith(status: ExploreStatus.loading));
    await _fetchData(1, emit);
  }

  Future<void> _onChangeExplorePage(ChangeExplorePage event, Emitter<ExploreState> emit) async {
    emit(state.copyWith(status: ExploreStatus.loading));
    await _fetchData(event.page, emit);
  }

  Future<void> _fetchData(int page, Emitter<ExploreState> emit) async {
    try {
      final response = await userRepository.exploreUsers(page: page, limit: 30);
      if (response.isSuccess) {
        final newUsers = response.dataList ?? <UserModel>[];
        emit(state.copyWith(
          status: ExploreStatus.loaded,
          users: newUsers,
          currentPage: page,
          hasMore: newUsers.length >= 30,
        ));
      } else {
        emit(state.copyWith(
          status: ExploreStatus.error,
          errorMessage: response.message ?? 'Failed to explore users',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ExploreStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
