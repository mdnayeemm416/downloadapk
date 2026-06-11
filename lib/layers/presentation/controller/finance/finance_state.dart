part of 'finance_bloc.dart';

enum FinanceStatus { initial, loading, loaded, logging, success, error }

class FinanceState extends Equatable {
  final FinanceStatus status;
  final FinanceSummaryModel? summary;
  final FinanceStatus detailStatus;
  final DailyDetailModel? dailyDetail;
  final String errorMessage;
  final String successMessage;
  final String activeCycle;
  final String activeNamespace;
  final String? activeDetailDate;

  const FinanceState({
    this.status = FinanceStatus.initial,
    this.summary,
    this.detailStatus = FinanceStatus.initial,
    this.dailyDetail,
    this.errorMessage = '',
    this.successMessage = '',
    this.activeCycle = '',
    this.activeNamespace = 'all',
    this.activeDetailDate,
  });

  FinanceState copyWith({
    FinanceStatus? status,
    FinanceSummaryModel? summary,
    FinanceStatus? detailStatus,
    DailyDetailModel? dailyDetail,
    String? errorMessage,
    String? successMessage,
    String? activeCycle,
    String? activeNamespace,
    String? activeDetailDate,
  }) {
    return FinanceState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      detailStatus: detailStatus ?? this.detailStatus,
      dailyDetail: dailyDetail ?? this.dailyDetail,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      activeCycle: activeCycle ?? this.activeCycle,
      activeNamespace: activeNamespace ?? this.activeNamespace,
      activeDetailDate: activeDetailDate ?? this.activeDetailDate,
    );
  }

  @override
  List<Object?> get props => [
        status,
        summary,
        detailStatus,
        dailyDetail,
        errorMessage,
        successMessage,
        activeCycle,
        activeNamespace,
        activeDetailDate,
      ];
}
