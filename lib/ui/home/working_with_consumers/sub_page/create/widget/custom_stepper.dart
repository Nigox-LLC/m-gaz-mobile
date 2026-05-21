import 'package:flutter/material.dart';
import 'package:m_gaz/core/extension/size_extension.dart';
import '../../../../../../core/common/words.dart';
import '../../../../../../core/utils/colors.dart';
import '../../../../../../core/utils/style.dart';
import '../create.dart';

class CustomStepper extends StatelessWidget {
  final int currentStep;
  final List<StepperItem> steps;
  final ValueChanged<int> onStepTapped;

  const CustomStepper({
    super.key,
    required this.currentStep,
    required this.steps,
    required this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      color: AppColors.cF5F5F5,
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = index == currentStep;
          final isCompleted = index < currentStep;
          final isInactive = index > currentStep;

          return Expanded(
            child: GestureDetector(
              onTap: () => onStepTapped(index),
              child: Column(
                children: [
                  _stepCircle(
                    icon: steps[index].icon,
                    isActive: isActive,
                    isCompleted: isCompleted,
                    isInactive: isInactive,
                  ),
                  8.getH(),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    style: AppTextStyles.style500.copyWith(
                      fontSize: 12.w,
                      color: isActive
                          ? AppColors.c1570EF
                          : isCompleted
                          ? AppColors.c1570EF
                          : AppColors.grey,
                    ),
                    child: Text(
                      steps[index].title.tr(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _stepCircle({
    required IconData icon,
    required bool isActive,
    required bool isCompleted,
    required bool isInactive,
  }) {
    final Color bgColor = isCompleted
        ? AppColors.c1570EF
        : isActive
        ? AppColors.white
        : AppColors.grey;

    final Color borderColor = isActive ? AppColors.c1570EF : Colors.transparent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 42.w : 36.w,
      height: isActive ? 42.w : 36.w,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.c1570EF.withValues(alpha: 0.25),
                  blurRadius: 10,
                ),
              ]
            : [],
      ),
      child: Center(
        child: Icon(
          icon,
          color: isActive ? AppColors.c1570EF : AppColors.white,
          size: 18.w,
        ),
      ),
    );
  }
}
