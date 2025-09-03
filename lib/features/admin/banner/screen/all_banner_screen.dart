import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/admin/banner/bloc/banner_bloc.dart';
import 'package:raising_india/features/admin/banner/screen/add_banner_screen.dart';

class AllBannerScreen extends StatelessWidget {
  const AllBannerScreen({super.key});

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
            Text('All Banners', style: simple_text_style(fontSize: 18)),
            const Spacer(),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddBannerScreen()),
                );
              },
              child: Text(
                'Add',
                style: simple_text_style(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColour.primary,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColour.white,
      ),
      body: BlocBuilder<BannerBloc, BannerState>(
        builder: (context, state) {
          if (state is BannerLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColour.primary),
            );
          } else if (state is BannerLoaded) {
            return state.list.isNotEmpty
                ? ListView.builder(
                    itemCount: state.list.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.all(8),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColour.grey,width: 1),
                        ),

                        child: Column(
                          children: [
                            Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColour.black,width: 1)
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(color: AppColour.primary,),
                                    );
                                  },
                                  filterQuality: FilterQuality.medium,
                                  state.list[index]['image'],
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                              width: double.infinity,
                              child: InkWell(
                                onTap: () {
                                  context.read<BannerBloc>().add(
                                    DeleteBannerEvent(state.list[index]['id']),
                                  );
                                },
                                child: Icon(
                                  Icons.delete_forever_outlined,
                                  color: AppColour.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : Center(child: Text('No Banner Added yet!!',style: simple_text_style(),));
          } else if(state is BannerDeleted){
            BlocProvider.of<BannerBloc>(
              context,
            ).add(LoadAllBannerEvent());
          }else if (state is ErrorBanner) {
            return Center(child: Text(state.error,style: simple_text_style(color: AppColour.red),));
          }
          return Center(child: Text('Loading.....',style: simple_text_style(),));
        },
      ),
    );
  }
}
