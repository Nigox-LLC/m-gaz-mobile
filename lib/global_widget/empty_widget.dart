import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/common/words.dart';
import 'app_tools.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Column(
        children: [
          SvgPicture.asset(
            AppTools.emptySaved,
            width: MediaQuery.of(context).size.width / 3,
            height: MediaQuery.of(context).size.height / 3,
          ),
          Text(
            Words.noInformationFound.tr(),
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
