import 'dart:isolate';
import 'dart:ui';

import 'package:ebook/component/book_grid_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ebook/app_localizations.dart';
import 'package:ebook/component/book_product_component.dart';
import 'package:ebook/models/response/author.dart';
import 'package:ebook/models/response/base_response.dart';
import 'package:ebook/models/response/book_description.dart';
import 'package:ebook/models/response/book_detail.dart';
import 'package:ebook/models/response/book_rating.dart';
import 'package:ebook/models/response/downloaded_book.dart';
import 'package:ebook/network/rest_apis.dart';
import 'package:ebook/screens/book_reviews_screen.dart';
import 'package:ebook/screens/sign_in_screen.dart';
import 'package:ebook/utils/common.dart';
import 'package:ebook/utils/constants.dart';
import 'package:ebook/utils/database_helper.dart';
import 'package:ebook/utils/permissions.dart';
import 'package:ebook/utils/resources/colors.dart';
import 'package:ebook/utils/resources/images.dart';
import 'package:ebook/utils/widgets.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:share/share.dart';

// ignore: must_be_immutable
class BookDescriptionScreen2 extends StatefulWidget {
  BookDetail bookDetail;

  BookDescriptionScreen2({this.bookDetail});

  @override
  _BookDescriptionScreen2State createState() => _BookDescriptionScreen2State();
}

class _BookDescriptionScreen2State extends State<BookDescriptionScreen2>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TabController tabController;

  TextEditingController controller = TextEditingController();

  double rating = 0.0;
  final dbHelper = DatabaseHelper.instance;

  BookDetail mBookDetail;
  AuthorDetail mAuthorDetail;
  BookRating userReviewData;

  bool isLoading = false;
  bool isExistInCart = false;
  bool mIsFirstTime = true;

  List<BookRating> bookRating = [];

  ReceivePort _port = ReceivePort();
  DownloadedBook mSampleDownloadTask;
  DownloadedBook mBookDownloadTask;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    500.milliseconds.delay.then((value) => setStatusBarColor(
        context.scaffoldBackgroundColor,
        statusBarBrightness: Brightness.light));
    if (widget.bookDetail != null) {
      mBookDetail = widget.bookDetail;
      setState(() {});
    }

    tabController = TabController(length: 3, vsync: this);
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
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

  readBook(context) async {
    if (await Permissions.storageAndAudioGranted()) {
      if (mBookDownloadTask.mDownloadTask.status ==
          DownloadTaskStatus.undefined) {
        var id = await requestDownload(
            context: context, downloadTask: mBookDownloadTask, isSample: false);
        setState(() {
          mBookDownloadTask.taskId = id;
          mBookDownloadTask.status = DownloadTaskStatus.running;
        });
        log("jalsa ${mBookDownloadTask.status}");
      } else if (mBookDownloadTask.status == DownloadTaskStatus.complete) {
        log("jalsa ${mBookDownloadTask.status}");
        readFile(context, mBookDownloadTask.mDownloadTask.filename,
            mBookDetail.name);
      } else {
        toast('Downloading');
      }
    }
  }

  sampleClick(context) async {
    if (await Permissions.storageAndAudioGranted()) {
      if (mSampleDownloadTask.status == DownloadTaskStatus.undefined) {
        var id = await requestDownload(
            context: context,
            downloadTask: mSampleDownloadTask,
            isSample: true);
        setState(() {
          mSampleDownloadTask.taskId = id;
          mSampleDownloadTask.status = DownloadTaskStatus.running;
        });
        await dbHelper.insert(mSampleDownloadTask);
      } else if (mSampleDownloadTask.status == DownloadTaskStatus.complete) {
        readFile(context, mSampleDownloadTask.mDownloadTask.filename,
            mBookDetail.name);
      } else {
        toast('Downloading');
      }
    }
  }

  addRemoveWishList(context, int id, int isWishList) async {
    toast('processing');
    await isNetworkAvailable().then((bool) {
      if (bool) {
        var request = {"book_id": id, "is_wishlist": isWishList};
        addFavourite(request).then((result) {
          BaseResponse response = BaseResponse.fromJson(result);
          if (response.status) {
            LiveStream().emit(WISH_DATA_ITEM_CHANGED, true);
          }
        }).catchError((error) {
          toast(error.toString());
        });
      } else {
        toast(keyString(context, "error_network_no_internet"));
      }
    });
  }

  addRemoveToWishList(isWishList) async {
    bool result =
        await addRemoveWishList(context, mBookDetail.bookId, isWishList);
    if (result ?? false) {
      setState(() {});
    }
  }

  showLoading(bool show) {
    isLoading = show;
    setState(() {});
  }

  deleteBookRating(ratingId) async {
    isNetworkAvailable().then((bool) {
      if (bool) {
        showLoading(true);
        var request = {
          "id": userReviewData.ratingId,
        };
        deleteRating(request).then((result) {
          BaseResponse response = BaseResponse.fromJson(result);
          if (response.status) {
            setState(() {});
          } else {
            showLoading(false);
            toast(response.message);
          }
        }).catchError((error) {
          toast(error.toString());
          showLoading(false);
        });
      } else {
        toast(keyString(context, "error_network_no_internet"));
      }
    });
  }

  Future<void> submitReview(String text, double rating) async {
    var id = await getInt(USER_ID);
    isNetworkAvailable().then((bool) {
      if (bool) {
        if (userReviewData != null) {
          var request = {
            "book_id": mBookDetail.bookId,
            "user_id": id,
            "rating_id": userReviewData.ratingId,
            "rating": rating.toString(),
            "review": text
          };
          showLoading(true);

          updateBookRating(request).then((result) {
            BaseResponse response = BaseResponse.fromJson(result);
            if (response.status) {
              Navigator.of(context).pop();
              setState(() {});
            } else {
              showLoading(false);
              toast(response.message);
            }
            return response.status;
          }).catchError((error) {
            showLoading(false);
            toast(error.toString());
          });
        } else {
          var request = {
            "book_id": mBookDetail.bookId,
            "user_id": id,
            "rating": rating.toString(),
            "review": text,
            "message": "",
            "status": true
          };
          showLoading(true);
          addBookRating(request).then((result) {
            BaseResponse response = BaseResponse.fromJson(result);
            if (response.status) {
              Navigator.of(context).pop();
              setState(() {});
            } else {
              showLoading(false);
              toast(response.message);
            }
            return response.status;
          }).catchError((error) {
            toast(error.toString());
            showLoading(false);
          });
        }
      } else {
        toast(keyString(context, "error_network_no_internet"));
      }
    });
  }

  void showRatingDialog(BuildContext context) {
    showDialog<ConfirmAction>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Scaffold(
          backgroundColor: transparent,
          body: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width - 40,
                    decoration: boxDecorationWithShadow(
                        backgroundColor: Theme.of(context).cardTheme.color,
                        borderRadius: radius(10)),
                    child: Column(
                      children: <Widget>[
                        Text(keyString(context, "lbl_rateBook"),
                                style: boldTextStyle(
                                    size: 24,
                                    color: context
                                        .theme.textTheme.headline6.color))
                            .paddingAll(10.0),
                        Divider(
                          thickness: 0.5,
                        ),
                        RatingBar.builder(
                          initialRating: rating,
                          minRating: 0,
                          glow: false,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (v) {
                            rating = v;
                            setState(() {});
                          },
                        ).paddingAll(24.0),
                        Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: TextFormField(
                            controller: controller,
                            keyboardType: TextInputType.multiline,
                            maxLines: 5,
                            validator: (value) {
                              return value.isEmpty
                                  ? keyString(context, "error_review_requires")
                                  : null;
                            },
                            style: TextStyle(
                                fontFamily: font_regular,
                                fontSize: 16,
                                color: context.theme.textTheme.headline6.color),
                            decoration: new InputDecoration(
                              hintText: keyString(context, "aRate_hint"),
                              border: InputBorder.none,
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: context
                                        .theme.textTheme.headline6.color),
                              ),
                              labelStyle: TextStyle(
                                  fontSize: 16,
                                  color:
                                      context.theme.textTheme.headline6.color),
                              labelText: keyString(
                                  context, "hint_confirm_your_new_password"),
                              filled: false,
                            ),
                          ).paddingOnly(left: 24.0, right: 24.0),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Expanded(
                              child: MaterialButton(
                                textColor:
                                    context.theme.textTheme.headline6.color,
                                child: Text(
                                    keyString(context, "aRate_lbl_Cancel"),
                                    style: primaryTextStyle(
                                        color: context
                                            .theme.textTheme.headline6.color)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(5.0),
                                  side: BorderSide(
                                      color: context
                                          .theme.textTheme.headline6.color),
                                ),
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(ConfirmAction.CANCEL);
                                },
                              ).paddingOnly(right: 8.0),
                            ),
                            Expanded(
                              child: MaterialButton(
                                color: context.theme.textTheme.headline6.color,
                                textColor: Theme.of(context).cardTheme.color,
                                child: Text(keyString(context, "lbl_post"),
                                    style: primaryTextStyle(
                                        color: context
                                            .theme.textTheme.headline6.color)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(5.0),
                                ),
                                onPressed: () {
                                  final form = _formKey.currentState;
                                  if (form.validate()) {
                                    form.save();
                                    submitReview(controller.text, rating);
                                  }
                                },
                              ).paddingOnly(left: 8.0),
                            )
                          ],
                        ).paddingAll(24.0)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  addBookToCart() {
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

  Widget buildActionForTask() {
    if (mSampleDownloadTask == null) {
      return Text(keyString(context, "lbl_download_sample"),
          style:
              primaryTextStyle(color: context.theme.textTheme.headline6.color));
    }
    if (mSampleDownloadTask.status == DownloadTaskStatus.undefined) {
      return Text(keyString(context, "lbl_download_sample"),
          style:
              primaryTextStyle(color: context.theme.textTheme.headline6.color));
    } else if (mSampleDownloadTask.status == DownloadTaskStatus.complete) {
      return Text(keyString(context, "lbl_view_sample"),
          style:
              primaryTextStyle(color: context.theme.textTheme.headline6.color));
    } else {
      return Text(keyString(context, "lbl_downloading"),
          style:
              primaryTextStyle(color: context.theme.textTheme.headline6.color));
    }
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    buildActionForTask();
    return Scaffold(
      appBar: appBarWidget(
        widget.bookDetail.name.toString().validate(),
        color: context.scaffoldBackgroundColor,
        textColor: context.theme.textTheme.headline6.color,
        actions: [
          IconButton(
              icon: SvgPicture.asset(
                icon_share,
                color: context.theme.iconTheme.color,
              ),
              onPressed: () {
                Share.share(mBookDetail.name +
                    " by " +
                    mBookDetail.authorName +
                    "\n" +
                    mBaseUrl +
                    "book/detail/" +
                    mBookDetail.bookId.toString());
              }),
          IconButton(
              icon: SvgPicture.asset(
                  mBookDetail.isWishList == 0
                      ? icon_bookmark
                      : icon_bookmark_fill,
                  color: context.theme.iconTheme.color),
              onPressed: () {
                if (getBoolAsync(IS_LOGGED_IN)) {
                  setState(() {
                    mBookDetail.isWishList =
                        mBookDetail.isWishList == 0 ? 1 : 0;
                  });
                  addRemoveToWishList(mBookDetail.isWishList);
                } else {
                  SignInScreen().launch(context);
                }
              }).visible(mBookDetail.isPurchase == 0),
          cartIcon(context, getIntAsync(CART_COUNT)),
        ],
      ),
      body: body(),
    );
  }

  Widget body() {
    var request = {
      "book_id": widget.bookDetail.bookId,
      "user_id": getIntAsync(USER_ID)
    };

    return FutureBuilder<BookDescription>(
      future: getBookDetail(request),
      builder: (_, snap) {
        if (snap.hasData) {
          mBookDetail = snap.data.bookDetail.first;
          mAuthorDetail = snap.data.authorDetail.first;
          bookRating.addAll(snap.data.bookRatingData);
          userReviewData = snap.data.userReviewData;
          if (mIsFirstTime == true) {
            loadBookFromOffline();
            mIsFirstTime = false;
          }
          /*   if (userReviewData != null) {
            userReviewData.userName = getStringAsync(USERNAME);
          }*/
          return Container(
            child: NestedScrollView(
              headerSliverBuilder: (_, innerScrolled) {
                return [
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Container(
                          child: Stack(
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            children: [
                              Container(
                                height: context.height() * 0.30,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: Image.network(snap
                                            .data.bookDetail.first.frontCover
                                            .toString()
                                            .validate())
                                        .image,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: ClipRRect(
                                  child: BackdropFilter(
                                    filter:
                                        ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                    child: Container(
                                      padding:
                                          EdgeInsets.only(top: 22, left: 20),
                                      width: context.width(),
                                      color: Colors.black.withOpacity(0.1),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 30,
                                left: 8,
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: boxDecorationWithShadow(
                                        borderRadius: radiusOnly(
                                            topLeft: 8,
                                            topRight: 8,
                                            bottomLeft: 8,
                                            bottomRight: 8),
                                        spreadRadius: 2,
                                        blurRadius: 2,
                                        backgroundColor: context.cardColor,
                                        border: Border.all(
                                            color: Colors.white, width: 2.0),
                                        offset: Offset(3, 2),
                                      ),
                                      child: cachedImage(
                                        snap.data.bookDetail.first.frontCover,
                                        fit: BoxFit.fill,
                                        height: context.height() * 0.25,
                                        width: 140,
                                        radius: 0,
                                      ).cornerRadiusWithClipRRectOnly(
                                          topLeft: 8,
                                          topRight: 8,
                                          bottomLeft: 8,
                                          bottomRight: 8),
                                    ),
                                    16.width,
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          snap.data.bookDetail.first.name
                                              .toString()
                                              .validate()
                                              .capitalizeFirstLetter(),
                                          style: boldTextStyle(
                                              size: 20, color: Colors.white),
                                          maxLines: 4,
                                        ),
                                        8.height,
                                        Text(
                                          snap.data.bookDetail.first
                                              .categoryName
                                              .toString()
                                              .validate(),
                                          style: secondaryTextStyle(
                                              size: 18, color: Colors.white),
                                        ),
                                        8.height,
                                        Row(
                                          children: [
                                            Container(
                                              height: 30,
                                              width: 30,
                                              decoration:
                                                  boxDecorationWithShadow(
                                                      boxShape: BoxShape.circle,
                                                      backgroundColor:
                                                          context.cardColor),
                                              child: cachedImage(
                                                      mAuthorDetail.image
                                                          .toString()
                                                          .validate(),
                                                      fit: BoxFit.fill)
                                                  .cornerRadiusWithClipRRect(
                                                      80),
                                            ),
                                            6.width,
                                            Text(
                                                mAuthorDetail.name
                                                    .toString()
                                                    .validate(),
                                                style: primaryTextStyle(
                                                    size: 16,
                                                    color: Colors.white)),
                                          ],
                                        ),
                                        8.height,
                                        Container(
                                          margin: EdgeInsets.only(top: 12.0),
                                          padding: EdgeInsets.all(6),
                                          decoration:
                                              boxDecorationWithRoundedCorners(
                                            backgroundColor:
                                                context.theme.highlightColor,
                                            borderRadius: radius(8),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              RatingBar.builder(
                                                tapOnlyMode: true,
                                                initialRating: double.parse(
                                                    mBookDetail.totalRating
                                                        .toString()),
                                                minRating: 0,
                                                glow: false,
                                                itemSize: 15,
                                                direction: Axis.horizontal,
                                                allowHalfRating: true,
                                                itemCount: 5,
                                                itemPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 0.0),
                                                itemBuilder: (context, _) =>
                                                    Icon(Icons.star,
                                                        color: Colors.amber),
                                                onRatingUpdate: (v) {
                                                  rating = v;
                                                  setState(() {});
                                                  showRatingDialog(context);
                                                },
                                              ),
                                              Text(
                                                      double.parse(mBookDetail
                                                              .totalRating
                                                              .toStringAsFixed(
                                                                  1))
                                                          .toString(),
                                                      style: primaryTextStyle(
                                                          color: context
                                                              .theme
                                                              .textTheme
                                                              .headline6
                                                              .color))
                                                  .paddingOnly(left: 8),
                                            ],
                                          ),
                                        ),
                                        8.height,
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                                    mBookDetail
                                                                .discountedPrice !=
                                                            0
                                                        ? mBookDetail
                                                            .discountedPrice
                                                            .toString()
                                                            .toCurrencyFormat()
                                                        : mBookDetail
                                                            .price
                                                            .toString()
                                                            .toCurrencyFormat(),
                                                    style:
                                                        boldTextStyle(
                                                            color: context
                                                                .theme
                                                                .textTheme
                                                                .headline6
                                                                .color,
                                                            size: 22))
                                                .visible(mBookDetail
                                                            .discountedPrice !=
                                                        0 ||
                                                    mBookDetail.price != 0),
                                            Text(
                                                    mBookDetail.price
                                                        .toString()
                                                        .toCurrencyFormat(),
                                                    style: primaryTextStyle(
                                                        color: context
                                                            .theme
                                                            .textTheme
                                                            .headline6
                                                            .color,
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough))
                                                .paddingOnly(left: 8.0)
                                                .visible(
                                                    mBookDetail.discount != 0),
                                          ],
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            AppButton(
                              color: Theme.of(context).cardTheme.color,
                              child: buildActionForTask(),
                              onTap: () async {
                                sampleClick(context);
                              },
                            ).expand(),
                            16.width,
                            mBookDetail.isPurchase == 0 &&
                                    mBookDetail.price != 0
                                ? AppButton(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    child: Text('Add to Cart',
                                        style:
                                            boldTextStyle(color: Colors.white)),
                                    onTap: () {
                                      if (getBoolAsync(IS_LOGGED_IN)) {
                                        if (isExistInCart) {
                                          toast("Already exist in cart");
                                        } else {
                                          addBookToCart();

                                          LiveStream().on("updateCart",
                                              (status) {
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
                            mBookDetail.isPurchase == 1 ||
                                    mBookDetail.price == 0
                                ? AppButton(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    child: Text('Read Book',
                                        style:
                                            boldTextStyle(color: Colors.white)),
                                    onTap: () {
                                      readBook(context);
                                    },
                                  ).expand()
                                : Offstage()
                          ],
                        ).paddingSymmetric(horizontal: 8, vertical: 16)
                      ],
                    ),
                  ),
                ];
              },
              body: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    TabBar(
                      isScrollable: false,
                      controller: tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorColor: context.theme.textTheme.headline6.color,
                      labelPadding: EdgeInsets.only(left: 10, right: 10),
                      tabs: [
                        Tab(
                            child: Text("Overview",
                                style: boldTextStyle(
                                    color: context
                                        .theme.textTheme.headline6.color))),
                        Tab(
                            child: Text("Information",
                                style: boldTextStyle(
                                    color: context
                                        .theme.textTheme.headline6.color))),
                        Tab(
                            child: Text("Review",
                                style: boldTextStyle(
                                    color: context
                                        .theme.textTheme.headline6.color))),
                      ],
                    ),
                    TabBarView(
                      controller: tabController,
                      children: [
                        overViewWidget(snap),
                        informationWidget(snap),
                        reviewWidget(snap),
                      ],
                    ).expand(),
                  ],
                ),
              ),
            ),
          );
        }
        return snapWidgetHelper(snap);
      },
    );
  }

  Widget overViewWidget(AsyncSnapshot<BookDescription> snap) {
    return Container(
      child: ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: [
          Text(
            parseHtmlString(mBookDetail.description),
            style: primaryTextStyle(
                color: context.theme.textTheme.headline6.color),
          ).paddingAll(16),
          16.height,
          Row(
            children: [
              Text(keyString(context, "lbl_more_books_by_this_author"),
                      style: boldTextStyle(
                          size: 18,
                          color: context.theme.textTheme.headline6.color))
                  .visible(
                    snap.data.recommendedBook.isNotEmpty,
                  )
                  .expand(),
            ],
          ).paddingSymmetric(horizontal: 16),
          BookProductComponent(snap.data.authorBookList, isHorizontal: true),
          32.height,
          Row(
            children: [
              Text(keyString(context, "lnl_you_may_also_like"),
                      style: boldTextStyle(
                          size: 18,
                          color: context.theme.textTheme.headline6.color))
                  .visible(
                    snap.data.recommendedBook.isNotEmpty,
                  )
                  .expand(),
            ],
          ).paddingSymmetric(horizontal: 16),
          BookProductComponent(snap.data.recommendedBook)
        ],
      ),
    );
  }

  Widget reviewWidget(AsyncSnapshot<BookDescription> snap) {
    return Container(
      child: ListView(
        padding: EdgeInsets.all(16),
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          Row(
            children: [
              Text(keyString(context, "lbl_top_reviews"),
                      style: boldTextStyle(
                          color: context.theme.textTheme.headline6.color))
                  .expand(),
              Text(
                keyString(context, "lbl_view_all"),
                style: secondaryTextStyle(
                    color: Theme.of(context).textTheme.button.color),
              ).onTap(() {
                BookReviews(bookDetail: mBookDetail).launch(context);
              })
            ],
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: snap.data.bookRatingData.length <= 5
                ? snap.data.bookRatingData.length
                : 5,
            itemBuilder: (context, index) {
              BookRating bookRating = snap.data.bookRatingData[index];
              return review(context, bookRating, isUserReview: true,
                  callback: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Theme(
                      data: ThemeData(
                          canvasColor: context.scaffoldBackgroundColor),
                      child: AlertDialog(
                        title: Text(keyString(context, "lbl_confirmation")),
                        content: Text(keyString(context, "lbl_note_delete")),
                        actions: <Widget>[
                          AppButton(
                            child: Text(keyString(context, "close")),
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          AppButton(
                            child: Text(keyString(context, "lbl_ok")),
                            onTap: () {
                              Navigator.of(context).pop();
                              deleteBookRating(userReviewData.ratingId);
                            },
                          )
                        ],
                      ),
                    );
                  },
                );
              });
            },
          ),
          16.height,
          MaterialButton(
            minWidth: MediaQuery.of(context).size.width,
            elevation: 4.0,
            padding: EdgeInsets.fromLTRB(24, 10.0, 24, 10.0),
            color: Theme.of(context).cardTheme.color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
              side: BorderSide(color: Theme.of(context).cardTheme.color),
            ),
            child: Text(keyString(context, "lbl_write_review"),
                style: primaryTextStyle(
                    color: context.theme.textTheme.headline6.color)),
            onPressed: () async {
              if (getBoolAsync(IS_LOGGED_IN)) {
                showRatingDialog(context);
              } else {
                SignInScreen().launch(context);
              }
            },
          ).visible(userReviewData == null)
        ],
      ),
    );
  }

  Widget informationWidget(AsyncSnapshot<BookDescription> snap) {
    BookDetail authorDetail = snap.data.bookDetail.first;
    return Container(
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          SettingItemWidget(
            titleTextStyle: primaryTextStyle(
                color: context.theme.textTheme.subtitle2.color),
            title: "Category",
            trailing: Text(authorDetail.categoryName,
                style: primaryTextStyle(
                    color: context.theme.textTheme.headline6.color)),
          ),
          Divider(),
          SettingItemWidget(
            titleTextStyle: primaryTextStyle(
                color: context.theme.textTheme.subtitle2.color),
            title: "Created",
            trailing: Text(authorDetail.dateOfPublication,
                style: primaryTextStyle(
                    color: context.theme.textTheme.headline6.color)),
          ),
          Divider(),
          SettingItemWidget(
            titleTextStyle: primaryTextStyle(
                color: context.theme.textTheme.subtitle2.color),
            title: "Author",
            trailing: Text(authorDetail.authorName,
                style: primaryTextStyle(
                    color: context.theme.textTheme.headline6.color)),
          ),
          Divider(),
          SettingItemWidget(
            titleTextStyle: primaryTextStyle(
                color: context.theme.textTheme.subtitle2.color),
            title: "Publisher",
            trailing: Text(authorDetail.publisher,
                style: primaryTextStyle(
                    color: context.theme.textTheme.headline6.color)),
          ),
          Divider(),
          SettingItemWidget(
            titleTextStyle: primaryTextStyle(
                color: context.theme.textTheme.subtitle2.color),
            title: "Language",
            trailing: Text(authorDetail.language,
                style: primaryTextStyle(
                    color: context.theme.textTheme.headline6.color)),
          ),
          Divider(),
          SettingItemWidget(
            titleTextStyle: primaryTextStyle(
                color: context.theme.textTheme.subtitle2.color),
            title: "Available Format",
            trailing: Text(authorDetail.format,
                style: primaryTextStyle(
                    color: context.theme.textTheme.headline6.color)),
          ),
          Divider(),
        ],
      ),
    );
  }
}
