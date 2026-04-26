part of 'login_bloc.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  final LoginStatus status;
  final bool isPasswordVisible;
  final bool isRememberMe;
  final String errorMessage;

  const LoginState({
    this.status = LoginStatus.initial,
    this.isPasswordVisible = false,
    this.isRememberMe = false,
    this.errorMessage = '',
  });

  LoginState copyWith({
    LoginStatus? status,
    bool? isPasswordVisible,
    bool? isRememberMe,
    String? errorMessage,
  }) {
    return LoginState(
      status: status ?? this.status,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isRememberMe: isRememberMe ?? this.isRememberMe,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        isPasswordVisible,
        isRememberMe,
        errorMessage,
      ];
}
