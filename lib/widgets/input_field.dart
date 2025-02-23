import 'package:flutter/material.dart';
import 'package:chatbox/constants/app_colors.dart';
import 'package:chatbox/constants/app_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ollama_dart/ollama_dart.dart';

class InputField extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSendMessage;
  final List<Model> models;
  final Model? selectedModel;
  final ValueChanged<Model?> onModelChange;

  const InputField({
    Key? key,
    required this.controller,
    required this.onSendMessage,
    required this.models,
    required this.selectedModel,
    required this.onModelChange,
  }) : super(key: key);

  @override
  _InputFieldState createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.buttonColor.withOpacity(0.1),
            spreadRadius: 0.1,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 200, vertical: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            cursorColor: AppColors.black,
            controller: widget.controller,
            style: AppFonts.primaryFont(color: Colors.black),
            decoration: InputDecoration(
              hintText: 'What are you thinking...',
              hintStyle: AppFonts.primaryFont(color: Colors.grey[500]!),
              filled: true,
              fillColor: AppColors.white,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(20),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onSubmitted: (_) => widget.onSendMessage(),
          ),
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedRobotic,
                    color: AppColors.black,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.transparent),
                    ),
                    child: DropdownButton<Model>(
                      value: widget.selectedModel,
                      underline: SizedBox(),
                      items:
                          widget.models.map((Model model) {
                            return DropdownMenuItem<Model>(
                              value: model,
                              child: Text(
                                model.model.toString(),
                                style: AppFonts.primaryFont(
                                  color: AppColors.black,
                                ),
                              ),
                            );
                          }).toList(),
                      onChanged: widget.onModelChange,
                      dropdownColor: AppColors.white,
                      style: AppFonts.primaryFont(color: Colors.black),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedSent,
                  color:
                      widget.controller.text.isEmpty
                          ? AppColors.grey
                          : AppColors.buttonColor,
                ),
                onPressed: widget.onSendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
