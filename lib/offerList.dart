import 'package:flutter/cupertino.dart';
import 'package:helloworld/entity/responseDto/offerList.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

import 'entity/offer.dart';

class OfferList extends StatefulWidget {
  OfferListState createState() => OfferListState();
}

class OfferListState extends State<OfferList> {
  ScrollController _scrollController;

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final store = context.read<OfferListStore>();
      if (store.isLastPage) return;
      store.setIsLoading(true);
      _load();
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() => _scrollListener());
    _load();
  }

  Future<void> _load() async {
    final store = context.read<OfferListStore>();
    final page = store.page;
    final offers = store.offers;
    try {
      var url =
          "https://baity2-stg-api.herokuapp.com/api/search_requests?page=${page.toString()}&per=10";
      var resp = await http.get(url);
      var data = OfferListResponseDto.fromJson(json.decode(resp.body));

      store.setPage(page + 1);
      if (data.meta.nextPage == null) {
        store.setIsLastPage(true);
      }
      if (data.requests is List<Offer>) {
        if (offers == null) {
          store.setOffer(<Offer>[]);
        } else {
          data.requests.forEach((Offer elem) {
            if (elem is Offer) {
              offers.add(elem);
            }
          });
          store.setOffer(offers);
        }
      }
      store.setIsLoading(false);
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('求人一覧'),
      ),
      body: LoadingOverlay(
          child: _buildSuggestions(
              context.select((OfferListStore store) => store.offers)),
          isLoading: context.select((OfferListStore store) => store.loading)),
    );
  }

  Widget _buildSuggestions(
    List<Offer> offers,
  ) {
    var length = offers?.length ?? 0;
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        controller: _scrollController,
        itemBuilder: (context, i) {
          if (length > i) {
            // アイテムがあるので返す
            var offer = offers[i];
            return new Container(
                height: 170,
                decoration: new BoxDecoration(
                  border: new Border(
                    bottom: new BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Center(
                    child: Container(
                        height: 500,
                        child: Card(
                            child: InkWell(
                                onTap: () {
                                  Navigator.of(context).pushNamed("/subpage",
                                      arguments: offer.id.toString());
                                  // Function is executed on tap.
                                },
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child: Image.network(
                                          offer.imageUrl,
                                          fit: BoxFit.cover,
                                          width: 100,
                                          height: 100,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child: Text(offer.title),
                                      ),
                                    ),
                                  ],
                                ))))));
          } else {
            return null;
          }
        });
  }
}

class OfferListStore with ChangeNotifier {
  List<Offer> offers = [];
  bool isLastPage = false;
  int page = 1;
  bool loading = true;

  void setOffer(List<Offer> offers) {
    this.offers = offers;
    notifyListeners();
  }

  void setIsLastPage(bool isLastPage) {
    this.isLastPage = isLastPage;
    notifyListeners();
  }

  void setPage(int page) {
    this.page = page;
    notifyListeners();
  }

  void setIsLoading(bool loading) {
    this.loading = loading;
    notifyListeners();
  }
}
