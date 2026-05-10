part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

/// Fired when the user submits the login form
class LoginSubmitted extends LoginEvent {
  final String email;
  final String password;

  const LoginSubmitted({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Toggles the password visibility in the form
class TogglePasswordVisibility extends LoginEvent {
  const TogglePasswordVisibility();
}

/// Toggles the "Remember Me" checkbox
class ToggleRememberMe extends LoginEvent {
  const ToggleRememberMe();
}

/// Sets the "Remember Me" checkbox explicitly
class InitializeRememberMe extends LoginEvent {
  final bool value;
  const InitializeRememberMe(this.value);
  
  @override
  List<Object?> get props => [value];
}

/// Fired when the user requests a password reset
class ForgotPasswordSubmitted extends LoginEvent {
  final String identifier;
  const ForgotPasswordSubmitted(this.identifier);

  @override
  List<Object?> get props => [identifier];
}
