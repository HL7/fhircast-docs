Instance: FHIRcastR4bContainerTopicTopic
InstanceOf: SubscriptionTopic
* id =  "fhircast-r4b-container-update-topic"
* url = "http://hl7.org/fhir/uv/fhircast/r5/SubscriptionTopic/container-update-topic"
* title = "R4b Subscribe to container changes in a topic"
* description = """
  Requests a topic and an anchor-type to be set.   
  Sends updates when content in the Container of the anchor of a type 
  anchor-type for the specified topic changes.
  """
* status = #active
* canFilterBy[+]
  * description = "filters to events for a specific topic"
  * filterParameter = "topic"
  * modifier = #exact
* canFilterBy[+]
  * description = "filters to events for a specific anchor type"
  * filterParameter = "anchor-type"
  * modifier = #exact

Instance: FHIRcastR4bContainerResourceTopic
InstanceOf: SubscriptionTopic
* id = "r4b-fhircast-r4b-container-update-resource"
* url = "http://hl7.org/fhir/uv/fhircast/r5/SubscriptionTopic/container-update-resource"
* title = "R4b Subscribe to container changes of an resource"
* description = """
  Requests an anchor-type and anchor-id to be set.   
  Sends updates when content in the Container of the anchor of a type 
  anchor-type with the id anchor-id changes.
  """
* status = #active
* canFilterBy[+]
  * description = "filters to events for a specific anchor type"
  * filterParameter = "anchor-type"
  * modifier = #exact
* canFilterBy[+]
  * description = "filters to events for a specific anchor (type and id))"
  * filterParameter = "anchor-id"
  * modifier = #exact

// Instance: FHIRcastR4bContainerResourceTopic
// InstanceOf: SubscriptionTopic
// * url = "http://fhircast.hl7.org/container-update/resource"
// * title = "FHIRcast container updates when content in a container changes"
// * description = ""
// * resourceTrigger.canFilterBy[+}.searchParamName = "anchor-type"
// * resourceTrigger.canFilterBy[=}.searchModifier = "eq"
// * resourceTrigger.canFilterBy[=}.documentation = "filters to events for a specific anchor type"
// * resourceTrigger.canFilterBy[+}.searchParamName = "anchor-id"
// * resourceTrigger.canFilterBy[=}.searchModifier = "eq"
// * resourceTrigger.canFilterBy[=}.documentation = "filters to events for a specific anchor (type and id))"

// Instance: FHIRcastR4bContainerTopicTopic
// InstanceOf: SubscriptionTopic
// * url = "http://fhircast.hl7.org/container-update/topic"
// * title = "FHIRcast container updates when content in the current anchor of a type for a topic changes"
// * description = ""
// * resourceTrigger.canFilterBy[+}.searchParamName = "topic"
// * resourceTrigger.canFilterBy[=}.searchModifier = "eq"
// * resourceTrigger.canFilterBy[=}.documentation = "filters to events for a specific topic"
// * resourceTrigger.canFilterBy[+}.searchParamName = "anchor-type"
// * resourceTrigger.canFilterBy[=}.searchModifier = "eq"
// * resourceTrigger.canFilterBy[=}.documentation = "filters to events for a specific anchor type"

// Instance: FHIRcastR4bContainerResourceTopic
// InstanceOf: SubscriptionTopic
// * url = "http://fhircast.hl7.org/container-update/resource"
// * title = "FHIRcast container updates when content in a container changes"
// * description = ""
// * resourceTrigger.canFilterBy[+}.searchParamName = "anchor-type"
// * resourceTrigger.canFilterBy[=}.searchModifier = "eq"
// * resourceTrigger.canFilterBy[=}.documentation = "filters to events for a specific anchor type"
// * resourceTrigger.canFilterBy[+}.searchParamName = "anchor-id"
// * resourceTrigger.canFilterBy[=}.searchModifier = "eq"
// * resourceTrigger.canFilterBy[=}.documentation = "filters to events for a specific anchor (type and id))"
