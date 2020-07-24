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
    return MaterialApp(
      title: 'Startup Name Generator',
      home: OfferList(),
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => OfferList(),
        '/subpage': (BuildContext context) => OfferDetail()
      },
    );
  }
}

class Offer {
  Offer({this.id, this.title, this.imageUrl, this.content});

  final int id;
  final String title;
  final String imageUrl;
  final String content;
  factory Offer.fromJson(Map<String, dynamic> json) => Offer(
      id: json["id"],
      title: json["title"],
      imageUrl: json["imageUrl"],
      content: json["content"]);
}

class Request {
  Request({this.request});
  final Offer request;

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(request: Offer.fromJson(json["request"]));
  }
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

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (isLastPage) return;
      startLoader();
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    startLoader();
  }

  void startLoader() {
    setState(() {
      loading = !loading;
      _load();
    });
  }

  Future<void> _load() async {
    if (isLastPage) return;
    try {
      var url =
          "https://baity2-stg-api.herokuapp.com/api/search_requests?page=${page.toString()}&per=10";
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
        loading = false;
      });
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
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
                                  debugPrint("ss");
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

class OfferList extends StatefulWidget {
  @override
  OfferListState createState() => new OfferListState();
}

class OfferDetail extends StatefulWidget {
  final String offerId;
  OfferDetail({Key key, this.offerId}) : super(key: key);
  @override
  OfferDetailState createState() => OfferDetailState();
}

class OfferDetailState extends State<OfferDetail> {
  Offer offer;
  bool loading = false;
  bool fetched = false;
  String offerId;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  void startLoader() {
    setState(() {
      loading = !loading;
      _load();
    });
  }

  Future<void> _load() async {
    try {
      var url = "https://baity2-stg-api.herokuapp.com/api/requests/${offerId}";
      var resp = await http.get(url);
      var data = Request.fromJson(json.decode(resp.body));
      setState(() {
        debugPrint(data.request.imageUrl);
        if (data != null && data.request is Offer) {
          offer = data.request;
        }
        loading = false;
        fetched = true;
      });
    } finally {}
  }

  Widget _buildSuggestions() {
    if (loading) {
      return Container();
    } else if (offer == null) {
      return Text("求人がありません");
    } else {
      debugPrint(offer.toString());
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
    offerId = ModalRoute.of(context).settings.arguments;
    print("aa");
    if (!fetched) {
      startLoader();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Startup Name Generator'),
      ),
      body: LoadingOverlay(child: _buildSuggestions(), isLoading: loading),
    );
  }
}
