part of 'campaign_bloc.dart';

enum CampaignStatus { initial, loading, loaded, error }
enum CampaignActionStatus { initial, loading, success, error }

class CampaignState extends Equatable {
  final CampaignStatus feedStatus;
  final CampaignStatus myLinksStatus;
  final List<CampaignLinkModel> feedLinks;
  final List<CampaignLinkModel> myLinks;
  final String feedErrorMessage;
  final String myLinksErrorMessage;
  final int completionsCount;

  final CampaignActionStatus actionStatus;
  final String actionMessage;

  // New fields for Lightweight Campaign Status
  final CampaignStatusModel? campaignStatus;
  final CampaignStatus statusLoadStatus;

  const CampaignState({
    this.feedStatus = CampaignStatus.initial,
    this.myLinksStatus = CampaignStatus.initial,
    this.feedLinks = const [],
    this.myLinks = const [],
    this.feedErrorMessage = '',
    this.myLinksErrorMessage = '',
    this.completionsCount = 0,
    this.actionStatus = CampaignActionStatus.initial,
    this.actionMessage = '',
    this.campaignStatus,
    this.statusLoadStatus = CampaignStatus.initial,
  });

  CampaignState copyWith({
    CampaignStatus? feedStatus,
    CampaignStatus? myLinksStatus,
    List<CampaignLinkModel>? feedLinks,
    List<CampaignLinkModel>? myLinks,
    String? feedErrorMessage,
    String? myLinksErrorMessage,
    int? completionsCount,
    CampaignActionStatus? actionStatus,
    String? actionMessage,
    CampaignStatusModel? campaignStatus,
    CampaignStatus? statusLoadStatus,
  }) {
    return CampaignState(
      feedStatus: feedStatus ?? this.feedStatus,
      myLinksStatus: myLinksStatus ?? this.myLinksStatus,
      feedLinks: feedLinks ?? this.feedLinks,
      myLinks: myLinks ?? this.myLinks,
      feedErrorMessage: feedErrorMessage ?? this.feedErrorMessage,
      myLinksErrorMessage: myLinksErrorMessage ?? this.myLinksErrorMessage,
      completionsCount: completionsCount ?? this.completionsCount,
      actionStatus: actionStatus ?? this.actionStatus,
      actionMessage: actionMessage ?? this.actionMessage,
      campaignStatus: campaignStatus ?? this.campaignStatus,
      statusLoadStatus: statusLoadStatus ?? this.statusLoadStatus,
    );
  }

  @override
  List<Object?> get props => [
        feedStatus,
        myLinksStatus,
        feedLinks,
        myLinks,
        feedErrorMessage,
        myLinksErrorMessage,
        completionsCount,
        actionStatus,
        actionMessage,
        campaignStatus,
        statusLoadStatus,
      ];
}
