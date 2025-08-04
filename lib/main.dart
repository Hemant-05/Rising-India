import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/admin/add_new_items/bloc/Image_cubit/image_cubit.dart';
import 'package:raising_india/features/admin/add_new_items/bloc/product_bloc/product_bloc.dart';
import 'package:raising_india/features/admin/all_product_list/bloc/products_cubit.dart';
import 'package:raising_india/features/admin/home/bloc/order_cubit/order_stats_cubit.dart';
import 'package:raising_india/features/admin/services/order_repository.dart';
import 'package:raising_india/features/user/home/bloc/user_product_bloc/user_product_bloc.dart';
import 'package:raising_india/features/user/order/bloc/order_bloc.dart';
import 'package:raising_india/features/user/product_details/bloc/product_funtction_bloc/product_fun_bloc.dart';
import 'package:raising_india/features/user/profile/bloc/profile_bloc.dart';
import 'package:raising_india/features/user/search/bloc/product_search_bloc/product_search_bloc.dart';
import 'package:raising_india/features/user/services/user_product_services.dart';
import 'package:raising_india/screens/splash_screen.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/services/auth_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<OrderRepository>(create: (_) => OrderRepository(firestore: FirebaseFirestore.instance)),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<UserBloc>(create: (_) => UserBloc(AuthService())..add(AppStarted()),),
          BlocProvider<ProductBloc>(create: (_) => ProductBloc()),
          BlocProvider<ImageSelectionCubit>(create: (_) => ImageSelectionCubit()),
          BlocProvider<ProductSearchBloc>(create: (context) => ProductSearchBloc(firestore: FirebaseFirestore.instance),),
          BlocProvider<UserProductBloc>(create: (context) =>UserProductBloc(services: UserProductServices())..add(FetchBestSellingProducts())),
          BlocProvider<ProductFunBloc>(create: (context) => ProductFunBloc()),
          BlocProvider<OrderBloc>(create: (context) => OrderBloc()),
          BlocProvider<ProfileBloc>(create: (context) => ProfileBloc(),),
          BlocProvider<OrderStatsCubit>(create: (context)=>OrderStatsCubit(FirebaseFirestore.instance),),
          BlocProvider<ProductsCubit>(create: (context) => ProductsCubit(FirebaseFirestore.instance)..fetchProducts()),
        ],
        child: MaterialApp(
          title: 'Raising India',
          debugShowCheckedModeBanner: false,
          theme : ThemeData(
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: AppColour.primary, // Cursor color
              selectionColor: AppColour.primary.withOpacity(0.5), // Highlight background
              selectionHandleColor: AppColour.primary, // This changes the handle color
            ),
          ),
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
