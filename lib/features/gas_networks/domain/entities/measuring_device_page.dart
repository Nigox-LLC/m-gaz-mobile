import 'package:equatable/equatable.dart';

import 'measuring_device_document.dart';

/// One page of measuring-device documents plus the cursor to the next page.
/// [nextUrl] is the backend's absolute `next` link (null when the last page is
/// reached).
class MeasuringDevicePage extends Equatable {
  final List<MeasuringDeviceDocument> items;
  final String? nextUrl;

  const MeasuringDevicePage({required this.items, this.nextUrl});

  bool get hasReachedMax => nextUrl == null;

  @override
  List<Object?> get props => [items, nextUrl];
}
