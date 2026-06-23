import 'package:adnetwork/layers/data/model/campaign_link_model.dart';
import 'package:adnetwork/layers/data/repo/remote/campaign_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'campaign_event.dart';
part 'campaign_state.dart';

class CampaignBloc extends Bloc<CampaignEvent, CampaignState> {
  final CampaignRepository campaignRepository;

  CampaignBloc({required this.campaignRepository}) : super(const CampaignState()) {
    on<LoadCampaignFeed>(_onLoadFeed);
    on<LoadMyCampaigns>(_onLoadMyCampaigns);
    on<AddCampaignLink>(_onAddCampaignLink);
    on<DeleteCampaignLink>(_onDeleteCampaignLink);
    on<LikeCampaignLink>(_onLikeCampaignLink);
    on<ClearCampaignErrors>(_onClearErrors);
    on<LoadCampaignCompletions>(_onLoadCompletions);
  }

  void _onClearErrors(ClearCampaignErrors event, Emitter<CampaignState> emit) {
    emit(state.copyWith(
      feedErrorMessage: '',
      myLinksErrorMessage: '',
      actionMessage: '',
      actionStatus: CampaignActionStatus.initial,
    ));
  }

  Future<void> _onLoadFeed(LoadCampaignFeed event, Emitter<CampaignState> emit) async {
    emit(state.copyWith(feedStatus: CampaignStatus.loading, feedErrorMessage: ''));
    try {
      final response = await campaignRepository.getCampaignFeed();
      if (response.isSuccess) {
        final links = response.dataList ?? <CampaignLinkModel>[];
        
        int updatedCompletions = state.completionsCount;
        final hasNoAdsToView = links.where((l) => !l.isLiked).isEmpty;
        if (hasNoAdsToView) {
          try {
            final completeResponse = await campaignRepository.completeCampaign();
            if (completeResponse.isSuccess && completeResponse.data != null) {
              updatedCompletions = completeResponse.data!;
            }
          } catch (_) {}
        }

        emit(state.copyWith(
          feedStatus: CampaignStatus.loaded,
          feedLinks: links,
          completionsCount: updatedCompletions,
        ));
      } else {
        emit(state.copyWith(
          feedStatus: CampaignStatus.error,
          feedErrorMessage: response.message ?? 'Failed to load campaign feed',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        feedStatus: CampaignStatus.error,
        feedErrorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadMyCampaigns(LoadMyCampaigns event, Emitter<CampaignState> emit) async {
    emit(state.copyWith(myLinksStatus: CampaignStatus.loading, myLinksErrorMessage: ''));
    try {
      final response = await campaignRepository.getMyCampaignLinks();
      if (response.isSuccess) {
        final links = response.dataList ?? <CampaignLinkModel>[];
        emit(state.copyWith(
          myLinksStatus: CampaignStatus.loaded,
          myLinks: links,
        ));
      } else {
        emit(state.copyWith(
          myLinksStatus: CampaignStatus.error,
          myLinksErrorMessage: response.message ?? 'Failed to load my campaigns',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        myLinksStatus: CampaignStatus.error,
        myLinksErrorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAddCampaignLink(AddCampaignLink event, Emitter<CampaignState> emit) async {
    emit(state.copyWith(actionStatus: CampaignActionStatus.loading, actionMessage: ''));
    try {
      final response = await campaignRepository.createCampaignLink(
        url: event.url,
        title: event.title,
        description: event.description,
      );
      if (response.isSuccess && response.data != null) {
        emit(state.copyWith(
          actionStatus: CampaignActionStatus.success,
          actionMessage: response.message ?? 'Campaign link added successfully',
          myLinks: [response.data!, ...state.myLinks],
        ));
      } else {
        emit(state.copyWith(
          actionStatus: CampaignActionStatus.error,
          actionMessage: response.message ?? 'Failed to add campaign link',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        actionStatus: CampaignActionStatus.error,
        actionMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteCampaignLink(DeleteCampaignLink event, Emitter<CampaignState> emit) async {
    emit(state.copyWith(actionStatus: CampaignActionStatus.loading, actionMessage: ''));

    // Optimistic UI update
    final originalMyLinks = List<CampaignLinkModel>.from(state.myLinks);
    emit(state.copyWith(
      myLinks: state.myLinks.where((l) => l.id != event.id).toList(),
    ));

    try {
      final response = await campaignRepository.deleteCampaignLink(event.id);
      if (response.isSuccess) {
        emit(state.copyWith(
          actionStatus: CampaignActionStatus.success,
          actionMessage: response.message ?? 'Campaign link deleted successfully',
        ));
      } else {
        emit(state.copyWith(
          actionStatus: CampaignActionStatus.error,
          actionMessage: response.message ?? 'Failed to delete campaign link',
          myLinks: originalMyLinks,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        actionStatus: CampaignActionStatus.error,
        actionMessage: e.toString(),
        myLinks: originalMyLinks,
      ));
    }
  }

  Future<void> _onLikeCampaignLink(LikeCampaignLink event, Emitter<CampaignState> emit) async {
    emit(state.copyWith(actionStatus: CampaignActionStatus.loading, actionMessage: ''));
    try {
      final response = await campaignRepository.likeCampaignLink(event.id);
      if (response.isSuccess) {
        // Update isLiked in the feed list
        final feedLinks = List<CampaignLinkModel>.from(state.feedLinks);
        final idx = feedLinks.indexWhere((l) => l.id == event.id);
        if (idx != -1) {
          final link = feedLinks[idx];
          feedLinks[idx] = link.copyWith(
            isLiked: true,
            likeCount: link.likeCount + 1,
            globalLikes: link.globalLikes + 1,
          );
        }

        int updatedCompletions = state.completionsCount;
        final hasNoAdsToView = feedLinks.where((l) => !l.isLiked).isEmpty;
        if (hasNoAdsToView) {
          try {
            final completeResponse = await campaignRepository.completeCampaign();
            if (completeResponse.isSuccess && completeResponse.data != null) {
              updatedCompletions = completeResponse.data!;
            }
          } catch (_) {}
        }

        emit(state.copyWith(
          actionStatus: CampaignActionStatus.success,
          actionMessage: response.message ?? 'Campaign completed successfully',
          feedLinks: feedLinks,
          completionsCount: updatedCompletions,
        ));
      } else {
        emit(state.copyWith(
          actionStatus: CampaignActionStatus.error,
          actionMessage: response.message ?? 'Failed to like campaign link',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        actionStatus: CampaignActionStatus.error,
        actionMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadCompletions(LoadCampaignCompletions event, Emitter<CampaignState> emit) async {
    try {
      final response = await campaignRepository.getMyCompletions();
      if (response.isSuccess && response.data != null) {
        emit(state.copyWith(completionsCount: response.data));
      }
    } catch (_) {}
  }
}
