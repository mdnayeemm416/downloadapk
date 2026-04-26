import 'package:adnetwork/layers/data/model/notice_model.dart';
import 'package:adnetwork/layers/data/repo/remote/notice_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'notice_event.dart';
part 'notice_state.dart';

class NoticeBloc extends Bloc<NoticeEvent, NoticeState> {
  final NoticeRepository noticeRepository;

  NoticeBloc({required this.noticeRepository}) : super(const NoticeState()) {
    on<LoadNotices>(_onLoadNotices);
    on<CreateNotice>(_onCreateNotice);
    on<DeleteNotice>(_onDeleteNotice);
  }

  Future<void> _onLoadNotices(
    LoadNotices event,
    Emitter<NoticeState> emit,
  ) async {
    emit(state.copyWith(
      status: NoticeStatus.loading,
      errorMessage: '',
      successMessage: '',
      actionId: '',
    ));

    try {
      final res = await noticeRepository.getNotices();
      if (res.isSuccess) {
        emit(state.copyWith(
          status: NoticeStatus.loaded,
          notices: res.dataList ?? [],
        ));
      } else {
        emit(state.copyWith(
          status: NoticeStatus.error,
          errorMessage: res.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: NoticeStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCreateNotice(
    CreateNotice event,
    Emitter<NoticeState> emit,
  ) async {
    emit(state.copyWith(
      actionId: 'create',
      errorMessage: '',
      successMessage: '',
    ));

    try {
      final res = await noticeRepository.createNotice(
        event.text,
        event.bgColor,
        event.textColor,
      );

      if (res.isSuccess && res.data != null) {
        final List<NoticeModel> updated = List.from(state.notices)..insert(0, res.data!);
        emit(state.copyWith(
          notices: updated,
          successMessage: res.message != null && res.message!.isNotEmpty ? res.message : 'Notice created successfully',
          actionId: '',
        ));
      } else {
        emit(state.copyWith(
          errorMessage: res.message,
          actionId: '',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: e.toString(),
        actionId: '',
      ));
    }
  }

  Future<void> _onDeleteNotice(
    DeleteNotice event,
    Emitter<NoticeState> emit,
  ) async {
    emit(state.copyWith(
      actionId: event.id,
      errorMessage: '',
      successMessage: '',
    ));

    try {
      final res = await noticeRepository.deleteNotice(event.id);

      if (res.isSuccess) {
        final List<NoticeModel> updated = state.notices.where((n) => n.id != event.id).toList();
        
        emit(state.copyWith(
          notices: updated,
          successMessage: res.message != null && res.message!.isNotEmpty ? res.message : 'Notice deleted',
          actionId: '',
        ));
      } else {
        emit(state.copyWith(
          errorMessage: res.message,
          actionId: '',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: e.toString(),
        actionId: '',
      ));
    }
  }
}
