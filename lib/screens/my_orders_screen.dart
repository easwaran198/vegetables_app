import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vegetables_app/models/MyOrderRestwo.dart';
import 'package:vegetables_app/providers/order_provider.dart'; // Import the new provider
import 'package:vegetables_app/models/order_model.dart'; // Import the new models
const Color backgroundColor = Color(0xFF4CAF50); // A shade of green

// lib/widgets/MyHeadingText.dart
class MyHeadingText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color backgroundColor; // This parameter seems unused in the original, keeping for signature
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
        fontWeight: FontWeight.bold, // Assuming heading text is bold
      ),
    );
  }
}

// lib/widgets/MyTextContent.dart
class Mytextcontent extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color backgroundColor; // This parameter seems unused in the original, keeping for signature
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
// --- End Placeholder Widgets/Constants ---

class MyOrdersScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyorderState();
}

class _MyorderState extends ConsumerState<MyOrdersScreen> {
  var type = "on process";
  @override
  void initState() {
    super.initState();
    // Fetch initial active orders when the screen loads
    // Using addPostFrameCallback to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderProvider.notifier).fetchOrders(OrderType.active);
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    // var screenHeight = MediaQuery.of(context).size.height; // Not directly used in layout, but can be for scaling

    // Watch the order state from the provider. This will rebuild the widget
    // whenever the OrderState changes (e.g., loading, data received, error).
    final orderState = ref.watch(orderProvider);
    // Read the notifier to call its methods (e.g., fetchOrders)
    final orderNotifier = ref.read(orderProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Section (Back button and title)
            Container(
              margin: EdgeInsets.only(left: 20, bottom: 20, top: 20), // Added top margin for better spacing
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically in center
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset("assets/images/back_img.png", width: 24, height: 24), // Specify size for image
                  ),
                  MyHeadingText(
                      text: "My orders",
                      fontSize: 22,
                      backgroundColor: Colors.white,
                      textColor: Colors.black),
                  // These empty Text widgets are likely placeholders for alignment
                  // Consider using Spacer() or adjusting mainAxisAlignment for better control
                  SizedBox(width: 48), // Placeholder for alignment, roughly same width as back button + margin
                ],
              ),
            ),
            // Order Type Selection Tabs (Active, Completed, Cancelled)
            Container(
              margin: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround, // Distribute space evenly
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
            // Conditional rendering for Loading, Error, No Data, or Order List
            Expanded(
              child: orderState.isLoading
                  ? Center(child: CircularProgressIndicator(color: backgroundColor)) // Show loading indicator
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
                          // Retry fetching orders
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
                  return _buildOrderItem(context, order,type);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build the tab buttons (Active, Completed, Cancelled)
  Widget _buildTabButton(BuildContext context, String text, OrderType type1,
      OrderType selectedType, OrderNotifier notifier) {
    final bool isSelected = selectedType == type1;
    return InkWell(
      onTap: () {
        type = type1.toString();
        // Fetch orders when a tab is tapped
        notifier.fetchOrders(type1);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8), // Increased padding
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: isSelected ? backgroundColor : Colors.white,
          border: Border.all(color: backgroundColor),
          boxShadow: [ // Add a subtle shadow for better visual
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
          fontSize: 16, // Slightly smaller font for tabs
          backgroundColor: isSelected ? backgroundColor : Colors.white,
          textColor: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  // Helper method to build a single order item card
  Widget _buildOrderItem(BuildContext context, Cart order,String type) {
    var screenWidth = MediaQuery.of(context).size.width;
    // Display the first item's details as a summary for the order.
    // You might want to expand this to show all items or a more detailed summary.
    final firstItem = order;

    if (firstItem == null) {
      return SizedBox.shrink(); // Don't display if there are no items in the order
    }

    // Determine status color, text, and icon based on order status
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (type.toLowerCase()) {
      case 'on process':
        statusColor = Colors.orange;
        statusText = "Order on process";
        statusIcon = Icons.pending_actions;
        break;
      case 'delivered':
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
        statusColor = Colors.grey;
        statusText = "Status: ${order.orderStatus}";
        statusIcon = Icons.info_outline;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(15)), // More rounded corners
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8, // Increased blur for softer shadow
            offset: Offset(0, 4), // changes position of shadow
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8), // Adjusted margins
      padding: EdgeInsets.all(12), // Adjusted padding
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align items to the top
        children: [
          // Product Image
          Container(
            width: screenWidth * 0.22, // Adjusted width for better spacing
            height: screenWidth * 0.22, // Make it square
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), // Rounded corners for image container
              color: Colors.grey[100], // Light grey background for image area
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                firstItem.image!,
                fit: BoxFit.cover,
                // Placeholder for image loading error
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(Icons.broken_image, size: screenWidth * 0.1, color: Colors.grey),
                  );
                },
                // Placeholder while image is loading
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                      color: backgroundColor,
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(width: 15), // Spacing between image and details

          // Product Details (Name, Order ID, Status)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyHeadingText(
                    text: "${firstItem.name} (${firstItem.tamilName})",
                    fontSize: 17,
                    backgroundColor: Colors.white,
                    textColor: Colors.black),
                SizedBox(height: 6),
                MyHeadingText(
                    text: "Order ID: ${order.id}",
                    fontSize: 14,
                    backgroundColor: Colors.white,
                    textColor: Colors.grey[700]!),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 20),
                    SizedBox(width: 8),
                    MyHeadingText(
                        text: statusText,
                        fontSize: 12,
                        backgroundColor: Colors.white,
                        textColor: statusColor),
                  ],
                ),
              ],
            ),
          ),

          // Price and Quantity
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              MyHeadingText(
                  text: "₹${order.totalPrice}", // Display total order amount
                  fontSize: 22,
                  backgroundColor: Colors.white,
                  textColor: Colors.green),
              SizedBox(height: 4),
              MyHeadingText(
                  text: "${firstItem.totalPrice} / ${firstItem.name}", // Display item's total price and name
                  fontSize: 15,
                  backgroundColor: Colors.white,
                  textColor: Colors.grey),
            ],
          )
        ],
      ),
    );
  }
}
