// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'شاتيفاي';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get emailHint => 'أدخل بريدك الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get passwordHint => 'أدخل كلمة المرور';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get displayName => 'اسم العرض';

  @override
  String get displayNameHint => 'أدخل اسم العرض الخاص بك';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get usernameHint => 'أدخل اسم المستخدم الخاص بك';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get resetPasswordSent =>
      'تم إرسال رسالة إعادة تعيين كلمة المرور. تحقق من بريدك الإلكتروني.';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get welcome => 'مرحباً بك في شاتيفاي';

  @override
  String get welcomeBack => 'مرحباً بعودتك';

  @override
  String get noAccount => 'ليس لديك حساب؟';

  @override
  String get hasAccount => 'لديك حساب بالفعل؟';

  @override
  String get invalidEmail => 'يرجى إدخال عنوان بريد إلكتروني صالح';

  @override
  String get invalidPassword => 'يجب أن تكون كلمة المرور 8 أحرف على الأقل';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get weakPassword => 'كلمة المرور ضعيفة جداً';

  @override
  String get userNotFound => 'لم يتم العثور على حساب بهذا البريد الإلكتروني';

  @override
  String get wrongPassword => 'كلمة المرور غير صحيحة';

  @override
  String get emailAlreadyInUse => 'يوجد حساب بالفعل بهذا البريد الإلكتروني';

  @override
  String get signInWithGoogle => 'تسجيل الدخول باستخدام Google';

  @override
  String get orContinueWith => 'أو تابع باستخدام';

  @override
  String get chats => 'المحادثات';

  @override
  String get contacts => 'جهات الاتصال';

  @override
  String get calls => 'المكالمات';

  @override
  String get settings => 'الإعدادات';

  @override
  String get searchChats => 'البحث في المحادثات';

  @override
  String get newChat => 'محادثة جديدة';

  @override
  String get noChatsYet => 'لا توجد محادثات بعد';

  @override
  String get startAConversation => 'ابدأ محادثة';

  @override
  String get typeMessage => 'اكتب رسالة...';

  @override
  String get send => 'إرسال';

  @override
  String get noMessagesYet => 'لا توجد رسائل بعد';

  @override
  String get sendAMessage => 'أرسل أول رسالة';

  @override
  String get reply => 'رد';

  @override
  String get forward => 'إعادة إرسال';

  @override
  String get copy => 'نسخ';

  @override
  String get edit => 'تعديل';

  @override
  String get deleteForMe => 'حذف بالنسبة لي';

  @override
  String get deleteForEveryone => 'حذف بالنسبة للجميع';

  @override
  String get deleteMessage => 'حذف الرسالة';

  @override
  String get deleteMessageConfirm => 'هل أنت متأكد أنك تريد حذف هذه الرسالة؟';

  @override
  String get messageDeleted => 'تم حذف الرسالة';

  @override
  String get messageEdited => 'تم التعديل';

  @override
  String get editMessage => 'تعديل الرسالة';

  @override
  String get reactions => 'ردود الفعل';

  @override
  String get addReaction => 'إضافة رد فعل';

  @override
  String get removeReaction => 'إزالة رد الفعل';

  @override
  String get forwardMessage => 'إعادة إرسال الرسالة';

  @override
  String get forwardTo => 'إعادة إرسال إلى';

  @override
  String get messageForwarded => 'تم إعادة إرسال الرسالة';

  @override
  String get createGroup => 'إنشاء مجموعة';

  @override
  String get groupName => 'اسم المجموعة';

  @override
  String get groupNameHint => 'أدخل اسم المجموعة';

  @override
  String get groupDescription => 'وصف المجموعة';

  @override
  String get addMembers => 'إضافة أعضاء';

  @override
  String get removeMember => 'إزالة عضو';

  @override
  String get removeMemberConfirm => 'هل أنت متأكد أنك تريد إزالة هذا العضو؟';

  @override
  String get leaveGroup => 'مغادرة المجموعة';

  @override
  String get leaveGroupConfirm => 'هل أنت متأكد أنك تريد مغادرة هذه المجموعة؟';

  @override
  String get admin => 'مدير';

  @override
  String get owner => 'المالك';

  @override
  String get memberList => 'الأعضاء';

  @override
  String get groupInfo => 'معلومات المجموعة';

  @override
  String get inviteMembers => 'دعوة أعضاء';

  @override
  String selectedCount(int count) {
    return '$count محدد';
  }

  @override
  String membersCount(int count) {
    return '$count أعضاء';
  }

  @override
  String get online => 'متصل';

  @override
  String lastSeen(String time) {
    return 'آخر ظهور $time';
  }

  @override
  String get incomingCall => 'مكالمة واردة';

  @override
  String get outgoingCall => 'مكالمة صادرة';

  @override
  String get voiceCall => 'مكالمة صوتية';

  @override
  String get videoCall => 'مكالمة فيديو';

  @override
  String get ringing => 'رنين...';

  @override
  String get callEnded => 'انتهت المكالمة';

  @override
  String callDuration(String duration) {
    return 'المدة: $duration';
  }

  @override
  String get mute => 'كتم الصوت';

  @override
  String get unmute => 'تشغيل الصوت';

  @override
  String get cameraOn => 'تشغيل الكاميرا';

  @override
  String get cameraOff => 'إيقاف الكاميرا';

  @override
  String get speaker => 'السماعة';

  @override
  String get endCall => 'إنهاء المكالمة';

  @override
  String get accept => 'قبول';

  @override
  String get reject => 'رفض';

  @override
  String get callRejected => 'تم رفض المكالمة';

  @override
  String get callMissed => 'مكالمة فائتة';

  @override
  String get callCancelled => 'تم إلغاء المكالمة';

  @override
  String get noCalls => 'لا توجد مكالمات';

  @override
  String missedCallFrom(String name) {
    return 'مكالمة فائتة من $name';
  }

  @override
  String get appearance => 'المظهر';

  @override
  String get theme => 'السمة';

  @override
  String get lightTheme => 'فاتح';

  @override
  String get darkTheme => 'داكن';

  @override
  String get systemTheme => 'النظام';

  @override
  String get language => 'اللغة';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get enableNotifications => 'تفعيل الإشعارات';

  @override
  String get messageNotifications => 'إشعارات الرسائل';

  @override
  String get callNotifications => 'إشعارات المكالمات';

  @override
  String get privacy => 'الخصوصية';

  @override
  String get lastSeenPrivacy => 'إظهار آخر ظهور';

  @override
  String get onlineStatus => 'إظهار حالة الاتصال';

  @override
  String get readReceipts => 'إشعارات القراءة';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get account => 'الحساب';

  @override
  String get signOutConfirm => 'هل أنت متأكد من تسجيل الخروج؟';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get changePhoto => 'تغيير الصورة';

  @override
  String get bio => 'النبذة التعريفية';

  @override
  String get bioHint => 'أخبرنا عن نفسك';

  @override
  String get about => 'حول';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get ok => 'موافق';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get error => 'خطأ';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get retryLater => 'حدث خطأ ما. يرجى المحاولة مرة أخرى لاحقاً.';

  @override
  String get noInternet => 'لا يوجد اتصال بالإنترنت';

  @override
  String get somethingWentWrong => 'حدث خطأ ما';

  @override
  String get search => 'بحث';

  @override
  String get searchInChat => 'ابحث في هذه المحادثة';

  @override
  String get noSearchResults => 'لا توجد رسائل تطابق بحثك';

  @override
  String get back => 'رجوع';

  @override
  String get done => 'تم';

  @override
  String get save => 'حفظ';

  @override
  String get close => 'إغلاق';

  @override
  String get delete => 'حذف';

  @override
  String get selectAll => 'تحديد الكل';

  @override
  String get deselectAll => 'إلغاء تحديد الكل';

  @override
  String get copied => 'تم النسخ إلى الحافظة';

  @override
  String get noResults => 'لم يتم العثور على نتائج';

  @override
  String get emptyList => 'لا شيء هنا بعد';

  @override
  String get justNow => 'الآن';

  @override
  String minutesAgo(int count) {
    return 'منذ $count دقيقة';
  }

  @override
  String hoursAgo(int count) {
    return 'منذ $count ساعة';
  }

  @override
  String daysAgo(int count) {
    return 'منذ $count يوم';
  }

  @override
  String get today => 'اليوم';

  @override
  String get yesterday => 'أمس';

  @override
  String unreadMessagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count رسائل غير مقروءة',
      one: 'رسالة غير مقروءة واحدة',
      zero: 'لا توجد رسائل غير مقروءة',
    );
    return '$_temp0';
  }

  @override
  String newMessagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count رسائل جديدة',
      one: 'رسالة جديدة واحدة',
      zero: 'لا توجد رسائل جديدة',
    );
    return '$_temp0';
  }

  @override
  String membersCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أعضاء',
      one: 'عضو واحد',
      zero: 'لا يوجد أعضاء',
    );
    return '$_temp0';
  }

  @override
  String get chatsTabLabel => 'المحادثات';

  @override
  String get contactsTabLabel => 'جهات الاتصال';

  @override
  String get callsTabLabel => 'المكالمات';

  @override
  String get settingsTabLabel => 'الإعدادات';

  @override
  String get sendButtonLabel => 'إرسال رسالة';

  @override
  String get attachFileLabel => 'إرفاق ملف';

  @override
  String get recordVoiceLabel => 'تسجيل رسالة صوتية';

  @override
  String get cameraLabel => 'فتح الكاميرا';

  @override
  String get galleryLabel => 'فتح المعرض';

  @override
  String get voiceCallLabel => 'بدء مكالمة صوتية';

  @override
  String get videoCallLabel => 'بدء مكالمة فيديو';

  @override
  String get searchLabel => 'بحث';

  @override
  String get closeDialogLabel => 'إغلاق مربع الحوار';

  @override
  String get moreOptionsLabel => 'خيارات إضافية';

  @override
  String get imageAttachmentLabel => 'مرفق صورة';

  @override
  String get videoAttachmentLabel => 'مرفق فيديو';

  @override
  String get documentAttachmentLabel => 'مرفق مستند';

  @override
  String get voiceMessageLabel => 'رسالة صوتية';

  @override
  String get playVoiceMessage => 'تشغيل الرسالة الصوتية';

  @override
  String get pauseVoiceMessage => 'إيقاف الرسالة الصوتية مؤقتاً';

  @override
  String get messageStatusSending => 'جاري الإرسال';

  @override
  String get messageStatusSent => 'تم الإرسال';

  @override
  String get messageStatusDelivered => 'تم التسليم';

  @override
  String get messageStatusSeen => 'تمت المشاهدة';

  @override
  String get messageStatusFailed => 'فشل الإرسال';

  @override
  String get retrySendingMessage => 'إعادة محاولة الإرسال';

  @override
  String get enterName => 'أدخل اسماً';

  @override
  String get enterEmail => 'أدخل عنوان بريد إلكتروني';

  @override
  String get enterPassword => 'أدخل كلمة المرور';

  @override
  String get minPasswordLength => '6 أحرف على الأقل';

  @override
  String get newGroup => 'مجموعة جديدة';

  @override
  String get newMessage => 'رسالة جديدة';

  @override
  String get startDirectConversation => 'ابدأ محادثة مباشرة';

  @override
  String get createGroupChat => 'أنشئ محادثة جماعية';

  @override
  String get pin => 'تثبيت';

  @override
  String get unpin => 'إلغاء التثبيت';

  @override
  String get archive => 'أرشفة';

  @override
  String get unarchive => 'إلغاء الأرشفة';

  @override
  String get deleteChat => 'حذف المحادثة';

  @override
  String get callHistoryEmpty => 'سيظهر سجل المكالمات هنا';

  @override
  String get accepted => 'مقبولة';

  @override
  String get busy => 'مشغول';

  @override
  String get connecting => 'جارٍ الاتصال…';

  @override
  String get flipCamera => 'قلب';

  @override
  String get earpiece => 'سماعة الأذن';

  @override
  String get myProfile => 'ملفي الشخصي';

  @override
  String get name => 'الاسم';

  @override
  String get tapToAddBio => 'اضغط لإضافة نبذة تعريفية';

  @override
  String get blockUser => 'حظر المستخدم';

  @override
  String get editDisplayName => 'تعديل الاسم';

  @override
  String get editBio => 'تعديل النبذة';

  @override
  String get findUsers => 'ابحث عن مستخدمين بالاسم أو اسم المستخدم';

  @override
  String couldNotStartChat(String error) {
    return 'تعذر بدء المحادثة: $error';
  }

  @override
  String get selectMemberRequired => 'يرجى تحديد عضو واحد على الأقل';

  @override
  String failedToCreateGroup(String error) {
    return 'فشل إنشاء المجموعة: $error';
  }

  @override
  String get groupNotFound => 'المجموعة غير موجودة';

  @override
  String get editGroup => 'تعديل المجموعة';

  @override
  String get member => 'عضو';

  @override
  String get makeAdmin => 'تعيين مشرفاً';

  @override
  String get removeAdmin => 'إزالة المشرف';
}
