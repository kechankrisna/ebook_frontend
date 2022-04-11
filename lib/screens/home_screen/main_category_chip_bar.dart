import 'package:ebook/models/response/category.dart';
import 'package:ebook/models/response/main_category.dart';
import 'package:ebook/screens/controllers/main_category_controller.dart';
import 'package:flutter/material.dart';

import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

class MainCategoryChipBar extends StatefulWidget {
  final Function(Category category, MainCategory raw) onTap;
  const MainCategoryChipBar({Key key, this.onTap}) : super(key: key);

  @override
  State<MainCategoryChipBar> createState() => _MainCategoryChipBarState();
}

class _MainCategoryChipBarState extends State<MainCategoryChipBar> {
  bool isLoadingMoreData = false;
  Category _category;

  @override
  void initState() {
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<MainCategoryController>();
    var mainCategories = controller.response.data;
    if (mainCategories == null) {
      return SizedBox();
    }
    return Container(
      decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(width: 1, color: Colors.grey[300]))),
      height: 50,
      child: ListView.builder(
        primary: false,
        scrollDirection: Axis.horizontal,
        itemCount: mainCategories.length,
        itemBuilder: (_, index) {
          final category = mainCategories[index].toCategory();
          return CategoryChip(
            category: category,
            selected: _category?.categoryId == category?.categoryId,
            onPressed: () {
              setState(() {
                _category = category;
              });
              widget.onTap?.call(_category, mainCategories[index]);
            },
          );
        },
      ),
    );
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
