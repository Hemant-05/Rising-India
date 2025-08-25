import 'package:flutter/material.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';

class cus_text_field extends StatefulWidget {
  cus_text_field({super.key, required this.label, required this.controller, required this.hintText, this.obscureText = false, this.isNumber = false});
  final String label;
  final TextEditingController controller;
  final String hintText;
  bool obscureText;
  bool isNumber;

  @override
  State<cus_text_field> createState() => _cus_text_fieldState();
}

class _cus_text_fieldState extends State<cus_text_field> {
  bool isShow = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.label,
            style: simple_text_style(color: AppColour.grey, fontSize: 12),
          ),
        ),
        const SizedBox(height: 10,),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColour.grey.withOpacity(0.1),
          ),
          child: TextField(
            keyboardType: widget.isNumber? TextInputType.number: TextInputType.text,
            controller: widget.controller,
            obscureText: !isShow && widget.obscureText,
            obscuringCharacter: '*',
            decoration: InputDecoration(
              suffixIcon: widget.obscureText? InkWell(
                  onTap: (){
                    setState(() {
                      isShow = !isShow;
                    });
                  },
                  child: Icon(isShow? Icons.remove_red_eye_outlined : Icons.remove_red_eye,color: AppColour.lightGrey,)) : null,
              hintStyle: simple_text_style(color: AppColour.lightGrey),
              hintText: widget.hintText,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
