import 'package:firebase_messaging/firebase_messaging.dart';

import 'constants.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fcmToken = await _firebaseMessaging.getToken();
    print('Token: $fcmToken');
    final userId = client.auth.currentUser!.id;

    if (userId != null) {
      // Check if the row for the user already exists
      final response = await client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .single();

      if (response is List && response.isNotEmpty) {
        // If the row exists, update the FCM token
        await client
            .from('notifications')
            .update({'fmc_token': fcmToken})
            .eq('user_id', userId)
            ;
      } else {
        // If the row doesn't exist, insert a new row for the user
        await client.from('notifications').upsert({
          'user_id': userId,
          'fmc_token': fcmToken,
        });
      }
    }
  }
}
