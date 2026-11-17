import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() {
  runApp(const SmartTriageApp());
}

class SmartTriageApp extends StatelessWidget {
  const SmartTriageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartTriage AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class EmailItem {
  final String id;
  final String sender;
  final String subject;
  final String body;
  String status; // inbox, urgent, archived, blocked
  String? guardrailNote;

  EmailItem({
    required this.id,
    required this.sender,
    required this.subject,
    required this.body,
    this.status = 'inbox',
    this.guardrailNote,
  });
}

class TraceLog {
  final String traceId;
  final String emailId;
  final String stage;
  final String detail;
  final bool isWarning;

  TraceLog({
    required this.traceId,
    required this.emailId,
    required this.stage,
    required this.detail,
    this.isWarning = false,
  });
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  bool _blockInternalArchive = true;
  bool _strictInjectionDefense = true;

  final List<EmailItem> _emails = [
    EmailItem(
      id: '001',
      sender: 'boss@company.com',
      subject: 'URGENT: Q3 Budget Review',
      body: 'Please review the attached Q3 financial projections by EOD today.',
      status: 'urgent',
    ),
    EmailItem(
      id: '002',
      sender: 'newsletter@techdigest.io',
      subject: 'This Week in AI Agents',
      body: 'Top architectural patterns for autonomous agents. Unsubscribe here.',
      status: 'archived',
    ),
    EmailItem(
      id: '003',
      sender: 'colleague@company.com',
      subject: 'Architecture slides?',
      body: 'Can you share the presentation deck from yesterday meeting?',
      status: 'inbox',
    ),
    EmailItem(
      id: '004',
      sender: 'ceo@company.com',
      subject: 'Board newsletter — Q3 priorities',
      body: 'Internal executive memo. Unsubscribe from internal updates below.',
      status: 'blocked',
      guardrailNote: 'Guardrail blocked archive_email on internal domain @company.com',
    ),
  ];

  final List<TraceLog> _traces = [
    TraceLog(
      traceId: 'a8f19c02',
      emailId: '004',
      stage: 'llm_call',
      detail: 'Proposed: {"tool": "archive_email", "args": {"email_id": "004"}}',
    ),
    TraceLog(
      traceId: 'a8f19c02',
      emailId: '004',
      stage: 'guardrail_blocked',
      detail: 'GuardrailViolation: Refused to archive internal sender ceo@company.com',
      isWarning: true,
    ),
    TraceLog(
      traceId: 'a8f19c02',
      emailId: '004',
      stage: 'fallback_exec',
      detail: 'Self-healed → Executed do_nothing(email_id="004")',
    ),
  ];

  void _runTriagePipeline() {
    setState(() {
      for (var email in _emails) {
        if (email.id == '003' && email.status == 'inbox') {
          email.status = 'urgent';
          _traces.insert(
            0,
            TraceLog(
              traceId: 'f92d11e4',
              emailId: '003',
              stage: 'tool_exec:flag_urgent',
              detail: 'Flagged colleague request as urgent based on active policy.',
            ),
          );
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.verified_user, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text('Agent Worker completed cycle. Guardrails verified!'),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4F46E5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildInboxView(),
      _buildGuardrailsView(),
      _buildTracerView(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.bolt, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SmartTriage AI',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'Deterministic Guardrail Engine',
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.white54),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: FilledButton.icon(
              onPressed: _runTriagePipeline,
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              label: const Text('Run'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF1E293B),
        indicatorColor: const Color(0xFF6366F1).withOpacity(0.25),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inbox_outlined),
            selectedIcon: Icon(Icons.inbox, color: Color(0xFF818CF8)),
            label: 'Inbox',
          ),
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield, color: Color(0xFF818CF8)),
            label: 'Guardrails',
          ),
          NavigationDestination(
            icon: Icon(Icons.terminal_outlined),
            selectedIcon: Icon(Icons.terminal, color: Color(0xFF818CF8)),
            label: 'Flight Recorder',
          ),
        ],
      ),
    );
  }

  Widget _buildInboxView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF172033)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statBadge('Total', '${_emails.length}', Colors.white),
                _statBadge('Urgent', '${_emails.where((e) => e.status == 'urgent').length}', Colors.amberAccent),
                _statBadge('Blocked', '${_emails.where((e) => e.status == 'blocked').length}', Colors.redAccent),
                _statBadge('Archived', '${_emails.where((e) => e.status == 'archived').length}', Colors.lightBlueAccent),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.15, end: 0),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Text(
            'Triage Queue',
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white70),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _emails.length,
            itemBuilder: (context, index) {
              final e = _emails[index];
              final badgeColor = _statusColor(e.status);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.75),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: e.status == 'blocked'
                        ? Colors.redAccent.withOpacity(0.4)
                        : Colors.white.withOpacity(0.06),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            e.sender,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF818CF8),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: badgeColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: badgeColor.withOpacity(0.5)),
                          ),
                          child: Text(
                            e.status.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: badgeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      e.subject,
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      e.body,
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.white60),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (e.guardrailNote != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.gpp_bad, color: Colors.redAccent, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                e.guardrailNote!,
                                style: GoogleFonts.inter(fontSize: 11, color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ).animate().fadeIn(delay: Duration(milliseconds: index * 80));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGuardrailsView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Read-Only Policy Constitution',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Deterministic code rules enforced before any side-effect tool executes.',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white60),
              ),
              const Divider(height: 24, color: Colors.white12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Protect Internal Domains (@company.com)'),
                subtitle: const Text('Raises GuardrailViolation if LLM proposes archiving'),
                value: _blockInternalArchive,
                activeColor: const Color(0xFF6366F1),
                onChanged: (val) => setState(() => _blockInternalArchive = val),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('XML Untrusted Data Isolation'),
                subtitle: const Text('Wraps email bodies in <email> tags to block prompt injection'),
                value: _strictInjectionDefense,
                activeColor: const Color(0xFF6366F1),
                onChanged: (val) => setState(() => _strictInjectionDefense = val),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTracerView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _traces.length,
      itemBuilder: (context, index) {
        final t = _traces[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: t.isWarning ? Colors.amberAccent.withOpacity(0.5) : Colors.white10,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '[${t.traceId}] ${t.stage}',
                    style: GoogleFonts.firaCode(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: t.isWarning ? Colors.amberAccent : const Color(0xFF818CF8),
                    ),
                  ),
                  Text(
                    'Email #${t.emailId}',
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.white54),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                t.detail,
                style: GoogleFonts.firaCode(fontSize: 11, color: Colors.white70),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statBadge(String label, String count, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.white60)),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'urgent':
        return Colors.amberAccent;
      case 'blocked':
        return Colors.redAccent;
      case 'archived':
        return Colors.lightBlueAccent;
      default:
        return const Color(0xFF818CF8);
    }
  }
}
