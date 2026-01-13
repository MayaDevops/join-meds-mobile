class AppAssets {
  // Base paths
  static const String _imagesPath = 'assets/v2/images';
  static const String _animationsPath = 'assets/v2/animations';

  // Logo
  static const String logo = '$_imagesPath/logo/logo.png';
  static const String logoWhite = '$_imagesPath/logo/logo_white.png';
  static const String logoIcon = '$_imagesPath/logo/icon.png';

  // Icons
  static const String iconHome = '$_imagesPath/icons/home.svg';
  static const String iconJobs = '$_imagesPath/icons/jobs.svg';
  static const String iconProfile = '$_imagesPath/icons/profile.svg';
  static const String iconNotification = '$_imagesPath/icons/notification.svg';
  static const String iconSearch = '$_imagesPath/icons/search.svg';
  static const String iconSettings = '$_imagesPath/icons/settings.svg';

  // Illustrations
  static const String onboarding1 =
      '$_imagesPath/illustrations/onboarding_1.png';
  static const String onboarding2 =
      '$_imagesPath/illustrations/onboarding_2.png';
  static const String onboarding3 =
      '$_imagesPath/illustrations/onboarding_3.png';
  static const String emptyState = '$_imagesPath/illustrations/empty_state.png';
  static const String errorState = '$_imagesPath/illustrations/error_state.png';
  static const String successState =
      '$_imagesPath/illustrations/success_state.png';
  static const String noInternet = '$_imagesPath/illustrations/no_internet.png';

  // Backgrounds
  static const String loginBg = '$_imagesPath/backgrounds/login_bg.png';
  static const String signupBg = '$_imagesPath/backgrounds/signup_bg.png';
  static const String homeBanner = '$_imagesPath/backgrounds/home_banner.png';

  // Animations (Lottie)
  static const String loadingAnimation = '$_animationsPath/loading.json';
  static const String successAnimation = '$_animationsPath/success.json';
  static const String errorAnimation = '$_animationsPath/error.json';
  static const String emptyAnimation = '$_animationsPath/empty.json';
  static const String splashAnimation = '$_animationsPath/splash.json';

  // Splash v2
  static const String _splashPath = 'assets/v2/splash';
  static const String splashPattern1 = '$_splashPath/Pattern.webp';
  static const String splashPattern2 = '$_splashPath/Pattern2.webp';
  static const String splashLogo = '$_splashPath/appLogo.webp';
  static const String splashImage1 = '$_splashPath/image1.webp';
  static const String splashImage2 = '$_splashPath/image2.webp';

  // Fallback to v1 assets (until v2 assets are added)
  static const String v1Logo = 'images/appLogo.png';
  static const String v1LoginBg = 'images/login_bg.png';
  static const String v1ProfileDefault = 'images/profile_default_img.jpg';
  static const String v1Loading = 'assets/animations/loading.json';
  static const String v1Success = 'assets/animations/Success animation.json';
}
