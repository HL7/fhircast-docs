# UserSession

This is a draft of the UserSession FHIR resource. The below will be superceded by the version officially published by HL7.

## Resource Structure

| Name | Flags | Cardinality | Type | Description & Constraints |
|------|-------|-------------|------|---------------------------|
|identifier | S | 0..* | Identifier | An identifier for this session |
|user | S | 1 | Reference(Practitioner, Patient, RelatedPerson) | The user engaged in the session. Based upon the description of the Person resource in the FHIR spec, I don't think that including person makes sense. |
|status | | 0..1 | BackboneElement | Status of the session. |
|status -> value | S | 1..1 | code | activating &#124; active &#124; suspended &#124; closing &#124; closed +  http://hl7.org/fhir/ValueSet/usersession-status-value |
|status -> source| | 1..1 | code | user &#124; system + 	http://hl7.org/fhir/ValueSet/usersession-status-source   This is intended to be used to prevent infinite loops in bi-directional context synchronization scenarios. |
|workstation | | 0..1 | CodeableConcept | Location that identifies the physical place at which the user's session is occurring. For the purposes of context synchronization, this is intended to represent the user's workstation.|
|focus | | 1..* | Reference(any) | The current focus of the user's session. Common values are a reference to a Patient, Encounter, ImagingStudy, etc. |
|created | | 0..1 | instant | When the session was first created.|
|expires | | 0..1 |instant | When the session will expire. |
|context | | 0..* | BackboneElement | Additional information about the session. (This follows the pattern established in AuditEvent.entity.detail).|
|context -> type | | 1..1 || string | Name of the property.|
|context -> value | | 1..1 | string | Value of the property.|



## Compartments

UserSession can belong to the following defined [compartments](https://www.hl7.org/fhir/compartmentdefinition.html):

* Patient - An instance of a UserSession resource can belong to a Patient compartment either as the user or the focus of UserSession.
* Encounter - A UserSession resource instance often will have a focus of an encounter.
* RelatedPerson - a UserSession resource instance belongs to a RelatedPerson compartment, when the user of the UserSession is a RelatedPerson.
* Practitioner - a UserSession resource instance belongs to a Practitioner compartment, when the user of the UserSession is a Practitioner.


##ValueSets
### usersession-status-value

* Value set http://hl7.org/fhir/ValueSet/usersession-status-value
* Defining URL:	http://hl7.org/fhir/ValueSet/usersession-status-value
* Name:	UserSessionStatusValue
* Definition	The status of the UserSession as a whole
* Committee:	FHIR-I?
* OID	

|Code | Display	Definition |
|-----|--------------------|
|activating | Activating | The session is about to be in use. If a user is defined on the resource, the user is actively engaged in the application, at the indicated location.|
|active | Active | The session is currently in use. If a user is defined on the resource, the user is actively engaged in the application, at the indicated location.|
|suspended | Suspended | The session was previously active and will become active again at an unknown point in the future. |
|closing | Closing | The session was active and is transitioning to closed. |
|closed | Closed | The session was previously active and will never again become active.|


###usersession-status-value
* Value set http://hl7.org/fhir/ValueSet/usersession-status-source
* Defining URL:	http://hl7.org/fhir/ValueSet/usersession-status-source
* Name:	UserSessionStatusSource
* Definition	The source of the current status of the UserSession. This is intended to be used to prevent infinite loops in bi-directional context synchronization scenarios.
* Committee:	FHIR-I?
* OID	

|Code | Display	Definition |
|-----|--------------------|
|active | Active | The session is currently in use. If a user is defined on the resource, the user is actively engaged in the application, at the indicated location.|
|suspended | Suspended | The session was previously active and will become active again at an unknown point in the future. |
|closed | Closed | The session was previously active and will never again become active.|
