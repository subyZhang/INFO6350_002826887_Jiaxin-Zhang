import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/item.dart';

class ItemDetailScreen extends StatelessWidget {
  final Item item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final images = item.imageBase64List
        .map((b64) => Image.memory(base64Decode(b64), fit: BoxFit.cover))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(item.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(
            height: 200,
            child: PageView.builder(
              itemCount: images.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: images[index],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Price'),
            trailing: Text(
              '\$${item.price.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            title: const Text('Condition'),
            trailing: Text(item.condition),
          ),
          if (item.description.isNotEmpty)
            ListTile(
              title: const Text('Description'),
              trailing: Text(item.description, textAlign: TextAlign.right),
            ),
          ListTile(
            title: const Text('Contact'),
            trailing: Text(item.contact),
          ),
          if (item.locationName != null)
            ListTile(
              title: const Text('Location'),
              trailing: Text(item.locationName!),
            ),
          const SizedBox(height: 10),
          if (item.locationLat != null && item.locationLng != null)
            SizedBox(
              height: 200,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(item.locationLat!, item.locationLng!),
                  zoom: 14,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('item_location'),
                    position: LatLng(item.locationLat!, item.locationLng!),
                    infoWindow: InfoWindow(title: item.locationName),
                  ),
                },
                zoomControlsEnabled: false,
              ),
            ),
        ],
      ),
    );
  }
}
