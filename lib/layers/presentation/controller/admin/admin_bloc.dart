import 'package:adnetwork/layers/data/model/user_model.dart';
import 'package:adnetwork/layers/data/repo/remote/admin_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository adminRepository;

  AdminBloc({required this.adminRepository}) : super(const AdminState()) {
    on<LoadAllUsers>(_onLoadAll);
    on<LoadPendingUsers>(_onLoadPending);
    on<ApproveUser>(_onApprove);
    on<RejectUser>(_onReject);
    on<BlockUser>(_onBlock);
    on<UnblockUser>(_onUnblock);
    on<MakeModerator>(_onMakeModerator);
    on<RemoveModerator>(_onRemoveModerator);
    on<ChangeTab>(_onChangeTab);
    on<SearchUsers>(_onSearch);
  }

  Future<void> _onLoadAll(LoadAllUsers event, Emitter<AdminState> emit) async {
    emit(state.copyWith(status: AdminStatus.loading));

    try {
      final response = await adminRepository.getAllUsers();

      if (response.isSuccess) {
        final users = response.dataList ?? <UserModel>[];
        emit(state.copyWith(
          status: AdminStatus.loaded,
          allUsers: users,
          filteredUsers: _filterByTab(users, state.currentTab),
        ));
      } else {
        emit(state.copyWith(
          status: AdminStatus.error,
          errorMessage: response.message ?? 'Failed to load users',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AdminStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadPending(
    LoadPendingUsers event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));

    try {
      final response = await adminRepository.getPendingApprovals();

      if (response.isSuccess) {
        final pending = response.dataList ?? <UserModel>[];
        emit(state.copyWith(
          status: AdminStatus.loaded,
          pendingUsers: pending,
        ));
      } else {
        emit(state.copyWith(
          status: AdminStatus.error,
          errorMessage: response.message ?? 'Failed to load pending users',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AdminStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onApprove(ApproveUser event, Emitter<AdminState> emit) async {
    emit(state.copyWith(actionUserId: event.userId, actionType: 'approve'));
    try {
      final response = await adminRepository.approveUser(event.userId);
      if (response.isSuccess) {
        _updateUserInList(emit, event.userId, isApproved: 1);
        emit(state.copyWith(successMessage: 'User approved successfully', actionUserId: '', actionType: ''));
      } else {
        emit(state.copyWith(errorMessage: response.message ?? 'Failed', actionUserId: '', actionType: ''));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString(), actionUserId: '', actionType: ''));
    }
  }

  Future<void> _onReject(RejectUser event, Emitter<AdminState> emit) async {
    emit(state.copyWith(actionUserId: event.userId, actionType: 'reject'));
    try {
      final response = await adminRepository.rejectUser(event.userId);
      if (response.isSuccess) {
        // Remove from pending list
        final pendingUsers = state.pendingUsers.where((u) => u.id != event.userId).toList();
        emit(state.copyWith(pendingUsers: pendingUsers, successMessage: 'User rejected', actionUserId: '', actionType: ''));
      } else {
        emit(state.copyWith(errorMessage: response.message ?? 'Failed', actionUserId: '', actionType: ''));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString(), actionUserId: '', actionType: ''));
    }
  }

  Future<void> _onBlock(BlockUser event, Emitter<AdminState> emit) async {
    emit(state.copyWith(actionUserId: event.userId, actionType: 'block'));
    try {
      final response = await adminRepository.blockUser(event.userId);
      if (response.isSuccess) {
        _updateUserInList(emit, event.userId, isBlocked: 1);
        emit(state.copyWith(successMessage: 'User blocked', actionUserId: '', actionType: ''));
      } else {
        emit(state.copyWith(errorMessage: response.message ?? 'Failed', actionUserId: '', actionType: ''));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString(), actionUserId: '', actionType: ''));
    }
  }

  Future<void> _onUnblock(UnblockUser event, Emitter<AdminState> emit) async {
    emit(state.copyWith(actionUserId: event.userId, actionType: 'unblock'));
    try {
      final response = await adminRepository.unblockUser(event.userId);
      if (response.isSuccess) {
        _updateUserInList(emit, event.userId, isBlocked: 0);
        emit(state.copyWith(successMessage: 'User unblocked', actionUserId: '', actionType: ''));
      } else {
        emit(state.copyWith(errorMessage: response.message ?? 'Failed', actionUserId: '', actionType: ''));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString(), actionUserId: '', actionType: ''));
    }
  }



  Future<void> _onMakeModerator(
    MakeModerator event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(
        actionUserId: event.userId, actionType: 'make-moderator'));
    try {
      final response = await adminRepository.makeModerator(event.userId);
      if (response.isSuccess) {
        _updateUserInList(emit, event.userId, role: 'moderator');
        emit(state.copyWith(
            successMessage: 'User promoted to moderator',
            actionUserId: '',
            actionType: ''));
      } else {
        emit(state.copyWith(
            errorMessage: response.message ?? 'Failed',
            actionUserId: '',
            actionType: ''));
      }
    } catch (e) {
      emit(state.copyWith(
          errorMessage: e.toString(), actionUserId: '', actionType: ''));
    }
  }

  Future<void> _onRemoveModerator(
    RemoveModerator event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(
        actionUserId: event.userId, actionType: 'remove-moderator'));
    try {
      final response = await adminRepository.removeModerator(event.userId);
      if (response.isSuccess) {
        _updateUserInList(emit, event.userId, role: 'user');
        emit(state.copyWith(
            successMessage: 'Moderator role removed',
            actionUserId: '',
            actionType: ''));
      } else {
        emit(state.copyWith(
            errorMessage: response.message ?? 'Failed',
            actionUserId: '',
            actionType: ''));
      }
    } catch (e) {
      emit(state.copyWith(
          errorMessage: e.toString(), actionUserId: '', actionType: ''));
    }
  }

  void _onChangeTab(ChangeTab event, Emitter<AdminState> emit) {
    final filtered = _filterByTab(state.allUsers, event.tab);
    emit(state.copyWith(currentTab: event.tab, filteredUsers: filtered, searchQuery: ''));
  }

  void _onSearch(SearchUsers event, Emitter<AdminState> emit) {
    final query = event.query.toLowerCase();
    final tabUsers = _filterByTab(state.allUsers, state.currentTab);
    final searched = query.isEmpty
        ? tabUsers
        : tabUsers.where((u) {
            final name = (u.username ?? '').toLowerCase();
            final email = (u.email ?? '').toLowerCase();
            return name.contains(query) || email.contains(query);
          }).toList();
    emit(state.copyWith(filteredUsers: searched, searchQuery: event.query));
  }

  List<UserModel> _filterByTab(List<UserModel> users, AdminTab tab) {
    switch (tab) {
      case AdminTab.all:
        return users;
      case AdminTab.pending:
        return users.where((u) => u.isApproved == 0).toList();
      case AdminTab.blocked:
        return users.where((u) => u.isBlocked == 1).toList();
      case AdminTab.moderators:
        return users.where((u) => u.role == 'moderator').toList();
    }
  }

  void _updateUserInList(
    Emitter<AdminState> emit,
    String userId, {
    int? isApproved,
    int? isBlocked,
    String? role,
  }) {
    final allUsers = state.allUsers.map((u) {
      if (u.id == userId) {
        return u.copyWith(
          isApproved: isApproved ?? u.isApproved,
          isBlocked: isBlocked ?? u.isBlocked,
          role: role ?? u.role,
        );
      }
      return u;
    }).toList();

    final filtered = _filterByTab(allUsers, state.currentTab);
    emit(state.copyWith(allUsers: allUsers, filteredUsers: filtered));
  }
}
