import 'package:flutter/material.dart';

class DoctorChatDetailScreen extends StatefulWidget {
  final String doctorName;
  const DoctorChatDetailScreen({super.key, required this.doctorName});

  @override
  State<DoctorChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<DoctorChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, dynamic>> _messages = [
    {"text": "Hi, Mandy", "isMe": true},
    {"text": "I've tried the app", "isMe": true},
    {"text": "Really?", "isMe": false},
    {"text": "Yeah, It's really good!", "isMe": true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // --- Back Button Functionality ---
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () => Navigator.pop(context), // ব্যাক বাটন কাজ করবে
        ),
        // --- স্ক্রিনশট অনুযায়ী টাইটেল ---
        title: Text(
          widget.doctorName,
          style: const TextStyle(
            color: Color(0xFF1B2C49), 
            fontSize: 20, 
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
        // --- কল এবং ভিডিও আইকন ---
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_outlined, color: Colors.black, size: 24),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: Colors.black, size: 28),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              "09:41 AM",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                return _buildBubble(m["text"], m["isMe"], index);
              },
            ),
          ),
          
          // --- ডিজাইন অনুযায়ী টাইপিং ইন্ডিকেটর ---
          _buildTypingIndicator(),

          // --- ইনপুট বক্স ডিজাইন ---
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Type your message.......",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const Icon(Icons.link, color: Colors.black87, size: 24),
                  const SizedBox(width: 15),
                  const Icon(Icons.image_outlined, color: Colors.black87, size: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(String text, bool isMe, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage("assets/images/doctor1.png"),
              ),
            ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.65,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              // স্ক্রিনশট অনুযায়ী লাইট পার্পল কালার
              color: isMe ? const Color(0xFF7C69FF) : const Color(0xFFF1F4F7),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
                bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
              ),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: isMe ? Colors.white : const Color(0xFF1B2C49),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          if (isMe)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage("assets/images/profile.png"),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 10),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundImage: AssetImage("assets/images/doctor1.png"),
          ),
          const SizedBox(width: 10),
          const Text(
            "Typing...",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}