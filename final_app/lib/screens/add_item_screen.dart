import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import '../models/item.dart';
import '../services/database_service.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});
  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final contactController = TextEditingController();

  List<File?> _imageFiles = List.generate(4, (_) => null);
  List<String> _imageBase64List = [];
  String selectedCondition = 'Like New';
  double price = 50;
  LatLng? selectedLocation;
  String? selectedLocationName;
  GoogleMapController? _mapController;

  Future<void> _pickImage(int index) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Camera'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text('Gallery'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    );

    if (source != null) {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final bytes = await pickedFile.readAsBytes();
        final base64 = base64Encode(bytes);

        setState(() {
          _imageFiles[index] = file;
          if (_imageBase64List.length > index) {
            _imageBase64List[index] = base64;
          } else {
            _imageBase64List.add(base64);
          }
        });
      }
    }
  }

  Future<void> _getPlaceName(LatLng pos) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      final p = placemarks.first;
      String name = '${p.street}, ${p.locality}, ${p.administrativeArea}';
      setState(() {
        selectedLocation = pos;
        selectedLocationName = name;
      });
    } catch (e) {
      print('Failed to get placemark: $e');
      setState(() {
        selectedLocation = pos;
        selectedLocationName = 'Unknown location';
      });
    }
  }

  void _submit() async {
    final validImages = _imageBase64List.where((e) => e.isNotEmpty).toList();
    if (_formKey.currentState!.validate() &&
        validImages.isNotEmpty &&
        selectedLocation != null &&
        selectedLocationName != null) {
      final item = Item(
        id: '',
        name: nameController.text,
        description: descriptionController.text,
        condition: selectedCondition,
        price: price,
        contact: contactController.text,
        imageBase64List: validImages,
        locationLat: selectedLocation!.latitude,
        locationLng: selectedLocation!.longitude,
        locationName: selectedLocationName!,
      );

      await DatabaseService().addItem(item);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields, upload at least one image, and pick a location.'),
        ),
      );
    }
  }

  Widget _buildHorizontalImageUploader() {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _imageFiles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final file = _imageFiles[index];
          return GestureDetector(
            onTap: () => _pickImage(index),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                color: Colors.grey[200],
              ),
              child: file != null
                  ? Image.file(file, fit: BoxFit.cover)
                  : const Icon(Icons.add_a_photo, size: 30, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 200,
          child: GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(37.7749, -122.4194),
              zoom: 12,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: _getPlaceName,
            markers: selectedLocation != null
                ? {
              Marker(
                markerId: const MarkerId('selected'),
                position: selectedLocation!,
              )
            }
                : {},
          ),
        ),
        const SizedBox(height: 10),
        if (selectedLocationName != null)
          Text('Selected location: $selectedLocationName'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Item')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedCondition,
                decoration: const InputDecoration(
                    labelText: 'How old is the product? (Condition)'),
                items: [
                  'Brand New',
                  'Like New',
                  'Almost New',
                  'Gently Used',
                  'Used - Good',
                  'Used - Fair',
                  'Heavily Used',
                  'For Parts'
                ]
                    .map((cond) =>
                    DropdownMenuItem(value: cond, child: Text(cond)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    selectedCondition = val!;
                  });
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 20),
              Text('Price: \$${price.toStringAsFixed(0)}'),
              Slider(
                value: price,
                min: 0,
                max: 500,
                divisions: 100,
                label: '\$${price.toStringAsFixed(0)}',
                onChanged: (val) => setState(() => price = val),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: contactController,
                decoration: const InputDecoration(labelText: 'Contact Info'),
              ),
              const SizedBox(height: 20),
              const Text('Upload Images (tap to add or replace):'),
              const SizedBox(height: 10),
              _buildHorizontalImageUploader(),
              const SizedBox(height: 20),
              const Text('Pick Location on Map:'),
              const SizedBox(height: 10),
              _buildMapPicker(),
              const SizedBox(height: 30),
              ElevatedButton(onPressed: _submit, child: const Text('Submit')),
            ],
          ),
        ),
      ),
    );
  }
}
