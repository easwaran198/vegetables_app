import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vegetables_app/models/MyOrderRestwo.dart';
import 'package:vegetables_app/providers/order_provider.dart';
import 'package:vegetables_app/screens/order_details_screen.dart';

const Color backgroundColor = Color(0xFF4CAF50);

class MyHeadingText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color backgroundColor;
  final Color textColor;

  const MyHeadingText({
    Key? key,
    required this.text,
    required this.fontSize,
    required this.backgroundColor,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class Mytextcontent extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color backgroundColor;
  final Color textColor;

  const Mytextcontent({
    Key? key,
    required this.text,
    required this.fontSize,
    required this.backgroundColor,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        color: textColor,
      ),
    );
  }
}

class MyOrdersScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyorderState();
}

class _MyorderState extends ConsumerState<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderProvider.notifier).fetchOrders(OrderType.active);
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    final orderState = ref.watch(orderProvider);
    final orderNotifier = ref.read(orderProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(left: 20, bottom: 20, top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset("assets/images/back_img.png", width: 24, height: 24),
                  ),
                  MyHeadingText(
                      text: "My orders",
                      fontSize: 22,
                      backgroundColor: Colors.white,
                      textColor: Colors.black),
                  SizedBox(width: 48),
                ],
              ),
            ),
            // Order Type Selection Tabs
            Container(
              margin: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTabButton(
                      context, "Active", OrderType.active, orderState.selectedType, orderNotifier),
                  _buildTabButton(
                      context, "Completed", OrderType.completed, orderState.selectedType, orderNotifier),
                  _buildTabButton(
                      context, "Cancelled", OrderType.cancelled, orderState.selectedType, orderNotifier),
                ],
              ),
            ),
            // Content area
            Expanded(
              child: orderState.isLoading
                  ? Center(child: CircularProgressIndicator(color: backgroundColor))
                  : orderState.errorMessage != null
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 40),
                      SizedBox(height: 10),
                      Text(
                        orderState.errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          orderNotifier.fetchOrders(orderState.selectedType);
                        },
                        icon: Icon(Icons.refresh),
                        label: Text("Retry"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: backgroundColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
                  : orderState.orders.isEmpty
                  ? Center(
                child: Text(
                  "No ${orderState.selectedType.name} orders found.",
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              )
                  : ListView.builder(
                itemCount: orderState.orders.length,
                itemBuilder: (context, index) {
                  final order = orderState.orders[index];
                  return _buildOrderItem(context, order, orderState.selectedType);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(BuildContext context, String text, OrderType type1,
      OrderType selectedType, OrderNotifier notifier) {
    final bool isSelected = selectedType == type1;
    return InkWell(
      onTap: () {
        // Remove setState and just call notifier
        notifier.fetchOrders(type1);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: isSelected ? backgroundColor : Colors.white,
          border: Border.all(color: backgroundColor),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: backgroundColor.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
          ],
        ),
        child: Mytextcontent(
          text: text,
          fontSize: 16,
          backgroundColor: isSelected ? backgroundColor : Colors.white,
          textColor: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, Orders order, OrderType orderType) {
    var screenWidth = MediaQuery.of(context).size.width;
    final firstItem = order;

    if (firstItem == null) {
      return SizedBox.shrink();
    }

    // Determine status based on actual order status from API response
    Color statusColor;
    String statusText;
    IconData statusIcon;

    // Use the actual order status from the API response
    switch (order.orderStatus?.toLowerCase()) {
      case 'on process':
        statusColor = Colors.orange;
        statusText = "Order on process";
        statusIcon = Icons.pending_actions;
        break;
      case 'delivered':
      case 'completed':
        statusColor = Colors.green;
        statusText = "Order delivered";
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusText = "Order cancelled";
        statusIcon = Icons.cancel;
        break;
      default:
      // Fallback to OrderType if order status is not clear
        switch (orderType) {
          case OrderType.active:
            statusColor = Colors.orange;
            statusText = "Order on process";
            statusIcon = Icons.pending_actions;
            break;
          case OrderType.completed:
            statusColor = Colors.green;
            statusText = "Order delivered";
            statusIcon = Icons.check_circle;
            break;
          case OrderType.cancelled:
            statusColor = Colors.red;
            statusText = "Order cancelled";
            statusIcon = Icons.cancel;
            break;
        }
        break;
    }

    return InkWell(
      onTap: () {
        // Navigate to order details page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(orderId: order.orderId ?? 0),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        padding: EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: screenWidth * 0.22,
              height: screenWidth * 0.22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[100],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset("assets/images/logo.png"),
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyHeadingText(
                                text: "${firstItem.orderNo}",
                                fontSize: 17,
                                backgroundColor: Colors.white,
                                textColor: Colors.black),
                            SizedBox(height: 6),
                            MyHeadingText(
                                text: "Order ID: ${order.orderId}",
                                fontSize: 14,
                                backgroundColor: Colors.white,
                                textColor: Colors.grey[700]!),
                            MyHeadingText(
                                text: "Product count: ${order.productCount}",
                                fontSize: 14,
                                backgroundColor: Colors.white,
                                textColor: Colors.grey[700]!),
                            SizedBox(height: 6),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          MyHeadingText(
                              text: "₹${order.totalAmount}",
                              fontSize: 22,
                              backgroundColor: Colors.white,
                              textColor: Colors.green),
                          SizedBox(height: 4),
                        ],
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Icon(statusIcon, color: statusColor, size: 15),
                      SizedBox(width: 5),
                      MyHeadingText(
                          text: statusText,
                          fontSize: 12,
                          backgroundColor: Colors.white,
                          textColor: statusColor),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}