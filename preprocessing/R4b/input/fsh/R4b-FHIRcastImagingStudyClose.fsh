Profile: FHIRcastR4bImagingStudyClose
Parent: ImagingStudy
Id: fhircast-r4b-imaging-study-close
Title: "FHIRcast R4b ImagingStudy for Close Events"
Description:
"""
Provides guidance as to which ImagingStudy attributes should be present and considerations as to how each attribute should be valued in all [FHIR resource]-close events.

It is recommended that the image study business identifiers provided in the corresponding [FHIR resource]-open event are provided in the [FHIR resource]-close event.  Providing
these business identifiers enables Subscribers to perform identity verification according to their requirements.  See [FHIRcast ImagingStudy for Open Events](StructureDefinition-fhircast-imaging-study-open.html)
for details on the business identifiers of an ImagingStudy.
"""
* id 1..1 
* id ^short = "A logical id of the resource must be provided."
* id ^definition =
"""
A logical id of the resource must be provided. The provided `id` SHALL be the same ImagingStudy resource id which was provided in the corresponding [FHIR resource]-open event (see also
[FHIRcast ImagingStudy for Open Events](StructureDefinition-fhircast-imaging-study-open.html)).
"""
* identifier 0..*
* identifier ^short = "At least one business identifier of the ImagingStudy SHOULD be provided in a [FHIR resource]-close request (see detailed description)."
* identifier ^definition = 
"""
The Study Instance UID SHOULD be included as a business identifier if it is known.  If a Study Instance UID was provided in the corresponding
[FHIR resource]-open event, then the same Study Instance UID SHOULD be provided in the corresponding [FHIR resource]-close event.
"""
* status 1..1
* status ^short = "Status of the ImagingStudy, note this may be not be known and hence have a value of `unknown`; however, `status` is included since it is required by the  FHIRcast "
* subject 1..1
* subject only Reference(FHIRcastR4bPatientClose or Device or Group)
* subject ^short = "Reference to the Patient resource associated with the ImagingStudy (see detailed description if the image study's subject is not a patient)"
* subject ^definition =
"""
A reference to the FHIR Patient resource describing the patient associated with the imaging study being closed.  Note there are rare cases in which the ImagingStudy subject references a resource
which is not a patient.  Regardless, the subject reference present in the corresponding [FHIR resource]-open event SHALL be provided in the [FHIR resource]-close event.
"""
* basedOn 0..1
* basedOn ^short = "At least one business identifier of the ImagingStudy SHOULD be provided in a [FHIR resource]-open request (see detailed description)."
* basedOn ^definition =
"""
The accession number of the order which triggered the image procedure to be performed SHOULD be included as a business identifier if it is known.  If an accession number was provided
in the corresponding [FHIR resource]-open event, then the same accession number SHOULD be provided in the corresponding [FHIR resource]-close event.
"""

Instance: FHIRcastR4bImagingStudyClose-Example
InstanceOf: FHIRcastR4bImagingStudyClose
Usage: #example
Description: "Example of an imaging study which could be used in a [FHIR resource]-close event.  Note that due to limitation of tools used to publishing the specification, the below
resource `id` is appended with '-close'.  The specification requires that the resource `id` in the [FHIR resource]-close be identical to the resource `id` provided in the corresponding [FHIR resource]-open;
hence in the real world the '-close' suffix would not be present."
* id = "r4b-e25c1d31-20a2-41f8-8d85-fe2fdeac74fd-close"
* status = http://terminology.hl7.org/fhir/ValueSet/imagingstudy-status#unknown
* identifier[0].system = "urn:dicom:uid"
* identifier[=].value = "urn:oid:1.2.840.83474.8.231.875.3.15.661594731"
* subject = Reference(FHIRcastR4bPatientClose-Example)
* basedOn[0].type = "ServiceRequest"
* basedOn[=].identifier.type.coding.system = http://terminology.hl7.org/CodeSystem/v2-0203#ACSN
* basedOn[=].identifier.system = "urn:oid:2.16.840.1.113883.19.5"
* basedOn[=].identifier.value = "GH339884"
* basedOn[=].identifier.assigner.reference = "Organization/a92ac1be-fb34-49c1-be58-10928bd271cc"
* basedOn[=].identifier.assigner.display = "My Healthcare Provider"
