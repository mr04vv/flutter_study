import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'offer.dart';
import 'offerList.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      home: ChangeNotifierProvider(
          create: (context) => OfferListStore(), child: OfferList()),
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => ChangeNotifierProvider(
            create: (context) => OfferListStore(), child: OfferList()),
        '/subpage': (BuildContext context) => ChangeNotifierProvider(
            create: (context) => OfferStore(), child: OfferDetail())
      },
    );
  }
}
