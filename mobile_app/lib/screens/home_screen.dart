import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/item_model.dart';
import 'map_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<ItemModel> _lostItems = [];
  List<ItemModel> _foundItems = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    setState(() {
      _loading = true;
    });

    // For simplicity, fetching all lost and found items sorted by createdAt descending.
    // Location-based filtering to be implemented later.

    QuerySnapshot lostSnapshot = await _firestore
        .collection('posts')
        .where('type', isEqualTo: 'lost')
        .orderBy('createdAt', descending: true)
        .get();

    QuerySnapshot foundSnapshot = await _firestore
        .collection('posts')
        .where('type', isEqualTo: 'found')
        .orderBy('createdAt', descending: true)
        .get();

    setState(() {
      _lostItems = lostSnapshot.docs
          .map((doc) => ItemModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      _foundItems = foundSnapshot.docs
          .map((doc) => ItemModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      _loading = false;
    });
  }

  Widget _buildItemCard(ItemModel item) {
    return Card(
      child: ListTile(
        title: Text(item.itemName),
        subtitle: Text(item.description),
        trailing: item.reward != null ? Text('\$${item.reward!.toStringAsFixed(2)}') : null,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ItemDetailsScreen(item: item)),
          );
        },
      ),
    );
  }

  Widget _buildList(List<ItemModel> items) {
    if (items.isEmpty) {
      return Center(child: Text('No items found.'));
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildItemCard(items[index]);
      },
    );
  }

  void _goToMap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Khojo App'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Lost Items Near You'),
            Tab(text: 'Found Items Near You'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.map),
            onPressed: _goToMap,
            tooltip: 'Map View',
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(_lostItems),
                _buildList(_foundItems),
              ],
            ),
    );
  }
}
