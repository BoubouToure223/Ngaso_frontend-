import 'package:flutter/foundation.dart';
import 'package:myapp/core/data/services/pro_api_service.dart';

class BadgeCounters {
  BadgeCounters._();
  static final BadgeCounters instance = BadgeCounters._();

  final ValueNotifier<int> messagesTotal = ValueNotifier<int>(0);
  final ValueNotifier<int> demandesTotal = ValueNotifier<int>(0);

  Future<void> refreshMessagesTotal() async {
    try {
      final v = await ProApiService().getConversationsUnreadTotal();
      messagesTotal.value = v;
    } catch (_) {}
  }

  Future<void> refreshDemandesTotal() async {
    try {
      final v = await ProApiService().getNovicePropositionsUnansweredCount();
      demandesTotal.value = v;
    } catch (_) {}
  }
}
