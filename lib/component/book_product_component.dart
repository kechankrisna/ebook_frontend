import 'package:ebook/app_localizations.dart';
import 'package:ebook/screens/home_screen/book_grid_action_button.dart';
import 'package:flutter/material.dart';
import 'package:ebook/component/book_widget_component.dart';
import 'package:ebook/component/horizontal_list.dart';
import 'package:ebook/models/response/book_detail.dart';
import 'package:ebook/screens/book_description_screen.dart';
import 'package:ebook/screens/book_description_screen2.dart';
import 'package:ebook/utils/common.dart';
import 'package:ebook/utils/constants.dart';
import 'package:ebook/utils/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:share/share.dart';

class BookProductComponent extends StatelessWidget {
  final List<BookDetail> list;
  final bool isHorizontal;

  BookProductComponent(this.list, {this.isHorizontal = false});

  @override
  Widget build(BuildContext context) {
    return isHorizontal
        ? HorizontalListWidget(
            itemCount: list.length,
            spacing: 16,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  if (getIntAsync(DETAIL_PAGE_VARIANT, defaultValue: 0) == 1) {
                    BookDescriptionScreen(bookDetail: list[index])
                        .launch(context);
                  } else {
                    BookDescriptionScreen2(bookDetail: list[index])
                        .launch(context);
                  }
                },
                child: Container(
                  width: 350,
                  height: 200,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: boxDecorationWithShadow(
                          borderRadius: BorderRadius.circular(8),
                          spreadRadius: 2,
                          blurRadius: 4,
                          border: Border.all(color: Colors.white, width: 2.0),
                          offset: Offset(1, 2),
                        ),
                        child: cachedImage(
                          list[index].frontCover,
                          width: 150,
                          height: 200,
                          fit: BoxFit.fill,
                        ).cornerRadiusWithClipRRect(8),
                      ),
                      16.width,
                      Stack(
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${list[index].name.toString().validate()}",
                                  maxLines: 2,
                                  style: boldTextStyle(
                                    color:
                                        context.theme.textTheme.headline6.color,
                                    size: 18,
                                  )),
                              4.height,
                              Text(
                                parseHtmlString(list[index]
                                    .description
                                    .toString()
                                    .validate()),
                                style: primaryTextStyle(
                                    color:
                                        context.theme.textTheme.headline6.color,
                                    size: 14),
                                maxLines: 6,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          Positioned(
                            bottom: 34,
                            child: Text(
                              "by ${list[index].authorName}",
                              style: boldTextStyle(
                                  color:
                                      context.theme.textTheme.headline6.color,
                                  size: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            child: Text(
                              list[index].categoryName,
                              style: boldTextStyle(
                                color: context.theme.textTheme.subtitle2.color,
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ).paddingTop(4).expand()
                    ],
                  ),
                ),
              );
            },
          )
        : HorizontalListWidget(
            itemCount: list.length,
            spacing: 16,
            itemBuilder: (context, index) {
              BookDetail data = list[index];
              return BookItemWidget(bookDetail: data);
            },
          );
  }
}

class BookProductComponentPlus extends StatelessWidget {
  final List<BookDetail> list;

  const BookProductComponentPlus(this.list);

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,

          /// stops: [0.1, 1],
          colors: [
            Colors.grey[100],
            Colors.grey[200],
            themeData.cardColor,
            themeData.cardColor
          ],
        ),
      ),
      child: GridView.count(
        shrinkWrap: true,
        childAspectRatio: 0.6,
        primary: false,
        children: list
            .map((e) => InkWell(
                  onTap: () {
                    if (getIntAsync(DETAIL_PAGE_VARIANT, defaultValue: 0) ==
                        1) {
                      BookDescriptionScreen(bookDetail: e).launch(context);
                    } else {
                      BookDescriptionScreen2(bookDetail: e).launch(context);
                    }
                  },
                  child: BookProductGrid(bookDetail: e),
                ))
            .toList(),
        crossAxisCount: 3,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
      ),
    );
  }
}

class BookProductGrid extends StatelessWidget {
  final BookDetail bookDetail;
  const BookProductGrid({Key key, this.bookDetail}) : super(key: key);

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
                  BookGridActionButton(bookDetail: bookDetail)
                ],
              ),
            ).withHeight(36).paddingSymmetric(vertical: 5),
            Text(
              "${bookDetail.price.toString().toCurrencyFormat().validate()}",
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
