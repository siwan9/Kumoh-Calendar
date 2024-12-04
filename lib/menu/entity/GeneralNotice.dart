class GeneralNotice {
  final int noticeId;
  final String noticeType;
  final String title;
  final String author;
  final String date;
  final String url;

  GeneralNotice(this.noticeId, this.noticeType, this.title, this.author,
      this.date, this.url);

  factory GeneralNotice.fromJson(Map<String, dynamic> json) {
    return GeneralNotice(
      json['noticeId'] as int,
      json['noticeType'] as String,
      json['title'] as String,
      json['author'] as String,
      json['date'] as String,
      json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'noticeId': noticeId,
      'noticeType': noticeType,
      'title': title,
      'author': author,
      'date': date,
      'url': url,
    };
  }
}
