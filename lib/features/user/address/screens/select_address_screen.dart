import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/auth/bloc/auth_bloc.dart';
import 'package:raising_india/features/auth/services/auth_service.dart';
import 'package:raising_india/features/services/location_service.dart';
import 'package:raising_india/features/user/address/screens/map_screen.dart';
import 'package:raising_india/models/address_model.dart';

class SelectAddressScreen extends StatefulWidget {
  const SelectAddressScreen({super.key});

  @override
  _SelectAddressScreenState createState() => _SelectAddressScreenState();
}

class _SelectAddressScreenState extends State<SelectAddressScreen> {
  bool isLoading = false;
  String? address;
  LatLng? latLng;
  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(GetLocationList());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Text('Addresses', style: simple_text_style(fontSize: 20)),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () async {
                  var user = await AuthService().getCurrentUser();
                  var id = user!.uid;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapScreen(userId: id),
                    ),
                  );
                },
                child: Text(
                  'ADD LOCATION',
                  style: simple_text_style(
                    color: AppColour.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColour.white,
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: state is LocationListLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: AppColour.primary,
                          ),
                        )
                      : state is LocationListSuccess
                      ? state.addressList.isNotEmpty
                            ? ListView.builder(
                                itemCount: state.addressList.length,
                                itemBuilder: (context, index) {
                                  AddressModel model = state.addressList[index];
                                  return ListTile(
                                    onTap: (){
                                      address = model.address;
                                      latLng = LatLng(model.position.latitude, model.position.longitude);
                                      Navigator.pop(context, {
                                        'address': address,
                                        'latLng': latLng,
                                      });
                                    },
                                    title: Text('${model.title}',style: simple_text_style(fontSize: 20,fontWeight: FontWeight.bold),),
                                    subtitle: Text('${model.address}',style: simple_text_style(),),
                                  );
                                },
                              )
                            : Center(
                                child: Text(
                                  'No Location Added',
                                  style: simple_text_style(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                      : Center(
                          child: Text(
                            'Some issue',
                            style: simple_text_style(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  style: elevated_button_style(),
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    var currentPosition =
                        await LocationService.getCurrentPosition();
                    latLng = LatLng(
                      currentPosition!.latitude,
                      currentPosition.longitude,
                    );
                    address = await LocationService.getReadableAddress(
                      latLng!,
                    );
                    Navigator.pop(context, {
                      'address': address,
                      'latLng': latLng,
                    });
                  },
                  child: isLoading
                      ? CircularProgressIndicator(color: AppColour.white)
                      : Text(
                          'Continue with current location',
                          style: simple_text_style(
                            color: AppColour.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
