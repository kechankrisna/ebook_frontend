import 'dart:async';
import 'package:ebook/app_localizations.dart';
import 'package:ebook/network/rest_apis.dart';
import 'package:ebook/screens/filters/book_filter.dart';
import 'package:ebook/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wordpress_api/wordpress_api.dart';

class BlogController extends ChangeNotifier
    with DiagnosticableTreeMixin
    implements ReassembleHandler {
  /// check if current controller is dispose
  bool isDisposed = false;

  bool get mounted => !isDisposed;

  ///
  BuildContext context;
  BookFilter filter;
  WPResponse response;
  List<Post> posts;
  ScrollController scrollController;
  RefreshController refreshController;

  BlogController([BuildContext ctx]) {
    context = ctx;
    filter = BookFilter.instance();
    scrollController = ScrollController();
    refreshController = RefreshController();
    response = WPResponse(statusCode: 200);
    posts = [];
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

    filter = this.filter.copyWith(page: 1);
    var queryParams = this.filter.toMap();
    queryParams["_embed"] = true;

    final api = WordPressAPI(blogUrl);
    final WPResponse result = await api.posts.fetch(args: queryParams);

    this.response = result;
    this.posts.clear();
    this.posts.addAll(result.data as List<Post>);
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

    var _page = (this.filter.page + 1);
    filter = this.filter.copyWith(page: _page);

    var queryParams = this.filter.toMap();
    queryParams["_embed"] = "author";
    final api = WordPressAPI(blogUrl);
    final WPResponse result = await api.posts.fetch(args: queryParams);
    this.response = result;
    this.posts.addAll(result.data as List<Post>);
    refreshController?.loadComplete();
    notifyListeners();
  }

  updateFilter(BookFilter value) {
    filter = value;
    notifyListeners();
  }

  updateRespone(WPResponse value) {
    response = value;
    notifyListeners();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    /// list all the properties of your class here.
    /// See the documentation of debugFillProperties for more information.

    properties.add(StringProperty('page', filter.page.toString()));
    properties.add(StringProperty('per_page', filter.perPage.toString()));
    properties.add(StringProperty('search_text', filter.searchText.toString()));
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
