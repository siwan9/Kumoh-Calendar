class Notice {
  final String noticeType;
  final String title;
  final String author;
  final String date;
  final String url;

  Notice(this.noticeType, this.title, this.author, this.date, this.url);

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      json['noticeType'] as String,
      json['title'] as String,
      json['author'] as String,
      json['date'] as String,
      json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'noticeType': noticeType,
      'title': title,
      'author': author,
      'date': date,
      'url': url,
    };
  }
}
