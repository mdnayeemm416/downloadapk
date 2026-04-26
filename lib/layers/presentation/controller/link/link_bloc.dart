import 'package:adnetwork/layers/data/model/link_model.dart';
import 'package:adnetwork/layers/data/repo/remote/link_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'link_event.dart';
part 'link_state.dart';

class LinkBloc extends Bloc<LinkEvent, LinkState> {
  final LinkRepository linkRepository;

  LinkBloc({required this.linkRepository}) : super(const LinkState()) {
    on<LoadMyLinks>(_onLoad);
    on<AddLink>(_onAdd);
    on<UpdateLink>(_onUpdate);
    on<DeleteLink>(_onDelete);
    on<ClearLinkError>(_onClearError);
  }

  void _onClearError(ClearLinkError event, Emitter<LinkState> emit) {
    emit(state.copyWith(errorMessage: ''));
  }

  Future<void> _onLoad(LoadMyLinks event, Emitter<LinkState> emit) async {
    emit(state.copyWith(status: LinkStatus.loading, links: []));

    try {
      // Load user's personal links using the dedicated /mylinks endpoint
      final response = await linkRepository.getMyLinks();

      if (response.isSuccess) {
        final links = response.dataList ?? <LinkModel>[];
        emit(state.copyWith(status: LinkStatus.loaded, links: links));
      } else {
        emit(state.copyWith(
          status: LinkStatus.loaded,
          errorMessage: response.message ?? 'Failed to load links',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: LinkStatus.loaded,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAdd(AddLink event, Emitter<LinkState> emit) async {
    try {
      final response = await linkRepository.createLink(
        title: event.title ?? event.url,
        url: event.url,
        description: event.description,
        tags: event.tags,
      );

      if (response.isSuccess && response.data != null) {
        emit(state.copyWith(
          links: [response.data!, ...state.links],
          errorMessage: '',
        ));
      } else {
        // Handle 403 (max upload limits)
        emit(state.copyWith(
          errorMessage: response.message ?? 'Failed to create link',
        ));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdate(UpdateLink event, Emitter<LinkState> emit) async {
    try {
      final response = await linkRepository.updateLink(
        event.linkId,
        url: event.url,
        title: event.title,
        description: event.description,
        tags: event.tags,
      );

      if (response.isSuccess && response.data != null) {
        final links = List<LinkModel>.from(state.links);
        final idx = links.indexWhere((l) => l.id == event.linkId);
        if (idx != -1) {
          links[idx] = response.data!;
          emit(state.copyWith(links: links, errorMessage: ''));
        }
      } else {
        emit(state.copyWith(
            errorMessage: response.message ?? 'Failed to update link'));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onDelete(DeleteLink event, Emitter<LinkState> emit) async {
    // Optimistic UI update: Remove the item eagerly to prevent Dismissible crash
    final originalLinks = List<LinkModel>.from(state.links);
    
    emit(state.copyWith(
      links: state.links.where((l) => l.id != event.linkId).toList(),
      errorMessage: '',
    ));

    try {
      final response = await linkRepository.deleteLink(event.linkId);

      if (!response.isSuccess) {
        // Rollback if the API call fails
        emit(state.copyWith(
            links: originalLinks,
            errorMessage: response.message ?? 'Failed to delete link'));
      }
    } catch (e) {
      // Rollback on exception
      emit(state.copyWith(
          links: originalLinks, 
          errorMessage: e.toString()));
    }
  }
}
