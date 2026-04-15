import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/models/dpr.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:construction_erp/controllers/dpr/dpr_controller.dart';

class DPRDetailsScreen extends ConsumerWidget {
  final DailyProgressReport dpr;

  const DPRDetailsScreen({
    super.key,
    required this.dpr,
  });

  Future<void> _openFile(BuildContext context, String url) async {
    final fixedUrl = _fixUrl(url);
    final uri = Uri.parse(fixedUrl);
    
    final isImage = fixedUrl.toLowerCase().contains(RegExp(r'\.(jpg|jpeg|png|webp)'));

    if (isImage) {
      _showImagePreview(context, fixedUrl);
    } else {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not open file")),
          );
        }
      }
    }
  }

  void _showImagePreview(BuildContext context, String url) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Preview",
      barrierColor: Colors.black.withOpacity(0.9),
      pageBuilder: (ctx, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(ctx),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.download, color: Colors.white),
                onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
              ),
            ],
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                url,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const CircularProgressIndicator(color: Colors.white);
                },
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.white, size: 50),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        title: const Text("DPR Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
        bottomNavigationBar: _bottomApproveBar(context, ref),      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerSection(),
            const SizedBox(height: 20),
            
            _sectionTitle("Work Description"),
            _descriptionBox(dpr.workDescription),
            const SizedBox(height: 24),

            _sectionTitle("Tasks & Subtasks"),
            _taskDetailsSection(),
            const SizedBox(height: 24),

            if (dpr.pendingWork != null && dpr.pendingWork!.trim().isNotEmpty) ...[
              _sectionTitle("Pending Work"),
              _descriptionBox(dpr.pendingWork!),
              const SizedBox(height: 24),
            ],

            if (dpr.challenges != null && dpr.challenges!.trim().isNotEmpty) ...[
              _sectionTitle("Challenges / Roadblocks"),
              _descriptionBox(dpr.challenges!),
              const SizedBox(height: 24),
            ],

            _attendanceSection(),
            const SizedBox(height: 24),
            _materialsSection(),
            const SizedBox(height: 24),
            _equipmentsSection(),
            const SizedBox(height: 24),

            if (dpr.subContractorName != null && dpr.subContractorName!.trim().isNotEmpty) ...[
               _sectionTitle("Sub-Contractor Details"),
               _descriptionBox("Name: ${dpr.subContractorName!}"),
               const SizedBox(height: 24),
            ],

            if (dpr.safetyObservations != null && dpr.safetyObservations!.trim().isNotEmpty) ...[
              _sectionTitle("Safety Observations"),
              _descriptionBox(dpr.safetyObservations!),
              const SizedBox(height: 24),
            ],

            if (dpr.qualityChecks != null && dpr.qualityChecks!.trim().isNotEmpty) ...[
              _sectionTitle("Quality Checks"),
              _descriptionBox(dpr.qualityChecks!),
              const SizedBox(height: 24),
            ],

            if (dpr.issuesFound != null && dpr.issuesFound!.trim().isNotEmpty) ...[
              _sectionTitle("Issues Found"),
              _descriptionBox(dpr.issuesFound!),
              const SizedBox(height: 24),
            ],

            _sectionTitle("Photos"),
            _photosSection(context), 
            const SizedBox(height: 24),
            _sectionTitle("Documents"),
            _documentsSection(context), 
            const SizedBox(height: 24),

            const Divider(color: Colors.grey, thickness: 0.5),
            const SizedBox(height: 12),
            _sectionTitle("Next Day Plan"),
            _descriptionBox(dpr.nextDayPlan ?? dpr.nextDayNotes ?? "No plans provided for the next day."),
            const SizedBox(height: 40), 
          ],
        ),
      ),
    );
  }

  // -------------------- UI Sections --------------------

  Widget _headerSection() {
    final dateLabel = DateFormat("dd MMM yyyy").format(dpr.date).toUpperCase();
    final weather = dpr.weather ?? "Sunny";

    String visitors = "None";
    if (dpr.siteVisitors.isNotEmpty) {
      try {
        visitors = dpr.siteVisitors.map((v) => v['name']).join(', ');
      } catch (_) {}
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(dateLabel, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textDark)),
            const Icon(Icons.edit_square, color: Colors.grey, size: 20), 
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(dpr.projectName ?? "Project Name", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryBlue), overflow: TextOverflow.ellipsis)),
            Text("ID-${dpr.reportNo.length > 4 ? dpr.reportNo.substring(dpr.reportNo.length - 4) : dpr.reportNo}", style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Site Visitor: $visitors",
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            _weatherChip(weather),
          ],
        ),
      ],
    );
  }

  Widget _descriptionBox(String text) {
    final desc = (text.trim().isEmpty || text == "null") ? "No details provided." : text;
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
      child: Text(desc, style: const TextStyle(fontSize: 13, color: AppColors.textDark, height: 1.4)),
    );
  }

  // 🚨 REFINED TASK DETAILS SECTION
  Widget _taskDetailsSection() {
    String rawText = dpr.completedWork ?? "";
    if (rawText.trim().isEmpty || rawText == "null") return _descriptionBox("No tasks recorded");

    String taskName = rawText;
    String percent = "";
    String subtasks = "";

    // 1. Separate Subtasks
    if (rawText.contains('Subtasks:')) {
      final parts = rawText.split('Subtasks:');
      taskName = parts[0].trim();
      subtasks = parts[1].trim();
    }

    // 2. Extract Percentage using Regex (e.g., "(100%)" or "(50%)")
    final match = RegExp(r'\((\d+)%\)').firstMatch(taskName);
    if (match != null) {
      percent = "${match.group(1)}%";
      // Remove the percentage from the raw name so it doesn't display twice
      taskName = taskName.replaceAll(match.group(0)!, '').trim();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Display the clean task name
              Expanded(child: Text(taskName.isNotEmpty ? taskName : "Task", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark))),
              
              // 🚨 Display the percentage cleanly in a badge next to the name
              if (percent.isNotEmpty) 
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), 
                  decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), 
                  child: Text(percent, style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12))
                ),
            ],
          ),
          if (subtasks.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 8),
            const Text("Subtasks:", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(subtasks, style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textDark)),
          ]
        ],
      ),
    );
  }

  Widget _attendanceSection() {
    final int workers =  dpr.totalWorkers ?? dpr.workersPresent ?? 0;
    final int staff = dpr.staffPresent ?? 0;
    final int total = workers + staff;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Attendance (Total: $total)"),
        const Divider(height: 1, thickness: 1),
        const SizedBox(height: 12),
        _listRow("Workers", "$workers", isValueBlue: true),
        _listRow("Staff", "$staff", isValueBlue: true),
      ],
    );
  }

  Widget _materialsSection() {
    final consumptions = dpr.materialConsumptions ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Materials Consumed"),
        const Divider(height: 1, thickness: 1),
        const SizedBox(height: 12),
        if (consumptions.isEmpty) const Text("No materials recorded", style: TextStyle(color: Colors.grey, fontSize: 13))
        else ...consumptions.map((c) {
          final matName = c.material?.name ?? "Material";
          final qty = c.quantity.toString();
          final unit = c.unit ?? "Nos";
          return _listRow(matName, "$qty $unit", isValueBlue: true);
        }),
      ],
    );
  }

  Widget _equipmentsSection() {
    List<dynamic> eqList = [];
    
    if (dpr.equipmentUsed != null && dpr.equipmentUsed!.startsWith('[')) {
      try { eqList = jsonDecode(dpr.equipmentUsed!); } catch (_) {}
    } 
    else if (dpr.equipments.isNotEmpty) {
      eqList = dpr.equipments;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Equipments Used"),
        const Divider(height: 1, thickness: 1),
        const SizedBox(height: 12),
        if (eqList.isEmpty) const Text("No equipment recorded", style: TextStyle(color: Colors.grey, fontSize: 13))
        else ...eqList.map((e) {
            String name = "Equipment"; 
            String hours = "0";
            
            if (e is Map) { 
              name = e['name']?.toString() ?? "Equipment"; 
              hours = e['hours']?.toString() ?? "0"; 
            } else if (e is DPREquipment) { 
              name = e.name; 
              hours = e.hoursUsed.toString(); 
            }
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                children: [
                  Expanded(child: Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark))), 
                  Text("$hours Hrs used", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryBlue)), 
                ]
              ),
            );
          }),
      ],
    );
  }

  String _fixUrl(String? url) {
    if (url == null || url.isEmpty) return "";
    String fixed = url;
    if (fixed.contains('localhost')) {
      fixed = fixed.replaceAll('localhost', '172.16.9.36'); 
    }
    return fixed;
  }

  Widget _photosSection(BuildContext context) {
    final photos = dpr.photos.where((p) {
      final url = (p.imageUrl ?? "").toLowerCase();
      return url.endsWith('.jpg') || url.endsWith('.jpeg') || url.endsWith('.png') || url.endsWith('.webp');
    }).toList();

    if (photos.isEmpty) return const Text("No photos attached.", style: TextStyle(color: Colors.grey, fontSize: 13));
    
    return Wrap(
      spacing: 12, runSpacing: 12, 
      children: photos.map((p) => InkWell(
        onTap: () => _openFile(context, p.imageUrl ?? ""),
        child: _imageBox(_fixUrl(p.imageUrl ?? p.thumbnailUrl))
      )).toList()
    );
  }

  Widget _documentsSection(BuildContext context) {
    final hiddenDocs = dpr.photos.where((p) {
      final url = (p.imageUrl ?? "").toLowerCase();
      return url.contains('.pdf') || url.contains('.doc') || url.contains('.docx') || url.contains('.txt');
    }).toList();

    final allDocs = [...dpr.documents, ...hiddenDocs];

    if (allDocs.isEmpty) return const Text("No documents attached.", style: TextStyle(color: Colors.grey, fontSize: 13));
    
    return Wrap(
      spacing: 12, runSpacing: 12, 
      children: allDocs.map((d) {
        String name = "Document";
        String fileUrl = "";
        
        if (d is DPRPhoto) {
           final parts = d.imageUrl.split('/');
           name = parts.last.split('?').first ?? "Document.pdf";
           fileUrl = d.imageUrl ?? "";
        } else {
           name = (d as dynamic).fileName ?? "Document.pdf";
           fileUrl = (d as dynamic).fileUrl ?? "";
        }
        
        return InkWell(
          onTap: () => _openFile(context, fileUrl),
          child: _docBox(name)
        );
      }).toList()
    );
  }

  // -------------------- Core Helpers --------------------

  Widget _listRow(String title, String value,
      {bool isValueBlue = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10), 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
        children: [
          Text(title, style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.w900 : FontWeight.w600, color: AppColors.textDark)), 
          Text(value, style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.w900 : FontWeight.w700, color: isValueBlue ? AppColors.primaryBlue : AppColors.textDark))
        ]
      )
    );
  }

  Widget _sectionTitle(String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8), 
      child: Text(t, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textDark))
    );
  }

  Widget _weatherChip(String weather) => Row(children: [Icon(weather.toLowerCase().contains('sunny') ? Icons.wb_sunny_outlined : Icons.cloud_outlined, size: 16, color: AppColors.primaryBlue), const SizedBox(width: 4), Text(weather, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryBlue))]);
  
  Widget _imageBox(String url) {
    if (url.isEmpty) return Container(height: 70, width: 90, color: Colors.grey.shade200, child: const Icon(Icons.broken_image, color: Colors.grey));
    return Container(
      height: 70, width: 90, 
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8), 
        border: Border.all(color: Colors.grey.shade300),
        image: DecorationImage(
          image: NetworkImage(url), 
          fit: BoxFit.cover, 
          onError: (e, stack) => debugPrint("Image Load Error: $e")
        )
      )
    );
  }
  
  Widget _docBox(String name) => Container(height: 70, width: 90, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 30), const SizedBox(height: 8), Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: Colors.black87)))]));

 Widget _bottomApproveBar(BuildContext context, WidgetRef ref) {
    final status = dpr.status.name.toUpperCase();
    final isApproved = status == "APPROVED" || status == "COMPLETED";
    final isPending = status == "REVIEW"; // Already in the inspection queue

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))]),
      child: SizedBox(
        height: 48, width: double.infinity, 
        child: ElevatedButton(
          onPressed: (isApproved || isPending) ? null : () async {
            try {
              // 🚨 FIXED: Changed from sendForApproval to approveDPR
              await ref.read(dprControllerProvider.notifier).approveDPR(
                dpr.id,
                status: 'REVIEW', 
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Sent for inspection successfully!"), backgroundColor: Colors.green)
                );
                Navigator.pop(context); 
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to send: $e"), backgroundColor: Colors.red)
                );
              }
            }
          }, 
          style: ElevatedButton.styleFrom(backgroundColor: (isApproved || isPending) ? Colors.grey : const Color(0xFF17A589), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), elevation: 0), 
          child: Text(
            isApproved ? "Approved" : (isPending ? "Pending Inspection" : "Send For Approval"), 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)
          )
        )
      ),
    );
  }
}
