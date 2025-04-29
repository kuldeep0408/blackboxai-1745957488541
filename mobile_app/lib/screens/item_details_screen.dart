import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/item_model.dart';
import '../services/report_service.dart';

class ItemDetailsScreen extends StatefulWidget {
  final ItemModel item;

  ItemDetailsScreen({required this.item});

  @override
  _ItemDetailsScreenState createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  final ReportService _reportService = ReportService();
  final TextEditingController _reportReasonController = TextEditingController();

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Report Post'),
          content: TextField(
            controller: _reportReasonController,
            decoration: InputDecoration(hintText: 'Enter reason for reporting'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String reason = _reportReasonController.text.trim();
                if (reason.isNotEmpty) {
                  String reporterId = FirebaseAuth.instance.currentUser?.uid ?? '';
                  await _reportService.createReport(widget.item.id, reporterId, reason);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Report submitted')));
                }
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _reportReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Scaffold(
      appBar: AppBar(
        title: Text(item.itemName),
        actions: [
          IconButton(
            icon: Icon(Icons.report),
            onPressed: _showReportDialog,
            tooltip: 'Report Post',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            if (item.photoUrl != null)
              Image.network(item.photoUrl!),
            SizedBox(height: 10),
            Text('Description: ${item.description}'),
            SizedBox(height: 10),
            Text('Category: ${item.category}'),
            SizedBox(height: 10),
            Text('Date Lost/Found: ${item.dateLost.toLocal().toString().split(' ')[0]}'),
            SizedBox(height: 10),
            Text('Reward: ${item.reward != null ? '\$${item.reward!.toStringAsFixed(2)}' : 'None'}'),
          ],
        ),
      ),
    );
  }
}
