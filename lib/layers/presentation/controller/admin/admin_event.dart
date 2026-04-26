part of 'admin_bloc.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();
  @override
  List<Object?> get props => [];
}

class LoadAllUsers extends AdminEvent {
  const LoadAllUsers();
}

class LoadPendingUsers extends AdminEvent {
  const LoadPendingUsers();
}

class ApproveUser extends AdminEvent {
  final String userId;
  const ApproveUser(this.userId);
  @override
  List<Object?> get props => [userId];
}

class RejectUser extends AdminEvent {
  final String userId;
  const RejectUser(this.userId);
  @override
  List<Object?> get props => [userId];
}

class BlockUser extends AdminEvent {
  final String userId;
  const BlockUser(this.userId);
  @override
  List<Object?> get props => [userId];
}

class UnblockUser extends AdminEvent {
  final String userId;
  const UnblockUser(this.userId);
  @override
  List<Object?> get props => [userId];
}

class MakeModerator extends AdminEvent {
  final String userId;
  const MakeModerator(this.userId);
  @override
  List<Object?> get props => [userId];
}

class RemoveModerator extends AdminEvent {
  final String userId;
  const RemoveModerator(this.userId);
  @override
  List<Object?> get props => [userId];
}

class ChangeTab extends AdminEvent {
  final AdminTab tab;
  const ChangeTab(this.tab);
  @override
  List<Object?> get props => [tab];
}

class SearchUsers extends AdminEvent {
  final String query;
  const SearchUsers(this.query);
  @override
  List<Object?> get props => [query];
}
