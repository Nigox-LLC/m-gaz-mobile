// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:m_gaz/global_widget/global_app_bar.dart';
// import 'package:m_gaz/core/models/global/global_model.dart';
// import 'package:m_gaz/core/models/egxu/create/egxu_request.dart';
// import '../../../../../global_bloc/global_bloc.dart';
// import '../../../../../global_bloc/global_event.dart';
// import '../../../../../global_bloc/global_state.dart';
// import 'package:m_gaz/global_widget/global_dropdown.dart';
// import '../../../../../core/common/words.dart';
//
//
// const _kPrimary = Color(0xFF3B82F6);
// const _kSuccess = Color(0xFF10B981);
// const _kSurface = Color(0xFFF8FAFC);
//
// class CreateEgxuScreen extends StatefulWidget {
//   const CreateEgxuScreen({super.key});
//
//   @override
//   State<CreateEgxuScreen> createState() => _CreateEgxuScreenState();
// }
//
// class _CreateEgxuScreenState extends State<CreateEgxuScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final ScrollController _scrollController = ScrollController();
//
//   // top-level form fields
//   int? _regionId;
//   int? _districtId;
//   int? _activityId;
//   int? _employeeId;
//   int? _consumerId;
//   String? _removalType;
//   String? _gasUsageType;
//   String? _usageType;
//   bool _isActive = true;
//
//   final List<EquipmentFormController> _equipmentControllers = [];
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<GlobalBloc>().add(EgxuFormInitialDataRequested());
//     });
//   }
//
//   @override
//   void dispose() {
//     for (final c in _equipmentControllers) c.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   void _addEquipment() {
//     setState(() => _equipmentControllers.add(EquipmentFormController()));
//     // scroll to bottom after a frame
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent + 200,
//         duration: const Duration(milliseconds: 350),
//         curve: Curves.easeOutCubic,
//       );
//     });
//   }
//
//   void _removeEquipment(int index) {
//     setState(() {
//       _equipmentControllers[index].dispose();
//       _equipmentControllers.removeAt(index);
//     });
//   }
//
//   void _onRegionChanged(int? v) {
//     setState(() {
//       _regionId = v;
//       _districtId = null;
//       _employeeId = null;
//       _consumerId = null;
//     });
//     if (v != null) context.read<GlobalBloc>().add(EgxuFormRegionSelected(v));
//   }
//
//   void _onDistrictChanged(int? v) {
//     setState(() {
//       _districtId = v;
//       _employeeId = null;
//       _consumerId = null;
//     });
//     if (v != null) context.read<GlobalBloc>().add(EgxuFormDistrictSelected(v));
//   }
//
//   // String? _validateRequired(String? v) =>
//   //     (v == null || v.trim().isEmpty) ? "Maydon to'ldirilishi shart" : null;
//
//   // String? _validateNumber(String? v) {
//   //   final e = _validateRequired(v);
//   //   if (e != null) return e;
//   //   return double.tryParse(v!.replaceAll(',', '').trim()) == null
//   //       ? 'Son kiriting'
//   //       : null;
//   // }
//   //
//   // String? _validatePositiveInt(String? v) {
//   //   final e = _validateRequired(v);
//   //   if (e != null) return e;
//   //   final n = int.tryParse(v!.trim());
//   //   return (n == null || n <= 0) ? 'Musbat son kiriting' : null;
//   // }
//
//   void _showSnack(String text, {Color? bg}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.info, color: Colors.white),
//             const SizedBox(width: 12),
//             Expanded(child: Text(text)),
//           ],
//         ),
//         backgroundColor: bg ?? Colors.blueGrey.shade700,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }
//
//   void _submitForm() {
//     if (!_formKey.currentState!.validate()) {
//       _showSnack(
//         Words.fixFormErrors.tr(),
//         bg: Colors.red.shade600,
//       );
//       return;
//     }
//     if (_equipmentControllers.isEmpty) {
//       _showSnack(Words.addAtLeastOneDevice.tr(), bg: Colors.red.shade600);
//       return;
//     }
//
//     try {
//       final equipmentList = _equipmentControllers
//           .map(
//             (c) => GasEquipmentItem(
//               gasEquipment: int.parse(c.gasEquipmentController.text.trim()),
//               egxu: int.parse(c.egxuController.text.trim()),
//               quantity: int.parse(c.quantityController.text.trim()),
//               stampNumber: c.stampController.text.trim(),
//               hourlyGasConsumption: c.hourlyController.text.trim(),
//               dailyGasConsumption: c.dailyController.text.trim(),
//               replacementReason: c.reasonController.text.trim(),
//               workCompletedDate: c.dateController.text.trim(),
//               photos: c.photos.map((p) => PhotoItem(file: p)).toList(),
//               uses: c.uses,
//             ),
//           )
//           .toList();
//
//       final req = EgxuRequest(
//         datetime: DateTime.now().toIso8601String(),
//         region: _regionId!,
//         district: _districtId!,
//         typeOfActivity: _activityId!,
//         removal: _removalType!,
//         gasUsage: _gasUsageType!,
//         usageType: _usageType!,
//         employee: _employeeId ?? 0,
//         consumers: _consumerId!,
//         isActive: _isActive,
//         gasEquipmentList: equipmentList,
//       );
//
//       _showPreview(req);
//     } catch (e) {
//       _showSnack(
//         Words.invalidDataFormat.tr(),
//         bg: Colors.red.shade600,
//       );
//     }
//   }
//
//   void _showPreview(EgxuRequest req) {
//     showDialog(
//       context: context,
//       builder: (_) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//         child: SizedBox(
//           width: double.infinity,
//           height: MediaQuery.of(context).size.height * 0.75,
//           child: Padding(
//             padding: const EdgeInsets.all(18.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     const Icon(Icons.check_circle, color: _kSuccess),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: Text(
//                         Words.requestInfo.tr(),
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: () => Navigator.of(context).pop(),
//                       icon: const Icon(Icons.close),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 Expanded(
//                   child: Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade100,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: SingleChildScrollView(
//                       child: SelectableText(
//                         const JsonEncoder.withIndent(
//                           '  ',
//                         ).convert(req.toJson()),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     TextButton(
//                       onPressed: () => Navigator.of(context).pop(),
//                       child: Text(Words.close.tr()),
//                     ),
//                     const SizedBox(width: 8),
//                     ElevatedButton(
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                         _showSnack(
//                           Words.successCreated.tr(),
//                           bg: Colors.green.shade600,
//                         );
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: _kSuccess,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: Text(Words.save.tr()),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _kSurface,
//       appBar: CustomGlobalAppBar(title: Words.createEgxu.tr()),
//       body: BlocConsumer<GlobalBloc, GlobalState>(
//         listener: (ctx, state) {
//           if (state.status == GlobalStatus.fail && state.errorMessage != null) {
//             _showSnack(state.errorMessage!, bg: Colors.red.shade600);
//           }
//         },
//         builder: (ctx, state) {
//           if (state.status == GlobalStatus.loading &&
//               _equipmentControllers.isEmpty) {
//             return const Center(
//               child: CircularProgressIndicator(
//                 strokeWidth: 3,
//                 color: _kPrimary,
//               ),
//             );
//           }
//
//           return Form(
//             key: _formKey,
//             child: Scrollbar(
//               controller: _scrollController,
//               thumbVisibility: true,
//               child: SingleChildScrollView(
//                 controller: _scrollController,
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     ModernSection(
//                       title: "📍 ${Words.locationInfo.tr()}",
//                       child: Column(
//                         children: [
//                           GenericSelectableField<GlobalModel>(
//                             title: Words.region.tr(),
//                             items: state.regions,
//                             selectedItem: state.regions
//                                 .where((e) => e.id == _regionId)
//                                 .cast<GlobalModel?>()
//                                 .firstOrNull,
//                             hintText: Words.selectProvince.tr(),
//                             getTitle: (m) => m.name ?? "",
//                             isEqual: (a, b) => a.id == b.id,
//
//                             onChanged: (m) => _onRegionChanged(m.id),
//                           ),
//
//                           const SizedBox(height: 12),
//
//                           GenericSelectableField<GlobalModel>(
//                             title: Words.district.tr(),
//                             items: state.districts,
//                             selectedItem: state.districts
//                                 .where((e) => e.id == _districtId)
//                                 .cast<GlobalModel?>()
//                                 .firstOrNull,
//                             hintText: Words.selectDistrict.tr(),
//                             getTitle: (m) => m.name ?? "",
//                             isEqual: (a, b) => a.id == b.id,
//
//                             onChanged: (m) => _onDistrictChanged(m.id),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     ModernSection(
//                       title: "⚡ ${Words.activityType.tr()}",
//                       child: Column(
//                         children: [
//                           GenericSelectableField<GlobalModel>(
//                             title: Words.activityType.tr(),
//                             items: state.activityTypes,
//                             selectedItem: state.activityTypes
//                                 .where((e) => e.id == _activityId)
//                                 .cast<GlobalModel?>()
//                                 .firstOrNull,
//                             hintText: Words.selectActivity.tr(),
//                             getTitle: (m) => m.name ?? "",
//                             isEqual: (a, b) => a.id == b.id,
//
//                             onChanged: (m) =>
//                                 setState(() => _activityId = m.id),
//                           ),
//
//                           const SizedBox(height: 12),
//
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     ModernSection(
//                       title: "👥 ${Words.employeeAndConsumer.tr()}",
//                       child: Column(
//                         children: [
//                           GenericSelectableField<GlobalModel>(
//                             title: Words.consumer.tr(),
//                             items: state.consumers,
//                             selectedItem: state.consumers
//                                 .where((e) => e.id == _consumerId)
//                                 .cast<GlobalModel?>()
//                                 .firstOrNull,
//                             hintText: Words.selectConsumer.tr(),
//                             getTitle: (m) => (m.name?.isNotEmpty ?? false)
//                                 ? m.name!
//                                 : (m.name ?? Words.unknown.tr()),
//                             isEqual: (a, b) => a.id == b.id,
//
//                             onChanged: (m) =>
//                                 setState(() => _consumerId = m.id),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//
//                     // equipment list
//                     ModernSection(
//                       title: "🔧 ${Words.gasDevices.tr()}",
//                       trailing: ElevatedButton.icon(
//                         onPressed: _addEquipment,
//                         icon: const Icon(Icons.add, size: 18),
//                         label: Text(Words.add.tr()),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: _kPrimary,
//                           elevation: 0,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                       child: Column(
//                         children: [
//                           if (_equipmentControllers.isEmpty)
//                             _buildEmptyEquipmentState(),
//                           ...List.generate(
//                             _equipmentControllers.length,
//                             (i) => Padding(
//                               padding: const EdgeInsets.only(bottom: 12),
//                               child: EquipmentCard(
//                                 controller: _equipmentControllers[i],
//                                 index: i,
//                                 onRemove: () => _removeEquipment(i),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(height: 20),
//                     // submit
//                     ElevatedButton(
//                       onPressed: _submitForm,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: _kSuccess,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14),
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Icon(Icons.save),
//                           const SizedBox(width: 8),
//                           Text(
//                             Words.saveEgxu.tr(),
//                             style: const TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildEmptyEquipmentState() => Padding(
//     padding: const EdgeInsets.symmetric(vertical: 16),
//     child: Center(
//       child: Column(
//         children: [
//           Icon(
//             Icons.inventory_2_outlined,
//             size: 48,
//             color: Colors.grey.shade400,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             Words.noDevicesAdded.tr(),
//             style: TextStyle(color: Colors.grey.shade600),
//           ),
//         ],
//       ),
//     ),
//   );
// }
//
// // Small reusable section card
// class ModernSection extends StatelessWidget {
//   final String title;
//   final Widget child;
//   final Widget? trailing;
//
//   const ModernSection({
//     super.key,
//     required this.title,
//     required this.child,
//     this.trailing,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 6),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   title,
//                   style: const TextStyle(fontWeight: FontWeight.w700),
//                 ),
//               ),
//               if (trailing != null) trailing!,
//             ],
//           ),
//           const SizedBox(height: 12),
//           child,
//         ],
//       ),
//     );
//   }
// }
//
// // Equipment card widget
// class EquipmentCard extends StatefulWidget {
//   final EquipmentFormController controller;
//   final int index;
//   final VoidCallback onRemove;
//
//   const EquipmentCard({
//     super.key,
//     required this.controller,
//     required this.index,
//     required this.onRemove,
//   });
//
//   @override
//   State<EquipmentCard> createState() => _EquipmentCardState();
// }
//
// class _EquipmentCardState extends State<EquipmentCard>
//     with SingleTickerProviderStateMixin {
//   Future<void> _selectDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(DateTime.now().year + 5),
//     );
//     if (picked != null) {
//       widget.controller.dateController.text = picked
//           .toIso8601String()
//           .split('T')
//           .first;
//     }
//     setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final c = widget.controller;
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(color: Colors.grey.shade200),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 CircleAvatar(
//                   radius: 18,
//                   backgroundColor: Colors.blue.shade50,
//                   child: Icon(Icons.settings, color: Colors.blue.shade700),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     '${Words.device.tr()} #${widget.index + 1}',
//                     style: const TextStyle(fontWeight: FontWeight.w600),
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: widget.onRemove,
//                   icon: const Icon(
//                     Icons.delete_outline,
//                     color: Colors.redAccent,
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 8),
//             _buildTextField(
//               controller: c.gasEquipmentController,
//               label: '${Words.gasDevices.tr()} ID',
//               icon: Icons.tag,
//               validator: (v) => v == null || v.isEmpty ? Words.enterId.tr() : null,
//               inputType: TextInputType.number,
//             ),
//             const SizedBox(height: 8),
//             _buildTextField(
//               controller: c.egxuController,
//               label: 'EGXU ID',
//               icon: Icons.confirmation_number,
//               validator: (v) =>
//                   v == null || v.isEmpty ? 'EGXU ID kiriting' : null,
//               inputType: TextInputType.number,
//             ),
//             const SizedBox(height: 8),
//             _buildTextField(
//               controller: c.quantityController,
//               label: Words.quantity.tr(),
//               icon: Icons.format_list_numbered,
//               validator: (v) {
//                 final n = int.tryParse(v ?? '');
//                 if (n == null || n <= 0) return 'Musbat son kiriting';
//                 return null;
//               },
//               inputType: TextInputType.number,
//             ),
//             const SizedBox(height: 8),
//             GestureDetector(
//               onTap: _selectDate,
//               child: AbsorbPointer(
//                 child: _buildTextField(
//                   controller: c.dateController,
//                   label: 'Ish tugatilgan ${Words.date.tr()}',
//                   icon: Icons.calendar_today,
//                   validator: (v) =>
//                       v == null || v.isEmpty ? Words.selectDate.tr() : null,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 8),
//             _buildTextField(
//               controller: c.stampController,
//               label: Words.stampNumber.tr(),
//               icon: Icons.stars,
//               validator: (v) =>
//                   v == null || v.isEmpty ? Words.requiredField.tr() : null,
//             ),
//             const SizedBox(height: 8),
//             _buildTextField(
//               controller: c.hourlyController,
//               label: Words.hourlyGasConsumption.tr(),
//               icon: Icons.av_timer,
//               validator: (v) =>
//                   v == null || v.isEmpty ? Words.requiredField.tr() : null,
//               inputType: const TextInputType.numberWithOptions(decimal: true),
//             ),
//             const SizedBox(height: 8),
//             _buildTextField(
//               controller: c.dailyController,
//               label: Words.dailyGasConsumption.tr(),
//               icon: Icons.today,
//               validator: (v) =>
//                   v == null || v.isEmpty ? Words.requiredField.tr() : null,
//               inputType: const TextInputType.numberWithOptions(decimal: true),
//             ),
//             const SizedBox(height: 8),
//             _buildTextField(
//               controller: c.reasonController,
//               label: Words.replacementReason.tr(),
//               icon: Icons.comment_outlined,
//               validator: null,
//               maxLines: 2,
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: () => setState(
//                     () => c.photos.add(
//                       'photo_\${DateTime.now().millisecondsSinceEpoch}.jpg',
//                     ),
//                   ),
//                   icon: const Icon(Icons.camera_alt),
//                   label: Text(Words.imageAdd.tr()),
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   '${c.photos.length} ${Words.imageCount.tr()}',
//                   style: TextStyle(color: Colors.grey.shade600),
//                 ),
//               ],
//             ),
//             if (c.photos.isNotEmpty)
//               Wrap(
//                 spacing: 8,
//                 runSpacing: 8,
//                 children: c.photos
//                     .map(
//                       (p) => Chip(
//                         label: Text(p),
//                         onDeleted: () => setState(() => c.photos.remove(p)),
//                       ),
//                     )
//                     .toList(),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     String? Function(String?)? validator,
//     TextInputType? inputType,
//     int maxLines = 1,
//   }) {
//     return TextFormField(
//       controller: controller,
//       decoration: InputDecoration(
//         prefixIcon: Icon(icon, color: _kPrimary),
//         labelText: label,
//         filled: true,
//         fillColor: Colors.grey.shade50,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey.shade300),
//         ),
//       ),
//       validator: validator,
//       keyboardType: inputType,
//       inputFormatters:
//           inputType == TextInputType.number ||
//               inputType == TextInputType.numberWithOptions(decimal: true)
//           ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))]
//           : null,
//       maxLines: maxLines,
//     );
//   }
// }
//
// class EquipmentFormController {
//   final TextEditingController gasEquipmentController = TextEditingController();
//   final TextEditingController egxuController = TextEditingController();
//   final TextEditingController quantityController = TextEditingController(
//     text: '1',
//   );
//   final TextEditingController stampController = TextEditingController();
//   final TextEditingController hourlyController = TextEditingController();
//   final TextEditingController dailyController = TextEditingController();
//   final TextEditingController reasonController = TextEditingController();
//   final TextEditingController dateController = TextEditingController();
//
//   bool uses = false;
//   List<String> photos = [];
//
//   void dispose() {
//     gasEquipmentController.dispose();
//     egxuController.dispose();
//     quantityController.dispose();
//     stampController.dispose();
//     hourlyController.dispose();
//     dailyController.dispose();
//     reasonController.dispose();
//     dateController.dispose();
//   }
// }
//
// // Choice maps
// const removalChoices = {
//   "other_type_or_factory": "Бошқа турга ёки завод рақамига",
//   "case_view_or_other": "Кейслов кўригига ёки бошқа холат",
// };
//
// const gasUsageChoices = {"tagged": "Тамгаланди", "used": "Фойдаланади"};
//
// const usageTypeChoices = {
//   "all_gas_devices": "Жами газ анҳомлари бўйича",
//   "selected_gas_devices": "Танланган газ анҳомлари бўйича",
// };
