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
