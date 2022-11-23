
The hybrid approach supports both content exchange models.

The figure below illustrates this approach.

<figure>
  {% include ContentExchangeHybrid.svg %}
  <figcaption><b>Figure: FHIRcast deployment supporting -update and FHIR based content exchange</b></figcaption>
</figure>

The FHIR server and FHIRcast Hub are linked.

The FHIRcast Hub SHALL send `-update` events to Subscribers of such events when a resource in the [Container](5_glossary.html) of the Anchor Resource of one of its active Topic changes in the FHIR server.

The FHIR server SHALL be updated based on the transaction information in a `-update` event.

A FHIR server MAY support one of the following FHIRcast specific `SubscriptionTopics`:

* *[topic-based](SubscriptionTopic-FhirCastContainerTopicTopic.html)*, subscribes to content changes in the container for an anchor in the indicated topic.
* *[resource-based](SubscriptionTopic-FhirCastContainerResourceTopic.html)*, subscribes to content changes in the container for an anchor with a specific id.
