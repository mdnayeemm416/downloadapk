import 'package:adnetwork/layers/data/repo/remote/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'signup_event.dart';
part 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final AuthRepository authRepository;

  SignupBloc({required this.authRepository}) : super(const SignupState()) {
    on<SignupSubmitted>(_onSignupSubmitted);
    on<ToggleSignupPasswordVisibility>(_onTogglePassword);
    on<ToggleConfirmPasswordVisibility>(_onToggleConfirmPassword);
    on<SelectGender>(_onSelectGender);
  }

  Future<void> _onSignupSubmitted(
    SignupSubmitted event,
    Emitter<SignupState> emit,
  ) async {
    if (event.firstName.isEmpty ||
        event.userName.isEmpty ||
        event.lastName.isEmpty ||
        event.email.isEmpty ||
        event.password.isEmpty ||
        event.confirmPassword.isEmpty) {
      emit(
        state.copyWith(
          status: SignupStatus.failure,
          errorMessage: 'Please fill in all fields',
        ),
      );
      return;
    }

    if (state.selectedGender == null) {
      emit(
        state.copyWith(
          status: SignupStatus.failure,
          errorMessage: 'Please select your gender',
        ),
      );
      return;
    }

    if (event.password != event.confirmPassword) {
      emit(
        state.copyWith(
          status: SignupStatus.failure,
          errorMessage: 'Passwords do not match',
        ),
      );
      return;
    }

    emit(state.copyWith(status: SignupStatus.loading, errorMessage: ''));

    try {
      // Map form fields to API: username = "$firstName $lastName", bio = gender

      final response = await authRepository.register(
        firstName: event.firstName,
        lastName: event.lastName,
        username: event.userName,
        email: event.email,
        password: event.password,
        gender: state.selectedGender?.name,
      );

      if (response.isSuccess) {
        emit(state.copyWith(status: SignupStatus.success));
      } else {
        emit(
          state.copyWith(
            status: SignupStatus.failure,
            errorMessage: response.message ?? 'Registration failed',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: SignupStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onTogglePassword(
    ToggleSignupPasswordVisibility event,
    Emitter<SignupState> emit,
  ) {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  void _onToggleConfirmPassword(
    ToggleConfirmPasswordVisibility event,
    Emitter<SignupState> emit,
  ) {
    emit(
      state.copyWith(isConfirmPasswordVisible: !state.isConfirmPasswordVisible),
    );
  }

  void _onSelectGender(SelectGender event, Emitter<SignupState> emit) {
    emit(state.copyWith(selectedGender: event.gender));
  }
}
