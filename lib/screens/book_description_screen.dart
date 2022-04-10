import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ebook/component/book_product_component.dart';
import 'package:ebook/main.dart';
import 'package:ebook/models/response/author.dart';
import 'package:ebook/models/response/base_response.dart';
import 'package:ebook/models/response/book_description.dart';
import 'package:ebook/models/response/book_detail.dart';
import 'package:ebook/models/response/book_rating.dart';
import 'package:ebook/models/response/downloaded_book.dart';
import 'package:ebook/network/common_api_calls.dart';
import 'package:ebook/network/rest_apis.dart';
import 'package:ebook/screens/book_description_screen2.dart';
import 'package:ebook/screens/book_reviews_screen.dart';
import 'package:ebook/screens/sign_in_screen.dart';
import 'package:ebook/utils/admob_utils.dart';
import 'package:ebook/utils/common.dart';
import 'package:ebook/utils/constants.dart';
import 'package:ebook/utils/database_helper.dart';
import 'package:ebook/utils/permissions.dart';
import 'package:ebook/utils/resources/colors.dart';
import 'package:ebook/utils/resources/images.dart';
import 'package:ebook/utils/widgets.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:readmore/readmore.dart';
import 'package:share/share.dart';

import '../app_localizations.dart';

// ignore: must_be_immutable
class BookDescriptionScreen extends StatefulWidget {
  static String tag = '/BookDetailScreen';
  BookDetail bookDetail;

  BookDescriptionScreen({Key key, this.bookDetail}) : super(key: key);

  @override
  _BookDescriptionScreenState createState() => _BookDescriptionScreenState();
}

class _BookDescriptionScreenState extends State<BookDescriptionScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
    2.seconds.delay.then((value) => setStatusBarColor(
        Theme.of(context).cardTheme.color,
        statusBarBrightness: Brightness.light));
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
                    width: context.width() - 40,
                    padding: EdgeInsets.all(16),
                    decoration: boxDecorationWithShadow(
                        backgroundColor: context.cardColor,
                        borderRadius: radius(8)),
                    child: Column(
                      children: <Widget>[
                        Text(keyString(context, "lbl_rateBook"),
                                style: boldTextStyle(
                                    size: 24,
                                    color: context
                                        .theme.textTheme.headline6.color))
                            .paddingAll(10),
                        Divider(thickness: 0.5),
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
                        ),
                        Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: AppTextField(
                            textStyle: primaryTextStyle(
                                color: context.theme.textTheme.headline6.color,
                                size: 14),
                            controller: controller,
                            keyboardType: TextInputType.multiline,
                            maxLines: 5,
                            validator: (value) {
                              return value.isEmpty
                                  ? keyString(context, "error_review_requires")
                                  : null;
                            },
                            decoration: inputDecoration(context,
                                label: keyString(context, "aRate_hint")),
                            textFieldType: TextFieldType.ADDRESS,
                          ),
                        ),
                        30.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            AppButton(
                              textColor:
                                  context.theme.textTheme.headline6.color,
                              child: Text(
                                keyString(context, "aRate_lbl_Cancel"),
                                style: primaryTextStyle(
                                    color: context
                                        .theme.textTheme.headline6.color),
                              ),
                              onTap: () {
                                finish(context, ConfirmAction.CANCEL);
                              },
                            ).expand(),
                            16.width,
                            AppButton(
                              color: context.primaryColor,
                              textColor: Colors.white,
                              text: keyString(context, "lbl_post"),
                              onTap: () {
                                if (_formKey.currentState.validate()) {
                                  _formKey.currentState.save();
                                  submitReview(controller.text, rating);
                                }
                              },
                            ).expand()
                          ],
                        )
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

  Future<void> submitReview(String text, double rating) async {
    isNetworkAvailable().then((bool) {
      if (bool) {
        if (userReviewData != null) {
          var request = {
            "book_id": mBookDetail.bookId,
            "user_id": getIntAsync(USER_ID),
            "rating_id": userReviewData.ratingId,
            "rating": rating.toString(),
            "review": text,
          };
          showLoading(true);

          updateBookRating(request).then((result) {
            BaseResponse response = BaseResponse.fromJson(result);
            if (response.status) {
              finish(context);
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
            "user_id": getIntAsync(USER_ID),
            "rating": rating.toString(),
            "review": text,
            "message": "",
            "status": true,
          };
          showLoading(true);
          addBookRating(request).then((result) {
            BaseResponse response = BaseResponse.fromJson(result);
            if (response.status) {
              finish(context);
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

  void deleteBookRating(ratingId) async {
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
            itemCount: snap.data.bookRatingData.length <= 3
                ? snap.data.bookRatingData.length
                : 3,
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
                              finish(context);
                            },
                          ),
                          AppButton(
                            child: Text(keyString(context, "lbl_ok")),
                            onTap: () {
                              finish(context);
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

  Widget ratingWidget() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        RatingBar.builder(
          tapOnlyMode: true,
          initialRating: double.parse(mBookDetail.totalRating.toString()),
          minRating: 0,
          glow: false,
          itemSize: 15,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemPadding: EdgeInsets.symmetric(horizontal: 0.0),
          itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
          onRatingUpdate: (double value) {
            setState(() {
              mBookDetail.totalRating = "$value";
            });
          },
        ),
        6.width,
        Text(
            "${double.parse(mBookDetail.totalRating.toStringAsFixed(1))} (${mBookDetail.totalReview.toString()})",
            style: primaryTextStyle(
                color: context.theme.textTheme.headline6.color)),
      ],
    );
  }

  Widget priceWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          mBookDetail.discountedPrice != 0
              ? mBookDetail.discountedPrice.toString().toCurrencyFormat()
              : mBookDetail.price.toString().toCurrencyFormat(),
          style: boldTextStyle(color: context.primaryColor, size: 16),
        ).visible(mBookDetail.discountedPrice != 0 || mBookDetail.price != 0),
        6.width,
        Text(
          mBookDetail.price.toString().toCurrencyFormat(),
          style: primaryTextStyle(decoration: TextDecoration.lineThrough),
        ).visible(mBookDetail.discount != 0),
      ],
    );
  }

  Widget discountWidget() {
    return Text(
        "~ " +
            mBookDetail.discount.toString() +
            keyString(context, "lbl_your_discount"),
        style: boldTextStyle(color: Theme.of(context).errorColor));
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
            // loadBookFromOffline();
            if (userReviewData != null) {
              userReviewData.userName = getStringAsync(USERNAME);
            }
            return Container(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              child: Container(
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
                                  mBookDetail.frontCover,
                                  fit: BoxFit.fill,
                                  height: 150,
                                  width: 100,
                                  radius: 0,
                                ).cornerRadiusWithClipRRectOnly(
                                    topLeft: 8,
                                    topRight: 8,
                                    bottomLeft: 8,
                                    bottomRight: 8),
                              ),
                              onTap: () {
                                if (getIntAsync(DETAIL_PAGE_VARIANT,
                                        defaultValue: 0) ==
                                    1) {
                                  BookDescriptionScreen(bookDetail: mBookDetail)
                                      .launch(context);
                                } else {
                                  BookDescriptionScreen2(
                                          bookDetail: mBookDetail)
                                      .launch(context);
                                }
                              },
                              radius: 8.0,
                            ),
                            16.width,
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  mBookDetail.name,
                                  style: boldTextStyle(
                                      color: context
                                          .theme.textTheme.headline6.color),
                                  maxLines: 4,
                                ),
                                10.height,
                                Text("By ${mBookDetail.authorName}",
                                    style: secondaryTextStyle(
                                        color: context
                                            .theme.textTheme.subtitle2.color)),
                                10.height,
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                      color: context.theme.highlightColor,
                                      borderRadius: radius(2)),
                                  child: Text(mBookDetail.categoryName,
                                      style: primaryTextStyle(
                                          color: context.theme.textTheme
                                              .headline6.color)),
                                ),
                                10.height,
                                ratingWidget(),
                                16.height,
                                priceWidget(),
                                16.height,
                                discountWidget(),
                              ],
                            ).paddingTop(8).expand()
                          ],
                        ).paddingSymmetric(horizontal: 16),
                        16.height,
                        Text('Introduction',
                                style: boldTextStyle(
                                    size: 22,
                                    color: context
                                        .theme.textTheme.headline6.color))
                            .paddingSymmetric(horizontal: 16),
                        ReadMoreText(mBookDetail.description,
                                style: primaryTextStyle(
                                    color: context
                                        .theme.textTheme.subtitle2.color))
                            .paddingSymmetric(horizontal: 16),
                        16.height,
                        // if (_bannerAd != null)
                        //   Container(
                        //       child: AdWidget(ad: _bannerAd),
                        //       height: _bannerAd.size.height.toDouble()),
                        16.height,
                        reviewWidget(snap),
                        Row(
                          children: [
                            Text(
                                    keyString(context,
                                        "lbl_more_books_by_this_author"),
                                    style: boldTextStyle(
                                        size: 18,
                                        color: context
                                            .theme.textTheme.headline6.color))
                                .visible(
                                  snap.data.recommendedBook.isNotEmpty,
                                )
                                .expand(),
                          ],
                        ).paddingSymmetric(horizontal: 16),
                        BookProductComponent(snap.data.authorBookList,
                            isHorizontal: true),
                        32.height,
                        Row(
                          children: [
                            Text(keyString(context, "lnl_you_may_also_like"),
                                    style: boldTextStyle(
                                        size: 18,
                                        color: context
                                            .theme.textTheme.headline6.color))
                                .visible(
                                  snap.data.recommendedBook.isNotEmpty,
                                )
                                .expand(),
                          ],
                        ).paddingSymmetric(horizontal: 16),
                        BookProductComponent(snap.data.recommendedBook)
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: buttonWidget(),
                  ),
                ],
              ),
            );
          }
          return snapWidgetHelper(snap);
        },
      );
    }

    return Scaffold(
      appBar: appBarWidget(
        widget.bookDetail.name.toString().validate(),
        elevation: 0,
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
                  mBookDetail.isWishList
                              .toString()
                              .toInt()
                              .validate(value: 0) ==
                          0
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
}

