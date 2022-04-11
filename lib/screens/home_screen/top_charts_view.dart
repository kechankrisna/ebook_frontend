import 'package:ebook/app_localizations.dart';
import 'package:ebook/models/response/book_detail.dart';
import 'package:ebook/models/response/book_list.dart';
import 'package:ebook/models/response/category.dart';
import 'package:ebook/network/rest_apis.dart';
import 'package:ebook/screens/controllers/book_controller.dart';
import 'package:ebook/screens/home_screen/book_grid_action_button.dart';
import 'package:ebook/screens/home_screen/main_category_chip_bar.dart';
import 'package:ebook/utils/refresh_data_container.dart';
import 'package:ebook/utils/widgets.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TopChartsView extends StatefulWidget {
  const TopChartsView({Key key}) : super(key: key);

  @override
  State<TopChartsView> createState() => _TopChartsViewState();
}

class _TopChartsViewState extends State<TopChartsView> {
  bool isLoadingMoreData = false;
  Category _category;
  String _option = "PAID";
  List<String> _options = ["PAID", "FREE"];
  List<Category> _subCategories = [];

  List<BookDetail> books = [];

  BookController bookController;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.endOfFrame.then((value) {
      _subCategoryList();
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  Future _subCategoryList([int categoryId]) async {
    isNetworkAvailable().then((bool) {
      if (bool) {
        var request = {"category_id": categoryId};
        subCategories(request).then((result) {
          if (result.data != null && result.data.isNotEmpty) {
            setState(() {
              _subCategories.clear();

              _subCategories.addAll(result.data);

              /// selectedCategory = 0;
              /// isLoadingMoreData = true;
              /// fetchBookList();
              /// scrollController.addListener(() {
              ///   scrollHandler();
              /// });
            });
          } else {
            /// setState(() {
            ///   isDataLoaded = true;
            ///   isLoadingMoreData = false;
            /// });
          }
        }).catchError((error) {
          toast(error.toString());

          /// setState(() {
          ///   isLoadingMoreData = false;
          ///   isLastPage = true;
          /// });
        });
      } else {
        setState(() {
          isLoadingMoreData = false;
        });
        toast(keyString(context, "error_network_no_internet"));
        finish(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (ctx) => BookController(ctx))],
      child: Column(
        children: [
          MainCategoryChipBar(
            onTap: (category) {
              setState(() {
                _category = category;
              });
              _subCategoryList(category?.categoryId);
            },
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                flex: 8,
                fit: FlexFit.tight,
                child: PopupMenuButton(
                  position: PopupMenuPosition.under,
                  constraints: BoxConstraints(
                    maxHeight: size.height - 230,
                  ),
                  itemBuilder: (_) => _subCategories
                      .map((e) => PopupMenuItem(
                            child: Text(e.name),
                            value: e,
                          ))
                      .toList(),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(_category == null ? "All" : _category.name),
                        Icon(MdiIcons.menuDown),
                      ],
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 4,
                fit: FlexFit.tight,
                child: PopupMenuButton(
                  position: PopupMenuPosition.under,
                  padding: EdgeInsets.zero,
                  itemBuilder: (_) => _options
                      .map((e) => PopupMenuItem(
                            child: Text(e),
                            value: e,
                          ))
                      .toList(),
                  onSelected: (v) {
                    setState(() => _option = v);

                    ///
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(_option),
                        Icon(MdiIcons.menuDown),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: TopChartsBookListView(),
          ),
        ],
      ),
    );
  }
}

class TopChartsBookListView extends StatefulWidget {
  const TopChartsBookListView({Key key}) : super(key: key);

  @override
  State<TopChartsBookListView> createState() => _TopChartsBookListViewState();
}

class _TopChartsBookListViewState extends State<TopChartsBookListView> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.endOfFrame.then((value) {
      context.read<BookController>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BookController>();
    final data = controller.response?.data;
    if (data == null) {
      return Loader();
    }
    if (data.isEmpty) {
      return RefreshDataContainer(
        onPressed: () => context.read<BookController>().refresh(),
      );
    }
    return SmartRefresher(
      controller: controller.refreshController,
      header: defaultTargetPlatform == TargetPlatform.iOS
          ? WaterDropHeader()
          : WaterDropMaterialHeader(),
      enablePullDown: true,
      enablePullUp: true,
      onRefresh: () => context.read<BookController>().refresh(),
      onLoading: () => context.read<BookController>().loadMore(),
      child: ListView.builder(
        controller: context.read<BookController>().scrollController,
        itemCount: data.length,
        itemBuilder: (_, index) {
          final bookDetail = data[index];
          return BookListTile(bookDetail: bookDetail);
        },
      ),
    );
  }
}

class BookListTile extends StatelessWidget {
  final BookDetail bookDetail;
  const BookListTile({Key key, this.bookDetail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Row(
        children: [
          Container(
            width: 75,
            height: 100,
            padding: EdgeInsets.all(8),
            child: cachedImage(
              bookDetail.frontCover,
              fit: BoxFit.fill,
            ).cornerRadiusWithClipRRect(0),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(
                      bookDetail.title,
                      overflow: TextOverflow.ellipsis,
                    )),
                    BookGridActionButton(bookDetail: bookDetail),
                  ],
                ),
                Text(bookDetail.authorName),
                RatingBar.builder(
                  initialRating:
                      double.parse(bookDetail.totalRating.toString()),
                  minRating: 0,
                  glow: false,
                  itemSize: 16,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 0.0),
                  itemBuilder: (context, _) =>
                      Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (double value) {},
                ),
                Row(
                  children: [
                    Spacer(),
                    Text(
                        "${bookDetail.price.toString().toCurrencyFormat().validate()}")
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
