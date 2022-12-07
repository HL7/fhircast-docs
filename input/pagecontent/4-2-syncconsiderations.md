<img src="Info_Simple_bw.svg.png" width="50" height="50"> 
This page contains guidance to implementers and is not part of the [normative-track](2_Specification.html); however, implementers are strongly encouraged to read and understand its content towards successful synchronization.
<p></p><p></p>

FHIRcast describes a mechanism for synchronizing distinct applications. Sometimes things go wrong, and applications fail to synchronize or become out of sync. For example, the user within the EHR opens a new patient's record, but a Subscriber fails to process the update and continues displaying the initial patient.

### Scenarios

Depending upon the expectations of the user and the error handling of the applications in use, this scenario is potentially risky. Identified below are several distinct synchronization scenarios, ranging from lowest level of expected synchronization to highest. Each scenario suggests a level of risk resulting from potential context synchronization failure, based upon the user's ability to distinguish between disparate applications. Implementers must assess and determine the appropriate response to potential synchronization failure given their application's workflows and users.

Also note that synchronization failure is a worst-case scenario and should rarely occur in production.

#### Machine-to-machine-to-machine: Different machines, different times

**Scenario**: Clinician walks away from her desktop EHR and accesses an app on her mobile device which synchronizes to the EHR's hibernated session.

{:.grid}
| Consideration | Risk |
|---------------|------|
|Synchronization failure significance | low |
|Performance expectations|negligible|
|User inability to distinguish between synchronized applications| n/a|

**Summary**: This serial or sequential use-case is a convenience synchronization and the clinical risk for synchronization failure is low.

#### Cross device: Different machines, same time

**Scenario**: Clinician accesses her desktop EHR as well as an app on her mobile device at the same time. Mobile device synchronizes with the EHR desktop session.

{:.grid}
|Consideration|Risk|
|--|--|
|Synchronization failure significance|medium|
|Performance expectations|low|
|User inability to distinguish between synchronized applications|low|

**Summary**: The user clearly distinguishes between the applications synchronized on multiple devices and therefore clinical risk for a synchronization failure depends upon the workflow and implementer's goals. User manual action may be appropriate when synchronization fails.

#### Same machine, same time

**Scenario**: Clinician is accessing two or more applications on the same machine in a single workflow.  

{:.grid}
|Consideration|Risk|
|--|--|
|Synchronization failure significance| medium|
|Performance expectations|high|
|User inability to distinguish between synchronized applications| medium|

**Summary**: Although, the applications are distinguishable from one another, the workflow requires rapidly accessing one then another application. Application responsivity to synchronization is particularly important. Synchronization failure may introduce clinical risk and therefore user notification of synchronization failure is suggested.

#### Embedded apps: Same machine, same time, same UI

**Scenario**: Clinician accesses multiple applications within a single user interface.

{:.grid}
|Consideration|Risk|
|--|--|
|Synchronization failure significance|very high|
|Performance expectations|high|
|User inability to distinguish between synchronized applications|very high|

**Summary**: Disparate applications indistinguishable from one another require the greatest amount of context synchronization. Clinical risk of synchronization failure is critical. Application responsivity to synchronization should be high. Synchronization failure may introduce clinical risk and therefore user notification of synchronization failure is suggested.

#### Multiple machines, multiple synchronized applications, same time

**Scenario**: Clinician accesses multiple applications on different monitors and machines at the same time. Each application fulfills a specific role. A typical example of such set-up is a radiology workstation.

{:.grid}
|Consideration | Risk |
|--|--|
| Synchronization failure significance | very high |
| Performance expectations | high |
| User inability to distinguish between synchronized applications | very high |

**Summary**: Different applications that work together require the greatest amount of context synchronization. Clinical risk of synchronization failure is critical. Application responsivity to synchronization should be high. Synchronization failure may introduce clinical risk and therefore user notification of synchronization failure is likely required.

### Synchronization error situations

FHIRcast is based on a subscription model where each Subscriber receives notifications of the updated state of the topic to which the Subscriber is subscribed. There is no explicit requirement for a Subscriber to follow the context of another Subscriber. The subscription model also implies that it is the Subsribers' responsibility to maintain a contextual synchronization or to notify end users whenever the contextual synchronization is lost.
However, as noted in above scenarios, there may be risk associated with the end user expectation of having two tightly synchronized applications if they fall out of sync.

There are in some cases good reasons for a Subscriber not to follow the subscribed context and this section will outline some of the recommended approaches.

#### Blocking action on Subscriber preventing context synchronization

Many applications go into edit mode or start a modal dialog that locks the system from changing context without user intervention. Examples can be when modifying texts, reports, annotating images or performing administrative tasks. The application may then decline to follow the context of the topic to which the Subscriber is subscribed to prevent loss of end user data.

{:.grid}
|System|Failure mode|Possible actions|
|--|--|--|
| Subscriber | Modal dialog open in UI, unable to change case without losing end user data | Present end user with clear indication that contextual synchronization is lost. Respond with a http status code of 409 conflict. |
| Subscriber | Unable to change context | Respond with a http status code of 409 conflict. |
| Subscriber | Ask user whether context can be changed, user refuses. | The Subscriber responds to the initial event with a 202 Accepted and sends a `syncerror` when the context change is refused, stating the source and reason for change. |
| Subscriber | Ask user whether context can be changed, user does not react in time. | The Subscriber responds to the initial event with a 202 Accepted. When the user does not respond within 10 second,  it sends a `syncerror`. Context change is refused, stating the source and reason for change. |
| Hub | One of the Subscribers cannot follow context | Update all Subscribers with a syncerror event |

#### Failure of Subscriber preventing context synchronization

Although not intended, applications do fail. In this case the event is received by the Subscriber, but some internal error prevents the Subscriber from processing the event.

{:.grid}
|System|Failure mode|Possible actions|
|--|--|--|
| Subscriber | Internal error state prevents processing of the event. | If possible, present end user with clear indication that contextual synchronization is lost. Respond with a http status code of 50X. |
| Hub | One of the Subscribers cannot follow context | Update all Subscribers with syncerror event using information from the subscriber.name field from the original subscription of the Subscriber which failed to follow the context change. |

#### Connection is lost

This error scenario is the Hub losing contact with a Subscriber. This may be due to a Subscriber crash or a network failure. In these cases, the Subscriber would not be aware of the fact that the context has changed or that the context change events are not received.  To mitigate this situation, Subscribers are recommended to register for `heartbeat` events.

{:.grid}
|System|Failure mode|Possible actions|
|--|--|--|
| Subscribing Client | No event received from Hub within the heartbeat time-out. | Present a clear indication to the end-user that the connection has been lost. Resubscribe to the topic. If supported by the Hub, receive [current context upon resubscription](2-4-Subscribing.html#current-context-notification-upon-successful-subscription) or retrieve the context manually  using [Get Current Context](2-9-GetCurrentContext.html).  |

| Hub | Subscriber failed to respond to an event | Update all Subscribers with a syncerror event using information from the `subscriber.name` field from the original subscription of the Subscriber which failed to respond to an event |

#### Race condition during launch

Once an application is launched with initial context, for example, the currently in context patient, the application must subscribe before it receives notifications of updated context. Between the instant of launch and the instant of a confirmed subscription, it is technically possible for context to change, such that the newly launched application joins a session with stale contextual information. In most scenarios, this problem is likely noticeable by the end user. This error situation is mitigated by the Hub sending the last relevant event(s) when a Subscriber (re)subscribes.

#### `syncerror` event received from Hub

In the scenarios where the Hub is aware of a synchronization error, it is advisable for the Hub to signal this to all Subscribers to minimize any patient risk associated with having one or more Subscribers out of sync.

{:.grid}
| System | Failure mode | Possible actions |
|--|--|--|
| Subscriber | syncerror event received from Hub | Present end user with clear indication that contextual synchronization is lost |

#### Subscription has expired

The Subscriber's subscription has expired causing it no longer receive event. The Subscriber can prevent this situation by resubscribing before the subscription expires.

{:.grid}
| System | Failure mode | Possible actions |
|--|--|--|
| Subscriber | Subscription has expired | Present a clear indication to the end-user that the subscription has expired. Resubscribe to the topic. If supported by the Hub, receive [current context upon resubscription](2-4-Subscribing.html#current-context-notification-upon-successful-subscription) or retrieve the context manually using [Get Current Context](2-9-GetCurrentContext.html). 

| Hub | None | The hub cannot distinguish between an intentional and unintentional subscription expiration. So the Hub cannot mitigate this situation.|

#### Race condition between context changes

Two or more Subscribers are sending context change events shortly after each other causing the events to cross.

{:.grid}
| System | Failure mode | Possible actions |
|--|--|--|
| Subscriber | Receive older events | Ensure that the timestamp is checked and that events older than the event that triggered the current context state are ignored. |
| Subscriber | Conflicting events | When a Subscriber detects an event with a suggested context change that is sent shortly after its own event, it should compare the timestamp of these events and treat the most recent event as current. It should also not respond with a resend of its context change without querying the user to prevent triggering an endless context switch waterfall. |
| Hub | None | The Hub cannot and should not be involved in distinguishing between an intentional and unintentional event expiration. So the Hub cannot mitigate this situation. |

#### Synchronization considerations for userLogout, userHibernate

Most synchronization failure considerations revolve around the possibility of introducing incorrect information into the clinical decision making process. In addition to these considerations, failures to synchronize userLogout and userHibernate events must also take into consideration the risk of unsecured, unattended health applications, risking data breach and user impersonation.

Distinct scenarios, related to userLogout and userHibernate:

1. User logs out of application A, then takes action in application B.
Negligible risk. User does not expect synchronization.
2. User hibernates application A, then takes action in application B.
Negligible risk. User does not expect synchronization.
3. Application A automatically hibernates without user action, user takes action in application B.
Application A should consider reacting to events when hibernated; perhaps with a syncerror.
4. User logs out of application A, walks away from workstation, application B remains open and unsecured.
Negligible risk. Per typical application security best practices, applications should automatically secure following a period of un-use. Following an automatic secure, user remains logged into application B. 
5. User hibernates application A, walks away from workstation, application B remains open and unsecured.
Negligible risk. Per typical application security best practices, application should automatically secure following a period of un-use.

### Re-establishing sync

The situations in which a sync error can occur are indicated in the previous section. Once a sync error situation occurs, applications need to be able to recover from it.

#### Subscribers that initiate a context change

A Subscriber that initiates a context change and receives a `syncerror` related to a context change event it sent, SHOULD resend this event at regular intervals until sync is reestablished or another, newer, event has been received. It is recommended to wait at least 10 seconds before resending the event. Note that such resend will use the timestamp of the original event to prevent race conditions.

#### Subscriber that follow context change

A Subscriber that follows context change should monitor new events or re-sends of the old event. When an event is received with a timestamp equal or newer than the event that caused the `syncerror`, it assumes sync is restored unless a new `syncerror` is received.

#### Subscriber that lose the connection to the Hub

Subscriber that lose the connection to the Hub should resubscribe to the topic. Once resubscribed and the most recent relevant event has been received, the Subscriber can assume that sync is restored.

#### Hubs

A Hub that sends a `syncerror` event (e.g. after it is not able to deliver an event) may resend this event regularly until the sync has been reestablished or a newer event has been received.

### Open topics

* Should a Subscriber get all syncerror's or only those related to events to which it subscribed?
* Does a Hub send an `syncerror` for each Subscriber that cannot be reached or refused, or is the Hub allowed to combine them in one.
* When the Hub/Subscriber resends an context change event, is the `heartbeat` still needed?
