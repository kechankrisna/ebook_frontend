import 'package:flutter/material.dart';
import 'package:ebook/models/response/book_detail.dart';
import 'package:ebook/models/response/wishlist_response.dart';
import 'package:ebook/screens/book_description_screen.dart';
import 'package:ebook/screens/book_description_screen2.dart';
import 'package:ebook/utils/common.dart';
import 'package:ebook/utils/constants.dart';
import 'package:ebook/utils/resources/colors.dart';
import 'package:ebook/utils/widgets.dart';
import 'package:nb_utils/nb_utils.dart';

import '../app_localizations.dart';

class WishlistScreen extends StatefulWidget {
  static String tag = '/WishlistScreen';

  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen>
    with AfterLayoutMixin<WishlistScreen> {
  List<WishListItem> list = [];
  bool mIsFirstTime = true;

  @override
  void afterFirstLayout(BuildContext context) async {
    if (mIsFirstTime) {
      LiveStream().on(WISH_LIST_DATA_CHANGED, (value) {
        if (mounted) {
          if (value != null) {
            setState(() {
              list.clear();
              list.addAll(value);
            });
          }
        }
      });
      LiveStream().on(CART_COUNT_ACTION, (value) {
        if (!mounted) {
          return;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: context.scaffoldBackgroundColor,
        iconTheme: context.theme.iconTheme,
        centerTitle: true,
        actions: <Widget>[
          cartIcon(context, getIntAsync(CART_COUNT))
              .visible(getBoolAsync(IS_LOGGED_IN)),
        ],
        title: Column(
          children: <Widget>[
            Text(keyString(context, "lbl_wish_list"),
                    style: boldTextStyle(
                        color: context.theme.textTheme.headline6.color))
                .paddingTop(12.0),
            2.height,
            Text(list.length.toString() + ' ' + keyString(context, "lbl_books"),
                style: primaryTextStyle(color: textColorSecondary, size: 14)),
          ],
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(top: 16),
        child: FutureBuilder<List<WishListItem>>(
          future: wishListItems(),
          builder: (_, snap) {
            if (snap.hasData) {
              ///
              if (list.isEmpty) {
                list.addAll(snap.data);
              }

              ///
              return GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 0,
                crossAxisSpacing: 0,
                childAspectRatio: 0.6,
                primary: false,
                children: list.map(
                  (e) {
                    WishListItem data = list[list.indexOf(e)];
                    return InkWell(
                      onTap: () {
                        if (getIntAsync(DETAIL_PAGE_VARIANT, defaultValue: 0) ==
                            1) {
                          BookDescriptionScreen(
                                  bookDetail: BookDetail(bookId: data.bookId))
                              .launch(context);
                        } else {
                          BookDescriptionScreen2(
                                  bookDetail: BookDetail(bookId: data.bookId))
                              .launch(context);
                        }
                      },
                      child: WishListItemGrid(bookDetail: data),
                    );
                  },
                ).toList(),
              );
            }
            return snapWidgetHelper(snap);
          },
        ),
      ),
      /* body: SingleChildScrollView(child: wishlist()),*/
    );
  }
}

class WishListItemGrid extends StatelessWidget {
  final WishListItem bookDetail;
  final Widget actionButton;
  const WishListItemGrid({Key key, this.bookDetail, this.actionButton})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Card(
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: cachedImage(
                bookDetail.frontCover,
                fit: BoxFit.fill,
                width: double.infinity,
                alignment: Alignment.center,
              ),
            ),
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: Text(
                    "${bookDetail.name.toString().validate()}",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: themeData.textTheme.bodyMedium,
                  )),
                  if (actionButton != null) actionButton,
                ],
              ),
            ).withHeight(36).paddingSymmetric(vertical: 5),
            Container(
              child: Text(
                bookDetail.authorName,
                maxLines: 2,
                style: themeData.textTheme.caption,
              ),
            )
          ],
        ),
      ),
    );
  }
}
