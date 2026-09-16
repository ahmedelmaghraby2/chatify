import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// The application name
  ///
  /// In en, this message translates to:
  /// **'Chatify'**
  String get appName;

  /// Button text for signing in
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// Button text for creating a new account
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// Button text for signing out
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// Label for the email input field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Placeholder text for the email input field
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailHint;

  /// Label for the password input field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Placeholder text for the password input field
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// Label for the confirm password input field
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// Label for the display name input field
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayName;

  /// Placeholder text for the display name input field
  ///
  /// In en, this message translates to:
  /// **'Enter your display name'**
  String get displayNameHint;

  /// Label for the username input field
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// Placeholder text for the username input field
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get usernameHint;

  /// Link text for password recovery
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// Button text to send a password reset email
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// Confirmation message after password reset email is sent
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent. Check your inbox.'**
  String get resetPasswordSent;

  /// Button text for creating a new account
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// Welcome message shown on the sign-in screen
  ///
  /// In en, this message translates to:
  /// **'Welcome to Chatify'**
  String get welcome;

  /// Greeting shown when a returning user signs in
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// Text prompting users to create an account
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// Text prompting users to sign in
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get hasAccount;

  /// Error message for invalid email format
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// Error message for password that is too short
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get invalidPassword;

  /// Error message when confirm password does not match
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Error message for a weak password
  ///
  /// In en, this message translates to:
  /// **'Password is too weak'**
  String get weakPassword;

  /// Error message when user account is not found
  ///
  /// In en, this message translates to:
  /// **'No account found with this email'**
  String get userNotFound;

  /// Error message for wrong password
  ///
  /// In en, this message translates to:
  /// **'Incorrect password'**
  String get wrongPassword;

  /// Error message when email is already registered
  ///
  /// In en, this message translates to:
  /// **'An account already exists with this email'**
  String get emailAlreadyInUse;

  /// Button text for signing in with Google
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// Divider text between sign-in options
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// Title for the chats tab
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chats;

  /// Title for the contacts tab
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get contacts;

  /// Title for the calls tab
  ///
  /// In en, this message translates to:
  /// **'Calls'**
  String get calls;

  /// Title for the settings tab
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Placeholder text for the chat search bar
  ///
  /// In en, this message translates to:
  /// **'Search chats'**
  String get searchChats;

  /// Button text to start a new chat
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get newChat;

  /// Empty state message when there are no chats
  ///
  /// In en, this message translates to:
  /// **'No chats yet'**
  String get noChatsYet;

  /// Prompt to start a new conversation
  ///
  /// In en, this message translates to:
  /// **'Start a conversation'**
  String get startAConversation;

  /// Placeholder text for the message input field
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// Button text for sending a message
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// Empty state message when there are no messages in a chat
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// Prompt to send the first message in a conversation
  ///
  /// In en, this message translates to:
  /// **'Send the first message'**
  String get sendAMessage;

  /// Context menu item to reply to a message
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// Context menu item to forward a message
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get forward;

  /// Context menu item to copy a message
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// Context menu item to edit a message
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Context menu item to delete a message only for the current user
  ///
  /// In en, this message translates to:
  /// **'Delete for me'**
  String get deleteForMe;

  /// Context menu item to delete a message for all participants
  ///
  /// In en, this message translates to:
  /// **'Delete for everyone'**
  String get deleteForEveryone;

  /// Title of the delete message confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete message'**
  String get deleteMessage;

  /// Confirmation text for deleting a message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this message?'**
  String get deleteMessageConfirm;

  /// Placeholder text shown when a message has been deleted
  ///
  /// In en, this message translates to:
  /// **'Message deleted'**
  String get messageDeleted;

  /// Label shown next to an edited message
  ///
  /// In en, this message translates to:
  /// **'edited'**
  String get messageEdited;

  /// Title of the edit message dialog
  ///
  /// In en, this message translates to:
  /// **'Edit message'**
  String get editMessage;

  /// Title for the reactions picker
  ///
  /// In en, this message translates to:
  /// **'Reactions'**
  String get reactions;

  /// Button text to add a reaction to a message
  ///
  /// In en, this message translates to:
  /// **'Add reaction'**
  String get addReaction;

  /// Button text to remove your reaction from a message
  ///
  /// In en, this message translates to:
  /// **'Remove reaction'**
  String get removeReaction;

  /// Title of the forward message dialog
  ///
  /// In en, this message translates to:
  /// **'Forward message'**
  String get forwardMessage;

  /// Label for selecting a conversation to forward a message to
  ///
  /// In en, this message translates to:
  /// **'Forward to'**
  String get forwardTo;

  /// Confirmation text after a message is forwarded
  ///
  /// In en, this message translates to:
  /// **'Message forwarded'**
  String get messageForwarded;

  /// Button text to create a new group
  ///
  /// In en, this message translates to:
  /// **'Create group'**
  String get createGroup;

  /// Label for the group name input field
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupName;

  /// Placeholder text for the group name input field
  ///
  /// In en, this message translates to:
  /// **'Enter group name'**
  String get groupNameHint;

  /// Label for the group description input field
  ///
  /// In en, this message translates to:
  /// **'Group description'**
  String get groupDescription;

  /// Button text to add members to a group
  ///
  /// In en, this message translates to:
  /// **'Add members'**
  String get addMembers;

  /// Button text to remove a member from a group
  ///
  /// In en, this message translates to:
  /// **'Remove member'**
  String get removeMember;

  /// Confirmation text for removing a group member
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this member?'**
  String get removeMemberConfirm;

  /// Button text to leave a group
  ///
  /// In en, this message translates to:
  /// **'Leave group'**
  String get leaveGroup;

  /// Confirmation text for leaving a group
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave this group?'**
  String get leaveGroupConfirm;

  /// Label for the admin role in a group
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// Label for the owner role in a group
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get owner;

  /// Title for the member list screen
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get memberList;

  /// Title for the group info screen
  ///
  /// In en, this message translates to:
  /// **'Group info'**
  String get groupInfo;

  /// Button text to invite new members to a group
  ///
  /// In en, this message translates to:
  /// **'Invite members'**
  String get inviteMembers;

  /// Text showing the number of selected items
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(int count);

  /// Text showing the number of members in a group
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String membersCount(int count);

  /// Status indicator for online users
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// Text showing when a user was last seen
  ///
  /// In en, this message translates to:
  /// **'Last seen {time}'**
  String lastSeen(String time);

  /// Label for an incoming call
  ///
  /// In en, this message translates to:
  /// **'Incoming call'**
  String get incomingCall;

  /// Label for an outgoing call
  ///
  /// In en, this message translates to:
  /// **'Outgoing call'**
  String get outgoingCall;

  /// Label for a voice call
  ///
  /// In en, this message translates to:
  /// **'Voice call'**
  String get voiceCall;

  /// Label for a video call
  ///
  /// In en, this message translates to:
  /// **'Video call'**
  String get videoCall;

  /// Status text while a call is ringing
  ///
  /// In en, this message translates to:
  /// **'Ringing...'**
  String get ringing;

  /// Status text after a call has ended
  ///
  /// In en, this message translates to:
  /// **'Call ended'**
  String get callEnded;

  /// Text showing the duration of a call
  ///
  /// In en, this message translates to:
  /// **'Duration: {duration}'**
  String callDuration(String duration);

  /// Button text to mute the microphone during a call
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get mute;

  /// Button text to unmute the microphone during a call
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get unmute;

  /// Button text to turn on the camera during a call
  ///
  /// In en, this message translates to:
  /// **'Camera on'**
  String get cameraOn;

  /// Button text to turn off the camera during a call
  ///
  /// In en, this message translates to:
  /// **'Camera off'**
  String get cameraOff;

  /// Button text to toggle speaker during a call
  ///
  /// In en, this message translates to:
  /// **'Speaker'**
  String get speaker;

  /// Button text to end an active call
  ///
  /// In en, this message translates to:
  /// **'End call'**
  String get endCall;

  /// Button text to accept an incoming call
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// Button text to reject an incoming call
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// Status text when a call is rejected
  ///
  /// In en, this message translates to:
  /// **'Call rejected'**
  String get callRejected;

  /// Label for a missed call
  ///
  /// In en, this message translates to:
  /// **'Missed call'**
  String get callMissed;

  /// Status text when a call is cancelled
  ///
  /// In en, this message translates to:
  /// **'Call cancelled'**
  String get callCancelled;

  /// Empty state message when there are no calls
  ///
  /// In en, this message translates to:
  /// **'No calls'**
  String get noCalls;

  /// Text showing who the missed call was from
  ///
  /// In en, this message translates to:
  /// **'Missed call from {name}'**
  String missedCallFrom(String name);

  /// Title for the appearance settings section
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Label for the theme setting
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Option for light theme
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// Option for dark theme
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// Option for system default theme
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// Label for the language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Title for the notifications settings section
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Label for the notification toggle
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get enableNotifications;

  /// Label for message notification settings
  ///
  /// In en, this message translates to:
  /// **'Message notifications'**
  String get messageNotifications;

  /// Label for call notification settings
  ///
  /// In en, this message translates to:
  /// **'Call notifications'**
  String get callNotifications;

  /// Title for the privacy settings section
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// Label for the last seen privacy setting
  ///
  /// In en, this message translates to:
  /// **'Show last seen'**
  String get lastSeenPrivacy;

  /// Label for the online status privacy setting
  ///
  /// In en, this message translates to:
  /// **'Show online status'**
  String get onlineStatus;

  /// Label for the read receipts setting
  ///
  /// In en, this message translates to:
  /// **'Read receipts'**
  String get readReceipts;

  /// Title for the profile section
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Title for the account settings section
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Confirmation text for signing out
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirm;

  /// Button text to edit the user profile
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// Button text to change the profile photo
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// Label for the bio input field
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// Placeholder text for the bio input field
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself'**
  String get bioHint;

  /// Label for the about section
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Generic cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Generic confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Generic OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Generic yes button text
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// Generic no button text
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Text shown while content is loading
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Title for error dialogs
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Button text to retry a failed operation
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Generic error message with retry prompt
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again later.'**
  String get retryLater;

  /// Error message when there is no internet connection
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternet;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// Label for the search button or bar
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Search field hint in the in-chat search screen
  ///
  /// In en, this message translates to:
  /// **'Search in this chat'**
  String get searchInChat;

  /// Empty state when a chat-wide search returns no messages
  ///
  /// In en, this message translates to:
  /// **'No messages match your search'**
  String get noSearchResults;

  /// Button text to go back
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Button text to finish an action
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Button text to save changes
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Button text to close a dialog or screen
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Button text to delete an item
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Button text to select all items
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAll;

  /// Button text to deselect all items
  ///
  /// In en, this message translates to:
  /// **'Deselect all'**
  String get deselectAll;

  /// Snackbar text when content is copied to clipboard
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copied;

  /// Text shown when a search returns no results
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// Empty state text for an empty list
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get emptyList;

  /// Relative time text for less than a minute ago
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// Relative time text for minutes ago
  ///
  /// In en, this message translates to:
  /// **'{count} minutes ago'**
  String minutesAgo(int count);

  /// Relative time text for hours ago
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago'**
  String hoursAgo(int count);

  /// Relative time text for days ago
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(int count);

  /// Relative time text for today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Relative time text for yesterday
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Pluralized text for unread messages count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No unread messages} =1{1 unread message} other{{count} unread messages}}'**
  String unreadMessagesCount(int count);

  /// Pluralized text for new messages count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No new messages} =1{1 new message} other{{count} new messages}}'**
  String newMessagesCount(int count);

  /// Pluralized text for members count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No members} =1{1 member} other{{count} members}}'**
  String membersCountPlural(int count);

  /// Accessibility label for the chats tab
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chatsTabLabel;

  /// Accessibility label for the contacts tab
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get contactsTabLabel;

  /// Accessibility label for the calls tab
  ///
  /// In en, this message translates to:
  /// **'Calls'**
  String get callsTabLabel;

  /// Accessibility label for the settings tab
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTabLabel;

  /// Accessibility label for the send button
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get sendButtonLabel;

  /// Accessibility label for the attach file button
  ///
  /// In en, this message translates to:
  /// **'Attach file'**
  String get attachFileLabel;

  /// Accessibility label for the voice recording button
  ///
  /// In en, this message translates to:
  /// **'Record voice message'**
  String get recordVoiceLabel;

  /// Accessibility label for the camera button
  ///
  /// In en, this message translates to:
  /// **'Open camera'**
  String get cameraLabel;

  /// Accessibility label for the gallery button
  ///
  /// In en, this message translates to:
  /// **'Open gallery'**
  String get galleryLabel;

  /// Accessibility label for the voice call button
  ///
  /// In en, this message translates to:
  /// **'Start voice call'**
  String get voiceCallLabel;

  /// Accessibility label for the video call button
  ///
  /// In en, this message translates to:
  /// **'Start video call'**
  String get videoCallLabel;

  /// Accessibility label for search inputs
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchLabel;

  /// Accessibility label for closing a dialog
  ///
  /// In en, this message translates to:
  /// **'Close dialog'**
  String get closeDialogLabel;

  /// Accessibility label for the more options menu
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptionsLabel;

  /// Accessibility label for an image attachment
  ///
  /// In en, this message translates to:
  /// **'Image attachment'**
  String get imageAttachmentLabel;

  /// Accessibility label for a video attachment
  ///
  /// In en, this message translates to:
  /// **'Video attachment'**
  String get videoAttachmentLabel;

  /// Accessibility label for a document attachment
  ///
  /// In en, this message translates to:
  /// **'Document attachment'**
  String get documentAttachmentLabel;

  /// Accessibility label for a voice message
  ///
  /// In en, this message translates to:
  /// **'Voice message'**
  String get voiceMessageLabel;

  /// Accessibility label for playing a voice message
  ///
  /// In en, this message translates to:
  /// **'Play voice message'**
  String get playVoiceMessage;

  /// Accessibility label for pausing a voice message
  ///
  /// In en, this message translates to:
  /// **'Pause voice message'**
  String get pauseVoiceMessage;

  /// Accessibility label for a message that is currently sending
  ///
  /// In en, this message translates to:
  /// **'Sending'**
  String get messageStatusSending;

  /// Accessibility label for a sent message
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get messageStatusSent;

  /// Accessibility label for a delivered message
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get messageStatusDelivered;

  /// Accessibility label for a seen message
  ///
  /// In en, this message translates to:
  /// **'Seen'**
  String get messageStatusSeen;

  /// Accessibility label for a failed message
  ///
  /// In en, this message translates to:
  /// **'Failed to send'**
  String get messageStatusFailed;

  /// Accessibility label for retrying to send a message
  ///
  /// In en, this message translates to:
  /// **'Retry sending'**
  String get retrySendingMessage;

  /// Validation message for an empty display name
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get enterName;

  /// Validation message for an empty email
  ///
  /// In en, this message translates to:
  /// **'Enter an email'**
  String get enterEmail;

  /// Validation message for an empty password
  ///
  /// In en, this message translates to:
  /// **'Enter a password'**
  String get enterPassword;

  /// Validation message for a password that is too short
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get minPasswordLength;

  /// Label for creating a new group
  ///
  /// In en, this message translates to:
  /// **'New group'**
  String get newGroup;

  /// Label for starting a new direct conversation
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get newMessage;

  /// Subtitle for the new direct conversation action
  ///
  /// In en, this message translates to:
  /// **'Start a direct conversation'**
  String get startDirectConversation;

  /// Subtitle for the new group action
  ///
  /// In en, this message translates to:
  /// **'Create a group chat'**
  String get createGroupChat;

  /// Context menu item to pin a conversation
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get pin;

  /// Context menu item to unpin a conversation
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get unpin;

  /// Context menu item to archive a conversation
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// Context menu item to unarchive a conversation
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get unarchive;

  /// Context menu item to delete a conversation
  ///
  /// In en, this message translates to:
  /// **'Delete chat'**
  String get deleteChat;

  /// Empty state message for the calls list
  ///
  /// In en, this message translates to:
  /// **'Your call history will appear here'**
  String get callHistoryEmpty;

  /// Label for an accepted call
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// Label for a declined call because the user was busy
  ///
  /// In en, this message translates to:
  /// **'Busy'**
  String get busy;

  /// Status text while a call is connecting
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get connecting;

  /// Button text to flip the camera during a video call
  ///
  /// In en, this message translates to:
  /// **'Flip'**
  String get flipCamera;

  /// Audio output option for the phone earpiece
  ///
  /// In en, this message translates to:
  /// **'Earpiece'**
  String get earpiece;

  /// Title for the profile screen of the current user
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// Label for the display name field
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Hint shown when the user has no bio yet
  ///
  /// In en, this message translates to:
  /// **'Tap to add a bio'**
  String get tapToAddBio;

  /// Button text to block another user
  ///
  /// In en, this message translates to:
  /// **'Block user'**
  String get blockUser;

  /// Sheet title for editing the display name
  ///
  /// In en, this message translates to:
  /// **'Edit display name'**
  String get editDisplayName;

  /// Sheet title for editing the bio
  ///
  /// In en, this message translates to:
  /// **'Edit bio'**
  String get editBio;

  /// Placeholder text for the people search bar
  ///
  /// In en, this message translates to:
  /// **'Find users by name or username'**
  String get findUsers;

  /// Error message when starting a conversation fails
  ///
  /// In en, this message translates to:
  /// **'Could not start chat: {error}'**
  String couldNotStartChat(String error);

  /// Validation message when creating a group without members
  ///
  /// In en, this message translates to:
  /// **'Please select at least one member'**
  String get selectMemberRequired;

  /// Error message when creating a group fails
  ///
  /// In en, this message translates to:
  /// **'Failed to create group: {error}'**
  String failedToCreateGroup(String error);

  /// Empty state message when a group could not be loaded
  ///
  /// In en, this message translates to:
  /// **'Group not found'**
  String get groupNotFound;

  /// Button text to edit the group name
  ///
  /// In en, this message translates to:
  /// **'Edit group'**
  String get editGroup;

  /// Label for a regular group member role
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// Button text to promote a member to admin
  ///
  /// In en, this message translates to:
  /// **'Make admin'**
  String get makeAdmin;

  /// Button text to demote an admin to a regular member
  ///
  /// In en, this message translates to:
  /// **'Remove admin'**
  String get removeAdmin;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
