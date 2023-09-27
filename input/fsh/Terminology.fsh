CodeSystem: FHIRcastCodeSystem
Id: fhircast-codesystem
Title: "FHIRcast related Terminology."
Description: """
    This codesystem defines terminology that is used within the FHIRcast specification.
"""
* #logout-reason "Codes related to why a logout event is send" 
    "Defines the reason a Subscriber sends a logout event."
  * #user-requested "User requests logout"
        "The user requests all Subscribers should logout."
  * #system-shutdown "System shutdown triggered"
        "The system of the Subscriber is shutting down and the Subscriber requests all Subscribers to log-out."
  * #unspecified "A reason with no corresponding code."
        "Logout request without a formally defined code. Implementers SHOULD extend the ValueSet instead of using this code."
  * #unknown "An unknown reason."
        "Logout due to a reason that is unknown."
  