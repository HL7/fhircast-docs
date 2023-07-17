Profile: FHIRcastR4ImagingStudyOpen
Parent: ImagingStudy
Id: fhircast-r4-imaging-study-open
Title: "R4 FHIRcast ImagingStudy for Open Events"
Description:
"""
Provides guidance as to which ImagingStudy attributes should be present and considerations as to how each attribute should be valued in all [FHIR resource]-open events.

At least one business identifier of the ImagingStudy SHALL be provided in a [FHIR resource]-open request.  Two business identifiers are typically
associated with an image study.  Imaging systems such as a PACS viewer, advanced visualization workstation, etc. typically identify an image study
by its DICOM Study Instance UID, which in DICOM is identified with a (0020,000D) tag.  Likewise information systems often identify an image study through
the accession number of the order which triggered the image procedure to be performed.

The Study Instance UID SHALL be included as a business identifier if it is known.  In FHIR, the Study Instance UID of an ImagingStudy is provided
in the `identifier` array using the Identifier system of `urn:dicom:uid` and prefix the UID value with `urn:oid:`.

The accession number SHALL be included as a business identifier if it is known.  In FHIR, the accession number is provided in the ImagingStudy's `basedOn` array as a
reference using a ServiceRequest reference type and the “ACSN” identifier type.

For a more detailed explanation of these business identifiers, see the [implementation notes of the FHIR ImagingStudy resource](https://hl7.org/fhir/imagingstudy.html).
Ideally both the accession number and Study Instance UID are available and present in an ImagingStudy.  The presence of both business identifiers ensures that
all Subscribers will be able to be able to identify the appropriate ImagingStudy.
"""
* ^fhirVersion = #5.0.0
* id 1..1 
* id ^short = "A logical id of the resource must be provided."
* id ^definition =
"""
A logical id of the resource SHALL be provided. It may be the `id` associated with the resource as persisted in a FHIR server.
If the resource is not stored in a FHIR server, the Subscriber requesting the context change SHOULD use a mechanism to generate
the `id` such that it will be globally unique (e.g., a [UUID](https://en.wikipedia.org/wiki/Universally_unique_identifier)).
When a [FHIR resource]-close event including this image study is requested, the Subscriber requesting the context be closed SHALL use
the same ImagingStudy `id` which was provided in the [FHIR resource]-open event (see also
[FHIRcast ImagingStudy for Close Events](StructureDefinition-fhircast-imaging-study-close.html)).
"""
* identifier 0..*
* identifier ^short = "At least one business identifier of the ImagingStudy SHALL be provided in a [FHIR resource]-open request (see detailed description)."
* identifier ^definition = 
"""
The Study Instance UID SHALL be included as a business identifier if it is known.  In FHIR, the Study Instance UID of an ImagingStudy is stored
in the `identifier` array using the Identifier system of `urn:dicom:uid` and prefix the UID value with `urn:oid:`.
"""
* status 1..1
* status ^short = "Status of the ImagingStudy, note this may not be known and hence have a value of `unknown`; however, `status` is included since it is required by FHIR"
* subject 1..1
* subject only Reference(FHIRcastR4PatientOpen or Device or Group)
* subject ^short = "Reference to the Patient resource associated with the ImagingStudy (see detailed description if the image study's subject is not a patient)"
* subject ^definition =
"""
A reference to the FHIR Patient resource describing the patient whose imaging study is currently in context.  A patient SHALL be present if there is a patient associated with the study.
Note there are rare cases in which the ImagingStudy.subject references a resource which is not a patient; for example a calibration study.  A reference to the related non-Patient subject of the study SHALL
be present in the ImagingStudy resource as it is required by the FHIR specification but is not required to be present in the [FHIR resource]-open event's context.  For example,
a reference to a Device resource could be provided as the subject (note, if no FHIR Device FHIR resource instance is available it is allowed to provide only a `display` value in the `reference`).
"""
* basedOn 0..1
* basedOn ^short = "At least one business identifier of the ImagingStudy SHALL be provided in a [FHIR resource]-open request (see detailed description)."
* basedOn ^definition =
"""
The accession number of the order which triggered the image procedure to be performed SHALL be included as a business identifier if it is known.  The accession number is
stored as Reference.identifier using the ServiceRequest Reference type and the “ACSN” identifier type.  The ServiceRequest SHALL be the only entry in the `basedOn` array.
"""

Instance: FHIRcastR4ImagingStudyOpen-Example
InstanceOf: FHIRcastR4ImagingStudyOpen
Usage: #example
Description: "Example of an imaging study which could be used in a [FHIR resource]-open event"
* id = "r4-e25c1d31-20a2-41f8-8d85-fe2fdeac74fd"
* status = http://terminology.hl7.org/fhir/ValueSet/imagingstudy-status#unknown
* identifier[0].system = "urn:dicom:uid"
* identifier[=].value = "urn:oid:1.2.840.83474.8.231.875.3.15.661594731"
* subject = Reference(FHIRcastR4PatientOpen-Example)
* basedOn[0].type = "ServiceRequest"
* basedOn[=].identifier.type.coding = http://terminology.hl7.org/CodeSystem/v2-0203#ACSN
* basedOn[=].identifier.system = "urn:oid:2.16.840.1.113883.19.5"
* basedOn[=].identifier.value = "GH339884"
* basedOn[=].identifier.assigner.reference = "Organization/a92ac1be-fb34-49c1-be58-10928bd271cc"
* basedOn[=].identifier.assigner.display = "My Healthcare Provider"
