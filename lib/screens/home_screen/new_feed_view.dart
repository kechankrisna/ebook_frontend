import 'package:ebook/screens/controllers/blog_controller.dart';
import 'package:ebook/utils/refresh_data_container.dart';
import 'package:ebook/utils/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class NewFeedView extends StatefulWidget {
  const NewFeedView({Key key}) : super(key: key);

  @override
  State<NewFeedView> createState() => _NewFeedViewState();
}

class _NewFeedViewState extends State<NewFeedView> {
  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.endOfFrame.then((value) {
      if (mounted) context.read<BlogController>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BlogController>();
    final data = controller.response?.data;
    final posts = controller.posts;
    if (data == null) {
      return Loader();
    }

    if (posts.isEmpty) {
      return RefreshDataContainer(
        onPressed: () => context.read<BlogController>().refresh(),
      );
    }
    return Container(
      padding: EdgeInsets.all(6),
      child: SmartRefresher(
        controller: controller.refreshController,
        header: defaultTargetPlatform == TargetPlatform.iOS
            ? WaterDropHeader()
            : WaterDropMaterialHeader(),
        enablePullDown: true,
        enablePullUp: true,
        onRefresh: () => context.read<BlogController>().refresh(),
        onLoading: () => context.read<BlogController>().loadMore(),
        child: ListView.separated(
          controller: context.read<BlogController>().scrollController,
          itemCount: posts.length,
          separatorBuilder: (_, index) => SizedBox(height: 6),
          itemBuilder: (_, index) {
            final post = posts[index];
            final imageUrl = post.embedModel?.media?.isNotEmpty == true
                ? post.embedModel?.media?.first?.sourceUrl
                : null;
            final authorName = post.embedModel?.author?.isNotEmpty == true
                ? post.embedModel?.author?.first?.name
                : "Unknown";
            final categoryName = post.embedModel?.categories?.isNotEmpty == true
                ? post.embedModel?.categories?.first?.name
                : "Uncategorized";

            if (index % 5 == 0 && index > 0) {
              return Card(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 250,
                      child: cachedImage(imageUrl, fit: BoxFit.fitWidth)
                          .cornerRadiusWithClipRRect(0)
                          .paddingAll(0),
                    ),
                    ListTile(
                      title: Text(
                        post.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(categoryName),
                    )
                  ],
                ),
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  child: cachedImage(imageUrl).cornerRadiusWithClipRRect(0),
                ),
                Expanded(
                  child: ListTile(
                    title: Text(
                      post.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(categoryName),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
