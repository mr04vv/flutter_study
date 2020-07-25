import 'package:flutter/material.dart';
import 'package:helloworld/entity/responseDto/offer.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

import 'entity/offer.dart';

class OfferDetail extends StatelessWidget {
  void startLoader(BuildContext context, String offerId) {
    _load(context, offerId);
  }

  Future<void> _load(BuildContext context, String offerId) async {
    final store = context.select((OfferStore store) => store);
    try {
      var url = "https://baity2-stg-api.herokuapp.com/api/requests/${offerId}";
      var resp = await http.get(url);
      var data = OfferResponseDto.fromJson(json.decode(resp.body));
      if (data != null && data.request is Offer) {
        store.setOffer(data.request);
      }
      store.setIsLoading(false);
      store.setFetched(true);
    } finally {}
  }

  Widget _buildSuggestions(BuildContext context) {
    final store = context.select((OfferStore store) => store);
    final loading = store.loading;
    final offer = store.offer;
    if (loading) {
      return Container();
    } else if (offer == null) {
      return Text("求人がありません");
    } else {
      return SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.only(left: 30, right: 30),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    height: 150,
                    child: Center(
                        child: Image.network(
                      offer.imageUrl,
                      fit: BoxFit.cover,
                      width: 300,
                    )),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Center(child: Text(offer.title)),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    child: Column(
                      children: <Widget>[
                        Align(
                          child: Text(
                            "業務内容",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          alignment: Alignment.centerLeft,
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 20),
                          child: Text(offer.content),
                        )
                      ],
                    ),
                  ),
                ],
              )));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.select((OfferStore store) => store.loading);
    final fetched = context.select((OfferStore store) => store.fetched);
    final offerId = ModalRoute.of(context).settings.arguments;
    if (!fetched && offerId != null) {
      startLoader(context, offerId);
    }
    return Scaffold(
        appBar: AppBar(
          title: Text('求人詳細'),
        ),
        body: LoadingOverlay(
            child: _buildSuggestions(context), isLoading: loading));
  }
}

class OfferStore with ChangeNotifier {
  Offer offer;
  bool loading = true;
  bool fetched = false;

  void setOffer(Offer offer) {
    this.offer = offer;
    notifyListeners();
  }

  void setIsLoading(bool loading) {
    this.loading = loading;
    notifyListeners();
  }

  void setFetched(bool fetched) {
    this.fetched = fetched;
    notifyListeners();
  }
}
