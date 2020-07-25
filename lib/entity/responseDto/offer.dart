import 'package:helloworld/entity/offer.dart';

class OfferResponseDto {
  OfferResponseDto({this.request});
  final Offer request;

  factory OfferResponseDto.fromJson(Map<String, dynamic> json) {
    return OfferResponseDto(request: Offer.fromJson(json["request"]));
  }
}
