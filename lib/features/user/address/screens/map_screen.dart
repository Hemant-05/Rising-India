import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/auth/bloc/auth_bloc.dart';
import 'package:raising_india/features/services/location_service.dart';
import 'package:raising_india/models/address_model.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.userId});
  final String userId;
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _titleController = TextEditingController();
  LatLng? _currentLatLng;
  String _selectedAddress = "Fetching address...";

  @override
  void initState() {
    super.initState();
    _getInitialLocation();
  }

  Future<void> _getInitialLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    _currentLatLng = LatLng(position.latitude, position.longitude);
    _selectedAddress = await LocationService.getReadableAddress(
      _currentLatLng!,
    );
    setState(() {});
  }

  void _onMapTap(LatLng latLng) async {
    _currentLatLng = latLng;
    _selectedAddress = await LocationService.getReadableAddress(
      _currentLatLng!,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Text('Map', style: simple_text_style(fontSize: 18)),
            const Spacer(),
          ],
        ),
      ),
      body: _currentLatLng == null
          ? Center(child: CircularProgressIndicator(color: AppColour.primary,))
          : Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLatLng!,
              zoom: 14,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onTap: _onMapTap,
            zoomControlsEnabled: false,
            markers: {
              Marker(
                markerId: MarkerId('selected'),
                position: _currentLatLng!,
                draggable: true,
                onDragEnd: _onMapTap,
              ),
            },
          ),
          Positioned(
            bottom: 140,
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: AppColour.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColour.primary, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hint: Text(
                    'Home, Work etc..',
                    style: simple_text_style(color: AppColour.lightGrey),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 90,
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: AppColour.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColour.primary, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              padding: EdgeInsets.all(12),
              child: Text(_selectedAddress, style: simple_text_style()),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                return ElevatedButton(
                  style: elevated_button_style(width: 200),
                  child: state is UserLocationLoading
                      ? Center(
                    child: CircularProgressIndicator(
                      color: AppColour.white,
                      constraints: BoxConstraints(
                        maxWidth: 40,
                        maxHeight: 40,
                      ),
                    ),
                  )
                      : Text(
                    "ADD ADDRESS",
                    style: simple_text_style(
                      color: AppColour.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    String title = _titleController.text.trim();
                    if(title.isNotEmpty) {
                      AddressModel model = AddressModel(title: title,
                          address: _selectedAddress,
                          position: GeoPoint(_currentLatLng!.latitude,
                              _currentLatLng!.longitude));
                      context.read<UserBloc>().add(
                        AddLocation(
                          model: model,
                        ),
                      );
                      Navigator.pop(context, true);
                    }else{
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColour.primary,
                            content: Text('Title is required...', style: simple_text_style(color: AppColour.white),),));
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
// remove current address and code and work on address list