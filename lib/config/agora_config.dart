class AgoraConfig {
  /// TODO: Replace with your Agora App ID
  static const String appId = '8299a6de4a084700a4a48d1c15f15d21';

  /// TODO: Replace with your Agora Temp Token if your project has App Certificate enabled.
  /// If your project is in testing mode (App ID only), you can leave this empty or null.
  static const String? token = '875690246eb429b9854852880402f39';

  /// The channel profile mode
  /// For 1-on-1 calls, Communication is recommended.
  /// For Group calls or Broadcasts, LiveBroadcasting is recommended.
  static const channelProfile =
      'communication'; // 'communication' or 'liveBroadcasting'
}
