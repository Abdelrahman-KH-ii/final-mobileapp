import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/services/farmbrain_chat_service.dart';
import 'package:farmtec/core/themes/app_theme_colors.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/features/chat/data/models/chat_message.dart';
import 'package:farmtec/features/chat/presentation/widgets/chat_drawer.dart';
import 'package:farmtec/features/chat/presentation/widgets/chat_input_bar.dart';
import 'package:farmtec/features/chat/presentation/widgets/chat_message_bubble.dart';
import 'package:farmtec/features/chat/presentation/widgets/chat_suggestions.dart';
import 'package:farmtec/features/chat/presentation/widgets/chat_typing_indicator.dart';
import 'package:flutter/material.dart';

class FarmBrainChatScreen extends StatefulWidget {
  const FarmBrainChatScreen({super.key});

  static const String routeName = 'farmbrain_chat';

  @override
  State<FarmBrainChatScreen> createState() => _FarmBrainChatScreenState();
}

class _FarmBrainChatScreenState extends State<FarmBrainChatScreen>
    with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  final _chatService = FarmbrainChatService();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isTyping = false;

  final List<List<ChatMessage>> _conversations = [[]];
  int _activeConversation = 0;

  List<ChatMessage> get _messages => _conversations[_activeConversation];

  @override
  void initState() {
    super.initState();
    _conversations[0] = [
      ChatMessage(
        text: 'chat_welcome',
        sender: ChatSender.ai,
        time: '09:00',
      ),
    ];
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isTyping) return;

    final userText = text.trim();
    setState(() {
      _messages.add(
        ChatMessage(
          text: userText,
          sender: ChatSender.user,
          time: _currentTime(),
        ),
      );
      _textController.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      final reply = await _chatService.sendMessage(userText);
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(
          ChatMessage(
            text: reply,
            sender: ChatSender.ai,
            time: _currentTime(),
          ),
        );
      });
      _scrollToBottom();
    } on FarmbrainChatException catch (_) {
      if (!mounted) return;
      setState(() => _isTyping = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).tr('connection_error')),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isTyping = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).tr('connection_error')),
        ),
      );
    }
  }

  String _currentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _newChat() {
    setState(() {
      _conversations.add([
        ChatMessage(
          text: 'new_conversation_started',
          sender: ChatSender.ai,
          time: _currentTime(),
        ),
      ]);
      _activeConversation = _conversations.length - 1;
    });
    Navigator.of(context).pop();
  }

  void _startNewConversation() {
    setState(() {
      _conversations.add([
        ChatMessage(
          text: 'chat_welcome',
          sender: ChatSender.ai,
          time: _currentTime(),
        ),
      ]);
      _activeConversation = _conversations.length - 1;
    });
  }

  Widget _headerIconButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: colors.elevatedSurface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: colors.iconAccent, size: 22),
      ),
    );
  }

  @override
  void dispose() {
    _chatService.dispose();
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = context.isDarkTheme;
    final l = AppLocalizations.of(context);
    final bgColor = colors.background;
    final cardColor = colors.card;
    final topPadding = MediaQuery.of(context).padding.top;
    final showQuestionChips = _messages.length <= 2;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bgColor,
      drawer: ChatDrawer(
        isDark: isDark,
        l: l,
        conversations: _conversations,
        activeConversation: _activeConversation,
        onNewChat: _newChat,
        onConversationSelected: (i) => setState(() => _activeConversation = i),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 170 + topPadding,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/myfarm_illus.png',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withAlpha(70)
                          : Colors.white.withAlpha(20),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20, topPadding + 10, 20, 0),
                child: Row(
                  children: [
                    _headerIconButton(
                      context: context,
                      icon: Icons.add_rounded,
                      onTap: _startNewConversation,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Pallete.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.eco_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              l.tr('farmbrain_ai'),
                              style: AppFonts.font(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: context.screenHeaderTitle,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _headerIconButton(
                      context: context,
                      icon: Icons.menu_rounded,
                      onTap: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(isDark ? 40 : 12),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
                          itemCount:
                              _messages.length + (_isTyping ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _messages.length && _isTyping) {
                              return ChatTypingIndicator(isDark: isDark);
                            }
                            return ChatMessageBubble(
                              message: _messages[index],
                              isDark: isDark,
                            );
                          },
                        ),
                      ),
                      if (showQuestionChips)
                        ChatQuestions(
                          isDark: isDark,
                          l: l,
                          onQuestionTap: _sendMessage,
                        ),
                    ],
                  ),
                ),
              ),
              ChatInputBar(
                isDark: isDark,
                l: l,
                textController: _textController,
                focusNode: _focusNode,
                isSending: _isTyping,
                onSend: _sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
