import 'dart:isolate';
import 'dart:ui';

import 'package:ebook/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

import 'package:ebook/models/response/author.dart';
import 'package:ebook/models/response/base_response.dart';
import 'package:ebook/models/response/book_detail.dart';
import 'package:ebook/models/response/book_rating.dart';
import 'package:ebook/models/response/downloaded_book.dart';
import 'package:ebook/network/common_api_calls.dart';
import 'package:ebook/network/rest_apis.dart';
import 'package:ebook/screens/sign_in_screen.dart';
import 'package:ebook/utils/common.dart';
import 'package:ebook/utils/constants.dart';
import 'package:ebook/utils/database_helper.dart';
import 'package:ebook/utils/permissions.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nb_utils/nb_utils.dart';

import 'package:share/share.dart';

// ignore: must_be_immutable
class BookGridActionButton extends StatefulWidget {
  BookDetail bookDetail;

  BookGridActionButton({Key key, this.bookDetail}) : super(key: key);

  @override
  _BookGridActionButtonState createState() => _BookGridActionButtonState();
}

class _BookGridActionButtonState extends State<BookGridActionButton> {
  final dbHelper = DatabaseHelper.instance;

  BookDetail mBookDetail;
  AuthorDetail mAuthorDetail;
  BookRating userReviewData;

  List<BookRating> bookRating = [];

  TextEditingController controller = TextEditingController();

  double rating = 0.0;

  ReceivePort _port = ReceivePort();

  DownloadedBook mSampleDownloadTask;
  DownloadedBook mBookDownloadTask;

  bool isExistInCart = false;
  bool mIsFirstTime = true;
  bool isLoading = false;

  // BannerAd _bannerAd;

  @override
  void initState() {
    super.initState();
    /// 2.seconds.delay.then((value) => setStatusBarColor(
    ///     Theme.of(context).cardTheme.color,
    ///     statusBarBrightness: Brightness.light));
    if (widget.bookDetail != null) {
      mBookDetail = widget.bookDetail;
      setState(() {});
    }

    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    // _bannerAd?.dispose();

    super.dispose();
  }

  void showLoading(bool show) {
    isLoading = show;
    setState(() {});
  }

  void loadBookFromOffline() async {
    if (mBookDetail != null) {
      DownloadedBook sampleBook;
      DownloadedBook purchaseBook;
      var sampleTask;
      var purchaseTask;
      List<DownloadedBook> list =
          await dbHelper.queryRowBook(mBookDetail.bookId.toString());
      List<DownloadTask> tasks = await FlutterDownloader.loadTasks();
      if (list != null && list.isNotEmpty) {
        list.forEach((book) {
          if (book.fileType == "sample") {
            sampleBook = book;
            sampleTask =
                tasks?.firstWhere((task) => task.taskId == book.taskId);
          }
          if (book.fileType == "purchased") {
            purchaseBook = book;
            purchaseTask =
                tasks?.firstWhere((task) => task.taskId == book.taskId);
          }
        });
      }
      if (sampleTask == null) {
        sampleTask = defaultTask(mBookDetail.fileSamplePath);
      }

      if (purchaseTask == null) {
        purchaseTask = defaultTask(mBookDetail.filePath);
      }
      if (sampleBook == null) {
        sampleBook = defaultBook(mBookDetail, "sample");
      }
      if (purchaseBook == null) {
        purchaseBook = defaultBook(mBookDetail, "purchased");
      }
      sampleBook.mDownloadTask = sampleTask;
      sampleBook.status = sampleTask.status;
      purchaseBook.mDownloadTask = purchaseTask;
      purchaseBook.status = purchaseTask.status;
      setState(() {
        mSampleDownloadTask = sampleBook;
        mBookDownloadTask = purchaseBook;
      });
    }
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      if (data[1] == DownloadTaskStatus.complete) {
        loadBookFromOffline();
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

  void addRemoveToWishList(isWishList) async {
    bool result =
        await addRemoveWishList(context, mBookDetail.bookId, isWishList);
    if (result) {
      setState(() {});
    }
  }

  void addBookToCart() {
    isNetworkAvailable().then((bool) {
      if (bool) {
        showLoading(true);

        var request = {
          "book_id": mBookDetail.bookId,
          "added_qty": 1,
          "user_id": getIntAsync(USER_ID)
        };
        addToCart(request).then((result) {
          BaseResponse response = BaseResponse.fromJson(result);
          if (response.status) {
            LiveStream().emit(CART_ITEM_CHANGED, true);
            setState(() {});
          } else {
            showLoading(false);
            toast(response.message);
          }
        }).catchError((error) {
          showLoading(false);
          toast(error.toString());
        });
      } else {
        toast(keyString(context, "error_network_no_internet"));
      }
    });
  }

  void sampleClick(context) async {
    if (await Permissions.storageAndAudioGranted()) {
      if (mSampleDownloadTask.status == DownloadTaskStatus.undefined) {
        var id = await requestDownload(
            context: context,
            downloadTask: mSampleDownloadTask,
            isSample: true);
        log(id);
        mSampleDownloadTask.taskId = id;
        mSampleDownloadTask.status = DownloadTaskStatus.running;
        log("Pending ${mSampleDownloadTask.status.toString()}");

        await dbHelper.insert(mSampleDownloadTask);
      } else if (mSampleDownloadTask.status == DownloadTaskStatus.complete) {
        log("Complete ${mSampleDownloadTask.status.toString()}");
        readFile(context, mSampleDownloadTask.mDownloadTask.filename,
            mBookDetail.name);
      } else {
        toast('Downloading');
      }
      setState(() {});
    }
  }

  void readBook(context) async {
    if (await Permissions.storageAndAudioGranted()) {
      print("filename= ${mBookDownloadTask.mDownloadTask.filename}");
      if (mBookDownloadTask.mDownloadTask.status ==
          DownloadTaskStatus.undefined) {
        var id = await requestDownload(
            context: context, downloadTask: mBookDownloadTask, isSample: false);
        setState(() {
          mBookDownloadTask.taskId = id;
          mBookDownloadTask.status = DownloadTaskStatus.running;
        });
        await dbHelper.insert(mBookDownloadTask);
      } else if (mBookDownloadTask.status == DownloadTaskStatus.complete) {
        readFile(context, mBookDownloadTask.mDownloadTask.filename,
            mBookDetail.name);
      } else {
        toast('Downloading');
      }
    }
  }

  IconData getCenter() {
    if (mSampleDownloadTask.status == DownloadTaskStatus.running) {
      return Icons.pause;
    } else if (mSampleDownloadTask.status == DownloadTaskStatus.paused) {
      return Icons.play_arrow;
    } else if (mSampleDownloadTask.status == DownloadTaskStatus.failed) {
      return Icons.refresh;
    }
    return Icons.refresh;
  }

  @override
  Widget build(BuildContext context) {
    Widget buildActionForTask() {
      if (mSampleDownloadTask == null) {
        return Text(keyString(context, "lbl_download_sample"),
            style: primaryTextStyle(
                color: context.theme.textTheme.headline6.color));
      }
      if (mSampleDownloadTask.status == DownloadTaskStatus.undefined) {
        return Text(keyString(context, "lbl_download_sample"),
            style: primaryTextStyle(
                color: context.theme.textTheme.headline6.color));
      } else if (mSampleDownloadTask.status == DownloadTaskStatus.complete) {
        return Text(keyString(context, "lbl_view_sample"),
            style: primaryTextStyle(
                color: context.theme.textTheme.headline6.color));
      } else {
        return Text(keyString(context, "lbl_downloading"),
            style: primaryTextStyle(
                color: context.theme.textTheme.headline6.color));
      }
    }

    Widget buttonWidget() {
      return Row(
        children: <Widget>[
          AppButton(
            color: Theme.of(context).cardTheme.color,
            child: buildActionForTask(),
            onTap: () async {
              if (await Permissions.storageGranted()) {
                sampleClick(context);
              }
            },
          ).expand(),
          16.width,
          mBookDetail.isPurchase == 0 && mBookDetail.price != 0
              ? AppButton(
                  color: Theme.of(context).colorScheme.secondary,
                  child: Text('Add to Cart',
                      style: boldTextStyle(color: Colors.white)),
                  onTap: () {
                    if (getBoolAsync(IS_LOGGED_IN)) {
                      if (isExistInCart) {
                        toast("Already exist in cart");
                      } else {
                        addBookToCart();
                        LiveStream().on("updateCart", (status) {
                          if (status ?? false) {
                            setState(() {});
                          }
                        });
                      }
                    } else {
                      SignInScreen().launch(context);
                    }
                  },
                ).expand()
              : Offstage(),
          mBookDetail.isPurchase == 1 || mBookDetail.price == 0
              ? AppButton(
                  color: Theme.of(context).colorScheme.secondary,
                  child: Text('Read Book',
                      style: boldTextStyle(color: Colors.white)),
                  onTap: () {
                    readBook(context);
                  },
                ).expand()
              : Offstage()
        ],
      );
    }

    return PopupMenuButton(
      constraints: BoxConstraints(minWidth: 200),
      padding: EdgeInsets.zero,
      itemBuilder: (_) => [
        PopupMenuItem(
          onTap: () {
            if (getBoolAsync(IS_LOGGED_IN)) {
              if (isExistInCart) {
                toast("Already exist in cart");
              } else {
                addBookToCart();
                LiveStream().on("updateCart", (status) {
                  if (status ?? false) {
                    setState(() {});
                  }
                });
              }
            } else {
              SignInScreen().launch(context);
            }
          },
          child: Row(
            children: [
              Icon(MdiIcons.creditCardOutline, size: 19).paddingRight(10),
              Expanded(child: Text(keyString(context, "lbl_buy_now"))),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () async {
            if (await Permissions.storageGranted()) {
              sampleClick(context);
            }
          },
          child: Row(
            children: [
              Icon(MdiIcons.download, size: 19).paddingRight(10),
              Expanded(child: Text(keyString(context, "lbl_samples"))),
            ],
          ),
        ),
        PopupMenuItem(
          enabled: mBookDetail.isPurchase == 0,
          onTap: () {
            if (getBoolAsync(IS_LOGGED_IN)) {
              setState(() {
                mBookDetail.isWishList = mBookDetail.isWishList == 0 ? 1 : 0;
              });
              addRemoveToWishList(mBookDetail.isWishList);
            } else {
              SignInScreen().launch(context);
            }
          },
          child: Row(
            children: [
              Icon(
                      mBookDetail.isWishList
                                  .toString()
                                  .toInt()
                                  .validate(value: 0) ==
                              0
                          ? MdiIcons.bookmarkOutline
                          : MdiIcons.bookmark,
                      size: 19)
                  .paddingRight(10),
              Expanded(child: Text(keyString(context, "lbl_wish_list"))),
            ],
          ),
        ),

        /// share
        PopupMenuItem(
          onTap: () {
            Share.share(mBookDetail.name +
                " by " +
                mBookDetail.authorName +
                "\n" +
                mBaseUrl +
                "book/detail/" +
                mBookDetail.bookId.toString());
          },
          child: Row(
            children: [
              Icon(MdiIcons.shareVariantOutline, size: 19).paddingRight(10),
              Expanded(child: Text(keyString(context, "lbl_share_app"))),
            ],
          ),
        )
      ],
      child: Icon(MdiIcons.dotsVertical, size: 19),
    );
  }
}
