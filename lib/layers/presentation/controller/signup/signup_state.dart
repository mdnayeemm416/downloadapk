part of 'signup_bloc.dart';

enum SignupStatus { initial, loading, success, failure }

enum Gender { male, female, other }

class SignupState extends Equatable {
  final SignupStatus status;
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final Gender? selectedGender;
  final String errorMessage;

  const SignupState({
    this.status = SignupStatus.initial,
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
    this.selectedGender,
    this.errorMessage = '',
  });

  SignupState copyWith({
    SignupStatus? status,
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
    Gender? selectedGender,
    String? errorMessage,
  }) {
    return SignupState(
      status: status ?? this.status,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible:
          isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
      selectedGender: selectedGender ?? this.selectedGender,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        isPasswordVisible,
        isConfirmPasswordVisible,
        selectedGender,
        errorMessage,
      ];
}
