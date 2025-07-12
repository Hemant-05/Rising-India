import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/user/payment/screens/payment_screen.dart';

class SelectAddressScreen extends StatefulWidget {
  const SelectAddressScreen({super.key});

  @override
  _SelectAddressScreenState createState() => _SelectAddressScreenState();
}

class _SelectAddressScreenState extends State<SelectAddressScreen> {
  GoogleMapController? _mapController;
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
    _getAddressFromLatLng(_currentLatLng!);
    setState(() {});
  }

  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      Placemark place = placemarks[0];

      _selectedAddress =
          "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
      setState(() {});
    } catch (e) {
      _selectedAddress = "Could not find address";
    }
  }

  void _onMapTap(LatLng latLng) {
    _currentLatLng = latLng;
    _getAddressFromLatLng(latLng);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Delivery Address")),
      body: _currentLatLng == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentLatLng!,
                    zoom: 16,
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
                  bottom: 100,
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
                  child: ElevatedButton(
                    style: elevated_button_style(width: 200),
                    child: Text(
                      "Confirm Location",
                      style: simple_text_style(
                        color: AppColour.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context, {
                        'latLng': _currentLatLng,
                        'address': _selectedAddress,
                      });
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
