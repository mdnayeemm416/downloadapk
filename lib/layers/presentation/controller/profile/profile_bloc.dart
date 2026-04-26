import 'package:adnetwork/core/services/token_storage.dart';
import 'package:adnetwork/layers/data/model/user_model.dart';
import 'package:adnetwork/layers/data/model/user_stats_model.dart';
import 'package:adnetwork/layers/data/repo/remote/user_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository userRepository;

  ProfileBloc({required this.userRepository}) : super(const ProfileState()) {
    on<LoadProfile>(_onLoad);
    on<LoadUserProfile>(_onLoadUser);
    on<ToggleFollow>(_onToggleFollow);
    on<LoadFollowers>(_onLoadFollowers);
    on<LoadFollowing>(_onLoadFollowing);
    on<ChangeFollowersPage>(_onChangeFollowersPage);
    on<ChangeFollowingPage>(_onChangeFollowingPage);
    on<LoadProfileStats>(_onLoadProfileStats);
    on<ClearProfile>(_onClearProfile);
  }

  void _onClearProfile(ClearProfile event, Emitter<ProfileState> emit) {
    emit(const ProfileState());
  }

  Future<void> _onLoad(LoadProfile event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    try {
      final userId = await TokenStorage.instance.getUserId();
      if (userId == null) {
        emit(state.copyWith(status: ProfileStatus.loaded));
        return;
      }

      final response = await userRepository.getUserProfile(userId);

      if (response.isSuccess && response.data != null) {
        emit(
          state.copyWith(
            status: ProfileStatus.loaded,
            currentUser: response.data,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: ProfileStatus.loaded,
            errorMessage: response.message,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadProfileStats(
    LoadProfileStats event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final response = await userRepository.getMyStats();
      if (response.isSuccess && response.data != null) {
        emit(state.copyWith(stats: response.data));
      }
    } catch (_) {
      // Silently fail stats
    }
  }

  Future<void> _onLoadUser(
    LoadUserProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    try {
      final response = await userRepository.getUserProfile(event.userId);

      if (response.isSuccess && response.data != null) {
        emit(
          state.copyWith(
            status: ProfileStatus.loaded,
            viewedUser: response.data,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: ProfileStatus.loaded,
            errorMessage: response.message,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onToggleFollow(
    ToggleFollow event,
    Emitter<ProfileState> emit,
  ) async {
    // Optimistic update
    if (state.viewedUser?.id == event.userId) {
      final user = state.viewedUser!;
      final newIsFollowing = !user.isFollowing;
      emit(
        state.copyWith(
          viewedUser: user.copyWith(
            isFollowing: newIsFollowing,
            followersCount: user.followersCount + (newIsFollowing ? 1 : -1),
          ),
        ),
      );
    }

    try {
      await userRepository.toggleFollow(event.userId);
    } catch (_) {
      // Revert on failure — reload profile
      add(LoadUserProfile(event.userId));
    }
  }

  Future<void> _onChangeFollowersPage(
    ChangeFollowersPage event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    await _fetchFollowers(event.page, event.userId, emit);
  }

  Future<void> _onChangeFollowingPage(
    ChangeFollowingPage event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    await _fetchFollowing(event.page, event.userId, emit);
  }

  Future<void> _onLoadFollowers(
    LoadFollowers event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    await _fetchFollowers(1, event.userId, emit);
  }

  Future<void> _fetchFollowers(
    int page,
    String? targetUserId,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final userId =
          targetUserId ?? await TokenStorage.instance.getUserId() ?? '';
      final response = await userRepository.getFollowers(
        userId,
        page: page,
        limit: 30,
      );

      if (response.isSuccess) {
        final newFollowers = response.dataList ?? <UserModel>[];
        emit(
          state.copyWith(
            status: ProfileStatus.loaded,
            followers: newFollowers,
            followersPage: page,
            hasMoreFollowers: newFollowers.length >= 30,
          ),
        );
      } else {
        emit(state.copyWith(status: ProfileStatus.loaded));
      }
    } catch (_) {
      emit(state.copyWith(status: ProfileStatus.loaded));
    }
  }

  Future<void> _onLoadFollowing(
    LoadFollowing event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    await _fetchFollowing(1, event.userId, emit);
  }

  Future<void> _fetchFollowing(
    int page,
    String? targetUserId,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final userId =
          targetUserId ?? await TokenStorage.instance.getUserId() ?? '';
      final response = await userRepository.getFollowing(
        userId,
        page: page,
        limit: 30,
      );

      if (response.isSuccess) {
        final newFollowing = response.dataList ?? <UserModel>[];
        emit(
          state.copyWith(
            status: ProfileStatus.loaded,
            following: newFollowing,
            followingPage: page,
            hasMoreFollowing: newFollowing.length >= 30,
          ),
        );
      } else {
        emit(state.copyWith(status: ProfileStatus.loaded));
      }
    } catch (_) {
      emit(state.copyWith(status: ProfileStatus.loaded));
    }
  }
}
