part of 'campaign_bloc.dart';

abstract class CampaignEvent extends Equatable {
  const CampaignEvent();
  @override
  List<Object?> get props => [];
}

class LoadCampaignFeed extends CampaignEvent {
  const LoadCampaignFeed();
}

class LoadMyCampaigns extends CampaignEvent {
  const LoadMyCampaigns();
}

class AddCampaignLink extends CampaignEvent {
  final String url;
  final String? title;
  final String? description;

  const AddCampaignLink({
    required this.url,
    this.title,
    this.description,
  });

  @override
  List<Object?> get props => [url, title, description];
}

class DeleteCampaignLink extends CampaignEvent {
  final String id;
  const DeleteCampaignLink(this.id);

  @override
  List<Object?> get props => [id];
}

class LikeCampaignLink extends CampaignEvent {
  final String id;
  const LikeCampaignLink(this.id);

  @override
  List<Object?> get props => [id];
}

class ClearCampaignErrors extends CampaignEvent {
  const ClearCampaignErrors();
}

class LoadCampaignCompletions extends CampaignEvent {
  const LoadCampaignCompletions();
}
