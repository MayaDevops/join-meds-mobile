#!/usr/bin/env python3
"""
Generate JSON configurations for all professions
"""
import json

# Template for professions with degree/diploma pattern
def create_profession_config(profession_id, display_name, icon, course_types, description=""):
    """
    Create a profession configuration
    course_types: list of dicts with keys: id, displayName, years, hasPG (optional)
    """
    flows = {}

    for course in course_types:
        course_id = course['id']
        course_name = course['displayName']
        years = course['years']
        has_pg = course.get('hasPG', False)

        steps = []

        # Step 1: Academic Status
        academic_status_step = {
            "stepId": "academic_status",
            "stepType": "cardSelection",
            "title": "Academic Status",
            "subtitle": "Please select your academic status 🎓",
            "showProgress": True,
            "validateBeforeNavigate": True,
            "fields": [{
                "fieldId": "academicStatus",
                "fieldType": "cardSelection",
                "label": "Select Your Status",
                "required": True,
                "options": [
                    {"value": "ongoing", "label": f"{'Degree' if 'bsc' in course_id or 'b_' in course_id or 'b-' in course_id or 'pharm_d' in course_id or 'mbbs' in course_id or 'bds' in course_id else 'Diploma'} Ongoing", "icon": "menu_book"},
                    {"value": "completed", "label": f"{'Degree' if 'bsc' in course_id or 'b_' in course_id or 'b-' in course_id or 'pharm_d' in course_id or 'mbbs' in course_id or 'bds' in course_id else 'Diploma'} Completed", "icon": "school"}
                ]
            }],
            "navigation": {
                "type": "conditional",
                "rules": []
            },
            "apiConfig": {
                "endpoint": "/api/user-details/update/{userId}",
                "method": "PUT",
                "fieldMapping": {"academicStatus": "academic_status"},
                "successMessage": "Academic status saved",
                "showLoading": True
            }
        }

        # Add navigation rules
        academic_status_step["navigation"]["rules"].append({
            "condition": {"field": "academicStatus", "operator": "equals", "value": "ongoing"},
            "actions": [{"type": "navigate", "nextStep": "degree_ongoing" if 'bsc' in course_id or 'b_' in course_id or 'pharm_d' in course_id or 'mbbs' in course_id or 'bds' in course_id else "diploma_ongoing"}]
        })

        if has_pg:
            academic_status_step["navigation"]["rules"].append({
                "condition": {"field": "academicStatus", "operator": "equals", "value": "completed"},
                "actions": [
                    {
                        "type": "showModal",
                        "modalConfig": {
                            "title": "Are you a Post Graduate?",
                            "fieldId": "postGradStatus",
                            "options": [
                                {"value": "pg_holder", "label": "Yes (PG-Holder)"},
                                {"value": "not_pg_holder", "label": "No (Not-PG-Holder)"}
                            ],
                            "dismissible": True
                        }
                    },
                    {
                        "type": "conditionalNavigate",
                        "condition": {"field": "postGradStatus", "operator": "equals", "value": "pg_holder"},
                        "nextStep": "work_experience"
                    },
                    {
                        "type": "conditionalNavigate",
                        "condition": {"field": "postGradStatus", "operator": "equals", "value": "not_pg_holder"},
                        "nextStep": "work_experience"
                    }
                ]
            })
            academic_status_step["apiConfig"]["fieldMapping"]["postGradStatus"] = "post_grad_status"
        else:
            academic_status_step["navigation"]["rules"].append({
                "condition": {"field": "academicStatus", "operator": "equals", "value": "completed"},
                "actions": [{"type": "navigate", "nextStep": "work_experience"}]
            })

        steps.append(academic_status_step)

        # Step 2: Degree/Diploma Ongoing
        ongoing_step_id = "degree_ongoing" if ('bsc' in course_id or 'b_' in course_id or 'pharm_d' in course_id or 'mbbs' in course_id or 'bds' in course_id) else "diploma_ongoing"
        year_options = [{"value": f"{i} Year", "label": f"{i} Year"} for i in ['1st', '2nd', '3rd', '4th', '5th', '6th'][:years]]

        ongoing_step = {
            "stepId": ongoing_step_id,
            "stepType": "form",
            "title": course_name,
            "subtitle": "Choose your current academic year and university",
            "showProgress": True,
            "validateBeforeNavigate": True,
            "fields": [
                {
                    "fieldId": "academicYear",
                    "fieldType": "radio",
                    "label": "Choose Your Current Year",
                    "required": True,
                    "layout": "wrap",
                    "options": year_options,
                    "apiMapping": "current_year",
                    "validation": {"required": True, "requiredMessage": "Please select your current year"}
                },
                {
                    "fieldId": "university",
                    "fieldType": "dropdown",
                    "label": "University of Education",
                    "hint": "Select University",
                    "required": True,
                    "searchable": True,
                    "dataSource": {"type": "firebase", "path": "universities/india"},
                    "apiMapping": "university",
                    "validation": {"required": True, "requiredMessage": "Please select your university"}
                }
            ],
            "apiConfig": {
                "endpoint": "/api/user-details/update/{userId}",
                "method": "PUT",
                "successMessage": "Academic details saved",
                "showLoading": True
            }
        }
        steps.append(ongoing_step)

        # Step 3: Work Experience (optional, skippable)
        work_exp_step = {
            "stepId": "work_experience",
            "stepType": "form",
            "title": "Work Experience",
            "subtitle": "Please provide your work experience details",
            "showProgress": True,
            "skippable": True,
            "fields": [{
                "fieldId": "experiences",
                "fieldType": "dynamicList",
                "label": "Work Experience",
                "minEntries": 1,
                "maxEntries": 5,
                "addButtonText": "Add More Experience",
                "template": [
                    {
                        "fieldId": "experienceType",
                        "fieldType": "radio",
                        "label": "Type of Experience",
                        "required": True,
                        "layout": "row",
                        "options": [
                            {"value": "Clinical", "label": "Clinical"},
                            {"value": "Non Clinical", "label": "Non Clinical"}
                        ]
                    },
                    {
                        "fieldId": "organisation",
                        "fieldType": "text",
                        "label": "Organisation / Hospital",
                        "hint": "Enter organisation name",
                        "required": True,
                        "validation": {
                            "required": True,
                            "minLength": 3,
                            "pattern": "^[a-zA-Z\\s]+$",
                            "patternMessage": "Enter a valid name using letters and spaces only"
                        }
                    },
                    {
                        "fieldId": "fromDate",
                        "fieldType": "date",
                        "label": "From",
                        "required": True,
                        "validation": {"required": True, "minDate": "1965-01-01", "maxDate": "today"}
                    },
                    {
                        "fieldId": "toDate",
                        "fieldType": "date",
                        "label": "To",
                        "required": True,
                        "validation": {"required": True, "minDate": "1965-01-01", "maxDate": "today"}
                    }
                ]
            }],
            "apiConfig": {
                "endpoint": "/api/work-experience/save",
                "method": "POST",
                "successMessage": "Work experience saved",
                "showLoading": True
            }
        }
        steps.append(work_exp_step)

        flows[course_id] = {
            "flowId": course_id,
            "displayName": course_name,
            "steps": steps
        }

    return {
        "version": "1.0.0",
        "profession": {
            "id": profession_id,
            "displayName": display_name,
            "courseTypes": [c['id'] for c in course_types],
            "icon": icon,
            "description": description or f"{display_name} professional"
        },
        "flows": flows,
        "sharedDataPaths": {"universities": "universities/india"}
    }


# Generate all profession configs
professions = [
    {
        "id": "lab_technician",
        "name": "Lab Technician",
        "icon": "biotech",
        "courses": [
            {"id": "bsc_mlt", "displayName": "B.Sc MLT", "years": 3, "hasPG": False},
            {"id": "dmlt", "displayName": "DMLT", "years": 2, "hasPG": False}
        ]
    },
    {
        "id": "anesthesia_technician",
        "name": "Anesthesia Technician",
        "icon": "medical_services",
        "courses": [
            {"id": "bsc_anesthesia_tech", "displayName": "B.Sc Anesthesia Technology", "years": 3, "hasPG": False},
            {"id": "diploma_anesthesia", "displayName": "Diploma in Anesthesia Technology", "years": 2, "hasPG": False}
        ]
    },
    {
        "id": "physiotherapy",
        "name": "Physiotherapy",
        "icon": "accessibility",
        "courses": [
            {"id": "bpt", "displayName": "BPT (Bachelor of Physiotherapy)", "years": 4, "hasPG": False},
            {"id": "dpt", "displayName": "DPT (Diploma in Physiotherapy)", "years": 2, "hasPG": False}
        ]
    },
    {
        "id": "audiologist",
        "name": "Audiologist",
        "icon": "hearing",
        "courses": [
            {"id": "bsc_audiology", "displayName": "B.Sc Audiology", "years": 3, "hasPG": False},
            {"id": "diploma_audiology", "displayName": "Diploma in Audiology", "years": 2, "hasPG": False}
        ]
    },
    {
        "id": "dietitian",
        "name": "Dietitian",
        "icon": "restaurant",
        "courses": [
            {"id": "bsc_dietetics", "displayName": "B.Sc Dietetics", "years": 3, "hasPG": False},
            {"id": "diploma_dietetics", "displayName": "Diploma in Dietetics", "years": 2, "hasPG": False}
        ]
    },
    {
        "id": "clinical_psychologist",
        "name": "Clinical Psychologist",
        "icon": "psychology",
        "courses": [
            {"id": "bsc_psychology", "displayName": "B.Sc Clinical Psychology", "years": 3, "hasPG": False},
            {"id": "diploma_psychology", "displayName": "Diploma in Clinical Psychology", "years": 2, "hasPG": False}
        ]
    },
    {
        "id": "social_worker",
        "name": "Social Worker",
        "icon": "volunteer_activism",
        "courses": [
            {"id": "bsw", "displayName": "BSW (Bachelor of Social Work)", "years": 3, "hasPG": False},
            {"id": "diploma_social_work", "displayName": "Diploma in Social Work", "years": 2, "hasPG": False}
        ]
    },
    {
        "id": "hospital_administrator",
        "name": "Hospital Administrator",
        "icon": "business",
        "courses": [
            {"id": "bha", "displayName": "BHA (Bachelor of Hospital Administration)", "years": 3, "hasPG": False},
            {"id": "diploma_hospital_admin", "displayName": "Diploma in Hospital Administration", "years": 2, "hasPG": False}
        ]
    }
]

# Generate and save configs
for prof in professions:
    config = create_profession_config(
        profession_id=prof['id'],
        display_name=prof['name'],
        icon=prof['icon'],
        course_types=prof['courses']
    )

    filename = f"{prof['id']}_config.json"
    with open(filename, 'w') as f:
        json.dump(config, f, indent=2)

    print(f"✓ Created {filename}")

print("\nAll profession configs generated successfully!")
