import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vegetables_app/providers/order_provider.dart';

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

class OrderDetailsScreen extends ConsumerStatefulWidget {
  final int orderId;

  const OrderDetailsScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  ConsumerState<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch order details when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderDetailsProvider.notifier).fetchOrderDetails(widget.orderId);
    });
  }

  @override
  void dispose() {
    // Clear order details when leaving the screen
    ref.read(orderDetailsProvider.notifier).clearOrderDetails();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderDetailsState = ref.watch(orderDetailsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildAppBar(context),

            // Content Area
            Expanded(
              child: orderDetailsState.isLoading
                  ? Center(child: CircularProgressIndicator(color: backgroundColor))
                  : orderDetailsState.errorMessage != null
                  ? _buildErrorWidget(orderDetailsState.errorMessage!)
                  : orderDetailsState.orderDetails != null
                  ? _buildOrderDetailsWidget(orderDetailsState.orderDetails!)
                  : _buildNoDataWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: MyHeadingText(
              text: 'Order Details',
              fontSize: 20,
              backgroundColor: backgroundColor,
              textColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(Icons.error_outline, color: Colors.red, size: 60),
            ),
            SizedBox(height: 20),
            MyHeadingText(
              text: 'Oops! Something went wrong',
              fontSize: 18,
              backgroundColor: Colors.white,
              textColor: Colors.black87,
            ),
            SizedBox(height: 12),
            Mytextcontent(
              text: errorMessage,
              fontSize: 16,
              backgroundColor: Colors.white,
              textColor: Colors.red,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(orderDetailsProvider.notifier).retryFetchOrderDetails(widget.orderId);
              },
              icon: Icon(Icons.refresh, color: Colors.white),
              label: Text("Try Again", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          MyHeadingText(
            text: 'No order details found',
            fontSize: 18,
            backgroundColor: Colors.white,
            textColor: Colors.grey[600]!,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsWidget(OrderDetailsModel orderDetails) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildOrderHeader(orderDetails),
          SizedBox(height: 16),
          _buildProductsList(orderDetails),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOrderHeader(OrderDetailsModel orderDetails) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyHeadingText(
                      text: orderDetails.orderNo.toString(),
                      fontSize: 22,
                      backgroundColor: Colors.white,
                      textColor: Colors.black87,
                    ),
                    SizedBox(height: 4),
                    Mytextcontent(
                      text: 'Order ID: ${orderDetails.orderId}',
                      fontSize: 14,
                      backgroundColor: Colors.white,
                      textColor: Colors.grey[600]!,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _getStatusColor(orderDetails.orderStatus.toString()).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _getStatusColor(orderDetails.orderStatus.toString())),
                ),
                child: Mytextcontent(
                  text: orderDetails.orderStatus!.toUpperCase(),
                  fontSize: 12,
                  backgroundColor: Colors.transparent,
                  textColor: _getStatusColor(orderDetails.orderStatus.toString()),
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          // Order Info Row
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.calendar_today,
                  label: 'Date & Time',
                  value: '${orderDetails.orderDate}\n${orderDetails.orderTime}',
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.grey[300],
                margin: EdgeInsets.symmetric(horizontal: 16),
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.shopping_bag,
                  label: 'Items',
                  value: '${orderDetails.productCount} products',
                ),
              ),
            ],
          ),

          SizedBox(height: 20),
          Divider(color: Colors.grey[200], thickness: 1),
          SizedBox(height: 16),

          // Total Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyHeadingText(
                text: 'Total Amount',
                fontSize: 18,
                backgroundColor: Colors.white,
                textColor: Colors.black87,
              ),
              MyHeadingText(
                text: '₹${orderDetails.totalAmount}',
                fontSize: 24,
                backgroundColor: Colors.white,
                textColor: backgroundColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24, color: backgroundColor),
        SizedBox(height: 8),
        Mytextcontent(
          text: label,
          fontSize: 12,
          backgroundColor: Colors.white,
          textColor: Colors.grey[600]!,
        ),
        SizedBox(height: 4),
        Mytextcontent(
          text: value,
          fontSize: 14,
          backgroundColor: Colors.white,
          textColor: Colors.black87,
        ),
      ],
    );
  }

  Widget _buildProductsList(OrderDetailsModel orderDetails) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyHeadingText(
            text: 'Products (${orderDetails.products?.length})',
            fontSize: 18,
            backgroundColor: Colors.white,
            textColor: Colors.black87,
          ),
          SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: orderDetails.products?.length,
            itemBuilder: (context, index) {
              final product = orderDetails.products![index];
              return _buildProductItem(product, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(Products product, int index) {
    return InkWell(

      onTap: (){},
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: product.images!.isNotEmpty
                    ? Image.network(
                  product.images![0].image.toString(),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildImagePlaceholder();
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        color: backgroundColor,
                        strokeWidth: 2,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                )
                    : _buildImagePlaceholder(),
              ),
            ),

            SizedBox(width: 16),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyHeadingText(
                    text: product.name.toString(),
                    fontSize: 16,
                    backgroundColor: Colors.white,
                    textColor: Colors.black87,
                  ),
                  SizedBox(height: 6),
                  Mytextcontent(
                    text: '₹${product.price} per ${product.unit}',
                    fontSize: 14,
                    backgroundColor: Colors.white,
                    textColor: Colors.grey[600]!,
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: backgroundColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: backgroundColor.withOpacity(0.3)),
                        ),
                        child: Mytextcontent(
                          text: 'Qty: ${product!.qty} ${product.unit}',
                          fontSize: 12,
                          backgroundColor: Colors.transparent,
                          textColor: backgroundColor,
                        ),
                      ),
                      MyHeadingText(
                        text: '₹${product!.total}',
                        fontSize: 16,
                        backgroundColor: Colors.white,
                        textColor: backgroundColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported,
                color: Colors.grey[400], size: 24),
            SizedBox(height: 4),
            Mytextcontent(
              text: 'No Image',
              fontSize: 10,
              backgroundColor: Colors.transparent,
              textColor: Colors.grey[500]!,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'on process':
        return Colors.orange;
      case 'delivered':
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}