{% include infonote.html text='This page contains guidance to implementers and is not part of the <a href="2_Specification.html">normative-track.</a>' %}


### Considerations for application with simultaneous contexts

Just as a modern Web browser supports multiple pages loaded, but only a single in active use at a given time, some healthcare applications support multiple, distinct patient charts loaded even though only a single chart is interacted with at a given time. Other applications in healthcare may only support a single patient (or study or ...) context being loaded in the application at a given time. It's important to be able to synchronize the context between two Subscribers supporting these different behaviors. For convenience, we refer to these two types of application behavior as "multi-tab" and "single tab".

### Single and Multiple Tab Applications

Applications can have different capabilities and layouts, but with FHIRcast they should still be able to stay in sync. A potential situation that could cause confusion is when a single and a multi-tab application work together. While the below guidance describes a patient chart as the primary concept for synchronization, the same guidance applies for other concepts.  

Let's start with a simple case.

#### Opening and Closing a Patient

The diagrams below show two applications without any context, followed by a `Patient-open` event communicated to the other application resulting in same patient being opened in the receiving application. When the patient is closed, a `Patient-close` event is triggered leading to the patient being closed in the other application as well.

{% include img.html img="PatientOpenAndClose.png" caption="Figure: Simple patient open and close example" %}

#### Opening Multiple Patients

As illustrated below, context synchronization is maintained between multiple and single-tabbed applications even across multiple contexts being opened. The initial `Patient-open` works as expected by synchronizing the two applicationss for Patient 1. When the multi-tab application opens a second patient (without closing the first) the single-tab application follows the context change, resulting in the applications staying in sync. Even when the user is working within the multi-tab application, the single-tab application can still stay in sync with the current context.

{% include img.html img="MultiplePatientOpens.png" caption="Figure: Multiple patient open example" %}

### Considerations with the [Get Current Context](2-9-GetCurrentContext.html) Operation

Multiple contexts may be present in the Hub; however, only one of these contexts is the current context.  Specifically, the context for which the last `-open` event has occurred is the current context.  This is the context returned by the Hub when a Subscriber calls the [Get Current Context](2-9-GetCurrentContext.html) operation. In the above example, Patient 1 and Patient 2 contexts exist simultaneously; however, Patient 2 was last opened therefore is the current context.  If, as in the above example, the Patient 2 context is closed there exists no current context (see the specification in [Get Current Context](2-9-GetCurrentContext.html)).  It is the responsibility of some Subscriber to make an `-open` request for Patient 1 in order for Patient 1 to become the current context.  The FHIRcast specification indicates that there is no current context without an `-open` event; hence, in the absence of an `-open` event after a `-close` occurs, the behavior expected of applications is not defined.

### Considerations on Maintaining Multiple Contexts

The specification deliberatively prescribes maintaining contexts for which an `-open` event has occurred but no `-close` event.  The rationale for this approach is driven by:

*  Applications may expend considerable network and compute resources to display information indicated by an open context.  Retrieving this information upon each `-open` that would occur if the user frequently switches tabs (as in the above examples) would require the application incur that expense on each tab switch.  By explicitly stating that a context which was opened but which has not been closed is considered to remain present in the Hub, applications so choosing can reflect this behavior in their business logic and UI.  When a `-close` event occurs, applications should reflect this state as is appropriate to the application's requirements.  In the above example, when Patient 2 is closed applications chose to remove the tab related to Patient 2.  If both Patient 1 and Patient 2 `-open` events have occurred (in that order), a subsequent Patient 1 open would not cause applications to remove the Patient 2 tab rather indicate that Patient 1 is now the current context.
*  When applications are participating in a content sharing session, maintaining multiple open contexts means that Hubs and participating applications retain the content state of open contexts.  Content state is released only upon a `-close` of the anchor context in which the content sharing is taking place.  This avoids substantial application overhead and coordination.

Recall that the multi-tab example is only one scenario in which the multiple contexts approach is valid.  Another scenario would be if a user has opened multiple imaging studies and is frequently changing between the studies which were opened.  The network and compute resource consumption for opening and reopening imaging studies is significant and may be avoided with the multiple context approach.  Applications may decide to support only a single context, in which case they would imply a close __in their application__ upon receiving an `-open` event.  A subsequent `-open` event for the context which they implicitly closed would require that application to retrieve the necessary resources related to this context.

### Considerations on Applications Issuing `-close` Events

Upon closing of an application or the user choosing to close a subject, the application with which the user is interacting has the choice to send or not send a `-close` event for the current context.  Typically making this decision is appropriate when an application knows it is being driven by another application; for example, when another application is providing some type of worklist functionality.

Often an application knowing that it is being driven by an external actor removes the ability for users to close a subject; for example, an imaging application could assume that an external actor is responsible for the closing of subjects and remove the UI element(s) enabling a user to close the current image study.  However, an application may choose to retain this capability.  When the capability to close subjects is retained, the application could decide to not send a `-close` event if it considers this close to be local to itself.  If an application decides not to send a `-close` event, to ensure a consistent context for the user, the application should not establish a new local context without receiving or sending an `-open` event.

### Recommendations

* When synchronizing with a multi-tab application, receiving multiple, sequential `-open` events (for example, `Patient-open`) does not indicate a synchronization error.
* Multi-tab applications should differentiate between the closing versus inactivating of contexts, by not communicating the inactivation of a context through a `-close` event.
* Single-tab applications should not send a `-close` event as the result of receiving subsequent `-open` events, unless the intent is to limit all applications in the session to a single "tab"
* Multi-tab applications should consider closing all contexts between disconnecting and re-subscribing to prevent "orphaning" a tab.

### Launching A Context-Less Tab

Many applications can have a "home" or "default" tab that contains no clinical context, but may hold useful application features. In some cases other applications may want to subscribe to and be notified when another application has switched to the no context tab.

Since we are inherently representing the lack of context, the event will not fully conform to the defined event naming syntax and will instead use a static name (similar to `UserLogout.html`).
