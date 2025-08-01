import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/admin/all_product_list/bloc/products_cubit.dart';
import 'package:raising_india/models/product_model.dart';

class AdminProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const AdminProductDetailScreen({super.key, required this.product});
  @override
  State<AdminProductDetailScreen> createState() => _AdminProductDetailScreenState();
}

class _AdminProductDetailScreenState extends State<AdminProductDetailScreen> {
  late TextEditingController nameC;
  late TextEditingController descC;
  late TextEditingController priceC;
  late TextEditingController quantityC;
  late bool isAvailable;
  bool loading = false;

  @override
  void initState() {
    nameC = TextEditingController(text: widget.product.name);
    descC = TextEditingController(text: widget.product.description);
    priceC = TextEditingController(text: widget.product.price.toString());
    quantityC = TextEditingController(text: widget.product.quantity.toString());
    isAvailable = widget.product.isAvailable;
    super.initState();
  }

  Future<void> save() async {
    setState(() => loading = true);
    try {
      await FirebaseFirestore.instance.collection('products').doc(widget.product.pid).update({
        'name': nameC.text.trim(),
        'description': descC.text.trim(),
        'price': double.tryParse(priceC.text.trim()) ?? widget.product.price,
        'quantity' : quantityC.text.trim().toString(),
        'isAvailable': isAvailable,
        'name_lower': nameC.text.trim().toLowerCase(),
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Save Failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final prod = widget.product;
    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: AppBar(
        backgroundColor: AppColour.white,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              back_button(),
              SizedBox(width: 10,),
              Text("Product Details",style: simple_text_style(fontSize: 20),),
            ],
          ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text("Delete Product",style: simple_text_style(fontWeight: FontWeight.bold),),
                  content: Text("Are you sure you want to delete this product? This cannot be undone.",style: simple_text_style(),),
                  actions: [
                    TextButton(child: Text("Cancel",style: simple_text_style(),), onPressed: () => Navigator.pop(ctx, false)),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text("Delete",style: simple_text_style(),),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                context.read<ProductsCubit>().deleteProduct(context, prod.pid);
              }
            },
          ),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(color: AppColour.primary,))
          : ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // Images
          if (prod.photos_list.isNotEmpty)
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: prod.photos_list.length,
                separatorBuilder: (_, __) => SizedBox(width: 8),
                itemBuilder: (c, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(prod.photos_list[i], width: 100, height: 100, fit: BoxFit.cover),
                ),
              ),
            ),
          const SizedBox(height: 20),
          text_field(nameC,null,'Product Name'),
          const SizedBox(height: 10),
          text_field(descC, 2,'Product Description'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: text_field(priceC, null, 'Product Price')),
              const SizedBox(width: 10),
              Expanded(child: text_field(quantityC, null, 'Product Quantity')),
            ],
          ),
          const SizedBox(height: 10),
          _detailRow("Category", prod.category),
          _detailRow("Measurement", prod.measurement),
          _detailRow("Rating", prod.rating.toStringAsFixed(2)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: save,
            style: elevated_button_style(),
            child: Text('Save Changes',style: simple_text_style(color: AppColour.white),)
          ),
        ],
      ),
    );
  }

  Widget text_field(TextEditingController controller,int? maxLine,String label) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: simple_text_style(color: AppColour.grey, fontSize: 12),
          ),
        ),
        const SizedBox(height: 10,),
        Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColour.grey.withOpacity(0.1),
              ),
              child: TextField(
                maxLines: maxLine?? null,
                controller: controller,
                mouseCursor: MouseCursor.uncontrolled,
                style: simple_text_style(),
                decoration: InputDecoration(
                  hintStyle: simple_text_style(color: AppColour.lightGrey),
                  hintText: '',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 18,
                  ),
                ),
              ),
            ),
      ],
    );
  }

  Widget _detailRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Row(
      children: [
        Text("$label: ", style: simple_text_style(fontWeight: FontWeight.bold)),
        Expanded(child: Text(value, style: simple_text_style())),
      ],
    ),
  );
}
