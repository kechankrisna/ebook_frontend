import 'dart:io';
import 'package:ebook/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ebook/component/book_product_component.dart';
import 'package:ebook/component/horizontal_list.dart';
import 'package:ebook/component/slider_component.dart';
import 'package:ebook/models/response/author.dart';
import 'package:ebook/models/response/category.dart';
import 'package:ebook/models/response/dashboard_response.dart';
import 'package:ebook/models/response/slider.dart';
import 'package:ebook/network/common_api_calls.dart';
import 'package:ebook/network/rest_apis.dart';
import 'package:ebook/screens/author_detail_screen.dart';
import 'package:ebook/screens/category_book_screen.dart';
import 'package:ebook/screens/view_all_book_screen.dart';
import 'package:ebook/utils/constants.dart';
import 'package:ebook/utils/resources/images.dart';
import 'package:ebook/utils/widgets.dart';
import 'package:nb_utils/nb_utils.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with AfterLayoutMixin<HomeView> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Category _category;

  List<Color> gradientColor2 = <Color>[
    Color(0xFF48c6ef),
    Color(0xFFDE0B33),
    Color(0xFF1e3c72),
    Color(0xFF8360c3),
    Color(0xFF1e130c)
  ];
  List<Color> gradientColor1 = <Color>[
    Color(0xFF6f86d6),
    Color(0xFFFd988d),
    Color(0xFF22a5298),
    Color(0xFF2ebf91),
    Color(0xFF9a8478)
  ];

  var mIsFirstTime = true;

  /// var cartCount = 0;
  /// var isUserLogin = false;

  @override
  void afterFirstLayout(BuildContext context) async {
    if (mIsFirstTime) {
      LiveStream().on(CART_COUNT_ACTION, (value) {
        if (!mounted) {
          return;
        }
        setState(() {
          /// cartCount = value;
          LiveStream().emit("updateCart", true);
        });
      });
      LiveStream().on(CART_ITEM_CHANGED, (value) {
        if (!mounted) {
          return;
        }
        fetchCartData(context);
      });
      LiveStream().on(WISH_DATA_ITEM_CHANGED, (value) {
        if (!mounted) {
          return;
        }
        fetchWishListData(context);
      });
      mIsFirstTime = false;
    }
  }

  @override
  void initState() {
    500
        .milliseconds
        .delay
        .then((value) => setStatusBarColor(context.scaffoldBackgroundColor));
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget get noInternetError => Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              icon_antenna,
              width: 120,
              height: 120,
            ),
            Text(
              keyString(context, "error_network_no_internet"),
              style: primaryTextStyle(
                  color: context.theme.textTheme.headline6.color, size: 20),
            ).paddingTop(10),
            MaterialButton(
              padding: EdgeInsets.fromLTRB(30, 8.0, 30, 8.0),
              textColor: Colors.white,
              child: Text(keyString(context, "lbl_try_again"),
                  style: primaryTextStyle(
                      color: context.theme.textTheme.headline6.color)),
              color: Colors.amber,
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(5.0),
                side: BorderSide(color: Colors.amber),
              ),
              onPressed: () {
                setState(() {});
              },
            ).paddingTop(12.0)
          ],
        ),
      );

  Widget get noData => Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              no_data,
              width: 180,
              height: 180,
            ),
            Text("No Books available",
                    style: primaryTextStyle(
                        color: context.theme.textTheme.subtitle2.color,
                        size: 22))
                .paddingTop(12.0),
          ],
        ),
      );

  Widget categoryList(List<Category> mCategories) {
    return HorizontalListWidget(
      itemCount: mCategories.length,
      padding: EdgeInsets.zero,
      itemBuilder: (BuildContext context, int index) {
        return TextButton(
          onPressed: () {
            CategoryBooks(
              type: 'category',
              title: mCategories[index].name,
              categoryId: mCategories[index].categoryId.toString(),
            ).launch(context);
          },
          child: Container(
            alignment: Alignment.center,
            height: 45,
            child: Text(mCategories[index].name,
                maxLines: 3, textAlign: TextAlign.center),
          ),
        );
      },
    );
  }

  Widget authorList(List<AuthorDetail> mBestAuthorList) {
    return HorizontalListWidget(
      itemCount: mBestAuthorList.length,
      spacing: 16,
      itemBuilder: (context, index) {
        return Container(
          child: Column(
            children: <Widget>[
              InkWell(
                radius: context.width() * 0.1,
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: mBestAuthorList[index].image != null
                      ? NetworkImage(mBestAuthorList[index].image)
                      : AssetImage(ic_profile),
                ),
                onTap: () {
                  AuthorDetailScreen(authorDetail: mBestAuthorList[index])
                      .launch(context);
                },
              ),
              6.height,
              Text(mBestAuthorList[index].name,
                  style: boldTextStyle(
                      color: context.theme.textTheme.headline6.color)),
            ],
          ),
        );
      },
    );
  }

  Widget containerBody(DashboardResponse dashboardResponse) {
    final themeData = Theme.of(context);
    bool mIsTopSearchBook = dashboardResponse.topSearchBook != null &&
        dashboardResponse.topSearchBook.isNotEmpty;
    bool mIsRecommendedBook = dashboardResponse.recommendedBook != null &&
        dashboardResponse.recommendedBook.isNotEmpty;
    bool mIsTopSellBook = dashboardResponse.topSellBook != null &&
        dashboardResponse.topSellBook.isNotEmpty;
    bool mIsTopAuthor = dashboardResponse.topAuthor != null &&
        dashboardResponse.topAuthor.isNotEmpty;
    bool mIsCategoryBook = dashboardResponse.categoryBook != null &&
        dashboardResponse.categoryBook.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 50,
          child: ListView.builder(
            primary: false,
            scrollDirection: Axis.horizontal,
            itemCount: dashboardResponse.categoryBook.length,
            itemBuilder: (_, index) {
              final category = dashboardResponse.categoryBook[index];
              return CategoryChip(
                category: category,
                selected: _category?.categoryId == category?.categoryId,
                onPressed: () {
                  setState(() {
                    _category = category;
                  });
                },
              );
            },
          ),
        ),
        Divider(height: 1),
        Expanded(
            child: SingleChildScrollView(
          child: Column(
            children: [
              slider(dashboardResponse.slider),
              //Collections
              /// horizontalHeading(context, keyString(context, "lbl_collections"),
              ///         showViewAll: false)
              ///     .visible(mIsCategoryBook),
              /// categoryList(dashboardResponse.categoryBook).visible(mIsCategoryBook),

              //Top Search Book
              HorizontalHeading(
                title: keyString(context, "top_search_books"),
                onTap: () {
                  ViewAllBooks(
                          type: type_top_search,
                          title: keyString(context, "top_search_books"))
                      .launch(context);
                },
              ).visible(mIsTopSearchBook),

              BookProductComponentPlus(dashboardResponse.topSearchBook)
                  .visible(mIsTopSearchBook),
              //Best Author

              /// HorizontalHeading(
              ///     title: keyString(context, "best_author"),
              ///     onTap: () {
              ///       AuthorsListScreen().launch(context);
              ///     }).visible(mIsTopAuthor),
              /// authorList(dashboardResponse.topAuthor).visible(mIsTopAuthor),
              //Recommended Books

              HorizontalHeading(
                  title: keyString(context, "recommended_books"),
                  onTap: () {
                    ViewAllBooks(
                            type: type_recommended,
                            title: keyString(context, "recommended_books"))
                        .launch(context);
                  }).visible(mIsRecommendedBook),
              BookProductComponentPlus(dashboardResponse.recommendedBook)
                  .visible(mIsRecommendedBook),
              //Popular Books

              HorizontalHeading(
                  title: keyString(context, "popular_books"),
                  onTap: () {
                    ViewAllBooks(
                            type: type_popular,
                            title: keyString(context, "popular_books"))
                        .launch(context);
                  }).visible(mIsRecommendedBook),
              BookProductComponentPlus(
                dashboardResponse.popularBook,
              ).visible(mIsRecommendedBook),
              //Top Selling

              HorizontalHeading(
                  title: keyString(context, "lbl_top_selling"),
                  onTap: () {
                    ViewAllBooks(
                            type: type_top_sell,
                            title: keyString(context, "lbl_top_selling"))
                        .launch(context);
                  }).visible(mIsTopSellBook),
              BookProductComponentPlus(dashboardResponse.topSellBook)
                  .visible(mIsTopSellBook),
            ],
          ),
        ))
      ],
    );
  }

  Widget slider(List<HomeSlider> mSliderList) {
    if (mSliderList.isEmpty) {
      return Container();
    }
    return HomeSliderWidget(mSliderList);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<DashboardResponse>(
        future: getDashboard(),
        builder: (_, snap) {
          if (!snap.hasData) return Loader();

          if (snap.hasError) {
            Widget error = noData;

            if (snap.error is SocketException) {
              error = noInternetError;
            }

            return snapWidgetHelper(snap,
                checkHasData: true, errorWidget: error);
          }
          setBoolAsync(IS_PAYPAL_ENABLED, snap.data.isPayPalEnabled);
          setBoolAsync(IS_PAYTM_ENABLED, snap.data.isPayTmEnabled);
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
              return Future.value(false);
            },
            child: snap.hasData ? containerBody(snap.data) : Loader(),
          );
        },
      ),
    );
  }
}

class HomeViewCartIcon extends StatefulWidget {
  const HomeViewCartIcon({Key key}) : super(key: key);

  @override
  State<HomeViewCartIcon> createState() => _HomeViewCartIconState();
}

class _HomeViewCartIconState extends State<HomeViewCartIcon> {
  var cartCount = 0;
  var isUserLogin = false;

  @override
  void initState() {
    super.initState();

    initialize();
  }

  initialize() async {
    LiveStream().on(CART_COUNT_ACTION, (value) {
      if (!mounted) {
        return;
      }
      setState(() {
        cartCount = value;
        LiveStream().emit("updateCart", true);
      });
    });
    LiveStream().on(CART_ITEM_CHANGED, (value) {
      if (!mounted) {
        return;
      }
      fetchCartData(context);
    });
    LiveStream().on(WISH_DATA_ITEM_CHANGED, (value) {
      if (!mounted) {
        return;
      }
      fetchWishListData(context);
    });
    isUserLogin = await getBool(IS_LOGGED_IN);
    // fetchDashboardData();
    if (isUserLogin) {
      fetchCartData(context);
      fetchWishListData(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return cartIcon(context, cartCount).visible(isUserLogin);
  }
}

class CategoryChip extends StatelessWidget {
  final Category category;
  final bool selected;
  final VoidCallback onPressed;
  const CategoryChip(
      {Key key,
      @required this.category,
      this.selected = false,
      @required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: selected
              ? BorderSide(color: themeData.primaryColor, width: 3)
              : BorderSide.none,
        ),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          category.name,
          style: themeData.textTheme.bodyText1.copyWith(
            color: selected ? themeData.primaryColor : Colors.grey,
          ),
        ),
      ),
    );
  }
}
