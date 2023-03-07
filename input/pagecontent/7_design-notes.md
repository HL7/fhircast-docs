This section contains various design decisions that might be relevant to understand the FHIRcast specification.

### Remove `webhook` channel

Originally, FHIRcast supported a `webhook` channel (URL callbacks). As part of FHIRcast STU3, support for `webhooks` was removed in favor of `websockets` as the single communication method.

The field `hub.channel.type` was used to indicate the channel type to use for event notification. This field has been retained in order to support backward compatibility as well as facilitate potentially adding new channels in the future.

Similarly, the conformance statement related to websocket support was retained.

### Content sharing approach

Two base use cases for content-exchange were identified during use case analysis. One employs a transactional, event-based exchange mechanism while the second uses content sharing content persisted in a FHIR server. It is also possible to use both methods concurrently. A detailed description of these approaches is found in the content sharing section of the specification.
