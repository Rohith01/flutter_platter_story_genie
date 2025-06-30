import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:story_genie/presentation/bloc/firebase_analytics_cubit.dart';
import 'package:story_genie/presentation/view/widgets/creative_credits_details_popup.dart';

class CreativeCreditsWidget extends StatelessWidget {
  const CreativeCreditsWidget({super.key, required this.credits});
  final String credits;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showCreditsPopup(context: context, credits: credits);
        BlocProvider.of<FirebaseAnalyticsCubit>(
          context,
        ).addEvent(eventName: 'click_creative_credit_details');
      },
      child: Hero(
        tag: 'credits',
        child: Container(
          height: 30.h,
          width: 60.w,
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
                offset: const Offset(0, -5),
                child: Text(
                  credits,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
