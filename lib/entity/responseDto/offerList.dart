import 'package:helloworld/entity/meta.dart';
import 'package:helloworld/entity/offer.dart';

class OfferListResponseDto {
  OfferListResponseDto({this.requests, this.meta});
  final List<Offer> requests;
  final Meta meta;

  factory OfferListResponseDto.fromJson(Map<String, dynamic> json) {
    return OfferListResponseDto(
        requests: json["requests"]
            .map<Offer>((json) => Offer.fromJson(json))
            .toList(),
        meta: Meta.fromJson(json["meta"]));
  }
}
