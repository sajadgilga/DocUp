import 'package:Neuronio/blocs/EntityBloc.dart';
import 'package:Neuronio/blocs/TextPlanBloc.dart';
import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/constants/strings.dart';
import 'package:Neuronio/models/DoctorEntity.dart';
import 'package:Neuronio/networking/CustomException.dart';
import 'package:Neuronio/networking/Response.dart';
import 'package:Neuronio/ui/widgets/ActionButton.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/ui/widgets/DoctorSummaryWidget.dart';
import 'package:Neuronio/ui/widgets/DocupHeader.dart';
import 'package:Neuronio/ui/widgets/PageTopLeftIcon.dart';
import 'package:Neuronio/ui/widgets/VerticalSpace.dart';
import 'package:Neuronio/utils/CrossPlatformDeviceDetection.dart';
import 'package:Neuronio/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TextPlanPage extends StatefulWidget {
  final DoctorEntity doctorEntity;
  final Function(String, dynamic) onPush;

  TextPlanPage({Key key, this.doctorEntity, this.onPush}) : super(key: key);

  @override
  _TextPlanPagePageState createState() => _TextPlanPagePageState();
}

class _TextPlanPagePageState extends State<TextPlanPage>
    with TickerProviderStateMixin {
  TextPlanBloc textPlanBloc;
  ClinicTrafficTextPlan selectedPlan;

  @override
  void dispose() {
    textPlanBloc.reNewStreams();
    super.dispose();
  }

  @override
  void initState() {
    textPlanBloc = BlocProvider.of<TextPlanBloc>(context);
    textPlanBloc.buyTextPlanStream.listen((data) {
      if (data.status == Status.COMPLETED) {
        EntityBloc entityBloc = BlocProvider.of<EntityBloc>(context);

        /// update user credit
        entityBloc.add(EntityUpdate());

        /// update remained traffic
        var panel = entityBloc.state.entity.mEntity
            .getPanelByDoctorId(widget.doctorEntity.id);
        textPlanBloc
            .add(GetPatientTextPlanEvent(partnerId: widget.doctorEntity.id));

        /// pop to prev page
        showOneButtonDialog(context, InAppStrings.planSuccessfullyActivated,
            InAppStrings.okAction, () => Navigator.pop(context));
      } else if (data.status == Status.ERROR) {
        if (data.error is ApiException) {
          ApiException apiException = data.error;
          if (apiException.getCode() == 602) {
            toast(context, InAppStrings.noCreditErrorCode_602);
          } else if (apiException.getCode() == 603) {
            toast(context, InAppStrings.oldPlanExistedErrorCode_603);
          } else {
            toast(context, data.error.toString());
          }
        } else {
          toast(context, data.error.toString());
        }
      }
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            PageTopLeftIcon(
              topLeft: Icon(
                Icons.arrow_back,
                size: 25,
              ),
              onTap: () {
                Navigator.pop(context);
              },
              topRightFlag: true,
              topRight: NeuronioHeader(
                title: "مشاوره متنی",
                docUpLogo: false,
              ),
              topLeftFlag: CrossPlatformDeviceDetection.isIOS,
            ),
            DoctorSummaryWidget(doctorEntity: widget.doctorEntity),
            ALittleVerticalSpace(),
            description(),
            ALittleVerticalSpace(),
            _doctorClinicTextPlans(),
          ]),
    );
  }

  // Widget planItem(ClinicTrafficTextPlan plan) {
  //   return GestureDetector(
  //     onTap: () {
  //       showOneButtonDialog(
  //           context,
  //           Strings.sureToBuyTextPlan[0] +
  //               plan.title +
  //               Strings.sureToBuyTextPlan[2],
  //           Strings.buyPlanActionTitle, () {
  //         /// trying to buy a text plan
  //         textPlanBloc.textPlanActivation(widget.doctorEntity.id, plan.id);
  //       });
  //     },
  //     child: Container(
  //       decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.all(Radius.circular(15)),
  //           boxShadow: [
  //             BoxShadow(color: Colors.grey, blurRadius: 10, spreadRadius: -1)
  //           ]),
  //       padding: EdgeInsets.all(10),
  //       margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
  //       child: Row(
  //         mainAxisSize: MainAxisSize.max,
  //         mainAxisAlignment: MainAxisAlignment.end,
  //         children: [
  //           Column(
  //             mainAxisSize: MainAxisSize.min,
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             crossAxisAlignment: CrossAxisAlignment.end,
  //             children: [
  //               AutoText(
  //                 plan.title,
  //                 fontWeight: FontWeight.bold,
  //                 fontSize: 16,
  //               ),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.end,
  //                 mainAxisSize: MainAxisSize.max,
  //                 children: [
  //                   Container(
  //                     height: 10,
  //                     color: Colors.red,
  //                   ),
  //                 ],
  //               ),
  //               // Container(
  //               //   margin: EdgeInsets.symmetric(vertical: 2),
  //               //   decoration: BoxDecoration(
  //               //       color: IColors.themeColor,
  //               //       borderRadius: BorderRadius.all(Radius.circular(15))),
  //               //   padding: EdgeInsets.symmetric(horizontal: 10),
  //               //   child: AutoText(
  //               //     plan.wordNumber.toString() + " کلمه برای استفاده از چت روم",
  //               //     fontSize: 13,
  //               //     color: Colors.white,
  //               //   ),
  //               // ),
  //               // Container(
  //               //   margin: EdgeInsets.symmetric(vertical: 2),
  //               //   decoration: BoxDecoration(
  //               //       color: IColors.themeColor,
  //               //       borderRadius: BorderRadius.all(Radius.circular(15))),
  //               //   padding: EdgeInsets.symmetric(horizontal: 10),
  //               //   child: AutoText(
  //               //     plan.medicalTestCount.toString() + " تست برای ارسال",
  //               //     fontSize: 13,
  //               //     color: Colors.white,
  //               //   ),
  //               // ),
  //               // Container(
  //               //   margin: EdgeInsets.symmetric(vertical: 2),
  //               //   decoration: BoxDecoration(
  //               //       color: IColors.themeColor,
  //               //       borderRadius: BorderRadius.all(Radius.circular(15))),
  //               //   padding: EdgeInsets.symmetric(horizontal: 10),
  //               //   child: AutoText(
  //               //     plan.fileVolume.toString() + " مگابایت برای ارسال فایل",
  //               //     fontSize: 13,
  //               //     color: Colors.white,
  //               //   ),
  //               // ),
  //               Container(
  //                 margin: EdgeInsets.symmetric(vertical: 2),
  //                 decoration: BoxDecoration(
  //                     color: IColors.themeColor,
  //                     borderRadius: BorderRadius.all(Radius.circular(15))),
  //                 padding: EdgeInsets.symmetric(horizontal: 10),
  //                 child: AutoText(
  //                   plan.price.toString() + " تومان",
  //                   fontSize: 13,
  //                   color: Colors.white,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  /// REMOVED: CHANGING CUSTOMER JOURNEY
  Widget priceWidget(ClinicTrafficTextPlan textPlan) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        AutoText("تومان", style: TextStyle(fontSize: 16)),
        SizedBox(width: 5),
        AutoText(replaceFarsiNumber(priceWithCommaSeparator(textPlan.price)),
            style: TextStyle(
                color: IColors.themeColor,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        SizedBox(width: 5),
        AutoText("قیمت نهایی", style: TextStyle(fontSize: 16))
      ],
    );
  }

  Widget description() {
    return Container(
      margin: EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AutoText(
                InAppStrings.textPlanDescription,
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _doctorClinicTextPlans() {
    Widget noPlanDefinedForDoctorClinic() {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: AutoText(InAppStrings.noPlanDefinedForDoctorClinic),
      );
    }

    return Container(
      child: Column(
        children: [
          (widget.doctorEntity?.clinic?.pClinic ?? []).length == 0
              ? noPlanDefinedForDoctorClinic()
              : Column(
                  children: [
                    priceWidget(widget.doctorEntity?.clinic?.pClinic[0]),
                    ALittleVerticalSpace(height: 40),
                    ActionButton(
                      title: "خرید مشاوره متنی",
                      color: IColors.themeColor,
                      callBack: () {
                        /// trying to buy a text plan
                        textPlanBloc.textPlanActivation(widget.doctorEntity.id,
                            widget.doctorEntity?.clinic?.pClinic[0].id);
                      },
                    ),
                    ALittleVerticalSpace()
                  ],
                )
        ],
      ),
    );
  }
}
