// in this page. Classes are created for receiving
// organisation sign Up data where user type in it

// for organisation Name
class OrganisationNameData {
  static final OrganisationNameData _instance =
      OrganisationNameData._internal();
  factory OrganisationNameData() => _instance;
  OrganisationNameData._internal();

  // Global variable
  String organisationName = '';
}

// for Company's Registered Location
class OrganisationRegisteredLocation {
  static final OrganisationRegisteredLocation _instance =
      OrganisationRegisteredLocation._internal();
  factory OrganisationRegisteredLocation() => _instance;
  OrganisationRegisteredLocation._internal();

  String organisationLocation = '';
}

// for organisation Email
class OrganisationOfficialEmail {
  static final OrganisationOfficialEmail _instance =
      OrganisationOfficialEmail._internal();
  factory OrganisationOfficialEmail() => _instance;
  OrganisationOfficialEmail._internal();

  String organisationEmail = '';
}

// for organisation Incorporation Number
class OrganisationIncorporationNumber {
  static final OrganisationIncorporationNumber _instance =
      OrganisationIncorporationNumber._internal();
  factory OrganisationIncorporationNumber() => _instance;
  OrganisationIncorporationNumber._internal();

  String organisationIncorporationNo = '';
}

class OrganisationPhoneNumber {
  static final OrganisationPhoneNumber _instance =
  OrganisationPhoneNumber._internal();
  factory OrganisationPhoneNumber() => _instance;
  OrganisationPhoneNumber._internal();

  String organisationPhoneNumber = '';
}
