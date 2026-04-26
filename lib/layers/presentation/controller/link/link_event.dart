part of 'link_bloc.dart';

abstract class LinkEvent extends Equatable {
  const LinkEvent();
  @override
  List<Object?> get props => [];
}

class LoadMyLinks extends LinkEvent {
  const LoadMyLinks();
}

class AddLink extends LinkEvent {
  final String url;
  final String? title;
  final String? description;
  final String? tags;

  const AddLink({
    required this.url,
    this.title,
    this.description,
    this.tags,
  });

  @override
  List<Object?> get props => [url, title, description, tags];
}

class UpdateLink extends LinkEvent {
  final String linkId;
  final String? url;
  final String? title;
  final String? description;
  final String? tags;

  const UpdateLink({
    required this.linkId,
    this.url,
    this.title,
    this.description,
    this.tags,
  });

  @override
  List<Object?> get props => [linkId, url, title, description, tags];
}

class DeleteLink extends LinkEvent {
  final String linkId;
  const DeleteLink(this.linkId);
  @override
  List<Object?> get props => [linkId];
}

class ClearLinkError extends LinkEvent {
  const ClearLinkError();
}
