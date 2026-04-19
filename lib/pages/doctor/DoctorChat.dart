/* Practitioner messenger view

Authors: Paige Hoffman

Citations: flutter.dev
 */
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:concierge_app/widgets/NavBar.dart';
import 'package:concierge_app/pages/doctor/DoctorHomePage.dart';
import 'package:concierge_app/pages/doctor/DoctorTracker.dart';

class DoctorChatPage extends StatefulWidget {
  const DoctorChatPage({super.key});

  @override
  State<DoctorChatPage> createState() => _DoctorChatPageState();
}

class _DoctorChatPageState extends State<DoctorChatPage> {
  static const _bg          = Color(0xFF0D0D14);
  static const _card        = Color(0xFF16161F);
  static const _accent      = Color(0xFF00C9A7);
  static const _textPrimary = Color(0xFFF0F0F6);
  static const _textMuted   = Color(0xFF6B6B80);
  static const _border      = Color(0xFF2A2A38);

  final _msgCtrl   = TextEditingController();
  final _scrollCtrl = ScrollController();

  // Placeholder messages — replace with Supabase realtime later
  final List<Map<String, dynamic>> _messages = [
    {'text': 'Hi Doctor, my pain has been a 7/10 today.', 'isMe': false, 'time': '9:01 AM'},
    {'text': 'Thanks for the update. Are you taking your medication?', 'isMe': true,  'time': '9:03 AM'},
    {'text': 'Yes, twice a day as prescribed.', 'isMe': false, 'time': '9:04 AM'},
  ];

  // Placeholder patients — replace with Supabase fetch later
  String _selectedPatient = 'Alice Johnson';
  final _patients = ['Alice Johnson', 'Bob Smith', 'Carol White'];

  void _onNavTap(int index) {
    if (index == 0) Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const DoctorHomePage()));
    if (index == 2) Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const DoctorTrackerPage()));
  }

  void _sendMessage() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'text': text, 'isMe': true, 'time': 'Now'});
      _msgCtrl.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _card,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Row(
          children: [
            const Icon(Icons.chat_bubble_outline_rounded,
                color: _accent, size: 18),
            const SizedBox(width: 10),
            const Text('Chat',
                style: TextStyle(
                    color: _textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3)),
            const SizedBox(width: 16),
            // Patient selector
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPatient,
                    dropdownColor: _card,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: _textMuted, size: 16),
                    style: const TextStyle(color: _textPrimary, fontSize: 13),
                    isExpanded: true,
                    onChanged: (v) => setState(() => _selectedPatient = v!),
                    items: _patients
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _border),
        ),
      ),
      body: Column(
        children: [
          // ── Message list ───────────────────────────────
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text('No messages yet',
                        style: TextStyle(color: _textMuted)))
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      final msg = _messages[i];
                      final isMe = msg['isMe'] as bool;
                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.7),
                          decoration: BoxDecoration(
                            color: isMe
                                ? _accent.withOpacity(0.15)
                                : _card,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(14),
                              topRight: const Radius.circular(14),
                              bottomLeft: Radius.circular(isMe ? 14 : 4),
                              bottomRight: Radius.circular(isMe ? 4 : 14),
                            ),
                            border: Border.all(
                                color: isMe
                                    ? _accent.withOpacity(0.3)
                                    : _border),
                          ),
                          child: Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(msg['text'],
                                  style: const TextStyle(
                                      color: _textPrimary, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(msg['time'],
                                  style: const TextStyle(
                                      color: _textMuted, fontSize: 10)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // ── Input bar ──────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            decoration: BoxDecoration(
              color: _card,
              border: Border(top: BorderSide(color: _border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    style: const TextStyle(color: _textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle:
                          const TextStyle(color: _textMuted, fontSize: 14),
                      filled: true,
                      fillColor: _bg,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: _accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: _bg, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavBar(
        selectedIndex: 1,
        onTap: _onNavTap,
        isDoctor: true,
      ),
    );
  }
}