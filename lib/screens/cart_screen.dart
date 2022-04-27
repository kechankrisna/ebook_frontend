import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ebook/models/request/order_detail.dart';
import 'package:ebook/models/response/braintree_payment_responses.dart';
import 'package:ebook/models/response/cart_response.dart';
import 'package:ebook/models/response/wishlist_response.dart';
import 'package:ebook/network/common_api_calls.dart';
import 'package:ebook/network/rest_apis.dart';
import 'package:ebook/screens/wishlist_screens.dart';
import 'package:ebook/utils/common.dart';
import 'package:ebook/utils/constants.dart';
import 'package:ebook/utils/payment/cart_payment.dart';
import 'package:ebook/utils/resources/colors.dart';
import 'package:ebook/utils/resources/images.dart';
import 'package:ebook/utils/widgets.dart';
import 'package:nb_utils/nb_utils.dart';

import '../app_localizations.dart';

class CartScreen extends StatefulWidget {
  static String tag = '/CartScreen';

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>
    with AfterLayoutMixin<CartScreen> {
  List<CartItem> list = [];
  List<WishListItem> wishList = [];
  double width;
  var mIsFirstTime = true;
  var totalMrp = 0.0;
  var total = 0.0;
  var discount = 0.0;
  var paymentMethod = LOCALEBANK;
  var userId;
  var userEmail;
  var phoneNo;
  var wishListCount = 0;
  var platform;
  bool isPayPalEnabled = false;
  bool isPayTmEnabled = false;
  bool isPayLocalBankEnabled = true;
  var authorization;

  @override
  void initState() {
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    if (mIsFirstTime) {
      platform = Theme.of(context).platform;
      isPayPalEnabled = await getBool(IS_PAYPAL_ENABLED);
      isPayTmEnabled = await getBool(IS_PAYTM_ENABLED);
      LiveStream().on(CART_DATA_CHANGED, (value) {
        if (mounted) {
          if (value != null) {
            showLoading(false);
            setCartItem(value);
          }
        }
      });
      LiveStream().on(WISH_LIST_DATA_CHANGED, (value) {
        if (mounted) {
          if (value != null) {
            showLoading(false);
            setWishListItem(value);
          }
        }
      });

      setCartItem(
          CartResponse.fromJson(jsonDecode(getStringAsync(CART_DATA))).data);
      var wishListItemList = await wishListItems();
      setWishListItem(wishListItemList);
      userId = await getInt(USER_ID);
      userEmail = await getString(USER_EMAIL) ?? "";
      phoneNo = await getString(USER_CONTACT_NO) ?? "";
    }
  }

  getClientToken(context) async {
    showLoading(true);
    isNetworkAvailable().then((bool) {
      if (bool) {
        generateClientToken().then((result) async {
          print(result);
          ClientTokenResponse response = ClientTokenResponse.fromJson(result);
          processBrainTreePayment(context, response.data);
        }).catchError((error) {
          print(error);
          toast(error.toString());
          finish(context);
          showLoading(false);
        });
      } else {
        toast(keyString(context, "error_network_no_internet"));
        finish(context);
        showLoading(false);
      }
    });
  }

  void setCartItem(List<CartItem> cartItems) {
    setState(() {
      list.clear();
      list.addAll(cartItems);
      var mrp = 0.0;
      var discounts = 0.0;
      list.forEach((cartItem) {
        mrp += tryParse(cartItem.price.toString()) ?? 0;
        discounts += getPercentageRate(tryParse(cartItem.price.toString()),
            tryParse(cartItem.discount.toString()));
      });
      totalMrp = mrp;
      discount = discounts;
      total = mrp - discounts;
    });
  }

  void setWishListItem(List<WishListItem> cartItems) {
    setState(() {
      wishList.clear();
      wishList.addAll(cartItems);
      wishListCount = cartItems.length;
    });
  }

  bool isLoading = false;

  showLoading(bool show) {
    setState(() {
      isLoading = show;
    });
  }

  OrderDetail getOrderDetail() {
    var orderDetail = OrderDetail();
    List<BookData> otherOrder = [];
    list.forEach((cartItem) {
      orderDetail.bookId = cartItem.bookId;
      orderDetail.price = cartItem.price;
      orderDetail.discount = cartItem.price;
      orderDetail.quantity = cartItem.addedQty;
      orderDetail.cashOnDelivery = cartItem.cashOnDelivery;
      BookData otherOrderData = BookData();
      otherOrderData.book_id = cartItem.bookId;
      otherOrderData.discount = cartItem.discount;
      otherOrderData.price = cartItem.price;
      otherOrder.add(otherOrderData);
    });
    orderDetail.otherDetail = OtherDetail(data: otherOrder);
    orderDetail.gstnumber = "";
    orderDetail.isHardCopy = "1";
    orderDetail.shippingCost = "";
    orderDetail.totalAmount = total.toString();
    orderDetail.userId = userId;
    orderDetail.discount = discount;
    orderDetail.paymentType = 1;
    orderDetail.gstnumber = "";
    orderDetail.isHardCopy = "1";
    return orderDetail;
  }

  processPayTmPayment(context) async {
    showLoading(true);

    await CartPayment.payWithPayTm(
        context, total, getOrderDetail().toJson(), paymentMethod);
  }

  processLocaleBankPayment(context) async {
    showLoading(true);
    var json = getOrderDetail().toJson();
    json["payment_type"] = "3";

    CartPayment.payWithLocalBank(context, total, json).then((res) {
      toast(keyString(context, "transaction will be checked"));
    }).catchError((error) {
      showLoading(false);
      toast(error.toString());
    });
  }

  processBrainTreePayment(context, token) async {
    showLoading(true);
    CartPayment.paywithPayPal(
            context, token, total.toString(), getOrderDetail().toJson())
        .then((res) {
      print(res + "paypal********************");
    }).catchError((error) {
      showLoading(false);
      toast(error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    placeOrder() {
      if (!isPayTmEnabled && !isPayPalEnabled && !isPayLocalBankEnabled) {
        toast("Payment option are not available");
        return;
      }
      if (paymentMethod.isNotEmpty) {
        if (paymentMethod == PAYPAL) {
          getClientToken(context);
        } else if (paymentMethod == PAYTM) {
          processPayTmPayment(context);
        } else if (paymentMethod == LOCALEBANK) {
          processLocaleBankPayment(context);
        }
      } else {
        toast(keyString(context, "error_select_payment_option"));
      }

      toast(keyString(context, "lbl_processing"));
    }

    final cartItems = list.isNotEmpty
        ? ListView.builder(
            itemCount: list.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return cartItemRow(list[index]);
            })
        : Container();

    final priceDetail = Container(
      decoration: boxDecorationWithShadow(
          borderRadius: radius(8), backgroundColor: context.cardColor),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(keyString(context, "lbl_total_mrp"),
                      style: primaryTextStyle(
                          color: context.theme.textTheme.headline6.color))
                  .expand(),
              Text(totalMrp.toString().toCurrencyFormat(),
                  style: boldTextStyle(
                      color: context.theme.textTheme.headline6.color)),
            ],
          ).paddingAll(12.0),
          Row(
            children: <Widget>[
              Text(keyString(context, "lbl_discount"),
                      style: primaryTextStyle(
                          color: context.theme.textTheme.headline6.color))
                  .expand(),
              Text("-" + discount.toString().toCurrencyFormat(),
                  style: boldTextStyle(color: Colors.green)),
            ],
          ).paddingOnly(left: 12.0, right: 12.0, bottom: 8.0),
          Divider(
            thickness: 0.8,
          ),
          Row(
            children: <Widget>[
              Text(keyString(context, "lbl_total"),
                      style: boldTextStyle(
                          color: context.theme.textTheme.headline6.color))
                  .expand(),
              Text(total.toString().toCurrencyFormat(),
                  style: boldTextStyle(
                      color: context.theme.textTheme.headline6.color)),
            ],
          ).paddingOnly(left: 12.0, right: 12.0, top: 4.0, bottom: 12.0),
        ],
      ),
    ).paddingOnly(left: 12.0, right: 12.0, bottom: 4.0);

    final next = Container(
      color: Theme.of(context).cardTheme.color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Wrap(
            children: <Widget>[
              Text(keyString(context, "lbl_total_amount"),
                  style: primaryTextStyle(
                      color: context.theme.textTheme.headline6.color,
                      size: 16)),
              Text(total.toString().toCurrencyFormat(),
                  style: boldTextStyle(
                      color: context.theme.textTheme.headline6.color,
                      size: 18)),
            ],
          ),
          MaterialButton(
            child: Text(keyString(context, "lbl_place_order"),
                style: primaryTextStyle(color: Colors.white)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4.0))),
            elevation: 5.0,
            minWidth: 150,
            height: 40,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              if (!isLoading) {
                placeOrder();
              }
            },
          ),
        ],
      ).paddingOnly(left: 16, right: 16, top: 8, bottom: 8),
    );

    Widget paymentOptions = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(keyString(context, "lbl_payment_method"),
                style: boldTextStyle(
                    color: context.theme.textTheme.headline6.color))
            .paddingAll(16)
            .visible(isPayPalEnabled || isPayTmEnabled),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              decoration: boxDecorationWithShadow(
                  borderRadius: radius(8), backgroundColor: context.cardColor),
              padding: EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Image.asset(icon_paytm, width: 60, height: 40),
                      Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: paymentMethod == PAYTM
                                ? Theme.of(context).primaryColor
                                : null,
                            border: paymentMethod == PAYTM
                                ? null
                                : Border.all(color: Colors.grey, width: 0.5),
                          ),
                          child: Icon(
                            Icons.done,
                            color: Colors.white,
                            size: 16,
                          )).visible(paymentMethod == PAYTM)
                    ],
                  ),
                  Text(keyString(context, "lbl_paytm"),
                      style: boldTextStyle(
                          color: context.theme.textTheme.headline6.color)),
                ],
              ),
            )
                .onTap(() {
                  setState(() {
                    paymentMethod = PAYTM;
                  });
                })
                .visible(isPayTmEnabled)
                .expand(),
            16.width,
            Container(
              decoration: boxDecorationWithShadow(
                  borderRadius: radius(8), backgroundColor: context.cardColor),
              padding: EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SvgPicture.asset(
                        icon_paypal,
                        width: 30,
                        height: 30,
                      ),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: paymentMethod == PAYPAL
                              ? Theme.of(context).primaryColor
                              : null,
                          border: paymentMethod == PAYPAL
                              ? null
                              : Border.all(color: Colors.grey, width: 0.5),
                        ),
                        child: Icon(
                          Icons.done,
                          color: Colors.white,
                          size: 16,
                        ).visible(paymentMethod == PAYPAL),
                      )
                    ],
                  ),
                  Text(keyString(context, "lbl_paypal"),
                          style: boldTextStyle(
                              color: context.theme.textTheme.headline6.color))
                      .paddingTop(8.0),
                ],
              ),
            )
                .onTap(
                  () {
                    setState(() {
                      paymentMethod = PAYPAL;
                    });
                  },
                )
                .visible(isPayPalEnabled)
                .expand(),
          ],
        ).paddingOnly(left: 12.0, right: 12.0)
      ],
    );

    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(keyString(context, "lbl_cart"),
            style:
                boldTextStyle(color: context.theme.textTheme.headline6.color)),
        centerTitle: true,
        iconTheme: context.theme.iconTheme,
        backgroundColor: context.scaffoldBackgroundColor,
        actions: <Widget>[
          Badge(
            badgeContent: Text(wishListCount.toString(),
                style: primaryTextStyle(color: Colors.white, size: 14)),
            badgeColor: Colors.red,
            showBadge: wishListCount > 0,
            position: BadgePosition.topEnd(end: -5),
            animationType: BadgeAnimationType.fade,
            child: SvgPicture.asset(
              icon_bookmark,
              height: 24,
              width: 24,
              color: context.theme.textTheme.headline6.color,
            ),
          ).paddingAll(12).onTap(() {
            if (wishListCount > 0) {
              WishlistScreen().launch(context);
            } else {
              toast(keyString(context, "error_wishlist_empty"));
            }
          })
        ],
      ),
      body: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () {
                    LiveStream().emit(CART_ITEM_CHANGED, true);
                    LiveStream().emit(WISH_DATA_ITEM_CHANGED, true);
                    return null;
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(keyString(context, "lbl_cart_items"),
                                style: boldTextStyle(
                                    color: context
                                        .theme.textTheme.headline6.color))
                            .paddingAll(16),
                        cartItems,
                        Text(keyString(context, "lbl_payment_detail"),
                                style: boldTextStyle(
                                    color: context
                                        .theme.textTheme.headline6.color))
                            .paddingAll(16),
                        priceDetail,
                        paymentOptions,
                      ],
                    ).paddingBottom(70),
                  ),
                ),
              ).visible(list.isNotEmpty),
              Container(
                alignment: Alignment.center,
                child: Column(
                  children: <Widget>[
                    SvgPicture.asset(ic_empty, width: 180, height: 180),
                    Text(keyString(context, "error_cart_empty"),
                            style: boldTextStyle(
                                color: context.theme.textTheme.subtitle2.color,
                                size: 22))
                        .paddingTop(12.0),
                  ],
                ),
              ).visible(list.isEmpty),
              next.visible(list.isNotEmpty)
            ],
          ),
          Center(
            child: Loader(),
          ).visible(isLoading)
        ],
      ),
    );
  }

  Widget cartItemRow(CartItem cartItem) {
    return Container(
      padding: EdgeInsets.all(8),
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      decoration: boxDecorationWithShadow(
          borderRadius: radius(8),
          spreadRadius: 1,
          blurRadius: 5,
          backgroundColor: context.cardColor),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            cachedImage(cartItem.frontCover,
                    height: 30, width: 100, fit: BoxFit.fill)
                .cornerRadiusWithClipRRect(8),
            16.width,
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(cartItem.name,
                        style: boldTextStyle(
                            color: context.theme.textTheme.headline6.color)),
                    6.height,
                    Text(cartItem.authorName,
                        style: primaryTextStyle(
                            color: context.theme.textTheme.headline6.color)),
                    6.height,
                    Row(
                      children: <Widget>[
                        Text(
                          cartItem.discount != 0
                              ? discountedPrice(
                                      tryParse(cartItem.price.toString()),
                                      tryParse(cartItem.discount.toString()))
                                  .toString()
                                  .toCurrencyFormat()
                              : cartItem.price.toString().toCurrencyFormat(),
                          style: boldTextStyle(
                              color: context.theme.textTheme.headline6.color),
                        ).visible(cartItem.price != 0),
                        6.width,
                        Text(
                          cartItem.price.toString().toCurrencyFormat(),
                          style: primaryTextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: context.theme.textTheme.subtitle2.color),
                        ).visible(cartItem.discount != 0),
                        6.width,
                        Text(
                                cartItem.discount.toString() +
                                    keyString(context, "lbl_off"),
                                style: boldTextStyle(color: Colors.red))
                            .visible(cartItem.discount != 0),
                      ],
                    ),
                  ],
                ),
                Divider(),
                Row(
                  children: <Widget>[
                    Flexible(
                        child: TextButton.icon(
                            onPressed: () {
                              removeBookFromCart(context, cartItem,
                                  addToWishList: true);
                            },
                            icon: Icon(Icons.bookmark_border,
                                size: 20, color: colorPrimary),
                            label: Text(
                                keyString(context, "lbl_move_to_wishlist"),
                                style: boldTextStyle(
                                    size: 14, color: colorPrimary),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1))),
                    Flexible(
                        child: TextButton.icon(
                            onPressed: () {
                              removeBookFromCart(context, cartItem);
                            },
                            icon: Icon(Icons.delete_outline,
                                size: 20, color: Colors.red),
                            label: Text(keyString(context, "lbl_remove"),
                                style: primaryTextStyle(
                                    size: 14, color: Colors.red)))),
                  ],
                ).expand()
              ],
            ).expand()
          ],
        ),
      ),
    );
  }
}
