part of 'notice_bloc.dart';

enum NoticeStatus { initial, loading, loaded, error }

class NoticeState extends Equatable {
  final NoticeStatus status;
  final List<NoticeModel> notices;
  final String errorMessage;
  final String successMessage;
  final String actionId;

  const NoticeState({
    this.status = NoticeStatus.initial,
    this.notices = const [],
    this.errorMessage = '',
    this.successMessage = '',
    this.actionId = '',
  });

  NoticeState copyWith({
    NoticeStatus? status,
    List<NoticeModel>? notices,
    String? errorMessage,
    String? successMessage,
    String? actionId,
  }) {
    return NoticeState(
      status: status ?? this.status,
      notices: notices ?? this.notices,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      actionId: actionId ?? this.actionId,
    );
  }

  @override
  List<Object?> get props =>
      [status, notices, errorMessage, successMessage, actionId];
}
