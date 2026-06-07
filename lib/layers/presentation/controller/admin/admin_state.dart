part of 'admin_bloc.dart';


enum AdminStatus { initial, loading, loaded, error }

enum AdminTab { all, pending, blocked, moderators, resetRequests, devices }

class AdminState extends Equatable {
  final AdminStatus status;
  final List<UserModel> allUsers;
  final List<UserModel> filteredUsers;
  final List<UserModel> pendingUsers;
  final List<UserModel> resetRequestedUsers;
  final List<DeviceAssociationModel> pendingDevices;
  final AdminTab currentTab;
  final String searchQuery;
  final String errorMessage;
  final String successMessage;
  final String actionUserId;
  final String actionType;
  final bool isSelectionMode;
  final Set<String> selectedUserIds;

  const AdminState({
    this.status = AdminStatus.initial,
    this.allUsers = const [],
    this.filteredUsers = const [],
    this.pendingUsers = const [],
    this.resetRequestedUsers = const [],
    this.pendingDevices = const [],
    this.currentTab = AdminTab.all,
    this.searchQuery = '',
    this.errorMessage = '',
    this.successMessage = '',
    this.actionUserId = '',
    this.actionType = '',
    this.isSelectionMode = false,
    this.selectedUserIds = const {},
  });

  AdminState copyWith({
    AdminStatus? status,
    List<UserModel>? allUsers,
    List<UserModel>? filteredUsers,
    List<UserModel>? pendingUsers,
    List<UserModel>? resetRequestedUsers,
    List<DeviceAssociationModel>? pendingDevices,
    AdminTab? currentTab,
    String? searchQuery,
    String? errorMessage,
    String? successMessage,
    String? actionUserId,
    String? actionType,
    bool? isSelectionMode,
    Set<String>? selectedUserIds,
  }) {
    return AdminState(
      status: status ?? this.status,
      allUsers: allUsers ?? this.allUsers,
      filteredUsers: filteredUsers ?? this.filteredUsers,
      pendingUsers: pendingUsers ?? this.pendingUsers,
      resetRequestedUsers: resetRequestedUsers ?? this.resetRequestedUsers,
      pendingDevices: pendingDevices ?? this.pendingDevices,
      currentTab: currentTab ?? this.currentTab,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      actionUserId: actionUserId ?? this.actionUserId,
      actionType: actionType ?? this.actionType,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedUserIds: selectedUserIds ?? this.selectedUserIds,
    );
  }

  @override
  List<Object?> get props => [
        status,
        allUsers,
        filteredUsers,
        pendingUsers,
        resetRequestedUsers,
        pendingDevices,
        currentTab,
        searchQuery,
        errorMessage,
        successMessage,
        actionUserId,
        actionType,
        isSelectionMode,
        selectedUserIds,
      ];
}
