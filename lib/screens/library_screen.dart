import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:ebook/models/response/book_detail.dart';
import 'package:ebook/models/response/book_list.dart';
import 'package:ebook/models/response/downloaded_book.dart';
import 'package:ebook/network/rest_apis.dart';
import 'package:ebook/utils/common.dart';
import 'package:ebook/utils/constants.dart';
import 'package:ebook/utils/database_helper.dart';
import 'package:ebook/utils/permissions.dart';
import 'package:ebook/utils/widgets.dart';
import 'package:nb_utils/nb_utils.dart';

import '../app_localizations.dart';

class LibraryScreen extends StatefulWidget {
  static String tag = '/LibraryScreen';

  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with AfterLayoutMixin<LibraryScreen> {
  double width;
  List<DownloadedBook> purchasedList = [];
  List<DownloadedBook> sampleList = [];
  List<DownloadedBook> downloadedList = [];

  bool isLoading = false;
  ReceivePort _port = ReceivePort();
  final dbHelper = DatabaseHelper.instance;
  var isDataLoaded = false;

  showLoading(bool show) {
    setState(() {
      isLoading = show;
    });
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    _bindBackgroundIsolate(context);
    FlutterDownloader.registerCallback(downloadCallback);

    fetchData(context);
  }

  void _bindBackgroundIsolate(context) {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate(context);
      return;
    }
    _port.listen((dynamic data) {
      print('UI Isolate Callback: $data');
      String id = data[0];
      final task = purchasedList?.firstWhere((task) => task.taskId == id);
      if (task != null) {
        if (data[1] == DownloadTaskStatus.complete) {
          fetchData(context);
        }
        setState(() {
          task.status = data[1];
        });
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    print(
        'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  DownloadedBook isExists(List<DownloadedBook> tasks, BookDetail mBookDetail) {
    DownloadedBook exist;
    tasks.forEach((task) {
      if (task.bookId == mBookDetail.bookId.toString() &&
          task.fileType == "purchased") {
        exist = task;
      }
    });
    if (exist == null) {
      exist = defaultBook(mBookDetail, "purchased");
    }
    return exist;
  }

  void fetchData(context) async {
    showLoading(true);
    List<DownloadTask> tasks = await FlutterDownloader.loadTasks();
    List<DownloadedBook> books = await dbHelper.queryAllRows();
    if (books.isNotEmpty && tasks.isNotEmpty) {
      List<DownloadedBook> samples = [];
      List<DownloadedBook> downloaded = [];
      books.forEach((DownloadedBook book) {
        var task = tasks.firstWhere((task) => task.taskId == book.taskId);
        if (task != null) {
          book.mDownloadTask = task;
          book.status = task.status;
          if (book.fileType == "sample") {
            samples.add(book);
          }
          if (book.fileType == "purchased") {
            downloaded.add(book);
          }
        }
      });
      setState(() {
        sampleList.clear();
        downloadedList.clear();
        sampleList.addAll(samples);
        downloadedList.addAll(downloaded);
      });
    } else {
      setState(() {
        sampleList.clear();
        downloadedList.clear();
      });
    }

    if (getBoolAsync(IS_LOGGED_IN)) {
      purchasedBookList().then((result) async {
        BookListResponse response = BookListResponse.fromJson(result);

        await setValue(LIBRARY_DATA, jsonEncode(response));
        setLibraryData(response, books, tasks);
        showLoading(false);
        setState(() {
          isDataLoaded = true;
        });
      }).catchError((error) async {
        showLoading(false);
        toast(error.toString());
        setLibraryData(
            BookListResponse.fromJson(jsonDecode(getStringAsync(LIBRARY_DATA))),
            books,
            tasks);
      });
    } else {
      setState(() {
        isDataLoaded = true;
      });
      showLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    var purchased = purchasedList.isNotEmpty
        ? getList(purchasedList, context)
        : Center(
            child: Text(keyString(context, "err_no_books_purchased"),
                style: primaryTextStyle(
                    color: context.theme.textTheme.headline6.color, size: 18)),
          ).visible(isDataLoaded);
    var samples = sampleList.isNotEmpty
        ? getList(sampleList, context)
        : Center(
            child: Text(keyString(context, "err_no_sample_books_downloaded"),
                style: primaryTextStyle(
                    color: context.theme.textTheme.headline6.color, size: 18)),
          ).visible(isDataLoaded);
    var downloaded = downloadedList.isNotEmpty
        ? getList(downloadedList, context)
        : Center(
            child: Text(keyString(context, "err_no_books_downloaded"),
                style: primaryTextStyle(
                    color: context.theme.textTheme.headline6.color, size: 18)),
          ).visible(isDataLoaded);

    return Container(
      color: context.scaffoldBackgroundColor,
      child: Stack(
        children: <Widget>[
          DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: getBoolAsync(IS_LOGGED_IN)
                  ? AppBar(
                      backgroundColor: context.scaffoldBackgroundColor,
                      iconTheme: context.theme.iconTheme,
                      centerTitle: true,
                      bottom: PreferredSize(
                        preferredSize: Size(double.infinity, 50),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: TabBar(
                            isScrollable: false,
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicatorColor:
                                context.theme.textTheme.headline6.color,
                            labelPadding: EdgeInsets.only(left: 10, right: 10),
                            tabs: [
                              Tab(
                                  child: Text(keyString(context, "lbl_samples"),
                                      style: boldTextStyle(
                                          color: context.theme.textTheme
                                              .headline6.color))),
                              Tab(
                                  child: Text(
                                      keyString(context, "lbl_purchased"),
                                      style: boldTextStyle(
                                          color: context.theme.textTheme
                                              .headline6.color))),
                              Tab(
                                  child: Text(
                                      keyString(context, "lbl_downloaded"),
                                      style: boldTextStyle(
                                          color: context.theme.textTheme
                                              .headline6.color))),
                            ],
                          ),
                        ),
                      ),
                      title: Text(keyString(context, "lbl_my_library"),
                          style: boldTextStyle(
                              color: context.theme.textTheme.headline6.color,
                              size: 22)))
                  : AppBar(
                      backgroundColor: context.scaffoldBackgroundColor,
                      iconTheme: context.theme.iconTheme,
                      centerTitle: true,
                      title: Text(keyString(context, "lbl_samples"),
                          style: boldTextStyle(
                              color: context.theme.textTheme.headline6.color))),
              body: getBoolAsync(IS_LOGGED_IN)
                  ? TabBarView(
                      children: [
                        samples,
                        purchased,
                        downloaded,
                      ],
                    )
                  : samples,
            ),
          ),
          Center(
            child: Loader(),
          ).visible(isLoading)
        ],
      ),
    );
  }

  onBookClick(context, DownloadedBook mSampleDownloadTask) async {
    if (await Permissions.storageGranted()) {
      if (mSampleDownloadTask.status == DownloadTaskStatus.undefined) {
        var id = await requestDownload(
            context: context,
            downloadTask: mSampleDownloadTask,
            isSample: false);
        setState(() {
          mSampleDownloadTask.taskId = id;
          mSampleDownloadTask.status = DownloadTaskStatus.running;
        });
        await dbHelper.insert(mSampleDownloadTask);
      } else if (mSampleDownloadTask.status == DownloadTaskStatus.failed) {
        var id = await retryDownload(mSampleDownloadTask.taskId);
        setState(() {
          mSampleDownloadTask.taskId = id;
        });
      } else if (mSampleDownloadTask.status == DownloadTaskStatus.complete) {
        readFile(context, mSampleDownloadTask.mDownloadTask.filename,
            mSampleDownloadTask.bookName);
      } else {
        toast(mSampleDownloadTask.bookName +
            " " +
            keyString(context, "lbl_is_downloading"));
      }
    }
  }

  remove(DownloadedBook task, context) async {
    await delete(task.taskId);
    await dbHelper.delete(task.id);
    fetchData(context);
  }

  Widget getList(List<DownloadedBook> list, BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 16,
        children: list.map((e) {
          DownloadedBook bookDetail = list[list.indexOf(e)];
          return Container(
            padding: EdgeInsets.only(left: 8),
            width: context.width() / 2 - 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    onBookClick(context, bookDetail);
                  },
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: <Widget>[
                      cachedImage(bookDetail.frontCover,
                              fit: BoxFit.fill,
                              height: 250,
                              width: context.width() / 2)
                          .cornerRadiusWithClipRRect(8),
                      bookDetail.status == DownloadTaskStatus.undefined
                          ? Container(
                              margin: EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.5)),
                              padding: EdgeInsets.all(4.0),
                              child: Icon(Icons.file_download,
                                  size: 14, color: Colors.white))
                          : bookDetail.status == DownloadTaskStatus.complete
                              ? InkWell(
                                  onTap: () {
                                    remove(bookDetail, context);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.all(4.0),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black.withOpacity(0.2)),
                                    padding: EdgeInsets.all(4.0),
                                    child: Icon(Icons.delete,
                                        size: 14, color: Colors.red),
                                  ),
                                )
                              : Container()
                    ],
                  ),
                ),
                8.height,
                Text(
                  bookDetail.bookName,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: boldTextStyle(
                      color: context.theme.textTheme.headline6.color),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  void setLibraryData(BookListResponse response, List<DownloadedBook> books,
      List<DownloadTask> tasks) {
    List<DownloadedBook> purchased = [];

    if (response.data.isNotEmpty) {
      DownloadedBook book;
      response.data.forEach((bookDetail) {
        if (books != null && books.isNotEmpty) {
          book = isExists(books, bookDetail);
          if (book.taskId != null) {
            var task = tasks.firstWhere((task) => task.taskId == book.taskId);
            book.mDownloadTask = task;
            book.status = task.status;
          } else {
            book = defaultBook(bookDetail, "purchased");
            book.mDownloadTask = defaultTask(bookDetail.filePath);
          }
        } else {
          book = defaultBook(bookDetail, "purchased");
          book.mDownloadTask = defaultTask(bookDetail.filePath);
        }
        purchased.add(book);
      });
      setState(() {
        purchasedList.clear();
        purchasedList.addAll(purchased);
      });
    }
  }
}
