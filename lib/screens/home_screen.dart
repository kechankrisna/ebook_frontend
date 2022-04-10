import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ebook/component/book_product_component.dart';
import 'package:ebook/component/home_drawer_component.dart';
import 'package:ebook/component/horizontal_list.dart';
import 'package:ebook/component/slider_component.dart';
import 'package:ebook/models/response/author.dart';
import 'package:ebook/models/response/category.dart';
import 'package:ebook/models/response/dashboard_response.dart';
import 'package:ebook/models/response/slider.dart';
import 'package:ebook/network/common_api_calls.dart';
import 'package:ebook/network/rest_apis.dart';
import 'package:ebook/screens/author_detail_screen.dart';
import 'package:ebook/screens/author_list_screen.dart';
import 'package:ebook/screens/category_book_screen.dart';
import 'package:ebook/screens/search_book_screen.dart';
import 'package:ebook/screens/view_all_book_screen.dart';
import 'package:ebook/utils/constants.dart';
import 'package:ebook/utils/resources/images.dart';
import 'package:ebook/utils/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../app_localizations.dart';
import 'home_screen/categories_view.dart';
import 'home_screen/library_view.dart';
import 'home_screen/new_feed_view.dart';
import 'home_screen/top_charts_view.dart';
import 'home_screen/home_view.dart';

class HomeScreen extends StatefulWidget {
  static String tag = '/HomeScreen';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //with AfterLayoutMixin<HomeScreen>
  /// GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// List<Color> gradientColor2 = <Color>[
  ///   Color(0xFF48c6ef),
  ///   Color(0xFFDE0B33),
  ///   Color(0xFF1e3c72),
  ///   Color(0xFF8360c3),
  ///   Color(0xFF1e130c)
  /// ];
  /// List<Color> gradientColor1 = <Color>[
  ///   Color(0xFF6f86d6),
  ///   Color(0xFFFd988d),
  ///   Color(0xFF22a5298),
  ///   Color(0xFF2ebf91),
  ///   Color(0xFF9a8478)
  /// ];

  /// var mIsFirstTime = true;
  /// var cartCount = 0;
  /// var isUserLogin = false;

  /// @override
  /// void afterFirstLayout(BuildContext context) async {
  ///   if (mIsFirstTime) {
  ///     //_bannerAd = createBannerAd()..load();

  ///     LiveStream().on(CART_COUNT_ACTION, (value) {
  ///       if (!mounted) {
  ///         return;
  ///       }
  ///       setState(() {
  ///         cartCount = value;
  ///         LiveStream().emit("updateCart", true);
  ///       });
  ///     });
  ///     LiveStream().on(CART_ITEM_CHANGED, (value) {
  ///       if (!mounted) {
  ///         return;
  ///       }
  ///       fetchCartData(context);
  ///     });
  ///     LiveStream().on(WISH_DATA_ITEM_CHANGED, (value) {
  ///       if (!mounted) {
  ///         return;
  ///       }
  ///       fetchWishListData(context);
  ///     });
  ///     // if (mounted) {
  ///     //   if (isMobile) {
  ///     //     OneSignal.shared.setNotificationOpenedHandler(
  ///     //         (OSNotificationOpenedResult result) async {
  ///     //       Map<String, dynamic> data = result.notification.rawPayload;
  ///     //       if (data != null) {
  ///     //         var payload = NotificationPayload.fromJson(data);
  ///     //         onReadNotification(payload.notificationId);
  ///     //         if (payload.type != null && payload.type.toString().isNotEmpty) {
  ///     //           if (payload.type == "book_added") {
  ///     //             if (getIntAsync(DETAIL_PAGE_VARIANT) == 1) {
  ///     //               BookDescriptionScreen(
  ///     //                       bookDetail: BookDetail(bookId: payload.bookId))
  ///     //                   .launch(context);
  ///     //             } else {
  ///     //               BookDescriptionScreen2(
  ///     //                       bookDetail: BookDetail(bookId: payload.bookId))
  ///     //                   .launch(context);
  ///     //             }
  ///     //           }
  ///     //         }
  ///     //       }
  ///     //     });
  ///     //   }
  ///     // }
  ///     isUserLogin = await getBool(IS_LOGGED_IN);
  ///     // fetchDashboardData();
  ///     if (isUserLogin) {
  ///       fetchCartData(context);
  ///       fetchWishListData(context);
  ///     }
  ///     mIsFirstTime = false;
  ///   }
  /// }

  /// @override
  /// void initState() {
  ///   500
  ///       .milliseconds
  ///       .delay
  ///       .then((value) => setStatusBarColor(context.scaffoldBackgroundColor));
  ///   super.initState();
  /// }

  /// @override
  /// void dispose() {
  ///   super.dispose();
  /// }

  /// @override
  /// void didChangeDependencies() {
  ///   // TODO: implement didChangeDependencies
  ///   super.didChangeDependencies();
  /// }

  /// Widget get noInternetError => Container(
  ///       alignment: Alignment.center,
  ///       height: MediaQuery.of(context).size.height,
  ///       child: Column(
  ///         mainAxisAlignment: MainAxisAlignment.center,
  ///         children: <Widget>[
  ///           SvgPicture.asset(
  ///             icon_antenna,
  ///             width: 120,
  ///             height: 120,
  ///           ),
  ///           Text(
  ///             keyString(context, "error_network_no_internet"),
  ///             style: primaryTextStyle(
  ///                 color: context.theme.textTheme.headline6.color, size: 20),
  ///           ).paddingTop(10),
  ///           MaterialButton(
  ///             padding: EdgeInsets.fromLTRB(30, 8.0, 30, 8.0),
  ///             textColor: Colors.white,
  ///             child: Text(keyString(context, "lbl_try_again"),
  ///                 style: primaryTextStyle(
  ///                     color: context.theme.textTheme.headline6.color)),
  ///             color: Colors.amber,
  ///             shape: RoundedRectangleBorder(
  ///               borderRadius: new BorderRadius.circular(5.0),
  ///               side: BorderSide(color: Colors.amber),
  ///             ),
  ///             onPressed: () {
  ///               setState(() {});
  ///             },
  ///           ).paddingTop(12.0)
  ///         ],
  ///       ),
  ///     );

  /// Widget get noData => Container(
  ///       alignment: Alignment.center,
  ///       height: MediaQuery.of(context).size.height,
  ///       child: Column(
  ///         mainAxisAlignment: MainAxisAlignment.center,
  ///         children: <Widget>[
  ///           SvgPicture.asset(
  ///             no_data,
  ///             width: 180,
  ///             height: 180,
  ///           ),
  ///           Text("No Books available",
  ///                   style: primaryTextStyle(
  ///                       color: context.theme.textTheme.subtitle2.color,
  ///                       size: 22))
  ///               .paddingTop(12.0),
  ///         ],
  ///       ),
  ///     );

  /// Widget categoryList(List<Category> mCategories) {
  ///   return HorizontalListWidget(
  ///     itemCount: mCategories.length,
  ///     itemBuilder: (BuildContext context, int index) {
  ///       return InkWell(
  ///         onTap: () {
  ///           CategoryBooks(
  ///             type: 'category',
  ///             title: mCategories[index].name,
  ///             categoryId: mCategories[index].categoryId.toString(),
  ///           ).launch(context);
  ///         },
  ///         child: Container(
  ///           alignment: Alignment.center,
  ///           height: 60,
  ///           padding: EdgeInsets.all(16),
  ///           decoration: BoxDecoration(
  ///               borderRadius: BorderRadius.all(Radius.circular(10)),
  ///               gradient: LinearGradient(
  ///                 colors: [
  ///                   gradientColor1[index % gradientColor1.length],
  ///                   gradientColor2[index % gradientColor2.length]
  ///                 ],
  ///               )),
  ///           child: Text(mCategories[index].name,
  ///               style: boldTextStyle(color: Colors.white),
  ///               maxLines: 3,
  ///               textAlign: TextAlign.center),
  ///         ),
  ///       );
  ///     },
  ///   );
  /// }

  /// Widget authorList(List<AuthorDetail> mBestAuthorList) {
  ///   return HorizontalListWidget(
  ///     itemCount: mBestAuthorList.length,
  ///     spacing: 16,
  ///     itemBuilder: (context, index) {
  ///       return Container(
  ///         child: Column(
  ///           children: <Widget>[
  ///             InkWell(
  ///               radius: context.width() * 0.1,
  ///               child: CircleAvatar(
  ///                 radius: 40,
  ///                 backgroundImage: mBestAuthorList[index].image != null
  ///                     ? NetworkImage(mBestAuthorList[index].image)
  ///                     : AssetImage(ic_profile),
  ///               ),
  ///               onTap: () {
  ///                 AuthorDetailScreen(authorDetail: mBestAuthorList[index])
  ///                     .launch(context);
  ///               },
  ///             ),
  ///             6.height,
  ///             Text(mBestAuthorList[index].name,
  ///                 style: boldTextStyle(
  ///                     color: context.theme.textTheme.headline6.color)),
  ///           ],
  ///         ),
  ///       );
  ///     },
  ///   );
  /// }

  /// Widget containerBody(DashboardResponse dashboardResponse) {
  ///   bool mIsTopSearchBook = dashboardResponse.topSearchBook != null &&
  ///       dashboardResponse.topSearchBook.isNotEmpty;
  ///   bool mIsRecommendedBook = dashboardResponse.recommendedBook != null &&
  ///       dashboardResponse.recommendedBook.isNotEmpty;
  ///   bool mIsTopSellBook = dashboardResponse.topSellBook != null &&
  ///       dashboardResponse.topSellBook.isNotEmpty;
  ///   bool mIsTopAuthor = dashboardResponse.topAuthor != null &&
  ///       dashboardResponse.topAuthor.isNotEmpty;
  ///   bool mIsCategoryBook = dashboardResponse.categoryBook != null &&
  ///       dashboardResponse.categoryBook.isNotEmpty;

  ///   return Column(
  ///     crossAxisAlignment: CrossAxisAlignment.start,
  ///     children: <Widget>[
  ///       //Collections
  ///       horizontalHeading(context, keyString(context, "lbl_collections"),
  ///               showViewAll: false)
  ///           .visible(mIsCategoryBook),
  ///       categoryList(dashboardResponse.categoryBook).visible(mIsCategoryBook),
  ///       //Top Search Book

  ///       horizontalHeading(context, keyString(context, "top_search_books"),
  ///           callback: () {
  ///         ViewAllBooks(
  ///                 type: type_top_search,
  ///                 title: keyString(context, "top_search_books"))
  ///             .launch(context);
  ///       }).visible(mIsTopSearchBook),
  ///       BookProductComponent(dashboardResponse.topSearchBook)
  ///           .visible(mIsTopSearchBook),
  ///       //Best Author

  ///       horizontalHeading(context, keyString(context, "best_author"),
  ///           callback: () {
  ///         AuthorsListScreen().launch(context);
  ///       }).visible(mIsTopAuthor),
  ///       authorList(dashboardResponse.topAuthor).visible(mIsTopAuthor),
  ///       //Recommended Books

  ///       horizontalHeading(context, keyString(context, "recommended_books"),
  ///           callback: () {
  ///         ViewAllBooks(
  ///                 type: type_recommended,
  ///                 title: keyString(context, "recommended_books"))
  ///             .launch(context);
  ///       }).visible(mIsRecommendedBook),
  ///       BookProductComponent(dashboardResponse.recommendedBook)
  ///           .visible(mIsRecommendedBook),
  ///       //Popular Books

  ///       horizontalHeading(context, keyString(context, "popular_books"),
  ///           callback: () {
  ///         ViewAllBooks(
  ///                 type: type_popular,
  ///                 title: keyString(context, "popular_books"))
  ///             .launch(context);
  ///       }).visible(mIsRecommendedBook),
  ///       BookProductComponent(dashboardResponse.popularBook, isHorizontal: true)
  ///           .visible(mIsRecommendedBook),
  ///       //Top Selling

  ///       horizontalHeading(context, keyString(context, "lbl_top_selling"),
  ///           callback: () {
  ///         ViewAllBooks(
  ///                 type: type_top_sell,
  ///                 title: keyString(context, "lbl_top_selling"))
  ///             .launch(context);
  ///       }).visible(mIsTopSellBook),
  ///       BookProductComponent(dashboardResponse.topSellBook)
  ///           .visible(mIsTopSellBook),
  ///     ],
  ///   );
  /// }

  /// Widget slider(List<HomeSlider> mSliderList) {
  ///   if (mSliderList.isEmpty) {
  ///     return Container();
  ///   }
  ///   return HomeSliderWidget(mSliderList).paddingTop(60);
  /// }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Scaffold(
      /// key: _scaffoldKey,
      drawer: HomeDrawer(),
      appBar: AppBar(
        title: Text(getBottomNavigationBarItem(selectedIndex).label),
        centerTitle: true,
        actions: <Widget>[
          InkWell(
            child: Container(
              width: 40,
              height: 40,
              padding: EdgeInsets.all(10.0),
              child: SvgPicture.asset(
                icon_search,
                color: context.theme.iconTheme.color,
              ),
            ),
            onTap: () {
              SearchScreen().launch(context);
            },
            radius: 12.0,
          ),
          HomeViewCartIcon(),
        ],
      ),
      body: getBody(selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: themeData.buttonTheme.colorScheme.onSecondary,
        selectedItemColor: themeData.buttonTheme.colorScheme.onPrimary,
        currentIndex: selectedIndex,
        onTap: (index) => setState(() => selectedIndex = index),
        items: [
          BottomNavigationBarItem(
              icon: Icon(MdiIcons.newspaperVariantOutline),
              label: keyString(context, "New Feed"),
              tooltip: keyString(context, "New Feed")),
          BottomNavigationBarItem(
              icon: Icon(MdiIcons.compassOutline),
              label: keyString(context, "Categories"),
              tooltip: keyString(context, "Categories")),
          BottomNavigationBarItem(
              icon: Icon(MdiIcons.storeOutline),
              label: keyString(context, "Store"),
              tooltip: keyString(context, "Store")),
          BottomNavigationBarItem(
              icon: Icon(MdiIcons.starOutline),
              label: keyString(context, "Top Charts"),
              tooltip: keyString(context, "Top Charts")),
          BottomNavigationBarItem(
              icon: Icon(MdiIcons.libraryShelves),
              label: keyString(context, "lbl_my_library"),
              tooltip: keyString(context, "lbl_my_library")),
        ],
      ),
    );
  }

  /// handle the page view and sheet
  int selectedIndex = 2;

  Widget getBody(int index) {
    return getBodies()[index];
  }

  List<Widget> getBodies() {
    return [
      NewFeedView(),
      CategoriesView(),
      HomeView(),
      TopChartsView(),
      LibraryView(),
    ];
  }

  BottomNavigationBarItem getBottomNavigationBarItem(int index) =>
      getBottomNavigationBarItems()[index];

  List<BottomNavigationBarItem> getBottomNavigationBarItems() {
    return [
      BottomNavigationBarItem(
          icon: Icon(MdiIcons.newspaperVariantOutline),
          label: keyString(context, "New Feed"),
          tooltip: keyString(context, "New Feed")),
      BottomNavigationBarItem(
          icon: Icon(MdiIcons.compassOutline),
          label: keyString(context, "Categories"),
          tooltip: keyString(context, "Categories")),
      BottomNavigationBarItem(
          icon: Icon(MdiIcons.storeOutline),
          label: keyString(context, "Store"),
          tooltip: keyString(context, "Store")),
      BottomNavigationBarItem(
          icon: Icon(MdiIcons.starOutline),
          label: keyString(context, "Top Charts"),
          tooltip: keyString(context, "Top Charts")),
      BottomNavigationBarItem(
          icon: Icon(MdiIcons.libraryShelves),
          label: keyString(context, "Libary"),
          tooltip: keyString(context, "Libary")),
    ];
  }
}
