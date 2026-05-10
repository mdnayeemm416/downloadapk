part of 'login_bloc.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  final LoginStatus status;
  final bool isPasswordVisible;
  final bool isRememberMe;
  final String errorMessage;
  final String forgotPasswordSuccessMessage;

  const LoginState({
    this.status = LoginStatus.initial,
    this.isPasswordVisible = false,
    this.isRememberMe = false,
    this.errorMessage = '',
    this.forgotPasswordSuccessMessage = '',
  });

  LoginState copyWith({
    LoginStatus? status,
    bool? isPasswordVisible,
    bool? isRememberMe,
    String? errorMessage,
    String? forgotPasswordSuccessMessage,
  }) {
    return LoginState(
      status: status ?? this.status,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isRememberMe: isRememberMe ?? this.isRememberMe,
      errorMessage: errorMessage ?? this.errorMessage,
      forgotPasswordSuccessMessage:
          forgotPasswordSuccessMessage ?? this.forgotPasswordSuccessMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        isPasswordVisible,
        isRememberMe,
        errorMessage,
        forgotPasswordSuccessMessage,
      ];
}
