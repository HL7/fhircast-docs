Profile: FhircastSyncErrorOperationOutcome
Parent:  OperationOutcome
Id: fhircast-operation-outcome-syncerror
Title: "OperationOutcome for sync-error events"
Description: """
Defines the structure of OperationOutcomes to be used in sync-error events. The content of the 
OperationOutcomes contains information that is used to determine the cause of the sync-error. 
"""
* issue MS
* issue 1..*
* issue ^slicing.rules = #open
* issue ^slicing.ordered = false   // can be omitted, since false is the default
* issue ^slicing.description = "FHIRcast specific information"
* issue contains fhircast 1..1
* issue[fhircast].code = #processing
* issue[fhircast].details 1..1 MS
* issue[fhircast].details.coding ^slicing.discriminator.type = #value
* issue[fhircast].details.coding ^slicing.discriminator.path = "coding.system"
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
* issue[fhircast].severity = #information

Profile: FhircastSubscriberSyncErrorOperationOutcome
Parent:  FhircastSyncErrorOperationOutcome
Id: fhircast-subscriber-operation-outcome-syncerrror
Title: "OperationOutcome for Subscriber generated sync-error events"
Description: """
Defines the structure of an OperationOutcome to be used in sync-error events send by a Suscriber indicting refusal 
to follow context.
"""
* issue[fhircast].severity = #warning

