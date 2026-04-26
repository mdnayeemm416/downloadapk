part of 'link_bloc.dart';

enum LinkStatus { initial, loading, loaded }

class LinkState extends Equatable {
  final LinkStatus status;
  final List<LinkModel> links;
  final String errorMessage;

  const LinkState({this.status = LinkStatus.initial, this.links = const [], this.errorMessage = ''});

  LinkState copyWith({LinkStatus? status, List<LinkModel>? links, String? errorMessage}) {
    return LinkState(
      status: status ?? this.status,
      links: links ?? this.links,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, links, errorMessage];
}
