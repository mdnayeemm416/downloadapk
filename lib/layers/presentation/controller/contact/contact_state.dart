part of 'contact_bloc.dart';

enum ContactStatus { initial, loading, success, failure }

class ContactState extends Equatable {
  final ContactStatus status;
  final String errorMessage;
  const ContactState({this.status = ContactStatus.initial, this.errorMessage = ''});

  ContactState copyWith({ContactStatus? status, String? errorMessage}) {
    return ContactState(status: status ?? this.status, errorMessage: errorMessage ?? this.errorMessage);
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
