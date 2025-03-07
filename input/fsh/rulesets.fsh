RuleSet: SetWorkgroupFmmAndStatusRule ( wg, fmm, status )
* ^extension[http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm].valueInteger = {fmm}
* ^extension[http://hl7.org/fhir/StructureDefinition/structuredefinition-wg][+].valueCode = {wg}
* ^status = {status}