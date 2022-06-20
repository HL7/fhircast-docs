<img src="Info_Simple_bw.svg.png" width="50" height="50"> 
This page contains guidance to implementers and is not part of the [normative-track](2_Specification.html). 
<p></p><p></p>

FHIRcast describes a mechanism for synchronizing distinct applications. Sometimes things go wrong, and applications fail to synchronize or become out of sync. For example, the user within the EHR opens a new patient's record, but the app fails to process the update and continues displaying the initial patient.

### Scenarios

Depending upon the expectations of the user and the error handling of the applications in use, this scenario is potentially risky. Identified below are four distinct synchronization scenarios, ranging from lowest level of expected synchronization to highest.
Also note that synchronization failure is a worst-case scenario and should rarely occur in production.
Machine-to-machine-to-machine: Different machines, different times

#### Machine-to-machine-to-machine: Different machines, different times

**Scenario**: Clinician walks away from her desktop EHR and accesses an app on her mobile device which synchronizes to the EHR's hibernated session.

| Consideration | Risk |
|--|--|
|Synchronization failure significance | low |
|Performance expectations|negligible|
|User inability to distinguish between synchronized applications| n/a|

**Summary**: This serial or sequential use-case is a convenience synchronization and the clinical risk for synchronization failure is low.

#### Cross device: Different machines, same time

**Scenario**: Clinician accesses her desktop EHR as well an app on her mobile device at the same time. Mobile device synchronizes with the EHR desktop session.

|Consideration|Risk|
|--|--|
|Synchronization failure significance|medium|
|Performance expectations|low|
|User inability to distinguish between synchronized applications| low|

**Summary**: The user clearly distinguishes between the applications synchronized on multiple devices and therefore clinical risk for a synchronization failure depends upon the workflow and implementer's goals. User manual action may be appropriate when synchronization fails.

#### Same machine, same time

**Scenario**: Clinician is accessing two or more applications on the same machine in a single workflow.  

|Consideration|Risk|
|--|--|
|Synchronization failure significance| medium|
|Performance expectations|high|
|User inability to distinguish between synchronized applications| medium|

**Summary**: Although, the applications applications are distinguishable from one another, the workflow requires rapidly accessing one then another application. Application responsivity to synchronization is particularly important. Synchronization failure may introduce clinical risk and therefore user notification of synchronization failure is suggested.

#### Embedded apps: Same machine, same time, same UI

**Scenario**: Clinician accesses multiple applications within a single user interface.

|Consideration|Risk|
|--|--|
|Synchronization failure significance|very high|
|Performance expectations|high|
|User inability to distinguish between synchronized applications|very high|

**Summary**: Disparate applications indistinguishable from one another require the greatest amount of context synchronization. Clinical risk of synchronization failure is critical. Application responsivity to synchronization should be high. Synchronization failure may introduce clinical risk and therefore user notification of synchronization failure is suggested.

#### Multiple machines, multiple synchronized applications, same time

**Scenario**: Clinician accesses multiple applications on different monitors and machines at the same time. Each application fulfills a specific role. A typical example of such set-up is a radiology workstation.

|Consideration | Risk |
|--|--|
| Synchronization failure significance | very high |
| Performance expectations | high |
| User inability to distinguish between synchronized applications | very high |

**Summary**: Different applications that work together require the greatest amount of context synchronization. Clinical risk of synchronization failure is critical. Application responsivity to synchronization should be high. Synchronization failure may introduce clinical risk and therefore user notification of synchronization failure is required.

### Synchronization error situations

FHIRcast is based on a subscription model where each subscribing client receives notifications of the updated state of the topic being subscribed to. There is no explicit requirement for a subscribing client to follow the context of another client. The subscription model also implies that it is the subscribing clients responsibility to maintain a contextual synchronization or to notify end users whenever the contextual synchronization is lost.
However, as noted in above scenarios, there may be risk associated with the end user expectation of have two tightly synchronized applications if they fall out of sync.

There are in some cases good reasons for a client not to follow the subscribed context and this section will outline some of the recommended approaches.

#### Blocking action on subscribing client preventing context synchronization

Many applications go into edit mode or start a modal dialog that locks the system from changing context without user intervention. Examples can be when modifying texts, reports, annotating images or performing administrative tasks. The clients may then decline to follow the subscribed context to prevent loss of end user data.

|System|Failure mode|Possible actions|
|--|--|--|
| Subscribing Client | Modal dialog open in UI, unable to change case without losing end user data | Present end user with clear indication that contextual synchronization is lost. Respond with a http status code of 409 conflict. |
| Subscribing Client | Unable to change context | Respond with a http status code of 409 conflict|
| Subscribing Client | Ask user whether context can be changed, user refuses. | The Client responds to the initial event with an 202 Accepted and sends a `syncerror` when the context change is refused, stating the source and reason for change. |
| Subscribing Client | Ask user whether context can be changed, user does not react in time. | The Client responds to the initial event with an 202 Accepted. When the user does not respond within 10 second,  it sends a `syncerror` text change is refused, stating the source and reason for change. |
| Hub | One of the subscribing clients cannot follow context | No action/Update all subscribing clients with event syncerror |

#### Failure of subscribing client preventing context synchronization

Although not intended, application do fail. In this case the event is received by the application but some internal error prevents it from processing it.
|System|Failure mode|Possible actions|
|--|--|--|
| Subscribing Client | Internal error state prevents processing of the event. | If possible, present end user with clear indication that contextual synchronization is lost. Respond with a http status code of 50X. |
| Hub | One of the subscribing clients cannot follow context | No action/update all subscribing clients with event syncerror using information from the subscriber.name field in the original subscription. |

#### Connection is lost

This error scenario is all about the Hub losing contact with its subscribing clients. This may be due to a client crash, mis-configured callback URL or simply an underlying network failure. In these cases, the clients are usually not aware of the fact that the context has changed or that the subscription messages are not received.
To mitigate this situation, clients are recommended to register for `heartbeat` events.

|System|Failure mode|Possible actions|
|--|--|--|
| Subscribing Client | No event received from Hub within the heartbeat time-out. | Present a clear indication to the end-user that the connection has been lost. Resubscribe to the topic. The resend relevant event feature will make sure the application will come back into sync. |
| Hub | Timeout or error from client callback URL | No action/Retry/Update all subscribing clients with event syncerror using information from the subscriber.name field in the original subscription. |

#### Race condition during launch

Once an app is launched with initial context, for example, the currently in context patient, the app must subscribe before it receives notifications of updated context. Between the instant of launch and the instant of a confirmed subscription, it is technically possible for context to change, such that the newly launched app joins a session with stale contextual information. In most scenarios, this problem is likely noticeable by the end user. This error situation is mitigated by the hub sending the last relevant event(s) when a client (re)subscribes.

#### `syncerror` event received from Hub

In the scenarios where the Hub is aware of a synchronization error, it is advisable for the Hub to signal this to the subscribing applications to minimize any patient risk associated with having one or many applications out of sync.

| System | Failure mode | Possible actions |
|--|--|--|
| Subscribing Client | Syncerror event received from Hub | Present end user with clear indication that contextual synchronization is lost |

#### Subscription has expired

The client subscription has expired causing it no longer receive event. The application can prevent this by resubscribing before the subscription expires.
| System | Failure mode | Possible actions |
|--|--|--|
| Subscribing Client | Subscription has expired | Present a clear indication to the end-user that the subscription has expired. Resubscribe to the topic. The resend relevant event feature will make sure the application will come back into sync.
| Hub | None | The hub cannot distinguish between an intentional and unintentional subscription expiration. So it cannot mitigate this.|

#### Race condition between context changes

Two or more clients are sending context change event shortly after each other causing the events to cross.
| System | Failure mode | Possible actions |
|--|--|--|
| Subscribing Client | Receive older events | Ensure that the timestamp is checked and that events older than the event that triggered the current context state are ignored. |
| Subscribing Client | Conflicting events | When a client detects an event with a suggested context change that is send shortly after its own event, it should compare the timestamp of these events and treat the most recent event as current. It should also not respond with a resend of its context change without querying the user to prevent triggering an endless context switch waterfall. |
| Hub | None | The hub cannot and should not be involved in distinguishing between an intentional and unintentional event  expiration. So it cannot mitigate this. |

### Re-establishing sync

The situations in which a sync error can occur are indicated in the previous section. Once a sync error situation occurs, applications need to be able to recover from it.

#### Clients that initiate a context change

A Client that initiates a context change and receives a `syncerror` related to a context change event it send, SHOULD resend this event at regular intervals until sync is reestablished or another, newer, event has been received. It is recommended to wait at least 10 seconds before resending the event. Note that such resend will use the timestamp of the original event to prevent race conditions.

#### Clients that follow context change

A Client that follow context change should monitor new events or re-sends of the old event. When an event is received with a timestamp equal or newer than the event that caused the `syncerror`, it shall assume sync is restored unless a new `syncerror` is received.

#### Clients that lose the connection to the hub

These Clients should resubscribe to the hub and topic. Once resubscribed, and the most recent relevant event has been received, the Client can assume that sync is restored.

#### Hubs

A hub that send a `syncerror` event (e.g. as it is not able to deliver an event) MAY resend this event regularly until sync has been reestablished or a newer event has been received.

### Open topics

* Do I get all syncerror's or only those related to events I subscribed to?
* Does a hub send an `syncerror` for each client that cannot be reached or refused or is it allowed to combine them in one.
* When the hub/application resends an context change event, is the `heartbeat` still needed?
