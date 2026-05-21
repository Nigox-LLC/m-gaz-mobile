import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_gaz/core/extension/size_extension.dart';
import 'package:m_gaz/ui/home/working_with_consumers/sub_page/create/widget/custom_stepper.dart';
import 'package:m_gaz/ui/home/working_with_consumers/sub_page/create/widget/step/step_certificate.dart';
import 'package:m_gaz/ui/home/working_with_consumers/sub_page/create/widget/step/step_company.dart';
import 'package:m_gaz/ui/home/working_with_consumers/sub_page/create/widget/step/step_egxu_list.dart';
import 'package:m_gaz/ui/home/working_with_consumers/sub_page/create/widget/step/step_main_info.dart';
import '../../../../../core/common/words.dart';
import '../../../../../core/utils/colors.dart';
import '../../../../../features/auth/domain/entities/user.dart';
import '../../../../../features/auth/presentation/bloc/login_bloc.dart';
import '../../../../../global_bloc/global_bloc.dart';
import '../../../../../global_bloc/global_event.dart';
import '../../../../../global_bloc/global_state.dart';
import '../../../../../global_widget/global_app_bar.dart';
import 'bloc/egxu_create_bloc.dart';
import 'bloc/egxu_create_event.dart';
import 'bloc/egxu_create_state.dart';

class EgxuCreateScreen extends StatelessWidget {
  const EgxuCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConsumerCreateBloc(),
      child: const _EgxuCreateView(),
    );
  }
}

class _EgxuCreateView extends StatefulWidget {
  const _EgxuCreateView();

  @override
  State<_EgxuCreateView> createState() => _EgxuCreateViewState();
}

class _EgxuCreateViewState extends State<_EgxuCreateView> {
  User? profile;

  final _steps = [
    StepperItem(title: Words.email.tr(), icon: Icons.location_on_outlined),
    StepperItem(title: Words.eghu.tr(), icon: Icons.list_alt),
    StepperItem(title: Words.company.tr(), icon: Icons.factory_outlined),
    StepperItem(title: Words.certificates.tr(), icon: Icons.file_present),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GlobalBloc>().add(EgxuFormInitialDataRequested());
      context.read<LoginBloc>().add(LoadUserProfile());
    });
  }

  void _error(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  final _step2Key = GlobalKey<StepEgxuListState>();
  final _step3Key = GlobalKey<StepCompanyState>();

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state.user != null && profile == null) {
              setState(() {
                profile = state.user!;
              });
              context.read<GlobalBloc>().add(
                    EgxuFormConsumersRequested(
                      regionId: profile!.regionId ?? 0,
                      districtId: profile!.districtId ?? 0,
                    ),
                  );
              if (profile!.regionId != null) {
                context
                    .read<GlobalBloc>()
                    .add(EgxuFormRegionSelected(profile!.regionId!));
              }
              if (profile!.districtId != null) {
                context
                    .read<GlobalBloc>()
                    .add(EgxuFormDistrictSelected(profile!.districtId!));
              }

              context.read<ConsumerCreateBloc>().add(ConsumerCreateStarted(profile!));
            }
          },
        ),
        BlocListener<ConsumerCreateBloc, ConsumerCreateState>(
          listenWhen: (previous, current) =>
              previous.errorMessage != current.errorMessage &&
              current.errorMessage != null,
          listener: (context, state) {
            if (state.errorMessage != null) {
              _error(context, state.errorMessage!);
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.cF5F5F5,
        appBar: CustomGlobalAppBar(title: Words.eghuEntry.tr()),
        body: profile == null
            ? const Center(child: CircularProgressIndicator())
            : BlocBuilder<GlobalBloc, GlobalState>(
                builder: (context, globalState) {
                  return BlocBuilder<ConsumerCreateBloc, ConsumerCreateState>(
                    builder: (context, state) {
                      return Column(
                        children: [
                          CustomStepper(
                            currentStep: state.currentStep,
                            steps: _steps,
                            onStepTapped: (i) {
                              if (i < state.currentStep) {
                                context
                                    .read<ConsumerCreateBloc>()
                                    .add(ConsumerCreatePreviousStep());
                              }
                            },
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.all(16.w),
                              child: _stepContent(state, globalState),
                            ),
                          ),
                          _navigationButtons(context, state),
                        ],
                      );
                    },
                  );
                },
              ),
      ),
    );
  }

  Widget _stepContent(ConsumerCreateState state, GlobalState globalState) {
    switch (state.currentStep) {
      case 0:
        return StepMainInfo(
          regionName: profile?.regionName ?? '',
          districtName: profile?.districtName ?? '',
          consumers: globalState.consumers,
        );
      case 1:
        return StepEgxuList(
          key: _step2Key,
          onDataSaved: (data) {
            context
                .read<ConsumerCreateBloc>()
                .add(ConsumerStep2DataSubmitted(data));
          },
        );
      case 2:
        return StepCompany(
          key: _step3Key,
          onDataSaved: (data) {
            context
                .read<ConsumerCreateBloc>()
                .add(ConsumerStep3DataSubmitted(data));
          },
        );
      case 3:
        return const StepCertificate(
          certificateNumber: "CERT-2025-001",
          issueDate: "12.01.2025",
          expiryDate: "12.01.2026",
          warningLetter: "№45-ogohlantirish",
          warningDate: "01.12.2025",
          warningReason: "Muddati tugashiga 30 kun qoldi",
        );
      default:
        return const SizedBox();
    }
  }

  Widget _navigationButtons(BuildContext context, ConsumerCreateState state) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (state.currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.c1570EF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  onPressed: () => context
                      .read<ConsumerCreateBloc>()
                      .add(ConsumerCreatePreviousStep()),
                  child: Text(Words.back.tr(),
                      style: const TextStyle(color: AppColors.c1570EF)),
                ),
              ),
            if (state.currentStep > 0) 12.getW(),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.c1570EF,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  elevation: 0,
                ),
                onPressed: () {
                  if (state.currentStep == 0) {
                      context.read<ConsumerCreateBloc>().add(ConsumerCreateNextStep());
                  } else if (state.currentStep == 1) {
                    if (_step2Key.currentState?.submit() ?? false) {
                       context.read<ConsumerCreateBloc>().add(ConsumerCreateNextStep());
                    }
                  } else if (state.currentStep == 2) {
                     if (_step3Key.currentState?.submit() ?? false) {
                       context.read<ConsumerCreateBloc>().add(ConsumerCreateNextStep());
                    }
                  } else if (state.currentStep == 3) {
                     context.read<ConsumerCreateBloc>().add(const ConsumerDataSubmitted());
                  }
                },
                child: Text(
                  state.currentStep < 3 ? Words.next.tr() : Words.finish.tr(),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StepperItem {
  final String title;
  final IconData icon;

  StepperItem({required this.title, required this.icon});
}

