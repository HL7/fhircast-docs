CodeSystem: FHIRcastCodeSystem
Id: fhircast-codesystem
Title: "FHIRcast related Terminology."
Description: """
    This codesystem defines terminology that is used within the FHIRcast specification.
"""
* ^experimental = false
* ^caseSensitive = true
* #user-initiated "User initiated action."
      "The user initiated the action."
* #system-initiated "System initiated action"
      "The system on which the Subscriber running is initiating the action."
  * #system-timeout: "Automated logout due to user inactivity"
      "System initiated logout. Implies that system will reasonably be available in the near future."
  * #system-downtime: "Temporarily unavailable due to system maintenance"
      "System initiated logout. Implies that additional processing of messages will likely fail."
  * #system-error: "System encountered error resulting logging out the user. System is unavailable."
      "System initiated logout. Implies that additional processing of messages will fail."
