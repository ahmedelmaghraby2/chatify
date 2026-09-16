// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Chatify';

  @override
  String get signIn => 'Sign in';

  @override
  String get signUp => 'Sign up';

  @override
  String get signOut => 'Sign out';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'Enter your email';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get displayName => 'Display name';

  @override
  String get displayNameHint => 'Enter your display name';

  @override
  String get username => 'Username';

  @override
  String get usernameHint => 'Enter your username';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get resetPasswordSent =>
      'Password reset email sent. Check your inbox.';

  @override
  String get createAccount => 'Create account';

  @override
  String get welcome => 'Welcome to Chatify';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get hasAccount => 'Already have an account?';

  @override
  String get invalidEmail => 'Please enter a valid email address';

  @override
  String get invalidPassword => 'Password must be at least 8 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get weakPassword => 'Password is too weak';

  @override
  String get userNotFound => 'No account found with this email';

  @override
  String get wrongPassword => 'Incorrect password';

  @override
  String get emailAlreadyInUse => 'An account already exists with this email';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get orContinueWith => 'Or continue with';

  @override
  String get chats => 'Chats';

  @override
  String get contacts => 'Contacts';

  @override
  String get calls => 'Calls';

  @override
  String get settings => 'Settings';

  @override
  String get searchChats => 'Search chats';

  @override
  String get newChat => 'New chat';

  @override
  String get noChatsYet => 'No chats yet';

  @override
  String get startAConversation => 'Start a conversation';

  @override
  String get typeMessage => 'Type a message...';

  @override
  String get send => 'Send';

  @override
  String get noMessagesYet => 'No messages yet';

  @override
  String get sendAMessage => 'Send the first message';

  @override
  String get reply => 'Reply';

  @override
  String get forward => 'Forward';

  @override
  String get copy => 'Copy';

  @override
  String get edit => 'Edit';

  @override
  String get deleteForMe => 'Delete for me';

  @override
  String get deleteForEveryone => 'Delete for everyone';

  @override
  String get deleteMessage => 'Delete message';

  @override
  String get deleteMessageConfirm =>
      'Are you sure you want to delete this message?';

  @override
  String get messageDeleted => 'Message deleted';

  @override
  String get messageEdited => 'edited';

  @override
  String get editMessage => 'Edit message';

  @override
  String get reactions => 'Reactions';

  @override
  String get addReaction => 'Add reaction';

  @override
  String get removeReaction => 'Remove reaction';

  @override
  String get forwardMessage => 'Forward message';

  @override
  String get forwardTo => 'Forward to';

  @override
  String get messageForwarded => 'Message forwarded';

  @override
  String get createGroup => 'Create group';

  @override
  String get groupName => 'Group name';

  @override
  String get groupNameHint => 'Enter group name';

  @override
  String get groupDescription => 'Group description';

  @override
  String get addMembers => 'Add members';

  @override
  String get removeMember => 'Remove member';

  @override
  String get removeMemberConfirm =>
      'Are you sure you want to remove this member?';

  @override
  String get leaveGroup => 'Leave group';

  @override
  String get leaveGroupConfirm => 'Are you sure you want to leave this group?';

  @override
  String get admin => 'Admin';

  @override
  String get owner => 'Owner';

  @override
  String get memberList => 'Members';

  @override
  String get groupInfo => 'Group info';

  @override
  String get inviteMembers => 'Invite members';

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String membersCount(int count) {
    return '$count members';
  }

  @override
  String get online => 'Online';

  @override
  String lastSeen(String time) {
    return 'Last seen $time';
  }

  @override
  String get incomingCall => 'Incoming call';

  @override
  String get outgoingCall => 'Outgoing call';

  @override
  String get voiceCall => 'Voice call';

  @override
  String get videoCall => 'Video call';

  @override
  String get ringing => 'Ringing...';

  @override
  String get callEnded => 'Call ended';

  @override
  String callDuration(String duration) {
    return 'Duration: $duration';
  }

  @override
  String get mute => 'Mute';

  @override
  String get unmute => 'Unmute';

  @override
  String get cameraOn => 'Camera on';

  @override
  String get cameraOff => 'Camera off';

  @override
  String get speaker => 'Speaker';

  @override
  String get endCall => 'End call';

  @override
  String get accept => 'Accept';

  @override
  String get reject => 'Reject';

  @override
  String get callRejected => 'Call rejected';

  @override
  String get callMissed => 'Missed call';

  @override
  String get callCancelled => 'Call cancelled';

  @override
  String get noCalls => 'No calls';

  @override
  String missedCallFrom(String name) {
    return 'Missed call from $name';
  }

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get systemTheme => 'System';

  @override
  String get language => 'Language';

  @override
  String get notifications => 'Notifications';

  @override
  String get enableNotifications => 'Enable notifications';

  @override
  String get messageNotifications => 'Message notifications';

  @override
  String get callNotifications => 'Call notifications';

  @override
  String get privacy => 'Privacy';

  @override
  String get lastSeenPrivacy => 'Show last seen';

  @override
  String get onlineStatus => 'Show online status';

  @override
  String get readReceipts => 'Read receipts';

  @override
  String get profile => 'Profile';

  @override
  String get account => 'Account';

  @override
  String get signOutConfirm => 'Are you sure you want to sign out?';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get bio => 'Bio';

  @override
  String get bioHint => 'Tell us about yourself';

  @override
  String get about => 'About';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get retryLater => 'Something went wrong. Please try again later.';

  @override
  String get noInternet => 'No internet connection';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get search => 'Search';

  @override
  String get searchInChat => 'Search in this chat';

  @override
  String get noSearchResults => 'No messages match your search';

  @override
  String get back => 'Back';

  @override
  String get done => 'Done';

  @override
  String get save => 'Save';

  @override
  String get close => 'Close';

  @override
  String get delete => 'Delete';

  @override
  String get selectAll => 'Select all';

  @override
  String get deselectAll => 'Deselect all';

  @override
  String get copied => 'Copied to clipboard';

  @override
  String get noResults => 'No results found';

  @override
  String get emptyList => 'Nothing here yet';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int count) {
    return '$count minutes ago';
  }

  @override
  String hoursAgo(int count) {
    return '$count hours ago';
  }

  @override
  String daysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String unreadMessagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unread messages',
      one: '1 unread message',
      zero: 'No unread messages',
    );
    return '$_temp0';
  }

  @override
  String newMessagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new messages',
      one: '1 new message',
      zero: 'No new messages',
    );
    return '$_temp0';
  }

  @override
  String membersCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
      zero: 'No members',
    );
    return '$_temp0';
  }

  @override
  String get chatsTabLabel => 'Chats';

  @override
  String get contactsTabLabel => 'Contacts';

  @override
  String get callsTabLabel => 'Calls';

  @override
  String get settingsTabLabel => 'Settings';

  @override
  String get sendButtonLabel => 'Send message';

  @override
  String get attachFileLabel => 'Attach file';

  @override
  String get recordVoiceLabel => 'Record voice message';

  @override
  String get cameraLabel => 'Open camera';

  @override
  String get galleryLabel => 'Open gallery';

  @override
  String get voiceCallLabel => 'Start voice call';

  @override
  String get videoCallLabel => 'Start video call';

  @override
  String get searchLabel => 'Search';

  @override
  String get closeDialogLabel => 'Close dialog';

  @override
  String get moreOptionsLabel => 'More options';

  @override
  String get imageAttachmentLabel => 'Image attachment';

  @override
  String get videoAttachmentLabel => 'Video attachment';

  @override
  String get documentAttachmentLabel => 'Document attachment';

  @override
  String get voiceMessageLabel => 'Voice message';

  @override
  String get playVoiceMessage => 'Play voice message';

  @override
  String get pauseVoiceMessage => 'Pause voice message';

  @override
  String get messageStatusSending => 'Sending';

  @override
  String get messageStatusSent => 'Sent';

  @override
  String get messageStatusDelivered => 'Delivered';

  @override
  String get messageStatusSeen => 'Seen';

  @override
  String get messageStatusFailed => 'Failed to send';

  @override
  String get retrySendingMessage => 'Retry sending';

  @override
  String get enterName => 'Enter a name';

  @override
  String get enterEmail => 'Enter an email';

  @override
  String get enterPassword => 'Enter a password';

  @override
  String get minPasswordLength => 'At least 6 characters';

  @override
  String get newGroup => 'New group';

  @override
  String get newMessage => 'New message';

  @override
  String get startDirectConversation => 'Start a direct conversation';

  @override
  String get createGroupChat => 'Create a group chat';

  @override
  String get pin => 'Pin';

  @override
  String get unpin => 'Unpin';

  @override
  String get archive => 'Archive';

  @override
  String get unarchive => 'Unarchive';

  @override
  String get deleteChat => 'Delete chat';

  @override
  String get callHistoryEmpty => 'Your call history will appear here';

  @override
  String get accepted => 'Accepted';

  @override
  String get busy => 'Busy';

  @override
  String get connecting => 'Connecting…';

  @override
  String get flipCamera => 'Flip';

  @override
  String get earpiece => 'Earpiece';

  @override
  String get myProfile => 'My Profile';

  @override
  String get name => 'Name';

  @override
  String get tapToAddBio => 'Tap to add a bio';

  @override
  String get blockUser => 'Block user';

  @override
  String get editDisplayName => 'Edit display name';

  @override
  String get editBio => 'Edit bio';

  @override
  String get findUsers => 'Find users by name or username';

  @override
  String couldNotStartChat(String error) {
    return 'Could not start chat: $error';
  }

  @override
  String get selectMemberRequired => 'Please select at least one member';

  @override
  String failedToCreateGroup(String error) {
    return 'Failed to create group: $error';
  }

  @override
  String get groupNotFound => 'Group not found';

  @override
  String get editGroup => 'Edit group';

  @override
  String get member => 'Member';

  @override
  String get makeAdmin => 'Make admin';

  @override
  String get removeAdmin => 'Remove admin';
}
