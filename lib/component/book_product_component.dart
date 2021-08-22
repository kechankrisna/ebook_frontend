import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:ebook/component/book_widget_component.dart';
import 'package:ebook/component/horizontal_list.dart';
import 'package:ebook/models/response/book_detail.dart';
import 'package:ebook/screens/book_description_screen.dart';
import 'package:ebook/screens/book_description_screen2.dart';
import 'package:ebook/utils/common.dart';
import 'package:ebook/utils/constants.dart';
import 'package:ebook/utils/widgets.dart';
import 'package:nb_utils/nb_utils.dart';

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
