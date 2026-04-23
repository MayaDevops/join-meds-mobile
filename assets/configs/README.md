# Join Meds - Dynamic Forms Configuration

This directory contains all JSON configurations for the dynamic forms system.

## 📁 Files Overview

### Configuration Files (12 professions)
- ✅ `doctor_config.json` - Doctor (MBBS)
- ✅ `nurse_config.json` - Nurse (B.Sc Nursing, GNM, ANM)
- ✅ `pharmacist_sample.json` - Pharmacist (B.Pharm, Pharm-D, D.Pharm)
- ✅ `lab_technician_config.json` - Lab Technician (B.Sc MLT, DMLT)
- ✅ `anesthesia_technician_config.json` - Anesthesia Technician
- ✅ `dentist_config.json` - Dentist (BDS)
- ✅ `physiotherapy_config.json` - Physiotherapy (BPT, DPT)
- ✅ `audiologist_config.json` - Audiologist
- ✅ `dietitian_config.json` - Dietitian
- ✅ `clinical_psychologist_config.json` - Clinical Psychologist
- ✅ `social_worker_config.json` - Social Worker
- ✅ `hospital_administrator_config.json` - Hospital Administrator

### Utility Files
- `generate_configs.py` - Python script to generate profession configs
- `upload_to_firebase.js` - Node.js script to upload configs to Firebase
- `package.json` - NPM dependencies for upload script
- `universities_sample.json` - Sample universities list (80 universities)
- `FIREBASE_UPLOAD_GUIDE.md` - Comprehensive upload instructions
- `README.md` - This file

## 🚀 Quick Start

### 1. Generate Configs (Already Done)

All configs have been generated. If you need to regenerate:

```bash
python3 generate_configs.py
```

### 2. Upload to Firebase

#### Prerequisites
1. Install Node.js dependencies:
```bash
npm install
```

2. Download Firebase service account key:
   - Go to Firebase Console → Project Settings → Service Accounts
   - Click "Generate New Private Key"
   - Save as `serviceAccountKey.json` in this directory

3. Update database URL in `upload_to_firebase.js`:
```javascript
const DATABASE_URL = 'https://YOUR_PROJECT_ID.firebaseio.com';
```

#### Run Upload
```bash
npm run upload
```

### 3. Upload Universities List

Use Firebase Console to import `universities_sample.json` to:
```
join_meds_JSON/universities/india/
```

### 4. Set Database Rules

In Firebase Console → Realtime Database → Rules:

```json
{
  "rules": {
    "join_meds_JSON": {
      ".read": true,
      ".write": false
    }
  }
}
```

## 📊 Configuration Structure

Each profession config follows this structure:

```json
{
  "version": "1.0.0",
  "profession": {
    "id": "doctor",
    "displayName": "Doctor",
    "courseTypes": ["mbbs"],
    "icon": "medical_services",
    "description": "Medical professional"
  },
  "flows": {
    "mbbs": {
      "flowId": "mbbs",
      "displayName": "MBBS",
      "steps": [
        {
          "stepId": "academic_status",
          "stepType": "cardSelection",
          "title": "Academic Status",
          "fields": [...],
          "navigation": {...},
          "apiConfig": {...}
        }
      ]
    }
  },
  "sharedDataPaths": {
    "universities": "universities/india"
  }
}
```

## 🔧 Supported Field Types

- `cardSelection` - Large card UI for status selection
- `radio` - Radio button options
- `dropdown` - Searchable dropdown (supports 700+ universities)
- `text` - Text input with validation
- `date` - Date picker with constraints
- `grid` - Grid layout for specializations
- `dynamicList` - Repeating sections (work experience)

## 🌐 Firebase Structure

```
join_meds_JSON/
├── professions/
│   ├── doctor/
│   ├── nurse/
│   ├── pharmacist/
│   └── ... (9 more)
└── universities/
    └── india/
        ├── 0: "AIIMS, New Delhi"
        ├── 1: "CMC Vellore"
        └── ... (700+ more)
```

## ✅ Testing Checklist

After upload:

- [ ] Navigate to `/profession-selection-v2` in app
- [ ] Select a profession
- [ ] Verify form loads from Firebase
- [ ] Test all field types render correctly
- [ ] Test conditional navigation
- [ ] Verify universities dropdown loads
- [ ] Test form submission
- [ ] Check offline caching works
- [ ] Test all 12 professions

## 📝 Profession Details

| Profession | ID | Courses | Steps | Size |
|-----------|-------|---------|-------|------|
| Doctor | doctor | 1 | 4 | 11K |
| Nurse | nurse | 3 | 3-4 | 25K |
| Pharmacist | pharmacist | 3 | 3 | 8K |
| Lab Technician | lab_technician | 2 | 3 | 14K |
| Anesthesia Tech | anesthesia_technician | 2 | 3 | 14K |
| Dentist | dentist | 1 | 3 | 6K |
| Physiotherapy | physiotherapy | 2 | 3 | 14K |
| Audiologist | audiologist | 2 | 3 | 14K |
| Dietitian | dietitian | 2 | 3 | 14K |
| Clinical Psych | clinical_psychologist | 2 | 3 | 14K |
| Social Worker | social_worker | 2 | 3 | 14K |
| Hospital Admin | hospital_administrator | 2 | 3 | 14K |

**Total:** 12 professions, 24 course types, ~155K of JSON config

## 🔗 Navigation Flow

All professions follow this general pattern:

1. **Academic Status** → Choose ongoing or completed
2. **Degree/Diploma Details** → Select year and university
3. **PG Specialization** (if applicable) → Select specialization
4. **Work Experience** (optional, skippable) → Add work history
5. **Country Preference** → Next step (handled by old flow)

## 🎯 Next Steps

1. **Test Dynamic Forms:**
   - Run app: `flutter run`
   - Navigate to: `/profession-selection-v2`
   - Test all professions

2. **Phase 7 - End-to-End Testing:**
   - Test complete user flows
   - Verify API submissions
   - Test offline mode
   - Check error handling

3. **Phase 8 - Feature Flags:**
   - Add feature toggle
   - Gradual rollout per profession
   - Monitor analytics

## 📚 Documentation

- See `FIREBASE_UPLOAD_GUIDE.md` for detailed upload instructions
- See `../lib/src/features/dynamic_forms/README.md` for code architecture

## 🐛 Troubleshooting

**Config not loading:**
- Check Firebase rules allow read access
- Verify profession ID matches exactly
- Check Firebase Console for uploaded data

**Field not rendering:**
- Verify field type is valid
- Check field config matches schema
- Look for console errors

**Universities not loading:**
- Verify universities uploaded to `join_meds_JSON/universities/india/`
- Check dataSource path in field config

## 🤝 Contributing

To add a new profession:

1. Create config JSON following the structure
2. Add to `configFiles` array in `upload_to_firebase.js`
3. Run `npm run upload`
4. Add profession to `ProfessionSelectionV2Screen`
5. Test the complete flow

---

**Status:** ✅ All configs generated and ready for upload
**Last Updated:** 2026-01-01
