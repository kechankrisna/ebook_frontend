import 'package:ebook/app_localizations.dart';
import 'package:ebook/models/response/category.dart';
import 'package:ebook/models/response/main_category.dart';
import 'package:ebook/network/rest_apis.dart';
import 'package:ebook/screens/home_screen/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nb_utils/nb_utils.dart';

class CategoriesView extends StatefulWidget {
  const CategoriesView({Key key}) : super(key: key);

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  bool isLoadingMoreData = false;
  List<Category> _subCategories = [];

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.endOfFrame.then((value) => _subCategoryList());
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
    return Column(
      children: [
        MainCategoryChipBar(
          onTap: (category) => _subCategoryList(category?.categoryId),
        ),
        Expanded(
          child: Container(
            child: ListView.builder(
              itemCount: _subCategories.length,
              itemBuilder: (_, index) {
                final Category subCategory = _subCategories[index];
                return Card(
                  child: ListTile(
                    title: Text(subCategory.name),
                    trailing: Icon(MdiIcons.arrowRight),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class MainCategoryChipBar extends StatefulWidget {
  final Function(Category category) onTap;
  const MainCategoryChipBar({Key key, this.onTap}) : super(key: key);

  @override
  State<MainCategoryChipBar> createState() => _MainCategoryChipBarState();
}

class _MainCategoryChipBarState extends State<MainCategoryChipBar> {
  bool isLoadingMoreData = false;
  Category _category;
  List<MainCategory> _mainCategories = [];

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.endOfFrame.then((value) => _categoryList());
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  Future _categoryList() async {
    isNetworkAvailable().then((bool) {
      if (bool) {
        mainCategories().then((result) {
          if (result.data != null && result.data.isNotEmpty) {
            setState(() {
              _mainCategories.clear();
              _mainCategories.add(MainCategory(categoryId: null, name: "ALL"));
              _mainCategories.addAll(result.data);

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
    return Container(
      decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(width: 1, color: Colors.grey[300]))),
      height: 50,
      child: ListView.builder(
        primary: false,
        scrollDirection: Axis.horizontal,
        itemCount: _mainCategories.length,
        itemBuilder: (_, index) {
          final category = _mainCategories[index].toCategory();
          return CategoryChip(
            category: category,
            selected: _category?.categoryId == category?.categoryId,
            onPressed: () {
              setState(() {
                _category = category;
              });
              widget.onTap?.call(_category);
            },
          );
        },
      ),
    );
  }
}
