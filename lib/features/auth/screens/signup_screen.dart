import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/admin/pagination/main_screen_a.dart';
import '../../../comman/bold_text_style.dart';
import '../../../constant/ConString.dart';
import '../../admin/home/screens/home_screen_a.dart';
import '../../user/home/screens/home_screen_u.dart';
import '../widgets/cus_text_field.dart';
import '../../../constant/ConPath.dart';
import '../../../models/user_model.dart';
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
  String _role = user;
  String? _error;

  @override
  void initState() {
    super.initState();
    setStatusBarColor();
  }

  void setStatusBarColor() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
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
            MaterialPageRoute(
              builder: (_) => state.user.role == admin
                  ? const MainScreenA()
                  : const HomeScreenU(),
            ),
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
                            margin: const EdgeInsets.only(top: 20, left: 20),
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
                          Text(
                            'Sign Up',
                            style: bold_text_style(AppColour.white),
                          ),
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
                const SizedBox(height: 10),
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
                    padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 22),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          cus_text_field(
                           label: 'NAME',
                            controller : _nameController,
                            hintText : 'Hemant sahu',
                          ),
                          const SizedBox(height: 10),
                          cus_text_field(
                            label: 'EMAIL',
                            controller: _emailController,
                            hintText: 'example@gmail.com',
                          ),
                          const SizedBox(height: 10),
                          cus_text_field(
                            label: 'MOBILE NUMBER',
                            controller: _numberController,
                            hintText: '1234567890',
                            isNumber: true,
                          ),
                          const SizedBox(height: 10),
                          cus_text_field(
                            label: 'PASSWORD',
                            controller: _passwordController,
                            hintText: '********',
                            obscureText: true,
                          ),
                          const SizedBox(height: 10),
                          cus_text_field(
                            label: 'CONFIRM PASSWORD',
                            controller: _confirmPasswordController,
                            hintText: '********',
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
                              return ElevatedButton(
                                style: elevated_button_style(),
                                onPressed: () {
                                  var email = _emailController.text.trim();
                                  if (email.split('#').first.toLowerCase() ==
                                      'admin') {
                                    _role = admin;
                                  } else {
                                    _role = user;
                                  }
                                  BlocProvider.of<UserBloc>(context).add(
                                    UserSignUp(
                                      name: _nameController.text,
                                      email: email.split('#').last,
                                      number: _numberController.text,
                                      password: _passwordController.text,
                                      confirmPassword:
                                          _confirmPasswordController.text,
                                      role: _role,
                                    ),
                                  );
                                },
                                child: state is UserLoading
                                    ? Center(
                                        child: CircularProgressIndicator(
                                          color: AppColour.white,
                                        ),
                                      )
                                    : Text(
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
