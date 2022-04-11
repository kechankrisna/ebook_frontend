import 'dart:async';

import 'package:ebook/app_localizations.dart';
import 'package:ebook/models/response/main_category.dart';
import 'package:ebook/network/rest_apis.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MainCategoryController extends ChangeNotifier
    with DiagnosticableTreeMixin
    implements ReassembleHandler {
  /// check if current controller is dispose
  bool isDisposed = false;

  bool get mounted => !isDisposed;

  ///
  BuildContext context;
  MainCategoryResponse response;
  ScrollController scrollController;
  RefreshController refreshController;

  MainCategoryController([BuildContext ctx]) {
    context = ctx;
    scrollController = ScrollController();
    refreshController = RefreshController();
    response = MainCategoryResponse();
    refresh();
  }

  Future refresh() async {
    /// check connection
    bool isConnected = await isNetworkAvailable();
    if (!isConnected) {
      toast(keyString(context, "error_network_no_internet"));
      refreshController?.refreshFailed();
      notifyListeners();
      return;
    }

    var result = await mainCategories();

    this.response = result;
    refreshController?.refreshCompleted();
    notifyListeners();
  }

  Future loadMore() async {
    /// check connection
    bool isConnected = await isNetworkAvailable();
    if (!isConnected) {
      toast(keyString(context, "error_network_no_internet"));
      refreshController?.loadFailed();
      notifyListeners();
      return;
    }

    var result = await mainCategories();
    this.response.data.addAll(result.data);
    refreshController?.loadComplete();
    notifyListeners();
  }

  updateRespone(MainCategoryResponse value) {
    response = value;
    notifyListeners();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    /// list all the properties of your class here.
    /// See the documentation of debugFillProperties for more information.

    /// properties.add(StringProperty('page', filter.page.toString()));
    /// properties.add(StringProperty('per_page', filter.perPage.toString()));
    /// properties.add(StringProperty('search_text', filter.searchText.toString()));
  }

  @override
  void reassemble() {
    print('Did hot-reload ApplicationController');
  }

  @override
  void notifyListeners() {
    if (!isDisposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    /// TODO: dispose
    isDisposed = true;
    refreshController?.dispose();
    scrollController?.dispose();
    super.dispose();
  }
}
