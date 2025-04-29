import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Set<Marker> _markers = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    setState(() {
      _loading = true;
    });

    QuerySnapshot snapshot = await _firestore.collection('posts').get();

    Set<Marker> markers = {};

    for (var doc in snapshot.docs) {
      ItemModel item = ItemModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      markers.add(
        Marker(
          markerId: MarkerId(item.id),
          position: LatLng(item.lastSeenLocation.latitude, item.lastSeenLocation.longitude),
          infoWindow: InfoWindow(
            title: item.itemName,
            snippet: item.type == 'lost' ? 'Lost Item' : 'Found Item',
            onTap: () {
              _showItemDetails(item);
            },
          ),
          icon: item.type == 'lost'
              ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
              : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }

    setState(() {
      _markers = markers;
      _loading = false;
    });
  }

  void _showItemDetails(ItemModel item) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.itemName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(item.description),
              SizedBox(height: 8),
              Text('Category: ${item.category}'),
              SizedBox(height: 8),
              if (item.reward != null) Text('Reward: \$${item.reward!.toStringAsFixed(2)}'),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement contact or comment functionality
                  Navigator.pop(context);
                },
                child: Text('Contact / Comment'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map View'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(37.7749, -122.4194), // Default to San Francisco
                zoom: 12,
              ),
              markers: _markers,
              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),
    );
  }
}
