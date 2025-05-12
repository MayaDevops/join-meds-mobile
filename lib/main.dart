// import 'package:flutter/material.dart';
// import 'package:untitled/screens/Anaesthesia%20technician/bsc_anaesthesia_tech_academic_status.dart';
// import 'package:untitled/screens/Anaesthesia%20technician/bsc_anaesthesia_tech_degree_ongoing.dart';
// import 'package:untitled/screens/Anaesthesia%20technician/diploma_anaesthesia_academic_status.dart';
// import 'package:untitled/screens/Anaesthesia%20technician/diploma_anaesthesia_ongoing.dart';
// import 'package:untitled/screens/Audiologist/bsc_audiology_academic_status.dart';
// import 'package:untitled/screens/Audiologist/bsc_audiology_degree_ongoing.dart';
// import 'package:untitled/screens/Audiologist/diploma_audiology_academic_status.dart';
// import 'package:untitled/screens/Audiologist/diploma_audiology_ongoing.dart';
// import 'package:untitled/screens/Clinical%20Psychologist/bsc_clinical_psychologist_academic_status.dart';
// import 'package:untitled/screens/Clinical%20Psychologist/bsc_clinical_psychologist_degree_ongoing.dart';
// import 'package:untitled/screens/Clinical%20Psychologist/diploma_clinical_psychologist_academic_status.dart';
// import 'package:untitled/screens/Clinical%20Psychologist/diploma_clinical_psychologist_ongoing.dart';
// import 'package:untitled/screens/Dentist/dentist_academic_status.dart';
// import 'package:untitled/screens/Dentist/dentist_degree_ongoing.dart';
// import 'package:untitled/screens/Dietitian/bsc_dietetics_academic_status.dart';
// import 'package:untitled/screens/Dietitian/bsc_dietetics_degree_ongoing.dart';
// import 'package:untitled/screens/Dietitian/diploma_dietetics_academic_status.dart';
// import 'package:untitled/screens/Dietitian/diploma_dietetics_ongoing.dart';
// import 'package:untitled/screens/Doctor/doctor_degree_completed/doctor_pg-holder/dr_pg_holder_speciality.dart';
// import 'package:untitled/screens/Doctor/doctor_degree_ongoing/dr_degree_ongoing_1.dart';
// import 'package:untitled/screens/Doctor/doctor_work_experience/certificate_specialisation.dart';
// import 'package:untitled/screens/Doctor/doctor_work_experience/work_experience.dart';
// import 'package:untitled/screens/Doctor/dr_academic_status.dart';
// import 'package:untitled/screens/Hospital%20Administrator/b_hospital_administrator_academic_status.dart';
// import 'package:untitled/screens/Hospital%20Administrator/b_hospital_administrator_degree_ongoing.dart';
// import 'package:untitled/screens/Hospital%20Administrator/diploma_hospital_administrator_academic_status.dart';
// import 'package:untitled/screens/Hospital%20Administrator/diploma_hospital_administrator_ongoing.dart';
// import 'package:untitled/screens/Lab%20Techinician/bsc_mlt_academic_status.dart';
// import 'package:untitled/screens/Lab%20Techinician/bsc_mlt_degree_ongoing.dart';
// import 'package:untitled/screens/Lab%20Techinician/dmlt_academic_status.dart';
// import 'package:untitled/screens/Lab%20Techinician/dmlt_diploma_ongoing.dart';
// import 'package:untitled/screens/Nurse/anm_nurse_diploma_status.dart';
// import 'package:untitled/screens/Nurse/gnm_nurse_diploma_acc_status.dart';
// import 'package:untitled/screens/Nurse/nurse_academic_status.dart';
// import 'package:untitled/screens/Nurse/nurse_degree_completed/nurse_pg_holder_speciality.dart';
// import 'package:untitled/screens/Nurse/nurse_degree_ongoing/nurse_degree_ongoing.dart';
// import 'package:untitled/screens/Nurse/nurse_diploma_completed/general_nurse_internship_completed.dart';
// import 'package:untitled/screens/Nurse/nurse_diploma_ongoing/anm_nurse_diploma_ongoing.dart';
// import 'package:untitled/screens/Nurse/nurse_diploma_ongoing/gn_nurse_diploma_ongoing.dart';
// import 'package:untitled/screens/Nurse/nurse_work_experience/nurse_work_experience.dart';
// import 'package:untitled/screens/Pharmacist/b_pharm_academic_status.dart';
// import 'package:untitled/screens/Pharmacist/b_pharm_degree_ongoing.dart';
// import 'package:untitled/screens/Pharmacist/d_pharm_academic_status.dart';
// import 'package:untitled/screens/Pharmacist/d_pharm_diploma_ongoing.dart';
// import 'package:untitled/screens/Pharmacist/pharm_d_academic_status.dart';
// import 'package:untitled/screens/Pharmacist/pharm_d_degree_ongoing.dart';
// import 'package:untitled/screens/Pharmacist/pharmacist_work_experience.dart';
// import 'package:untitled/screens/Physiotherapy/bsc_physiotherapy_academic_status.dart';
// import 'package:untitled/screens/Physiotherapy/bsc_physiotherapy_degree_ongoing.dart';
// import 'package:untitled/screens/Physiotherapy/diploma_physiotherapy_academic_status.dart';
// import 'package:untitled/screens/Physiotherapy/diploma_physiotherapy_ongoing.dart';
// import 'package:untitled/screens/Social%20Worker/bsw_academic_status.dart';
// import 'package:untitled/screens/Social%20Worker/bsw_degree_ongoing.dart';
// import 'package:untitled/screens/Social%20Worker/diploma_social_work_academic_status.dart';
// import 'package:untitled/screens/Social%20Worker/diploma_social_work_ongoing.dart';
// import 'package:untitled/screens/country_preferred_pages/country_that_you_preferred.dart';
// import 'package:untitled/screens/landing_page.dart';
// import 'package:untitled/screens/login_page/login_page.dart';
// import 'package:untitled/screens/onboarding.dart';
// import 'package:untitled/screens/organisation/about_organisation.dart';
// import 'package:untitled/screens/organisation/org_phone_number.dart';
// import 'package:untitled/screens/organisation/organisation_landing.dart';
// import 'package:untitled/screens/organisation/organisation_otp_page.dart';
// import 'package:untitled/screens/signupPages/profile_picture.dart';
// import 'package:untitled/screens/signupPages/resume_upload.dart';
// import 'package:untitled/screens/signupPages/sign_up.dart';
// import 'screens/signupPages/personal_data.dart';
// import 'screens/signupPages/sing_up_loading.dart';
//
// void main() {
//   runApp(
//     MaterialApp(
//       debugShowCheckedModeBanner: false,
//       routes: {
//         '/': (context) => const Onboarding(), // Loading Screen of the App
//         '/landing_page': (context) =>
//             const LandingPage(), // Landing Page of the App
//
//         //Organisation Pages starts here
//         '/organisation_home': (context) =>
//             const OrganisationLanding(), // Organisation Landing Page of the App
//         '/organisation_otp': (context) =>
//             const OrganisationOtpPage(), // Organisation OTP Page of the App
//         '/org_phone_number': (context) =>
//             const OrgPhoneNumber(), // Organisation Phone Number Typing Page of the App
//         '/about_organisation': (context) =>
//             const AboutOrganisation(), // Organisation About mentioning Page of the App
//         //Organisation Pages ends here
//
//         // Login and Sing Up pages of App starts here
//         '/login_page': (context) => const LoginPage(), // Login Page of the App
//         '/sign_up': (context) => const SignUp(), // Sing Up Page of the App
//         '/sign_up_loading': (context) =>
//             const SignUpLoading(), // After Singing Up loading Page of the App
//         // Login and Sing Up pages of App ends here
//
//         // Personal data collection pages of the App starts here
//         '/personal_data': (context) =>
//             const PersonalData(), // Personal data Page of the App
//         '/profile_picture': (context) =>
//             const ProfilePicture(), // Profile Pic Page of the App
//         '/resume_upload': (context) =>
//             const ResumeUpload(), // Resume Page of the App
//         // Personal data collection pages of the App ends here
//
//         // Doctor pages starts here
//         '/dr_acd_status': (context) =>
//             const DrAcademicStatus(), // Doctor Academic Status page of the App
//         '/dr_degree_ongoing_1': (context) =>
//             const DrDegreeOngoing1(), // Doctor Degree Ongoing page of the App
//         '/dr_pg_holder_speciality': (context) =>
//             const SelectingDrSpeciality(), // Doctor PG holder speciality page of the App
//         '/work_experience': (context) =>
//             const WorkExperience(), // Doctor Work Experience page of the App
//         '/dr_certification_of_spl': (context) =>
//             const CertificateOfSpecialisation(), // Doctor certificate of specialisation picking page
//         // Doctor pages ends here
//
//         // Nurse pages starts here
//         '/nurse_academic_status': (context) =>
//             const NurseAcademicStatus(), // Nurse Academic Status page of the App
//         '/nurse_pg_holder_speciality': (context) =>
//             const SelectingNurseSpeciality(), // Nurse PG holder speciality page of the App
//         '/nurse_work_experience': (context) =>
//             const NurseWorkExperience(), // Nurse Work Experience page of the App
//         '/nurse_degree_ongoing': (context) => const NurseDegreeOngoing(),
//         '/gn_nurse_academic_status': (context) =>
//             const GnNurseDiplomaAcademicStatus(), // General Nurse Diploma Academic status Page of the App
//         '/gn_nurse_internship_completed': (context) =>
//             const GeneralNurseInternshipCompleted(), // General Nurse Internship completed Page of the App
//         '/gn_nurse_diploma_ongoing': (context) =>
//             const GnNurseDiplomaOngoing(), // General Nurse Diploma Ongoing Page of the App
//         '/anm_nurse_diploma_status': (context) =>
//             const AnmNurseDiplomaAcademicStatus(), // Auxiliary Nursing Midwifery Diploma Academic status Page of the App
//         '/anm_nurse_diploma_ongoing': (context) =>
//             const AnmNurseDiplomaOngoing(), // Auxiliary Nursing Midwifery Diploma Ongoing page of the App
//         // Nurse pages ends here
//
//         // Pharmacist pages starts here
//         '/pharmacist_academic_status_page': (context) =>
//         const BPharmaAcademicStatus(), // pharmacist academic status page of the App
//         '/b-pharm_degree_ongoing': (context) =>
//         const BPharmDegreeOngoing(), // pharmacist degree ongoing page of the App
//         '/pharmacist_work_experience': (context) =>
//         const PharmacistWorkExperience(), // pharmacist work experience page of the App
//         '/pharm_d_academic_status': (context) =>
//         const PharmDAcademicStatus(), // pharm D Academic Status page of the App
//         '/pharm_d_degree_ongoing': (context) =>
//         const PharmDDegreeOngoing(), // pharm D degree ongoing page of the App
//         '/d_pharmd_diploma_academic_status': (context) =>
//         const DPharmDiplomaAcademicStatus(), //  D pharm Academic Status page of the App
//         '/d_pharm_degree_ongoing': (context) =>
//         const DPharmDiplomaOngoing(), // D pharm  degree ongoing page of the App
//         // Pharmacist pages ends here
//
//         // Lab technician starts here
//         '/bsc_mlt_academic_status': (context) =>
//         const BScMLTAcademicStatus(), // BSc MLT academic status page of the App
//         '/dmlt_academic_status': (context) =>
//         const DMLTAcademicStatus(), // DMLT academic status page of the App
//         '/bsc_mlt_degree_ongoing': (context) =>
//         const BScMLTDegreeOngoing(), // BSc MLT Degree ongoing page of the App
//         '/dmlt_diploma_ongoing': (context) =>
//         const DMLTDiplomaOngoing(), // BSc MLT Degree ongoing page of the App
//         // Lab technician ends here
//
//         // Anaesthesia technician starts here
//         '/bsc_at_academic_status': (context) =>
//         const BScAnaesthesiaTechAcademicStatus(), // BSc AT academic status page of the App
//         '/dat_academic_status': (context) =>
//         const DiplomaAnaesthesiaTechAcademicStatus(), // DAT academic status page of the App
//         '/bsc_at_degree_ongoing': (context) =>
//         const BScAnaesthesiaTechDegreeOngoing(), // BSc AT Degree ongoing page of the App
//         '/dat_diploma_ongoing': (context) =>
//         const DiplomaAnaesthesiaTechOngoing(), // DAT diploma ongoing page of the App
//         // Anaesthesia technician ends here
//
//         // Dentist starts here
//         '/dentist_academic_status': (context) =>
//         const DentistAcademicStatus(), // Dentist academic status page of the App
//         '/dentist_degree_ongoing': (context) =>
//         const DentistDegreeOngoing(), // Dentist degree ongoing page of the App
//         // Dentist ends here
//
//         // physiotherapy starts here
//         '/bpt_academic_status': (context) =>
//         const BScPhysiotherapyAcademicStatus(), // BPT academic status page of the App
//         '/dpt_academic_status': (context) =>
//         const DiplomaPhysiotherapyAcademicStatus(), // DPT academic status page of the App
//         '/bpt_degree_ongoing': (context) =>
//         const BScPhysiotherapyDegreeOngoing(), // BPT Degree ongoing page of the App
//         '/dpt_diploma_ongoing': (context) =>
//         const DiplomaPhysiotherapyOngoing(), // DPT diploma ongoing page of the App
//         // physiotherapy ends here
//
//         // Audiologist starts here
//         '/bsc_audiology_academic_status': (context) =>
//         const BScAudiologyAcademicStatus(), // BSc Audiology academic status page of the App
//         '/diploma_audiology_academic_status': (context) =>
//         const DiplomaAudiologyAcademicStatus(), // Diploma audiology academic status page of the App
//         '/bsc_audiology_degree_ongoing': (context) =>
//         const BScAudiologyDegreeOngoing(), // BSc Audiology Degree ongoing page of the App
//         '/diploma_audiology_diploma_ongoing': (context) =>
//         const DiplomaAudiologyOngoing(), // Diploma audiology ongoing page of the App
//         // Audiologist ends here
//
//         // Dietitian starts here
//         '/bsc_dietetics_academic_status': (context) =>
//         const BScDieteticsAcademicStatus(), // BSc Dietetics academic status page of the App
//         '/diploma_dietetics_academic_status': (context) =>
//         const DiplomaDieteticsAcademicStatus(), // Diploma Dietetics academic status page of the App
//         '/bsc_dietetics_degree_ongoing': (context) =>
//         const BScDieteticsDegreeOngoing(), // BSc Dietetics Degree ongoing page of the App
//         '/diploma_dietetics_diploma_ongoing': (context) =>
//         const DiplomaDieteticsTechOngoing(), // Diploma Dietetics ongoing page of the App
//         // Dietitian ends here
//
//         // Clinical Psychologist starts here
//         '/bsc_psychology_academic_status': (context) =>
//         const BScPsychologyStatus(), // BSc Psychology academic status page of the App
//         '/diploma_psychology_academic_status': (context) =>
//         const DiplomaPsychologyAcademicStatus(), // Diploma Psychology academic status page of the App
//         '/bsc_psychology_degree_ongoing': (context) =>
//         const BScPsycologyDegreeOngoing(), // BSc Psychology Degree ongoing page of the App
//         '/diploma_psychology_diploma_ongoing': (context) =>
//         const DiplomaPsychologyOngoing(), // Diploma Psychology ongoing page of the App
//         // Clinical Psychologist ends here
//
//         // Social Worker starts here
//         '/bsw_academic_status': (context) =>
//         const BSWAcademicStatus(), // bsw academic status page of the App
//         '/diploma_social_worker_academic_status': (context) =>
//         const DiplomaSocialWorkAcademicStatus(), // Diploma social worker academic status page of the App
//         '/bsw_degree_ongoing': (context) =>
//         const BSWDegreeOngoing(), // bsw Degree ongoing page of the App
//         '/diploma_social_worker_diploma_ongoing': (context) =>
//         const DiplomaSocialWorkOngoing(), // Diploma social worker ongoing page of the App
//         // Social Worker ends here
//
//         // Hospital Administrator starts here
//         '/bha_academic_status': (context) =>
//         const BHAdministratorAcademicStatus(), // bha academic status page of the App
//         '/diploma_hospital_administrator_academic_status': (context) =>
//         const DiplomaHospitalAdministratorAcademicStatus(), // Diploma Hospital Administrator academic status page of the App
//         '/bha_degree_ongoing': (context) =>
//         const BHAdministratorDegreeOngoing(), // bha Degree ongoing page of the App
//         '/diploma_hospital_administrator_diploma_ongoing': (context) =>
//         const DiplomaHospitalAdministratorOngoing(), // Diploma Hospital Administrator ongoing page of the App
//         // Hospital Administrator ends here
//
//         // Country that you preferred page starts here
//         '/County_that_you_preferred_page': (context) =>
//         const CountryThatYouPreferred(),
//       },
//       initialRoute: '/',
//     ),
//   );
// }
import 'package:flutter/material.dart';
import 'package:untitled/screens/Doctor/dr_academic_status.dart';
import 'package:untitled/screens/landing_page.dart';
import 'package:untitled/screens/login_page/login_page.dart';
import 'package:untitled/screens/onboarding.dart';
import 'package:untitled/screens/organisation/about_organisation.dart';
import 'package:untitled/screens/organisation/org_phone_number.dart';
import 'package:untitled/screens/organisation/organisation_landing.dart';
import 'package:untitled/screens/organisation/organisation_otp_page.dart';
import 'package:untitled/screens/signupPages/profile_picture.dart';
import 'package:untitled/screens/signupPages/resume_upload.dart';
import 'package:untitled/screens/signupPages/sign_up.dart';
import 'screens/signupPages/personal_data.dart';
import 'screens/signupPages/sing_up_loading.dart';
import 'screens/login_page/home_screen.dart';
import 'screens/login_page/my_jobs_screen.dart';

void main() {
  runApp(MaterialApp(

    debugShowCheckedModeBanner: false,
    routes: {
      '/': (context)=> const Onboarding(),
      '/landing_page': (context)=> const LandingPage(),
      '/organisation_home': (context)=> const OrganisationLanding(),
      '/organisation_otp': (context)=> const OrganisationOtpPage(),
      '/org_phone_number': (context)=> const OrgPhoneNumber(),
      '/about_organisation': (context)=> const AboutOrganisation(),
      '/login_page': (context)=> const LoginPage(),
      '/sign_up': (context)=> const SignUp(),
      '/sign_up_loading': (context)=> const SignUpLoading(),
      '/personal_data': (context)=> const PersonalData(),
      '/profile_picture': (context)=> const ProfilePicture(),
      '/resume_upload': (context)=> const ResumeUpload(),
      '/dr_acd_status': (context)=> const DrAcademicStatus(),
      '/home': (context) => const HomeScreen(),
      '/work': (context) => const MyJobsScreen(),



    },
    initialRoute: '/',
  ),
  );
}