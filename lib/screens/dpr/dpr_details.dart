import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/models/dpr.dart';

class DPRDetailsScreen extends StatelessWidget {
  final DailyProgressReport dpr;

  const DPRDetailsScreen({
    super.key,
    required this.dpr,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        title: const Text(
          "DPR Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      bottomNavigationBar: _bottomApproveBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _topHeaderCard(),
            const SizedBox(height: 12),

            _sectionTitle("Tasks completed"),
            _tasksCompletedCard(),
            const SizedBox(height: 12),

            _sectionTitle("Attendance"),
            _attendanceCard(),
            const SizedBox(height: 12),

            _sectionTitle("Materials"),
            _materialsCard(),
            const SizedBox(height: 12),

            _sectionTitle("Equipments"),
            _equipmentsCard(),
            const SizedBox(height: 12),

            _sectionTitle("Photos"),
            _photosCard(),
            const SizedBox(height: 12),

            _sectionTitle("Documents"),
            _documentsCard(),
            const SizedBox(height: 12),

            _sectionTitle("Issues"),
            _issuesCard(),
            const SizedBox(height: 12),

            _sectionTitle("Next Day Plan"),
            _nextDayPlanCard(),
            const SizedBox(height: 12),

            _sectionTitle("Notes"),
            _notesCard(),
          ],
        ),
      ),
    );
  }

  // -------------------- UI blocks --------------------

  Widget _topHeaderCard() {
    final dateLabel = DateFormat("dd MMM yyyy").format(dpr.date).toUpperCase();
    final weather = dpr.weather ?? "-";

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                dateLabel,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              _chip(weather, icon: _weatherIcon(weather)),
              const SizedBox(width: 8),
              _statusPill(dpr.status.name),
            ],
          ),
          const SizedBox(height: 10),

          _kvRow("Report No", dpr.reportNo),
          _kvRow("Project", dpr.projectName ?? dpr.projectId),
          _kvRow("Site Visitor", dpr.siteVisitor ?? "-"),
          _kvRow("Prepared By", dpr.preparedBy?.name ?? dpr.preparedById),
          const SizedBox(height: 10),

          const Text(
            "Description",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.lightGrey),
            ),
            child: Text(
              dpr.workDescription.trim().isEmpty ? "-" : dpr.workDescription,
              style: const TextStyle(fontSize: 13, color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tasksCompletedCard() {
    final tasks = dpr.tasksCompleted ?? const [];

    if (tasks.isNotEmpty) {
      return _card(
        child: Column(
          children: tasks.map((t) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          t.name,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                        ),
                      ),
                      Text(
                        t.percent == null ? "-" : "${t.percent}%",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  if ((t.subtasks ?? const []).isNotEmpty) ...[
                    const SizedBox(height: 6),
                    ...t.subtasks!.map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              const Icon(Icons.circle, size: 6, color: AppColors.textGrey),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(s.name, style: const TextStyle(fontSize: 13)),
                              ),
                            ],
                          ),
                        )),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
      );
    }

    final fallback = dpr.completedWork?.trim();
    return _card(
      child: (fallback == null || fallback.isEmpty)
          ? const Text("-", style: TextStyle(color: AppColors.textGrey))
          : Text(fallback, style: const TextStyle(fontSize: 13)),
    );
  }

  Widget _attendanceCard() {
    final wp = dpr.workersPresent;
    final wt = dpr.workersTotal;
    final sp = dpr.staffPresent;
    final st = dpr.staffTotal;

    return _card(
      child: Column(
        children: [
          _kvRow("Workers", (wp != null && wt != null) ? "$wp / $wt" : "-"),
          _kvRow("Staff", (sp != null && st != null) ? "$sp / $st" : "-"),
          const Divider(height: 18),
          _kvRow(
            "Total Workers",
            "${dpr.totalWorkers ?? 0}",
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _materialsCard() {
    final items = dpr.materials ?? const [];
    if (items.isNotEmpty) {
      return _card(
        child: Column(
          children: items
              .map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(child: Text(m.name, style: const TextStyle(fontSize: 13))),
                        Text("${m.qtyUsed}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ))
              .toList(),
        ),
      );
    }

    final txt = dpr.materialsUsed?.trim();
    return _card(
      child: (txt == null || txt.isEmpty)
          ? const Text("-", style: TextStyle(color: AppColors.textGrey))
          : Text(txt, style: const TextStyle(fontSize: 13)),
    );
  }

  Widget _equipmentsCard() {
    final items = dpr.equipments ?? const [];
    if (items.isNotEmpty) {
      return _card(
        child: Column(
          children: items
              .map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(child: Text(e.name, style: const TextStyle(fontSize: 13))),
                        Text("x${e.qty}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                        const SizedBox(width: 10),
                        Text("${e.hoursUsed}h", style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                      ],
                    ),
                  ))
              .toList(),
        ),
      );
    }

    final txt = dpr.equipmentUsed?.trim();
    return _card(
      child: (txt == null || txt.isEmpty)
          ? const Text("-", style: TextStyle(color: AppColors.textGrey))
          : Text(txt, style: const TextStyle(fontSize: 13)),
    );
  }

  Widget _photosCard() {
    final photos = dpr.photos ?? const [];

    return _card(
      child: photos.isEmpty
          ? const Text("-", style: TextStyle(color: AppColors.textGrey))
          : Wrap(
              spacing: 10,
              runSpacing: 10,
              children: photos.take(9).map((p) => _photoBox(p.imageUrl)).toList(),
            ),
    );
  }

  Widget _documentsCard() {
    final docs = dpr.documents ?? const [];

    return _card(
      child: docs.isEmpty
          ? const Text("-", style: TextStyle(color: AppColors.textGrey))
          : Column(
              children: docs
                  .map((d) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.insert_drive_file_outlined, color: AppColors.textGrey),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(d.fileName ?? "Document", style: const TextStyle(fontSize: 13)),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
    );
  }

  Widget _issuesCard() {
    final issues = dpr.issuesFound?.trim();

    return _card(
      child: (issues == null || issues.isEmpty)
          ? const Text("-", style: TextStyle(color: AppColors.textGrey))
          : Text(issues, style: const TextStyle(fontSize: 13)),
    );
  }

  Widget _nextDayPlanCard() {
    final task = dpr.nextDayTaskName?.trim() ?? "";
    final notes = dpr.nextDayNotes?.trim() ?? "";

    final combined = [task, notes].where((x) => x.isNotEmpty).join("\n");

    return _card(
      child: combined.isEmpty
          ? const Text("-", style: TextStyle(color: AppColors.textGrey))
          : Text(combined, style: const TextStyle(fontSize: 13)),
    );
  }

  Widget _notesCard() {
    final notes = dpr.notes?.trim() ?? dpr.challenges?.trim();

    return _card(
      child: (notes == null || notes.isEmpty)
          ? const Text("-", style: TextStyle(color: AppColors.textGrey))
          : Text(notes, style: const TextStyle(fontSize: 13)),
    );
  }

  // -------------------- helpers --------------------

  Widget _bottomApproveBar(BuildContext context) {
    final isApproved = dpr.status.name.toLowerCase() == "approved";

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: SizedBox(
        height: 46,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isApproved ? null : () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF17A589),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
            elevation: 0,
          ),
          child: Text(
            isApproved ? "Sent for Approval" : "Send for Approval",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightGrey.withOpacity(0.8)),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(left: 2, bottom: 8),
        child: Text(
          t,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      );

  Widget _kvRow(String k, String v, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              k,
              style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
            ),
          ),
          Text(
            v,
            style: TextStyle(
              fontSize: 12,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
              color: bold ? AppColors.textDark : AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppColors.primaryBlue),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _statusPill(String status) {
    Color bg;
    final s = status.toLowerCase();
    if (s == "approved") {
      bg = const Color(0xFF2ECC71);
    } else if (s == "submitted") {
      bg = const Color(0xFF2E86C1);
    } else if (s == "done") {
      bg = const Color(0xFF17A589);
    } else {
      bg = const Color(0xFFF39C12);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Text(
        status,
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _photoBox(String url) {
    return Container(
      height: 54,
      width: 54,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.lightGrey),
      ),
      clipBehavior: Clip.antiAlias,
      child: url.isEmpty
          ? const Icon(Icons.image_outlined, color: AppColors.textGrey)
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined, color: AppColors.textGrey),
            ),
    );
  }

  IconData _weatherIcon(String w) {
    final s = w.toLowerCase();
    if (s.contains("sun")) return Icons.wb_sunny_outlined;
    if (s.contains("cloud")) return Icons.cloud_outlined;
    if (s.contains("rain")) return Icons.thunderstorm_outlined;
    return Icons.wb_sunny_outlined;
  }
}