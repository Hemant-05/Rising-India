import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import '../../../comman/bold_text_style.dart';
import '../../../comman/cus_text_field.dart';
import '../../../constant/ConPath.dart';
import '../../../models/user_model.dart';
import '../../../screens/home_screen.dart';
import '../bloc/auth_bloc.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _numberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  UserRole _role = UserRole.USER;
  String? _error;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setStatusBarColor();
  }
  void setStatusBarColor() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        // For light status bar icons (dark background)
        statusBarIconBrightness: Brightness.light,

        // For dark status bar icons (light background)
        // statusBarIconBrightness: Brightness.dark,

        // Optional: Change status bar color (Android only)
        statusBarColor: Colors.transparent, // or any color
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserAuthenticated) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        } else if (state is UserError) {
          setState(() => _error = state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColour.background,
        body: Stack(
          children: [
            Align(
              alignment: Alignment(-2.5, -1.4),
              child: SvgPicture.asset(
                back_vector_svg,
                color: AppColour.lightGrey.withOpacity(0.2),
                height: 250,
                width: 250,
              ),
            ),
            Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                           Container(
                              height: 40,
                              width: 40,
                             margin: const EdgeInsets.only(top : 20,left: 20),
                              decoration: BoxDecoration(
                                color: AppColour.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Icon(
                                  size: 16,
                                  Icons.arrow_back_ios_rounded,
                                  color: AppColour.black,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Column(
                        children: [
                          Text('Sign Up', style: bold_text_style(AppColour.white)),
                          const SizedBox(height: 10),
                          Text(
                            'Please sign up to get started',
                            style: simple_text_style(color: AppColour.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColour.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(22),
                        topRight: Radius.circular(22),
                      ),
                    ),
                    padding: const EdgeInsets.all(22),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          cus_text_field(
                            'NAME',
                            _nameController,
                            'Hemant sahu',
                          ),
                          const SizedBox(height: 10),
                          cus_text_field(
                            'EMAIL',
                            _emailController,
                            'example@gmail.com',
                          ),
                          const SizedBox(height: 10),
                          cus_text_field(
                            'NUMBER',
                            _numberController,
                            '1234567890',
                            isNumber: true,
                          ),
                          const SizedBox(height: 10),
                          cus_text_field(
                            'PASSWORD',
                            _passwordController,
                            '********',
                            obscureText: true,
                          ),
                          const SizedBox(height: 10),
                          cus_text_field(
                            'CONFIRM PASSWORD',
                            _confirmPasswordController,
                            '********',
                            obscureText: true,
                          ),
                          const SizedBox(height: 20),
                          if (_error != null)
                            Text(
                              _error!,
                              style: TextStyle(color: AppColour.red),
                            ),
                          if (_error != null) const SizedBox(height: 20),
                          BlocBuilder<UserBloc, UserState>(
                            builder: (context, state) {
                              if (state is UserLoading) {
                                return SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: const CircularProgressIndicator(),
                                );
                              }
                              return ElevatedButton(
                                style: elevated_button_style(),
                                onPressed: () {
                                  var email = _emailController.text;
                                  if (email.split('#').first.toLowerCase() ==
                                      'admin')
                                    _role = UserRole.ADMIN;
                                  else
                                    _role = UserRole.USER;
                                  BlocProvider.of<UserBloc>(context).add(
                                    UserSignUp(
                                      name: _nameController.text,
                                      email: _emailController.text,
                                      number: _numberController.text,
                                      password: _passwordController.text,
                                      confirmPassword: _confirmPasswordController.text,
                                      role: _role,
                                    ),
                                  );
                                },
                                child: Text(
                                  'Sign Up',
                                  style: simple_text_style(
                                    color: AppColour.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
