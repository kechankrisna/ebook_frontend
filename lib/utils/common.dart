import 'dart:convert';
import 'dart:io';

import 'package:epub_viewer/epub_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ebook/component/pdf_component.dart';
import 'package:ebook/component/video_play_component.dart';
import 'package:ebook/models/response/downloaded_book.dart';
import 'package:ebook/models/response/wishlist_response.dart';
import 'package:ebook/utils/constants.dart';
import 'package:ebook/utils/resources/images.dart';
import 'package:html/parser.dart';
import 'package:nb_utils/nb_utils.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_localizations.dart';

String parseHtmlString(String htmlString) {
  return parse(htmlString.validate()).body.text;
}

enum ConfirmAction { CANCEL, ACCEPT }

InputDecoration inputDecoration(BuildContext context, {String label}) {
  return InputDecoration(
    labelText: label.validate(),
    labelStyle:
        primaryTextStyle(color: context.theme.textTheme.headline6.color),
    alignLabelWithHint: false,
    floatingLabelBehavior: FloatingLabelBehavior.auto,
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Theme.of(context).primaryColor),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: context.theme.textTheme.headline6.color),
    ),
  );
}

String validatePassword(context, String value) {
  return value.isEmpty ? keyString(context, "error_pwd_requires") : null;
}

Future<List<WishListItem>> wishListItems() async {
  var data = await getString(WISH_LIST_DATA);
  if (data == null) {
    return [];
  }
  WishListResponse response = WishListResponse.fromJson(jsonDecode(data));
  return response.data;
}

getPercentageRate(num amount, num percentage) {
  return (amount * percentage) / 100;
}

discountedPrice(num amount, num percentage) {
  return amount - getPercentageRate(amount, percentage);
}

num tryParse(var input) {
  return _isNumeric(input)
      ? int.tryParse(input.toString().trim()) ??
          double.tryParse(input.toString().trim())
      : null;
}

bool _isNumeric(var str) {
  return str == null ? false : double.tryParse(str.toString()) != null;
}

Future<String> get localPath async {
  Directory directory;
  if (isAndroid) {
    directory = await getExternalStorageDirectory();
  } else if (isIos) {
    directory = await getApplicationDocumentsDirectory();
  } else {
    throw "Unsupported platform";
  }
  return directory.absolute.path;
}

Future<String> requestDownload(
    {BuildContext context, DownloadedBook downloadTask, bool isSample}) async {
  String path = await localPath;
  var url = downloadTask.mDownloadTask.url.replaceAll(' ', '%20');
  var fileName = getFileName(url, isSample, downloadTask.bookId);
  final savedDir = Directory(path);
  bool hasExisted = await savedDir.exists();
  if (!hasExisted) {
    savedDir.create();
  }
  return await FlutterDownloader.enqueue(
    url: url,
    fileName: fileName,
    savedDir: path,
    showNotification: true,
    openFileFromNotification: true,
  );
}

Future<String> retryDownload(taskId) async {
  return await FlutterDownloader.retry(taskId: taskId);
}

Future<Null> delete(taskId) async {
  return await FlutterDownloader.remove(
      taskId: taskId, shouldDeleteContent: true);
}

String getFileName(String path, bool isSample, String bookId) {
  var name = path.split("/");
  String fileNameNew = path;
  if (name.length > 0) {
    fileNameNew = name[name.length - 1];
  }
  fileNameNew = fileNameNew.replaceAll("%", "");
  return isSample
      ? bookId + "_sample_" + fileNameNew
      : bookId + "_purchased_" + fileNameNew;
}

readFile(context, String filePath, String name) async {
  String path = await localPath;
  filePath = "$path/$filePath";
  filePath = filePath.replaceAll("null/", "");
  if (filePath.isPdf) {
    PDFViewComponent(filePath, name).launch(context);
  } else if (filePath.contains(".epub")) {
    EpubViewer.setConfig(
        themeColor: Theme.of(context).primaryColor,
        identifier: "iosBook",
        scrollDirection: EpubScrollDirection.VERTICAL,
        allowSharing: true,
        enableTts: true,
        nightMode: false);

    EpubLocator ePubLocator = EpubLocator();
    String locatorPref = getStringAsync('locator');

    try {
      if (locatorPref.isNotEmpty) {
        Map<String, dynamic> r = jsonDecode(locatorPref);

        ePubLocator = EpubLocator.fromJson(r);
      }
    } on Exception {
      ePubLocator = EpubLocator();
      await removeKey('locator');
    }
    EpubViewer.open(Platform.isAndroid ? filePath : filePath,
        lastLocation: ePubLocator);

    EpubViewer.locatorStream.listen((locator) {
      setString('locator', locator);
    });
  } else if (filePath.isVideo) {
    VideoPlayComponent(filePath).launch(context);
  }
}

void launchUrl(url, {bool forceWebView = false}) async {
  log(url);
  await launch(url,
          forceWebView: forceWebView,
          enableJavaScript: true,
          statusBarBrightness: Brightness.light)
      .catchError((e) {
    log(e);
    toast('Invalid URL: $url');
  });
}

showTransactionDialog(context, isSuccess) {
  showDialog(
    context: context,
    builder: (BuildContext context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
          decoration: boxDecorationWithShadow(
              backgroundColor: Theme.of(context).cardTheme.color,
              borderRadius: radius(10)),
          width: MediaQuery.of(context).size.width - 40,
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                    padding: EdgeInsets.all(16),
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.close,
                        color: context.theme.iconTheme.color)),
              ),
              Text(isSuccess ? "SUCCESSFUL" : "UNSUCCESSFUL",
                  style: boldTextStyle(
                      color: isSuccess
                          ? Colors.green
                          : Theme.of(context).errorColor,
                      size: 22)),
              SizedBox(height: 16),
              SvgPicture.asset(
                ic_pay_1,
                color: isSuccess ? Colors.green : Theme.of(context).errorColor,
                width: 90,
                height: 90,
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Text(
                  isSuccess
                      ? "Your payment is apporved"
                      : "Your payment is declined",
                  style: boldTextStyle(
                    color: context.theme.textTheme.headline6.color,
                    size: 18,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Text(
                  "Plese refer transaction history for more detail",
                  style: primaryTextStyle(
                      color: context.theme.textTheme.headline6.color),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
              SizedBox(height: 16),
              MaterialButton(
                child: Text("OK", style: primaryTextStyle(color: Colors.white)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4.0))),
                elevation: 5.0,
                minWidth: 150,
                height: 40,
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  finish(context);
                },
              ),
              SizedBox(
                height: 16,
              )
            ],
          )),
    ),
  );
}

Future<void> saveOneSignalPlayerId() async {
  // OneSignal.shared.().then((value) async {
  //   await setValue(PLAYER_ID, value.userId);
  // });
}
