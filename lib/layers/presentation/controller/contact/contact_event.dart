part of 'contact_bloc.dart';

abstract class ContactEvent extends Equatable {
  const ContactEvent();
  @override
  List<Object?> get props => [];
}

class SubmitContact extends ContactEvent {
  final String name;
  final String email;
  final String message;
  const SubmitContact({required this.name, required this.email, required this.message});
  @override
  List<Object?> get props => [name, email, message];
}
