Profile: FHIRcastImagingStudyOpen
Parent: ImagingStudy
Id: fhircast-imaging-study-open
Title: "FHIRcast ImagingStudy for Open Events"
Description:
"""
Provides guidance as to which ImagingStudy attributes should be present and considerations as to how each attribute should be valued in all [FHIR resource]-open events.

At least one business identifier of the ImagingStudy SHALL be provided in a [FHIR resource]-open request.  Two business identifiers are typically associated with an image study.  Imaging systems such as a PACS viewer, advanced visualization workstation, etc. typically identify an image study by its DICOM Study Instance UID (which in DICOM is identified with a (0020,000D) tag).  Likewise, information systems often identify an image study through the accession number of the order which triggered the image procedure to be performed.

The Study Instance UID SHALL be included as a business identifier if it is known.  In FHIR, the Study Instance UID of an ImagingStudy is provided in the `identifier` array using the identifier system of `urn:dicom:uid` and prefixing the UID value with `urn:oid:`.

The accession number SHALL be included as a business identifier if it is known.

**FHIR R4 versus FHIR R5**

Relative to FHIR R4, the ImagingStudy resource's change relevant to FHIRcast is the guidance FHIR R5 provides in specifying the accession number.  In FHIR R4, the guidance is to provide the accession number in the `identifier` array.  In FHIR R5, the accession number is provided in the ImagingStudy's `basedOn` array as a reference using a ServiceRequest reference type.

Since this version of FHIRcast promotes the use of FHIR R4 resources, the guidance to provide the accession number in the `identifier` array SHOULD be used and this approach is shown in all ImagingStudy examples in the FHIRcast specification.  However, if Subscribers agree to use FHIR R5 resources, the FHIR R5 recommendation MAY be used.

For a more detailed explanation of these business identifiers, see the [FHIR R4 implementation notes of the FHIR ImagingStudy resource](https://hl7.org/fhir/R4B/imagingstudy.html) (and the [FHIR R5 implementation notes of the FHIR ImagingStudy resource](https://hl7.org/fhir/R5/imagingstudy.html)). Ideally both the accession number and Study Instance UID are available and present in an ImagingStudy resource used in FHIRcast.  The presence of both business identifiers ensures that all Subscribers will be able to be able to identify the appropriate imaging study.
"""
* id 1..1 
* id ^short = "A logical id of the resource must be provided."
* id ^definition =
"""
A logical id of the resource SHALL be provided. It may be the `id` associated with the resource as persisted in a FHIR server.  If the resource is not stored in a FHIR server, the Subscriber requesting the context change SHOULD use a mechanism to generate the `id` such that it will be globally unique (e.g., a [UUID](https://en.wikipedia.org/wiki/Universally_unique_identifier)).  When a [FHIR resource]-close event including this image study is requested, the Subscriber requesting the context be closed SHALL use the same ImagingStudy resource `id` which was provided in the [FHIR resource]-open event (see also [FHIRcast ImagingStudy for Close Events](StructureDefinition-fhircast-imaging-study-close.html)).
"""

// This identifier attribute documentation shows the FHIR R4 approach and should be removed when the FHIRcast specification transitions to R5 or above
* identifier 1..*
* identifier ^short = "At least one business identifier of the ImagingStudy SHALL be provided in a [FHIR resource]-open request (see this event's detailed description for more information)."
* identifier ^definition = 
"""
The Study Instance UID SHALL be included as a business identifier if it is known.  In FHIR, the Study Instance UID of an ImagingStudy is stored in the `identifier` array using the identifier system of `urn:dicom:uid` and prefixing the UID value with `urn:oid:`.

The accession number of the order which triggered the image procedure to be performed SHALL be included as a business identifier if it is known.  The accession number is provided using the “ACSN” identifier type.
"""
// The indentifier sequence below should be used and with 0..* when FHIRcast transitions to FHIR R5 or above since it would be valid to provide only the accession number in the basedOn array
// * identifier 0..*
// * identifier ^short = "At least one business identifier of the ImagingStudy SHALL be provided in a [FHIR resource]-open request (see this event's detailed description for more information)."
// * identifier ^definition = 
// """
// The Study Instance UID SHALL be included as a business identifier if it is known.  In FHIR, the Study Instance UID of an ImagingStudy is stored in the `identifier` array using the identifier system of `urn:dicom:uid` and prefixing the UID value with `urn:oid:`.
// """

* status 1..1
* status ^short = "Status of the ImagingStudy, note this may not be known and hence have a value of `unknown`; however, `status` is included since it is required by the FHIR standard"
* subject 1..1
* subject only Reference(FHIRcastPatientOpen or Device or Group)
* subject ^short = "Reference to the Patient resource associated with the ImagingStudy (see detailed description if the image study's subject is not a patient)"
* subject ^definition =
"""
A reference to the FHIR Patient resource describing the patient whose imaging study is currently in context.  A patient SHALL be present if there is a patient associated with the study.  Note there are rare cases in which the ImagingStudy.subject references a resource which is not a patient; for example a calibration study.  A reference to the related non-Patient subject of the study SHALL be present in the ImagingStudy resource as it is required by the FHIR specification but is not required to be present in the [FHIR resource]-open event's context.  For example, a reference to a Device resource could be provided as the subject (note, if no FHIR Device FHIR resource instance is available it is allowed to provide only a `display` value in the `reference`) but not provided in the FHIRcast event's `context` array.
"""
// The basedOn sequence below should be used when FHIRcast transitions to FHIR R5 or above
// * basedOn 0..1
// * basedOn ^short = "At least one business identifier of the ImagingStudy SHALL be provided in a [FHIR resource]-open request (see detailed description)."
// * basedOn ^definition =
// """
// The accession number of the order which triggered the image procedure to be performed SHALL be included as a business identifier if it is known.  The accession number is provided as Reference.identifier using the ServiceRequest Reference type and the “ACSN” identifier type.  The ServiceRequest SHALL be the only entry in the `basedOn` array.
// """

Instance: FHIRcastImagingStudyOpen-Example
InstanceOf: FHIRcastImagingStudyOpen
Usage: #example
Description: "Example of an imaging study which could be used in a [FHIR resource]-open event"
* id = "e25c1d31-20a2-41f8-8d85-fe2fdeac74fd"
* status = http://terminology.hl7.org/fhir/ValueSet/imagingstudy-status#unknown

* identifier[0].system = "urn:dicom:uid"
* identifier[=].value = "urn:oid:1.2.840.83474.8.231.875.3.15.661594731"

// This identifier slice shows the FHIR R4 approach and should be removed when the FHIRcast specification transitions to R5 or above
* identifier[+].type.coding = http://terminology.hl7.org/CodeSystem/v2-0203#ACSN
* identifier[=].system = "urn:oid:2.16.840.1.113883.19.5"
* identifier[=].value = "GH339884"
* identifier[=].assigner = Reference(FHIRcastSampleHealthcareProvider)
* identifier[=].assigner.display = "My Healthcare Provider"

* subject = Reference(FHIRcastPatientOpen-Example)

// FHIR R5 Example should use the below for providing an accession number value
// * basedOn[0].type = "ServiceRequest"
// * basedOn[=].identifier.type.coding = http://terminology.hl7.org/CodeSystem/v2-0203#ACSN
// * basedOn[=].identifier.system = "urn:oid:2.16.840.1.113883.19.5"
// * basedOn[=].identifier.value = "GH339884"
// * basedOn[=].identifier.assigner.reference = "Organization/a92ac1be-fb34-49c1-be58-10928bd271cc"
// * basedOn[=].identifier.assigner.display = "My Healthcare Provider"