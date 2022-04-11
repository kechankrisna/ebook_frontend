import 'package:ebook/screens/home_screen/top_charts_view.dart';
import 'package:flutter/material.dart';
import 'package:ebook/component/book_widget_component.dart';
import 'package:ebook/models/response/book_detail.dart';
import 'package:ebook/models/response/book_list.dart';
import 'package:ebook/network/rest_apis.dart';
import 'package:ebook/screens/book_description_screen2.dart';
import 'package:ebook/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../app_localizations.dart';
import 'book_description_screen.dart';

class SearchScreen extends StatefulWidget {
  static String tag = '/SearchScreen';

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<BookDetail> list = [];
  var totalBooks = 0;
  var page = 1;
  var scrollController = new ScrollController();
  bool isLoading = false;
  bool isLoadingMoreData = false;
  bool isLastPage = false;
  var searchText = '';
  double width;
  bool isExpanded = false;
  bool isEmpty = false;

  TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    super.dispose();

    scrollController.dispose();
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      scrollHandler();
    });
  }

  scrollHandler() {
    if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent &&
        !isLastPage &&
        !isLoadingMoreData) {
      page++;
      setState(() {
        isLoadingMoreData = true;
        isLastPage = false;
        isEmpty = false;
      });
      fetchBookList(page);
    }
  }

  Future<void> fetchBookList(page) async {
    isNetworkAvailable().then((bool) {
      if (bool) {
        searchBook(page, searchText).then((result) {
          BookListResponse response = BookListResponse.fromJson(result);
          setState(() {
            isLoadingMoreData = false;
            totalBooks = response.pagination.totalItems;
            isLastPage = page == response.pagination.totalPages;
            if (response.data.isEmpty) {
              if (list.isEmpty) {
                isEmpty = true;
              }
              isLastPage = true;
            }
            list.addAll(response.data);
          });
          return response.data;
        }).catchError((error) {
          toast(error.toString());
          setState(() {
            isLoadingMoreData = false;
            isLastPage = true;
          });
        });
      } else {
        toast(keyString(context, "error_network_no_internet"));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    final customeAppBar = Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.only(top: 8),
      alignment: Alignment.center,
      width: double.infinity,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              elevation: 8.0,
              margin: EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Row(
                children: <Widget>[
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                        controller: controller,
                        textInputAction: TextInputAction.search,
                        style: TextStyle(
                            fontFamily: font_regular,
                            fontSize: 16,
                            color: context.theme.textTheme.headline6.color),
                        decoration: InputDecoration(
                          hintText: 'Search for books',
                          hintStyle: TextStyle(
                              fontFamily: font_regular,
                              color: context.theme.textTheme.subtitle2.color),
                          border: InputBorder.none,
                          filled: false,
                        ),
                        onFieldSubmitted: (term) {
                          page = 1;
                          searchText = term;
                          setState(() {
                            list.clear();
                            isLoadingMoreData = true;
                            isEmpty = false;
                          });
                          fetchBookList(page);
                        }),
                  ),
                  /* InkWell(
                    child: Icon(
                      Icons.mic,
                      color: context.theme.textTheme.subtitle2.color,
                    ),
                    onTap: () {
                      startListening();
                    },
                    radius: 12.0,
                  ),*/
                ],
              ).paddingOnly(left: 4, right: 4),
            ),
          ),
          12.width,
          InkWell(
            onTap: () {
              finish(context);
            },
            child: Text('Cancel',
                style: boldTextStyle(
                    color: context.theme.textTheme.headline6.color)),
          )
        ],
      ),
    ).paddingOnly(left: 8, right: 8);

    final searchList = Container(
      child: ListView.builder(
        itemCount: list.length,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          BookDetail bookDetail = list[index];

          return InkWell(
            onTap: () {
              if (getIntAsync(DETAIL_PAGE_VARIANT, defaultValue: 0) == 1) {
                BookDescriptionScreen(bookDetail: list[index]).launch(context);
              } else {
                BookDescriptionScreen2(bookDetail: list[index]).launch(context);
              }
            },
            child: BookListTile(bookDetail: bookDetail),

            /// child: BookItemWidget(bookDetail: bookDetail),
          );
        },
      ),
    );

    return SafeArea(
      child: Stack(
        children: <Widget>[
          Scaffold(
              backgroundColor: context.scaffoldBackgroundColor,
              appBar: PreferredSize(
                preferredSize: Size(MediaQuery.of(context).size.width, 60),
                child: customeAppBar,
              ),
              body: SingleChildScrollView(
                controller: scrollController,
                physics: BouncingScrollPhysics(),
                child: !isEmpty
                    ? isLoadingMoreData
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              searchList,
                              Loader().paddingTop(24.0)
                            ],
                          )
                        : searchList
                    : Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                                keyString(context, "error_search") +
                                    " \"" +
                                    searchText +
                                    "\"",
                                style: boldTextStyle(
                                    color:
                                        context.theme.textTheme.headline6.color,
                                    size: 18)),
                            Text(keyString(context, "note_search"),
                                style: boldTextStyle(
                                    color:
                                        context.theme.textTheme.headline6.color,
                                    size: 18))
                          ],
                        ).paddingTop(width * 0.2),
                      ),
              )),
        ],
      ),
    );
  }
}
