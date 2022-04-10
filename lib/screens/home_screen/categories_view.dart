import 'package:ebook/app_localizations.dart';
import 'package:ebook/models/response/category.dart';
import 'package:ebook/network/rest_apis.dart';
import 'package:ebook/screens/home_screen/home_view.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nb_utils/nb_utils.dart';

class CategoriesView extends StatefulWidget {
  const CategoriesView({Key key}) : super(key: key);

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  bool isLoadingMoreData = false;

  /// final _categoryId = 6;
  Category _category;
  List<Category> _categories = [];
  List<Category> _subCategories = [];

  @override
  void initState() {
    super.initState();
    subCategoryList();
  }

  Future CategoryList() async {
    isNetworkAvailable().then((bool) {
      if (bool) {
        categoryList().then((result) {
          if (result.data != null && result.data.isNotEmpty) {
            
            setState(() {
              _categories.clear();
              _categories.add(Category(
                  categoryId: result.data,
                  subCategoryId: "",
                  name: "ALL BOOKS"));
              _categories.addAll(result.data);

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

  Future subCategoryList() async {
    isNetworkAvailable().then((bool) {
      if (bool) {
        var request = {"category_id": _category?.categoryId};
        subCategories(request).then((result) {
          if (result.data != null && result.data.isNotEmpty) {
            setState(() {
              _subCategories.clear();
              _subCategories.add(Category(
                  categoryId: _category?.categoryId,
                  subCategoryId: "",
                  name: "ALL BOOKS"));
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
        Container(
          height: 50,
          child: ListView.builder(
            primary: false,
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (_, index) {
              final category = _categories[index];
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
