Profile: FhircastSyncErrorOperationOutcome
Parent:  OperationOutcome
Id: fhircast-operation-outcome-syncerror
Title: "OperationOutcome for sync-error events"
Description: """
Defines the structure of OperationOutcomes to be used in sync-error events. The content of the 
OperationOutcomes contains information that is used to determine the cause of the sync-error. 
"""
* insert SetWorkgroupFmmAndStatusRule( #inm, 4, #active)
* issue MS
* issue 1..*
* issue ^slicing.rules = #open
* issue ^slicing.ordered = false   // can be omitted, since false is the default
* issue ^slicing.description = "FHIRcast specific information"
* issue ^slicing.discriminator.type = #value
* issue ^slicing.discriminator.path = "code"
* issue contains fhircast 1..1
* issue[fhircast].code = #processing
* issue[fhircast].details 1..1 MS
* issue[fhircast].details.coding ^slicing.discriminator.type = #value
* issue[fhircast].details.coding ^slicing.discriminator.path = "system"
* issue[fhircast].details.coding ^slicing.rules = #open
* issue[fhircast].details.coding ^slicing.ordered = false   // can be omitted, since false is the default
* issue[fhircast].details.coding ^slicing.description = "Detailed information on syncerror cause."
* issue[fhircast].details.coding 3..*
* issue[fhircast].details.coding contains eventid 1..1 and eventname 1..1 and subscribername 1..1
* issue[fhircast].details.coding[eventid].system = "https://fhircast.hl7.org/events/syncerror/eventid"
* issue[fhircast].details.coding[eventid].code ^short = "The event id of the related event."
* issue[fhircast].details.coding[eventname].system = "https://fhircast.hl7.org/events/syncerror/eventname"
* issue[fhircast].details.coding[eventname].code ^short = "The event eventname of the related event."
* issue[fhircast].details.coding[subscribername].system = "https://fhircast.hl7.org/events/syncerror/subscribername"
* issue[fhircast].details.coding[subscribername].code ^short = "The subscribername of the subscriber causing the event."
* issue[fhircast].diagnostics 1..1 MS
* issue[fhircast].diagnostics ^short = "This field SHALL contain a human readable description of the source and reason for the error."

Profile: FhircastHubSyncErrorOperationOutcome
Parent:  FhircastSyncErrorOperationOutcome
Id: fhircast-hub-operation-outcome-syncerrror
Title: "OperationOutcome for Hub generated sync-error events"
Description: """
Defines the structure of an OperationOutcome to be used in sync-error events created by the Hub.
"""
* insert SetWorkgroupFmmAndStatusRule( #inm, 4, #active)
* issue[fhircast].severity = #warning

Profile: FhircastSubscriberSyncErrorOperationOutcome
Parent:  FhircastSyncErrorOperationOutcome
Id: fhircast-subscriber-operation-outcome-syncerrror
Title: "OperationOutcome for Subscriber generated sync-error events"
Description: """
Defines the structure of an OperationOutcome to be used in sync-error events send by a Suscriber indicting refusal 
to follow context.
"""
* insert SetWorkgroupFmmAndStatusRule( #inm, 4, #active)
* issue[fhircast].severity = #warning

Instance: FhircastHubSyncErrorOperationOutcome-Example
InstanceOf: FhircastHubSyncErrorOperationOutcome
Usage: #example
Description: "Example OperationOutcome as present in sync-error events"
* issue[fhircast]
  * severity = #warning
  * code = #processing
  * diagnostics = "Subscriber Acme Product could not be reached."
  * details
    * coding[+]
      * system = "https://fhircast.hl7.org/events/syncerror/eventid"
      * code = #fdb2f928-5546-4f52-87a0-0648e9ded065
    * coding[+] 
      * system = "https://fhircast.hl7.org/events/syncerror/eventname"
      * code = #Patient-open
    * coding[+]
      * system = "https://fhircast.hl7.org/events/syncerror/subscribername"
      * code = #"Acme Product"
    * coding[+] = http://example.com/events/syncerror/your-error-code-system#"FHIRcast sync error"


Instance: FhircastSubscriberSyncErrorOperationOutcome-Example
InstanceOf: FhircastSubscriberSyncErrorOperationOutcome
Usage: #example
Description: "Example OperationOutcome as present in sync-error events"
* issue[fhircast]
  * severity = #warning
  * code = #processing
  * diagnostics = "Acme Product refused to follow context"
  * details
    * coding[+]
      * system = "https://fhircast.hl7.org/events/syncerror/eventid"
      * code = #fdb2f928-5546-4f52-87a0-0648e9ded065
    * coding[+] 
      * system = "https://fhircast.hl7.org/events/syncerror/eventname"
      * code = #Patient-open
    * coding[+]
      * system = "https://fhircast.hl7.org/events/syncerror/subscribername"
      * code = #"Acme Product"
    * coding[+] = http://example.com/events/syncerror/your-error-code-system#"FHIRcast sync error"

