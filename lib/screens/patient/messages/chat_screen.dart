import 'package:flutter/material.dart';

class ChatDetailScreen extends StatefulWidget {
  final String doctorName;
  const ChatDetailScreen({super.key, required this.doctorName});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, dynamic>> _messages = [
    {"text": "Hi, Mandy", "isMe": true},
    {"text": "I've tried the app", "isMe": true},
    {"text": "Really?", "isMe": false},
    {"text": "Yeah, It's really good!", "isMe": true},
  ];

  void _sendMsg() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add({"text": _controller.text, "isMe": true});
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF), // স্ক্রিনশটের মতো হালকা ব্যাকগ্রাউন্ড
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFF),
        elevation: 0,
        // --- স্ক্রিনশট অনুযায়ী ব্যাক বাটন ---
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 26),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Messages",
          style: TextStyle(
            color: Colors.black, 
            fontSize: 22, 
            fontWeight: FontWeight.w500
          ),
        ),
        centerTitle: true,
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
          
          // ইনপুট বক্স
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Type your message.......",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const Icon(Icons.link, color: Colors.black87),
                  const SizedBox(width: 15),
                  const Icon(Icons.image_outlined, color: Colors.black87),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildBubble(String text, bool isMe, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe)
                const CircleAvatar(
                  radius: 16,
                  // --- ইমেজ পাথটি আপনার প্রজেক্ট অনুযায়ী চেক করুন ---
                  backgroundImage: AssetImage("assets/images/doctor1.png"),
                ),
              const SizedBox(width: 8),
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  // স্ক্রিনশট অনুযায়ী কালার
                  color: isMe ? const Color(0xFF6C5CE7) : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(5),
                    bottomRight: isMe ? const Radius.circular(5) : const Radius.circular(20),
                  ),
                  boxShadow: [
                    if (!isMe)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (isMe)
                const CircleAvatar(
                  radius: 16,
                  // --- ইমেজ পাথটি আপনার প্রজেক্ট অনুযায়ী চেক করুন ---
                  backgroundImage: AssetImage("assets/images/profile.png"),
                ),
            ],
          ),
          // "Typing..." স্ট্যাটাস শুধু ডেমো হিসেবে শেষ মেসেজের পর
          if (!isMe && index == _messages.length - 1)
            const Padding(
              padding: EdgeInsets.only(left: 45, top: 5),
              child: Text("Typing...", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
        ],
      ),
    );
  }
}