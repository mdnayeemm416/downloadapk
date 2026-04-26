part of 'notice_bloc.dart';

abstract class NoticeEvent extends Equatable {
  const NoticeEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotices extends NoticeEvent {
  const LoadNotices();
}

class CreateNotice extends NoticeEvent {
  final String text;
  final String bgColor;
  final String textColor;

  const CreateNotice({
    required this.text,
    required this.bgColor,
    required this.textColor,
  });

  @override
  List<Object?> get props => [text, bgColor, textColor];
}

class DeleteNotice extends NoticeEvent {
  final String id;
  const DeleteNotice(this.id);

  @override
  List<Object?> get props => [id];
}
