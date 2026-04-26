import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'contact_event.dart';
part 'contact_state.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  ContactBloc() : super(const ContactState()) {
    on<SubmitContact>(_onSubmit);
  }

  Future<void> _onSubmit(SubmitContact event, Emitter<ContactState> emit) async {
    if (event.email.isEmpty || event.message.isEmpty) {
      emit(state.copyWith(status: ContactStatus.failure, errorMessage: 'Please fill all fields'));
      return;
    }
    emit(state.copyWith(status: ContactStatus.loading));
    await Future.delayed(const Duration(seconds: 1));
    emit(state.copyWith(status: ContactStatus.success));
  }
}
