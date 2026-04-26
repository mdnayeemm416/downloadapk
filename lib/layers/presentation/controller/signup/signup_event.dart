part of 'signup_bloc.dart';

abstract class SignupEvent extends Equatable {
  const SignupEvent();

  @override
  List<Object?> get props => [];
}

class SignupSubmitted extends SignupEvent {
  final String firstName;
  final String lastName;
  final String userName;
  final String email;
  final String password;
  final String confirmPassword;

  const SignupSubmitted({
    required this.firstName,
    required this.userName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    userName,
    email,
    password,
    confirmPassword,
  ];
}

class ToggleSignupPasswordVisibility extends SignupEvent {
  const ToggleSignupPasswordVisibility();
}

class ToggleConfirmPasswordVisibility extends SignupEvent {
  const ToggleConfirmPasswordVisibility();
}

class SelectGender extends SignupEvent {
  final Gender gender;
  const SelectGender(this.gender);

  @override
  List<Object?> get props => [gender];
}
