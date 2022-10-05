import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'ar_EG': {
          'appointments': 'حجوزات',
          'account': 'الحساب',
          'status': 'الحالة',
          'available': 'متاح',
          'unavailable': 'غير متاح',
          'error': 'خطأ',
          'something_went_wrong': 'حدث خطأ ما',
          'current_appointments': 'الحجوزات الحالية',
          'todays_appointments': 'حجوزات اليوم',
          'prev_appointments': 'الحجوزات السابقة',
          'riyal': 'ريال',
          'service': 'الخدمة',
          'no_appointments': 'لا يوجد حجوزات',
          'pending': 'قيد الانتظار',
          'accepted': 'تم قبول الطلب',
          'approved': 'قيد التنفيذ',
          'canceled': 'تم الإلغاء',
          'completed': 'تم الإنتهاء',
          'appointment_not_found': 'هذا الحجز غير موجود',
          'confirm': 'تأكيد',
          'confirm_status': 'هل انت متاكد من تغيير الحالة ؟',
          'cancel': 'الغاء',
          'try_again': 'يرجى المحاولة مرة اخرى',
          'ok': 'حسنا',
          'appointment_details': 'تفاصيل الحجز',
          'client_location': 'موقع العميل',
          'appointment_number': 'رقم الحجز',
          'date': 'التاريخ',
          'services': 'الخدمات',
          'duration': 'المدة',
          'invoice_details': 'تفاصيل الفاتورة',
          'payment_done_by': 'تم الدفع بواسطة ',
          'subtotal': 'المطلوب للدفع',
          'accept_appointment': 'قبول الطلب',
          'reject_appointment': 'رفض الطلب',
          'cancel_appointment': 'الغاء الطلب',
          'start_appointment': 'بدء الطلب',
          'complete_appointment': 'انهاء الطلب',
          'payment_collected': 'هل تم تحصيل مبلغ',
          'no': 'لا',
          'collect_payment': "تحصيل الفاتورة",
          'gallery': 'معرض الصور',
          'camera': 'الكاميرا',
          'name': 'الاسم',
          'enter_name': 'ادخل الاسم',
          'phone': 'الجوال',
          'confirmed': 'تم التأكيد',
          'change_password': 'تغيير كلمة المرور',
          'current_password': 'كلمة المرور الحالية',
          'enter_current_password': 'ادخل كلمة المرور الحالية',
          'short_password': 'كلمة المرور قصيرة جدا',
          'new_password': 'كلمة المرور الجديدة',
          'enter_new_password': 'ادخل كلمة المرور الجديدة',
          'confirm_new_password': 'تأكيد كلمة المرور الجديدة',
          'enter_confirm_new_password': 'ادخل كلمة المرور الجديدة مرة اخرى',
          'password_not_match': 'كلمة المرور غير متطابقة',
          'no_internet': 'لا يوجد اتصال بالانترنت',
          'check_internet': 'يرجى التحقق من الاتصال بالانترنت',
          'sign_in': 'تسجيل الدخول',
          'enter_email': 'الرجاء ادخال البريد الالكتروني',
          'enter_valid_email': 'الرجاء ادخال بريد الكتروني صحيح',
          'enter_password': 'الرجاء ادخال كلمة المرور',
          'password': 'كلمة المرور',
          'forgot_password': 'نسيت كلمة المرور؟',
          'enter_password_to_continue': 'ادخل بريدك الالكتروني لاسترجاع كلمة المرور',
          'email_address': 'البريد الالكتروني',
          'reset_password': 'استرجاع كلمة المرور',
          'password_sent': '"تم إرسال كلمة المرور إلى بريدك الالكتروني',
          'do_try_again': 'حاول مرة اخرى',
          'arabic': 'استخدام اللغة العربية؟',
          'cant_phone': 'لا يمكن الاتصال بالهاتف',
          'client_details': 'بيانات العميل',
        },
        'en_US': {
          'appointments': 'Appointments',
          'account': 'Account',
          'status': 'Status',
          'available': 'Available',
          'unavailable': 'Unavailable',
          'error': 'Error',
          'something_went_wrong': 'Something went wrong',
          'current_appointments': 'Current Appointments',
          'todays_appointments': 'Todays Appointments',
          'prev_appointments': 'Previous Appointments',
          'riyal': 'Riyal',
          'service': 'Service',
          'no_appointments': 'No Appointments',
          'pending': 'Pending',
          'accepted': 'Accepted',
          'approved': 'Approved',
          'canceled': 'Canceled',
          'completed': 'Completed',
          'appointment_not_found': 'This appointment is not found',
          'confirm': 'Confirm',
          'confirm_status': 'Are you sure to change the status ?',
          'cancel': 'Cancel',
          'try_again': 'Please try again',
          'ok': 'Ok',
          'appointment_details': 'Appointment Details',
          'client_location': 'Client Location',
          'appointment_number': 'Appointment Number',
          'date': 'Date',
          'services': 'Services',
          'duration': 'Duration',
          'invoice_details': 'Invoice Details',
          'payment_done_by': 'Payment done by ',
          'subtotal': 'Subtotal',
          'accept_appointment': 'Accept',
          'reject_appointment': 'Reject',
          'cancel_appointment': 'Cancel',
          'start_appointment': 'Start',
          'complete_appointment': 'Complete',
          'payment_collected': 'Is payment collected',
          'no': 'No',
          'collect_payment': "Collect Invoice",
          'gallery': 'Gallery',
          'camera': 'Camera',
          'name': 'Name',
          'enter_name': 'Enter Name',
          'phone': 'Phone',
          'confirmed': 'Confirmed',
          'change_password': 'Change Password',
          'current_password': 'Current Password',
          'enter_current_password': 'Enter Current Password',
          'short_password': 'Password is too short',
          'new_password': 'New Password',
          'enter_new_password': 'Enter New Password',
          'confirm_new_password': 'Confirm New Password',
          'enter_confirm_new_password': 'Enter Confirm New Password',
          'password_not_match': 'Passwords do not match',
          'no_internet': 'No internet connection',
          'check_internet': 'Please check your internet connection',
          'sign_in': 'Sign In',
          'enter_email': 'Please enter your email',
          'enter_valid_email': 'Please enter a valid email',
          'enter_password': 'Please enter your password',
          'password': 'Password',
          'forgot_password': 'Forgot Password?',
          'enter_password_to_continue': 'Enter your email to reset your password',
          'email_address': 'Email Address',
          'reset_password': 'Reset Password',
          'password_sent': 'Password sent to your email',
          'do_try_again': 'Try again',
          'arabic': 'Use Arabic?',
          'cant_phone': 'Can\'t call phone',
          'client_details': 'Client Details',
        }
      };
}