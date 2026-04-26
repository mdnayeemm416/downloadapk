import 'package:adnetwork/core/services/token_storage.dart';
import 'package:adnetwork/layers/data/repo/remote/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;

  LoginBloc({required this.authRepository}) : super(const LoginState()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<TogglePasswordVisibility>(_onTogglePasswordVisibility);
    on<ToggleRememberMe>(_onToggleRememberMe);
    on<InitializeRememberMe>(_onInitializeRememberMe);
  }

  void _onInitializeRememberMe(InitializeRememberMe event, Emitter<LoginState> emit) {
    emit(state.copyWith(isRememberMe: event.value));
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    // Basic validation
    if (event.email.isEmpty || event.password.isEmpty) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'Please fill in all fields',
        ),
      );
      return;
    }

    emit(state.copyWith(status: LoginStatus.loading, errorMessage: ''));

    try {
      final response = await authRepository.login(
        email: event.email,
        password: event.password,
      );

      if (response.isSuccess && response.data != null) {
        // Save token
        final token = response.data!.token;
        if (token != null) {
          await TokenStorage.instance.saveToken(token);
        }

        // Save user ID
        final userId = response.data!.user?.id;
        if (userId != null) {
          await TokenStorage.instance.saveUserId(userId);
        }

        // Cache credentials if Remember Me is checked, otherwise clear them
        if (state.isRememberMe) {
          await TokenStorage.instance.saveCredentials(event.email, event.password);
        } else {
          await TokenStorage.instance.clearCredentials();
        }

        // Clear manual logout flag
        await TokenStorage.instance.setManualLogout(false);

        emit(state.copyWith(status: LoginStatus.success));
      } else {
        emit(
          state.copyWith(
            status: LoginStatus.failure,
            errorMessage: response.message ?? 'Login failed',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(status: LoginStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  void _onTogglePasswordVisibility(
    TogglePasswordVisibility event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  void _onToggleRememberMe(ToggleRememberMe event, Emitter<LoginState> emit) {
    emit(state.copyWith(isRememberMe: !state.isRememberMe));
  }
}
