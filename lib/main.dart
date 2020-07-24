import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:loading_overlay/loading_overlay.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Startup Name Generator', home: OfferList());
  }
}

class Offer {
  Offer({this.id, this.title, this.imageUrl});

  final int id;
  final String title;
  final String imageUrl;
  factory Offer.fromJson(Map<String, dynamic> json) =>
      Offer(id: json["id"], title: json["title"], imageUrl: json["imageUrl"]);
}

class Meta {
  Meta({this.nextPage});
  final int nextPage;
  factory Meta.fromJson(Map<String, dynamic> json) =>
      Meta(nextPage: json["nextPage"]);
}

class Requests {
  Requests({this.requests, this.meta});
  final List<Offer> requests;
  final Meta meta;

  factory Requests.fromJson(Map<String, dynamic> json) {
    return Requests(
        requests: json["requests"]
            .map<Offer>((json) => Offer.fromJson(json))
            .toList(),
        meta: Meta.fromJson(json["meta"]));
  }
}

class OfferListState extends State<OfferList> {
  int page = 1;
  final _suggestions = <WordPair>[];
  final _biggerFont = const TextStyle(fontSize: 18.0);
  List<Offer> offers;
  bool loading = false;
  bool isLastPage = false;

  ScrollController _scrollController;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _load();
  }

  onPressMyButton() async {
    //ローディングを表示
    setState(() {
      loading = true;
    });
  }

  Future<void> _load() async {
    try {
      loading = true;

      var url =
          "https://baity2-stg-api.herokuapp.com/api/search_requests?page=${page.toString()}&per=20";
      var resp = await http.get(url);
      var data = Requests.fromJson(json.decode(resp.body));
      setState(() {
        page += 1;
        if (data.meta.nextPage == null) {
          isLastPage = true;
        }
        if (data.requests is List<Offer>) {
          if (offers == null) {
            offers = <Offer>[];
          }
          data.requests.forEach((Offer elem) {
            if (elem is Offer) {
              offers.add(elem);
            }
          });
        }
      });
      loading = false;
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(loading.toString());
    return Scaffold(
      appBar: AppBar(
        title: Text('Startup Name Generator'),
      ),
      body: LoadingOverlay(child: _buildSuggestions(), isLoading: loading),
    );
  }

  Widget _buildSuggestions() {
    var length = offers?.length ?? 0;
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          if (i == length) {
            if (isLastPage) {
              return null;
            }
            if (loading) {
              return null;
            }
            // アイテム数を超えたので次のページを読み込む
            _load();
            // 画面にはローディング表示しておく
            return Center(
              child: Container(
                margin: EdgeInsets.only(top: 8.0),
                width: 32.0,
                height: 32.0,
                child: CircularProgressIndicator(),
              ),
            );
          } else if (i > length) {
            // ローディング表示より先は無し
            return null;
          }
          // アイテムがあるので返す
          var offer = offers[i];
          return new Container(
            height: 120,
            decoration: new BoxDecoration(
              border: new Border(
                bottom: new BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Center(
                child: new ListTile(
              key: new ValueKey<String>(offer.id.toString()),
              leading: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 104,
                  minHeight: 134,
                  maxWidth: 104,
                  maxHeight: 134,
                ),
                child: Image.network(offer.imageUrl, fit: BoxFit.cover),
              ),
              title: new Text(offer.title),
            )),
          );
        });
  }
}

class OfferList extends StatefulWidget {
  @override
  OfferListState createState() => new OfferListState();
}
