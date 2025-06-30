import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:story_genie/presentation/view/widgets/popup_widget.dart';
import 'package:story_genie/presentation/view/widgets/rounded_button_widget.dart';

void showNoInternetPopup({required BuildContext context}) {
  showPopup(
    context: context,
    height: 300.h,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.signal_wifi_off_rounded, size: 50),
        Text('No Internet', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 20),
        Text(
          'There seems to be some issue with your internet connection. Please check and try again',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        const Spacer(),
        RoundedButton(
          isLoading: false,
          title: 'Ok',
          width: 200.w,
          titleTextStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).primaryColor,
          ),
          onTap: () {
            context.pop();
          },
        ),
        const SizedBox(height: 20),
      ],
    ),
  );
}
