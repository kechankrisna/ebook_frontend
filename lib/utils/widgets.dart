import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:ebook/app_localizations.dart';
import 'package:ebook/models/response/book_rating.dart';
import 'package:ebook/screens/cart_screen.dart';
import 'package:ebook/screens/sign_in_screen.dart';
import 'package:ebook/utils/constants.dart';
import 'package:ebook/utils/resources/images.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

Widget cachedImage(String url,
    {double height,
    double width,
    BoxFit fit,
    AlignmentGeometry alignment,
    bool usePlaceholderIfUrlEmpty = true,
    double radius}) {
  if (url.validate().isEmpty) {
    return placeHolderWidget(
        height: height,
        width: width,
        fit: fit,
        alignment: alignment,
        radius: radius);
  } else if (url.validate().startsWith('http')) {
    return CachedNetworkImage(
      imageUrl: url,
      height: height,
      width: width,
      fit: fit,
      alignment: alignment ?? Alignment.center,
      errorWidget: (_, s, d) {
        return placeHolderWidget(
            height: height,
            width: width,
            fit: fit,
            alignment: alignment,
            radius: radius);
      },
      placeholder: (_, s) {
        if (!usePlaceholderIfUrlEmpty) return SizedBox();
        return placeHolderWidget(
            height: height,
            width: width,
            fit: fit,
            alignment: alignment,
            radius: radius);
      },
    );
  } else {
    return Image.asset(url,
            height: height,
            width: width,
            fit: fit,
            alignment: alignment ?? Alignment.center)
        .cornerRadiusWithClipRRect(radius ?? defaultRadius);
  }
}

Widget placeHolderWidget(
    {double height,
    double width,
    BoxFit fit,
    AlignmentGeometry alignment,
    double radius}) {
  return Image.asset(placeholder,
          height: height,
          width: width,
          fit: BoxFit.fitHeight,
          alignment: alignment ?? Alignment.center)
      .cornerRadiusWithClipRRect(radius ?? defaultRadius);
}

Widget horizontalHeading(BuildContext context, var title,
    {bool showViewAll = true, var callback}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Expanded(
          child: Text(title,
              style: boldTextStyle(
                  color: context.theme.textTheme.headline6.color, size: 22))),
      GestureDetector(
        onTap: callback,
        child: Container(
          padding: EdgeInsets.only(left: 12.0, top: 8.0, bottom: 8.0),
          child: Text(keyString(context, "lbl_view_all"),
              style: secondaryTextStyle(
                  color: Theme.of(context).textTheme.button.color)),
        ).visible(showViewAll),
      )
    ],
  ).paddingOnly(left: 12.0, right: 12.0, top: 8.0);
}

extension StringExtension on String {
  String toCurrencyFormat({var format = '\$'}) {
    var value = double.tryParse(this);
    return format + value.toStringAsFixed(2);
  }

  String formatDateTime() {
    if (this == null || this.isEmpty || this == "null") {
      return "NA";
    } else {
      return DateFormat("HH:mm dd MMM yyyy", "en_US").format(
          DateFormat("yyyy-MM-dd HH:mm:ss", "en_US")
              .parse(this.replaceAll("T", " ").replaceAll(".0", "")));
    }
  }
}

Widget review(BuildContext context, BookRating bookRating,
    {bool isUserReview = false, VoidCallback callback}) {
  return Stack(
    children: <Widget>[
      Container(
        margin: EdgeInsets.only(top: 16.0),
        padding: EdgeInsets.all(8),
        decoration: boxDecorationWithShadow(
          borderRadius: radius(8),
          blurRadius: 4,
          spreadRadius: 2,
          backgroundColor: context.cardColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            bookRating.profileImage != null
                ? cachedImage(bookRating.profileImage, width: 40, height: 40)
                    .cornerRadiusWithClipRRect(25)
                : Image.asset(ic_profile, width: 40, height: 40)
                    .cornerRadiusWithClipRRect(25),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(bookRating.userName.toString().validate(),
                    style: boldTextStyle(
                        color: context.theme.textTheme.headline6.color)),
                Row(
                  children: <Widget>[
                    RatingBar.builder(
                      tapOnlyMode: true,
                      initialRating: double.parse(bookRating.rating.toString()),
                      minRating: 0,
                      glow: false,
                      itemSize: 15,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 0.0),
                      itemBuilder: (context, _) =>
                          Icon(Icons.star, color: Colors.amber),
                      onRatingUpdate: (double value) {},
                    ),
                    Text(bookRating.createdAt,
                            style: primaryTextStyle(
                                color: context.theme.textTheme.headline6.color))
                        .paddingOnly(left: 8),
                  ],
                ),
                Text(bookRating.review != null ? bookRating.review : "NA",
                    style: primaryTextStyle(
                        color: context.theme.textTheme.headline6.color)),
              ],
            ).paddingLeft(12.0).expand(),
          ],
        ),
      ),
      Align(
        alignment: Alignment.topRight,
        child: IconButton(
          icon: Icon(Icons.delete,
              size: 20, color: context.theme.textTheme.subtitle2.color),
          onPressed: callback,
        ),
      ).paddingTop(8.0).visible(isUserReview),
    ],
  );
}

Widget cartIcon(BuildContext context, cartCount) {
  return InkWell(
    child: Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          margin: EdgeInsets.only(right: 12.0),
          padding: EdgeInsets.all(8.0),
          child: Image.asset(
            icoCart,
            color: context.theme.iconTheme.color,
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Container(
            margin: EdgeInsets.only(top: 4.0),
            padding: EdgeInsets.all(6),
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: Colors.red),
            child: Text(cartCount.toString(),
                style: primaryTextStyle(color: Colors.white)),
          ).visible(cartCount != 0),
        )
      ],
    ),
    onTap: () {
      getBoolAsync(IS_LOGGED_IN)
          ? CartScreen().launch(context)
          : SignInScreen().launch(context);
    },
    radius: 12,
  );
}

class HorizontalHeading extends StatelessWidget {
  final String title;
  final bool showViewAll;
  final VoidCallback onTap;
  const HorizontalHeading(
      {Key key, this.title, this.showViewAll = true, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
            child: Text(title,
                style: boldTextStyle(
                  color: context.theme.textTheme.bodyMedium.color,
                ))),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.only(left: 12.0, top: 8.0, bottom: 8.0),
            child: Text(keyString(context, "more").toUpperCase(),
                style: secondaryTextStyle(
                    color: Theme.of(context).textTheme.button.color)),
          ).visible(showViewAll),
        )
      ],
    ).paddingOnly(left: 12.0, right: 12.0, top: 8.0);
  }
}
