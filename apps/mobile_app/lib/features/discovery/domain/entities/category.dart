import 'package:equatable/equatable.dart';

/// Represents a service category (e.g. Haircut, Spa, Massage).
class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    required this.iconUrl,
    required this.sortOrder,
    this.parentId,
  });

  final String id;
  final String name;
  final String iconUrl;
  final String? parentId;
  final int sortOrder;

  @override
  List<Object?> get props => [id, name, iconUrl, parentId, sortOrder];
}
