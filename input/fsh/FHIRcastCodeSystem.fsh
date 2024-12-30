CodeSystem: FHIRcastCodeSystem
Id: fhircast-codesystem
Title: "FHIRcast related Terminology."
Description: """
    This codesystem defines terminology that is used within the FHIRcast specification.
"""
* ^experimental = false
* ^caseSensitive = true
* ^version = "0.1.0"
* ^status = #active
* ^extension[0].url = "http://hl7.org/fhir/StructureDefinition/structuredefinition-wg"
* ^extension[0].valueCode = #inm
* #user-initiated "User initiated action."
      "The user initiated the action."
* #system-timeout "System initiated action due to timeout"
      "The system on which the Subscriber running has reached a pre-specified length of inactivity such that it is initiating the logout."
* #system-initiated "System initiated action"
      "The system on which the Subscriber running is initiating the action for a reason other than timeout."
