import 'package:equatable/equatable.dart';
import 'package:http_parser/http_parser.dart';

/// {@template multi_part_form_mime_type}
/// Represents the MIME type for a multi-part form file.
/// {@endtemplate}
class MultiPartFormMimeType extends Equatable {
  //#region Initializers

  /// {@macro multi_part_form_mime_type}
  const MultiPartFormMimeType({
    required this.subType,
    required this.type,
  });

  /// {@macro multipart_form_file}
  factory MultiPartFormMimeType.csv() {
    return const MultiPartFormMimeType(subType: 'csv', type: 'text');
  }

  /// {@macro multipart_form_file}
  factory MultiPartFormMimeType.jpeg() {
    return const MultiPartFormMimeType(subType: 'jpeg', type: 'image');
  }

  /// {@macro multipart_form_file}
  factory MultiPartFormMimeType.pdf() {
    return const MultiPartFormMimeType(subType: 'pdf', type: 'application');
  }

  /// {@macro multipart_form_file}
  factory MultiPartFormMimeType.png() {
    return const MultiPartFormMimeType(subType: 'png', type: 'image');
  }

  //#endregion

  /// The subtype of the media type.
  final String subType;

  /// The type of the media type.
  final String type;

  /// The list of properties that will be used to determine whether
  /// two instances are equal.
  @override
  List<Object?> get props => [
        subType,
        type,
      ];
}

/// {@template multi_part_form_file}
/// Represents a file to be included in a multipart form data request.
/// {@endtemplate}
class MultiPartFormFile extends Equatable {
  //#region Initializers

  /// {@macro multi_part_form_file}
  const MultiPartFormFile({
    required this.mimeType,
    required this.path,
    this.name,
  });

  //#endregion

  /// The media type of the file.
  MediaType get mediaType {
    return MediaType(mimeType.type, mimeType.subType);
  }

  /// The mime type of the file.
  final MultiPartFormMimeType mimeType;

  /// The name of the file.
  final String? name;

  /// The path of the file to upload.
  final String path;

  /// The list of properties that will be used to determine whether
  /// two instances are equal.
  @override
  List<Object?> get props => [
        mediaType,
        mimeType,
        name,
        path,
      ];

  //#region Instance methods

  /// Returns the basename of the file.
  String getName() {
    return name ?? path.split('/').last;
  }

  //#endregion
}
