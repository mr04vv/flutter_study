class Meta {
  Meta({this.nextPage});
  final int nextPage;
  factory Meta.fromJson(Map<String, dynamic> json) =>
      Meta(nextPage: json["nextPage"]);
}
