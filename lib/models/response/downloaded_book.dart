import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:ebook/models/response/book_detail.dart';

class DownloadedBook {
  int id;
  String taskId;
  String bookId;
  String bookName;
  String frontCover;
  String fileType;
  DownloadTask mDownloadTask;
  DownloadTaskStatus status = DownloadTaskStatus.undefined;

  DownloadedBook(
      {this.id,
      this.taskId,
      this.bookId,
      this.bookName,
      this.frontCover,
      this.fileType});

  factory DownloadedBook.fromJson(Map<String, dynamic> json) {
    return DownloadedBook(
      id: json['id'],
      taskId: json['task_id'],
      bookId: json['book_id'],
      bookName: json['book_name'],
      frontCover: json['front_cover'],
      fileType: json['file_type'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['task_id'] = this.taskId;
    data['book_id'] = this.bookId;
    data['book_name'] = this.bookName;
    data['front_cover'] = this.frontCover;
    data['file_type'] = this.fileType;
    return data;
  }
}

DownloadTask defaultTask(url) {
  return DownloadTask(
    status: DownloadTaskStatus.undefined,
    url: url,
  );
}

DownloadedBook defaultBook(BookDetail mBookDetail, fileType) {
  return DownloadedBook(
      bookId: mBookDetail.bookId.toString(),
      bookName: mBookDetail.name,
      frontCover: mBookDetail.frontCover,
      fileType: fileType);
}
