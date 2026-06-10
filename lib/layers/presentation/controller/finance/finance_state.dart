part of 'finance_bloc.dart';

enum FinanceStatus { initial, loading, loaded, logging, success, error }

class FinanceState extends Equatable {
  final FinanceStatus status;
  final FinanceSummaryModel? summary;
  final String errorMessage;
  final String successMessage;
  final String activeCycle;
  final String activeNamespace;

  const FinanceState({
    this.status = FinanceStatus.initial,
    this.summary,
    this.errorMessage = '',
    this.successMessage = '',
    this.activeCycle = '',
    this.activeNamespace = 'all',
  });

  FinanceState copyWith({
    FinanceStatus? status,
    FinanceSummaryModel? summary,
    String? errorMessage,
    String? successMessage,
    String? activeCycle,
    String? activeNamespace,
  }) {
    return FinanceState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      activeCycle: activeCycle ?? this.activeCycle,
      activeNamespace: activeNamespace ?? this.activeNamespace,
    );
  }

  @override
  List<Object?> get props => [
        status,
        summary,
        errorMessage,
        successMessage,
        activeCycle,
        activeNamespace,
      ];
}
