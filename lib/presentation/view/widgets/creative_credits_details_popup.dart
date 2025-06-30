import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:story_genie/presentation/view/widgets/popup_widget.dart';

void showCreditsPopup({
  required BuildContext context,
  required String credits,
}) {
  showPopup(
    context: context,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            height: 50.h,
            width: 90.w,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Theme.of(context).colorScheme.secondary,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Image.asset('assets/image/credit.png'),
                Transform.translate(
                  offset: Offset(0, 5.h),
                  child: Text(
                    credits,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            'Creative Credits',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Use credits to generate stories. 1 credit = 1 story',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          '*30 credits are added on 1st of every month and they expire on last day of the month',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 10),

        Text(
          'Coming Soon',
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(fontSize: 16.sp),
        ),
        Text(
          ' - Unlock Premium Featured Images using Creative Credits',
          style: Theme.of(context).textTheme.bodyLarge,
        ),

        Text(
          ' - Remix an old story with new twists',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          ' - Narrate the Story (Audio)',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    ),
  );
}
