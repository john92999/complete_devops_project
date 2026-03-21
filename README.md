📬 AWS SQS — Complete Beginner's Guide

> **Simple Queue Service explained from zero — what it is, why it exists, how it works, and how to use it**

---

📖 Table of Contents
What is a Queue? (Real Life First)
What is AWS SQS?
Why Do We Need SQS?
Core Concepts — Every Term Explained
Types of Queues
How SQS Works — Step by Step
SQS Message — What Does It Look Like?
Visibility Timeout — The Most Important Concept
Dead Letter Queue (DLQ)
SQS vs SNS vs EventBridge — What is the Difference?
Creating a Queue — Step by Step (AWS Console)
Using SQS with AWS CLI
Using SQS with Python (boto3)
Using SQS with Java
Real World Use Cases
SQS Pricing
Common Errors and Fixes
Quick Reference Card

---

1. What is a Queue? (Real Life First)
   Before touching AWS, understand what a queue is in real life.
   Example 1 — McDonald's Counter

```
Customers (Producers)          Queue (Waiting Line)       Kitchen (Consumers)

  👤 Customer 1  ──────▶  [ Order1 | Order2 | Order3 ]  ──────▶  👨‍🍳 Chef
  👤 Customer 2  ──────▶                                           processes
  👤 Customer 3  ──────▶                                           one by one
```

Customers place orders (produce messages) at their own speed
Orders wait in a queue if the kitchen is busy
The kitchen processes orders (consumes messages) one at a time
If the kitchen is slow, orders pile up in the queue — but nothing is lost
If a chef is sick, other chefs can still pick up orders from the same queue
Example 2 — Post Office

```
You (Sender)                  Post Box (Queue)           Post Office (Receiver)

Write letter    ──────▶   📬 [ Letter1 ]   ──────▶   Opens when ready
Drop it in                    [ Letter2 ]               Processes at own pace
Walk away                     [ Letter3 ]               You don't wait around
```

Key insight: You don't stand there waiting for the post office to process your letter. You drop it and leave. The post office processes it when it can. This is called asynchronous communication.
Without a Queue (Synchronous) vs With a Queue (Asynchronous)

```
WITHOUT QUEUE (Synchronous):
─────────────────────────────
App A  ──── calls ────▶  App B
App A  ◀─── waits ────── App B is processing...
App A  ◀─── waits ────── App B still processing...
App A  ◀─── waits ────── App B crashed! ❌
App A  FAILS TOO because it was waiting

WITH QUEUE (Asynchronous):
──────────────────────────
App A  ──── sends message ────▶  [ Queue ]  ◀──── App B reads when ready
App A  continues doing           message      App B processes it
       other work  ✅            is safe      App B crashes → message
                                              stays in queue → retry ✅
```

---

2. What is AWS SQS?
   AWS SQS (Simple Queue Service) is a fully managed message queue service provided by Amazon Web Services.
   "Fully managed" means:
   AWS runs the servers for you
   AWS handles failures, scaling, and maintenance
   You never install or manage queue software
   You just CREATE a queue and START USING it
   In One Line
   > SQS lets one part of your application **send a message** and another part **receive that message** — without both parts needing to be running at the same time.
   > What SQS Guarantees

```
┌─────────────────────────────────────────────────────────────────┐
│                    SQS GUARANTEES                               │
├─────────────────────────────────────────────────────────────────┤
│  ✅  Messages are NOT lost (stored redundantly in AWS)          │
│  ✅  Messages are delivered AT LEAST once                       │
│  ✅  Scales automatically (1 message or 1 billion messages)     │
│  ✅  Highly available (99.9% uptime SLA)                        │
│  ✅  Secure (encrypted at rest and in transit)                  │
│  ✅  No message size limit beyond 256KB per message             │
└─────────────────────────────────────────────────────────────────┘
```

---

3. Why Do We Need SQS?
   Problem 1 — What if the Receiver is Down?

```
SCENARIO: Your app sends an email after every purchase

WITHOUT SQS:
Purchase happens
    │
    ▼
App calls Email Service directly
    │
    ▼
Email Service is DOWN ❌
    │
    ▼
Purchase FAILS too! Customer can't buy. 😱

WITH SQS:
Purchase happens
    │
    ▼
App sends message to SQS Queue ✅
    │
Queue stores the message safely
    │
    ▼
Email Service is DOWN ❌ ... comes back UP ✅
    │
Email Service reads from queue
    │
    ▼
Email is sent! Customer is happy. 😊
Purchase never failed.
```

Problem 2 — What if Traffic Spikes Suddenly?

```
SCENARIO: Flash sale — 100,000 orders in 1 minute

WITHOUT SQS:
100,000 requests ──▶ Database ──▶ Database CRASHES 💥
                                  All orders LOST ❌

WITH SQS:
100,000 requests ──▶ SQS Queue ──▶ Database reads at its pace
                     (stores all)   10 orders/second... slowly
                                    All 100,000 processed ✅
                                    Nothing lost ✅
```

This is called load levelling — SQS absorbs the spike.
Problem 3 — Slow Tasks Blocking Fast Tasks

```
SCENARIO: User uploads a photo, app resizes it to 10 different sizes

WITHOUT SQS:
User uploads photo
    │
    ▼
App resizes all 10 sizes (takes 30 seconds)
    │
User WAITS 30 seconds staring at loading spinner 😡

WITH SQS:
User uploads photo
    │
    ▼
App sends "resize this photo" message to SQS
    │
Response: "Upload successful!" (in 0.1 seconds) 😊
    │
SEPARATELY: Worker reads from queue, resizes photo in background
User gets notification when done
```

---

4. Core Concepts — Every Term Explained
   4.1 Producer
   The sender of messages. Any application, service, or script that puts messages INTO the queue.

```
Examples of producers:
- Your web app sending an order notification
- A payment service sending "payment received" event
- A cron job sending "generate report" command
- AWS Lambda triggered by an API call
```

4.2 Consumer
The receiver of messages. Any application or service that reads messages FROM the queue and processes them.

```
Examples of consumers:
- An email service reading "send email" messages
- A worker process resizing uploaded images
- A database updater reading "update record" commands
- AWS Lambda triggered by SQS events
```

4.3 Message
The data sent through the queue. A message is just text (usually JSON) that carries information.

```json
{
  "orderId": "ORD-12345",
  "customerId": "CUST-789",
  "items": ["item1", "item2"],
  "totalAmount": 59.99,
  "timestamp": "2024-01-15T10:30:00Z"
}
```

Limits:
Maximum size: 256 KB per message
For larger data: store in S3 and send the S3 link in the message
4.4 Queue
The waiting room where messages sit until a consumer reads them.

```
Queue characteristics:
- Has a unique URL (like a postal address)
- Messages stay in queue until consumed OR until retention period expires
- Default retention: 4 days
- Maximum retention: 14 days
- You can have MANY producers and MANY consumers per queue
```

4.5 Queue URL
Every SQS queue has a unique URL. This is how you identify and talk to it:

```
https://sqs.ap-south-1.amazonaws.com/123456789012/my-order-queue
         ↑                           ↑              ↑
    AWS Region               Your Account ID    Queue Name
```

4.6 Message Receipt Handle
When a consumer reads a message, AWS gives it a receipt handle — a temporary ticket proving "I am currently processing this message." Used to delete the message after processing.

```
Think of it like a cloakroom ticket:
- You give your coat (message) to the cloakroom (queue)
- You get a ticket (receipt handle)
- When you want your coat back (delete message), show the ticket
```

4.7 Polling
Consumers don't receive messages automatically — they have to ask for messages (poll the queue).

```
Short Polling (default):
Consumer: "Any messages?"
SQS:      "Nope" (even if messages exist on other servers)
Consumer: "Any messages?"
SQS:      "Yes, here's one!"
Problem:  Lots of empty responses → costs money + wastes time

Long Polling (recommended):
Consumer: "Any messages? I'll wait up to 20 seconds"
SQS:      ... (waits until a message arrives) ...
SQS:      "Yes, here's one!" (after 3 seconds)
Benefit:  Fewer API calls, cheaper, more efficient
```

## Always use Long Polling (WaitTimeSeconds = 20) in production.

5. Types of Queues
   AWS SQS has two types of queues:
   5.1 Standard Queue

```
┌─────────────────────────────────────────────────────────────┐
│                     STANDARD QUEUE                          │
├─────────────────────────────────────────────────────────────┤
│  ✅ Nearly unlimited throughput (unlimited messages/second)  │
│  ✅ At-least-once delivery (message delivered 1 or more)    │
│  ⚠️  Best-effort ordering (order NOT guaranteed)            │
│  ⚠️  Occasional duplicates possible                         │
├─────────────────────────────────────────────────────────────┤
│  USE WHEN:                                                  │
│  - Order doesn't matter                                     │
│  - You can handle duplicates (idempotent processing)        │
│  - You need maximum throughput                              │
│  - Example: sending notifications, resizing images          │
└─────────────────────────────────────────────────────────────┘
```

5.2 FIFO Queue (First In, First Out)

```
┌─────────────────────────────────────────────────────────────┐
│                       FIFO QUEUE                            │
├─────────────────────────────────────────────────────────────┤
│  ✅ Strict ordering (first in = first out, guaranteed)      │
│  ✅ Exactly-once processing (no duplicates ever)            │
│  ⚠️  Limited throughput (3,000 messages/second with batch)  │
│  ⚠️  Slightly more expensive                                │
├─────────────────────────────────────────────────────────────┤
│  USE WHEN:                                                  │
│  - Order is critical                                        │
│  - Duplicates would cause problems                          │
│  - Example: bank transactions, e-commerce orders,           │
│    inventory updates                                        │
│  Note: Queue name MUST end with .fifo                       │
│  Example: my-order-queue.fifo                               │
└─────────────────────────────────────────────────────────────┘
```

Visual Comparison

```
STANDARD QUEUE:
Send order: A, B, C, D
Receive:    B, A, D, C   ← order may differ (but all arrive eventually)
            D, A, A, B   ← duplicates possible

FIFO QUEUE:
Send order: A, B, C, D
Receive:    A, B, C, D   ← always same order, always once
```

---

6. How SQS Works — Step by Step

```
STEP 1 — Producer sends a message
────────────────────────────────────────────────────────────────

 [Your App]  ──── SendMessage API call ────▶  [SQS Queue]
                                                    │
                                          Message stored safely
                                          in AWS (replicated
                                          across multiple servers)


STEP 2 — Message waits in the queue
────────────────────────────────────────────────────────────────

 [SQS Queue]
 ┌────────────────────────────────────────┐
 │  msg1 (age: 2 min)                     │
 │  msg2 (age: 1 min)                     │
 │  msg3 (age: 30 sec)                    │
 └────────────────────────────────────────┘
   Messages sit here until consumed
   OR until retention period expires (max 14 days)


STEP 3 — Consumer polls for messages
────────────────────────────────────────────────────────────────

 [Worker App]  ──── ReceiveMessage API call ────▶  [SQS Queue]
              ◀──── Returns up to 10 messages ──────


STEP 4 — Message becomes invisible (Visibility Timeout)
────────────────────────────────────────────────────────────────

 [SQS Queue]
 ┌────────────────────────────────────────┐
 │  🔒 msg1 (INVISIBLE for 30 seconds)   │  ← msg1 is being processed
 │  msg2 (visible, waiting)              │
 │  msg3 (visible, waiting)              │
 └────────────────────────────────────────┘
   Other consumers CANNOT see msg1 right now
   This prevents two workers from processing the same message


STEP 5a — Processing succeeds → Delete the message
────────────────────────────────────────────────────────────────

 [Worker App]  processes msg1 ✅
               ──── DeleteMessage API call ────▶  [SQS Queue]
                    (uses receipt handle)               │
                                              msg1 PERMANENTLY deleted
                                              from queue


STEP 5b — Processing FAILS → Message becomes visible again
────────────────────────────────────────────────────────────────

 [Worker App]  crashes while processing msg1 ❌
               (never calls DeleteMessage)
                                                   [SQS Queue]
                                                        │
                                           Visibility timeout expires
                                                        │
                                           msg1 becomes VISIBLE again
                                                        │
                                           Another worker picks it up
                                           and tries again ✅
```

---

7. SQS Message — What Does It Look Like?
   When you receive a message from SQS, it comes with this structure:

```json
{
  "MessageId": "abc123-def456-ghi789",
  "ReceiptHandle": "AQEBwJnKyrHigUMZj...very long string...",
  "MD5OfBody": "fafb00f5732ab283681e124bf8747ed1",
  "Body": "{\"orderId\": \"ORD-001\", \"amount\": 59.99}",
  "Attributes": {
    "SenderId": "123456789012",
    "SentTimestamp": "1705312200000",
    "ApproximateReceiveCount": "1",
    "ApproximateFirstReceiveTimestamp": "1705312260000"
  },
  "MessageAttributes": {
    "OrderType": {
      "StringValue": "EXPRESS",
      "DataType": "String"
    }
  }
}
```

What Each Field Means

```
Field                           Meaning
──────────────────────────────────────────────────────────────────
MessageId                       Unique ID assigned by AWS to this message
                                Use for logging/tracking

ReceiptHandle                   Your "claim ticket" for this message
                                Required to DELETE the message
                                Changes every time you receive the message

MD5OfBody                       Checksum — verify message wasn't corrupted

Body                            YOUR ACTUAL DATA (what the producer sent)
                                Always a string — parse JSON from it

Attributes.SentTimestamp        When message was sent (Unix timestamp in ms)

Attributes.ApproximateReceive   How many times this message has been
Count                           received — if > 1, it's being retried
                                (something failed before)

MessageAttributes               Custom metadata you attached to the message
                                Like HTTP headers — extra info without
                                touching the body
```

---

8. Visibility Timeout — The Most Important Concept
   What is Visibility Timeout?
   When a consumer reads a message, SQS hides that message from all other consumers for a set period. This is the Visibility Timeout.
   Why? So two workers don't process the same message simultaneously.
   Visual Explanation

```
Timeline ────────────────────────────────────────────────────────────▶

Message sent to queue
│
▼
[Message VISIBLE in queue]
│
Consumer 1 reads message (ReceiveMessage)
│
▼
[Message INVISIBLE — visibility timeout starts: 30 seconds]
│
├── Consumer 1 processes successfully in 10 seconds
│         │
│         ▼
│   Consumer 1 calls DeleteMessage ✅
│         │
│         ▼
│   Message PERMANENTLY GONE from queue
│   (visibility timeout cancelled)
│
OR
│
├── Consumer 1 crashes after 5 seconds ❌
          │
          ▼
    Visibility timeout expires at 30 seconds
          │
          ▼
    [Message VISIBLE again] ← another consumer can now pick it up
          │
          ▼
    Consumer 2 reads it and retries ✅
```

What Happens if Your Processing Takes Longer Than Visibility Timeout?

```
PROBLEM:
Visibility timeout: 30 seconds
Your processing time: 45 seconds

Timeline:
0s  → Consumer reads message (timeout starts)
30s → Timeout expires! Message becomes VISIBLE again
      Consumer 2 picks up the SAME message ← DUPLICATE PROCESSING!
45s → Consumer 1 finishes and calls DeleteMessage
      Consumer 2 is ALSO processing it ← PROBLEM!

SOLUTIONS:
1. Set visibility timeout HIGHER than your maximum processing time
   Rule of thumb: 6x your average processing time

2. Call ChangeMessageVisibility to extend timeout while processing

3. Design your processing to be IDEMPOTENT
   (same message processed twice = same result, no side effects)
```

Recommended Values

```
Your processing time    →    Set visibility timeout to
────────────────────────────────────────────────────────
< 5 seconds             →    30 seconds
< 30 seconds            →    3 minutes
< 5 minutes             →    30 minutes
< 1 hour                →    6 hours
Very long/unknown       →    Use heartbeat (ChangeMessageVisibility)
```

---

9. Dead Letter Queue (DLQ)
   What is a DLQ?
   A Dead Letter Queue is a separate queue for failed messages — messages that couldn't be processed after several attempts.
   Real Life Analogy
   Think of a post office:
   Normal queue = letters that should be delivered
   Dead Letter Queue = a special bin for letters that couldn't be delivered after 3 attempts (wrong address, recipient moved, etc.)
   Instead of trying forever and blocking the queue, failed messages move to the DLQ where you can:
   Inspect them to understand why they failed
   Fix the bug
   Reprocess them manually
   How DLQ Works

```
NORMAL QUEUE → DLQ (when maxReceiveCount is exceeded)

Normal Queue:
Message arrives
    │
    ▼
Consumer reads it (receive count: 1)
Consumer FAILS ❌
    │
    ▼ (visibility timeout expires)
Consumer reads it again (receive count: 2)
Consumer FAILS ❌
    │
    ▼ (visibility timeout expires)
Consumer reads it again (receive count: 3)
Consumer FAILS ❌
    │
    ▼ maxReceiveCount = 3 exceeded!
Message MOVED to Dead Letter Queue
    │
    ▼
Alert triggered → Developer investigates
```

Setting Up a DLQ

```
Step 1: Create the DLQ first
  Name: my-order-queue-dlq
  (same type as source queue — Standard or FIFO)

Step 2: Configure the source queue to use it
  Source queue: my-order-queue
  Dead-letter queue: my-order-queue-dlq
  Maximum receives (maxReceiveCount): 3
  (move to DLQ after 3 failed attempts)

Step 3: Set up CloudWatch alarm on DLQ
  Alert when: DLQ message count > 0
  So you are notified immediately when something fails
```

What to Do With Messages in DLQ

```
1. INVESTIGATE
   Read the message → understand what data caused the failure
   Check CloudWatch logs → find the error/exception

2. FIX THE BUG
   Deploy a fix to your consumer application

3. REPLAY (move messages back to original queue)
   AWS console: DLQ → "Start DLQ redrive" button
   Or use AWS CLI to move messages back manually
```

---

10. SQS vs SNS vs EventBridge — What is the Difference?
    These three services are often confused. Here is a clear breakdown:

```
┌──────────────┬──────────────────────────┬───────────────────────────────┐
│ Service      │ What it does             │ Use it when...                │
├──────────────┼──────────────────────────┼───────────────────────────────┤
│ SQS          │ Queue — one sender,      │ You want guaranteed delivery  │
│              │ one receiver at a time   │ Worker pools, task queues     │
│              │ Pull-based (poll)        │ Decoupling two services       │
├──────────────┼──────────────────────────┼───────────────────────────────┤
│ SNS          │ Pub/Sub — one sender,    │ You want to notify MANY       │
│              │ MANY receivers at once   │ services at the same time     │
│ (Simple      │ Push-based (immediate)   │ Fan-out: one event →          │
│ Notification │                          │ email + SMS + Lambda + SQS    │
│ Service)     │                          │                               │
├──────────────┼──────────────────────────┼───────────────────────────────┤
│ EventBridge  │ Event bus — complex      │ You want routing rules        │
│              │ routing rules            │ "If event is X, send to Y"   │
│              │ Filter and route events  │ Connecting AWS services       │
└──────────────┴──────────────────────────┴───────────────────────────────┘
```

Common Pattern — SNS + SQS Together (Fan-out)

```
                         ┌──────────────────┐
                         │   SNS Topic      │
                         │  "order-placed"  │
                         └────────┬─────────┘
                 ┌────────────────┼───────────────────┐
                 ▼                ▼                   ▼
        ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
        │  SQS Queue   │  │  SQS Queue   │  │  SQS Queue   │
        │  (email svc) │  │ (inventory   │  │  (analytics  │
        │              │  │  service)    │  │   service)   │
        └──────┬───────┘  └──────┬───────┘  └──────┬───────┘
               ▼                 ▼                  ▼
        [Email Worker]   [Inventory Worker]  [Analytics Worker]

One order → three services notified → each processes independently
```

---

11. Creating a Queue — Step by Step (AWS Console)
    Standard Queue

```
Step 1: Open AWS Console
  → Go to: https://console.aws.amazon.com
  → Search: SQS
  → Click: Simple Queue Service

Step 2: Create Queue
  → Click: "Create queue" (orange button)

Step 3: Configuration
  Type:         Standard
  Name:         my-order-queue

Step 4: Configuration Settings
  Visibility timeout:    30 seconds  (increase if processing takes longer)
  Message retention:     4 days      (how long unread messages stay)
  Maximum message size:  256 KB      (leave as default)
  Delivery delay:        0 seconds   (delay before message is visible)
  Receive message wait:  20 seconds  ← SET THIS! (enables long polling)

Step 5: Dead-letter queue (Optional but recommended)
  Enable: Yes
  Queue:  Create a new DLQ named my-order-queue-dlq first
  Maximum receives: 3

Step 6: Encryption
  SSE type: SQS-managed (SSE-SQS)  ← enables encryption at rest

Step 7: Access Policy
  Leave as default for now
  (restricts who can send/receive messages)

Step 8: Click "Create Queue"

Done! You will see your Queue URL:
https://sqs.ap-south-1.amazonaws.com/123456789012/my-order-queue
```

FIFO Queue

```
Same steps as above, EXCEPT:

Type: FIFO
Name: my-order-queue.fifo    ← MUST end with .fifo

Additional settings:
  Content-based deduplication: Enable
  (SQS auto-detects duplicate messages using message body hash)

  OR use Message Deduplication ID:
  You provide a unique ID per message to prevent duplicates
```

---

12. Using SQS with AWS CLI
    The AWS CLI lets you interact with SQS from your terminal.
    Setup

```bash
# Install AWS CLI (if not already installed)
pip install awscli

# Configure credentials
aws configure
# Enter:
#   AWS Access Key ID: YOUR_KEY
#   AWS Secret Access Key: YOUR_SECRET
#   Default region: ap-south-1
#   Default output format: json
```

Send a Message

```bash
aws sqs send-message \
    --queue-url "https://sqs.ap-south-1.amazonaws.com/123456789012/my-order-queue" \
    --message-body '{"orderId": "ORD-001", "amount": 59.99}'
#   ↑                                                            ↑
#   queue-url: the full URL of your SQS queue                    message-body: your data (any string)

# Response:
# {
#     "MD5OfMessageBody": "...",
#     "MessageId": "abc123-def456"    ← save this for tracking
# }
```

Receive a Message

```bash
aws sqs receive-message \
    --queue-url "https://sqs.ap-south-1.amazonaws.com/123456789012/my-order-queue" \
    --max-number-of-messages 10 \
#   ↑ receive up to 10 messages at once (maximum allowed per call)
    --wait-time-seconds 20
#   ↑ long polling — wait up to 20 seconds for a message to arrive
#     if no messages, returns empty after 20 seconds

# Response:
# {
#     "Messages": [
#         {
#             "MessageId": "abc123",
#             "ReceiptHandle": "AQEBwJnKyrH...",   ← save this!
#             "Body": "{\"orderId\": \"ORD-001\"}"
#         }
#     ]
# }
```

Delete a Message (after processing)

```bash
aws sqs delete-message \
    --queue-url "https://sqs.ap-south-1.amazonaws.com/123456789012/my-order-queue" \
    --receipt-handle "AQEBwJnKyrHigUMZj..."
#   ↑ the receipt handle from the receive-message response
#     without this, message reappears after visibility timeout!
```

Check Queue Attributes (how many messages waiting)

```bash
aws sqs get-queue-attributes \
    --queue-url "https://sqs.ap-south-1.amazonaws.com/123456789012/my-order-queue" \
    --attribute-names All

# Important attributes in response:
# ApproximateNumberOfMessages         → messages waiting to be processed
# ApproximateNumberOfMessagesNotVisible → messages being processed right now
# ApproximateNumberOfMessagesDelayed  → messages with delivery delay
```

Purge a Queue (delete ALL messages)

```bash
aws sqs purge-queue \
    --queue-url "https://sqs.ap-south-1.amazonaws.com/123456789012/my-order-queue"
# WARNING: deletes ALL messages immediately, cannot be undone!
# Can only be called once every 60 seconds
```

---

13. Using SQS with Python (boto3)
    Install boto3

```bash
pip install boto3
```

Producer — Send Messages

```python
import boto3
import json

# Create SQS client
# boto3 automatically reads credentials from:
# 1. Environment variables (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
# 2. ~/.aws/credentials file
# 3. IAM role (if running on EC2/Lambda)
sqs = boto3.client('sqs', region_name='ap-south-1')

QUEUE_URL = 'https://sqs.ap-south-1.amazonaws.com/123456789012/my-order-queue'

def send_order(order_data):
    """
    Send an order message to SQS.
    order_data: a Python dictionary with order details
    """

    # Convert dict to JSON string
    # SQS only accepts strings, not Python objects
    message_body = json.dumps(order_data)

    response = sqs.send_message(
        QueueUrl=QUEUE_URL,
        MessageBody=message_body,

        # Optional: Add metadata without changing the body
        MessageAttributes={
            'OrderType': {
                'StringValue': order_data.get('type', 'STANDARD'),
                'DataType': 'String'
                # DataType options: String, Number, Binary
            },
            'Priority': {
                'StringValue': '1',
                'DataType': 'Number'
            }
        },

        # Optional: delay this specific message
        # (overrides queue-level delay setting)
        DelaySeconds=0
    )

    message_id = response['MessageId']
    print(f"Message sent! ID: {message_id}")
    return message_id


# Example usage
order = {
    'orderId': 'ORD-001',
    'customerId': 'CUST-789',
    'items': ['Laptop', 'Mouse'],
    'totalAmount': 1299.99,
    'type': 'EXPRESS'
}

send_order(order)
```

Send Multiple Messages at Once (Batch)

```python
def send_orders_batch(orders):
    """
    Send up to 10 messages in a single API call.
    Cheaper and faster than sending one by one.
    """
    entries = []
    for i, order in enumerate(orders[:10]):  # max 10 per batch
        entries.append({
            'Id': str(i),                        # unique ID within the batch
            'MessageBody': json.dumps(order),
        })

    response = sqs.send_message_batch(
        QueueUrl=QUEUE_URL,
        Entries=entries
    )

    success_count = len(response.get('Successful', []))
    failed_count = len(response.get('Failed', []))
    print(f"Sent: {success_count}, Failed: {failed_count}")

    # Handle failures
    for failure in response.get('Failed', []):
        print(f"Failed to send message ID {failure['Id']}: {failure['Message']}")
```

Consumer — Receive and Process Messages

```python
import boto3
import json
import time

sqs = boto3.client('sqs', region_name='ap-south-1')
QUEUE_URL = 'https://sqs.ap-south-1.amazonaws.com/123456789012/my-order-queue'

def process_order(order_data):
    """
    Your actual business logic goes here.
    Replace this with your real processing code.
    """
    print(f"Processing order: {order_data['orderId']}")
    print(f"Customer: {order_data['customerId']}")
    print(f"Amount: ${order_data['totalAmount']}")
    # ... your code here ...
    # Simulate some work
    time.sleep(1)
    print(f"Order {order_data['orderId']} processed successfully!")


def poll_and_process():
    """
    Continuously poll SQS and process messages.
    This runs in a loop until interrupted.
    """
    print("Worker started. Polling for messages...")

    while True:  # run forever (or until Ctrl+C)
        try:
            # Step 1: Ask SQS for messages
            response = sqs.receive_message(
                QueueUrl=QUEUE_URL,

                MaxNumberOfMessages=10,
                # ↑ receive up to 10 messages per call (max allowed)
                #   processing them in batch is more efficient

                WaitTimeSeconds=20,
                # ↑ LONG POLLING — wait up to 20 seconds
                #   if no messages, SQS waits before returning empty
                #   this reduces API calls and costs

                VisibilityTimeout=30,
                # ↑ hide message for 30 seconds while we process
                #   set this longer than your processing time!

                MessageAttributeNames=['All']
                # ↑ include custom message attributes in response
            )

            messages = response.get('Messages', [])
            # .get('Messages', []) returns empty list if no messages
            # (avoids KeyError when queue is empty)

            if not messages:
                print("No messages. Waiting...")
                continue  # go back to polling

            print(f"Received {len(messages)} message(s)")

            # Step 2: Process each message
            for message in messages:
                message_id     = message['MessageId']
                receipt_handle = message['ReceiptHandle']
                # ↑ SAVE THIS — needed to delete the message

                try:
                    # Parse the JSON body back into a Python dict
                    order_data = json.loads(message['Body'])

                    # Process the order (your business logic)
                    process_order(order_data)

                    # Step 3: Delete message ONLY after successful processing
                    # If we crash before this, message reappears in queue
                    sqs.delete_message(
                        QueueUrl=QUEUE_URL,
                        ReceiptHandle=receipt_handle
                    )
                    print(f"Message {message_id} deleted from queue")

                except json.JSONDecodeError as e:
                    # Bad JSON in message body — this will never succeed
                    # Delete it to prevent infinite retries (or let DLQ handle it)
                    print(f"Invalid JSON in message {message_id}: {e}")
                    sqs.delete_message(
                        QueueUrl=QUEUE_URL,
                        ReceiptHandle=receipt_handle
                    )

                except Exception as e:
                    # Processing failed — DO NOT delete the message
                    # It will reappear after visibility timeout
                    # and another worker (or this one) will retry it
                    print(f"Failed to process message {message_id}: {e}")
                    # The message will go to DLQ after maxReceiveCount attempts

        except KeyboardInterrupt:
            print("Worker stopped.")
            break

        except Exception as e:
            print(f"Error polling queue: {e}")
            time.sleep(5)  # wait before retrying to avoid hammering SQS


# Run the worker
if __name__ == "__main__":
    poll_and_process()
```

---

14. Using SQS with Java
    Add Dependency (Maven pom.xml)

```xml
<dependency>
    <groupId>software.amazon.awssdk</groupId>
    <artifactId>sqs</artifactId>
    <version>2.21.0</version>
</dependency>
```

Producer — Send a Message

```java
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.sqs.SqsClient;
import software.amazon.awssdk.services.sqs.model.*;

public class OrderProducer {

    private static final String QUEUE_URL =
        "https://sqs.ap-south-1.amazonaws.com/123456789012/my-order-queue";

    // Create SQS client
    // Automatically reads credentials from:
    // 1. Environment variables
    // 2. ~/.aws/credentials
    // 3. IAM role on EC2/ECS
    private SqsClient sqsClient = SqsClient.builder()
        .region(Region.AP_SOUTH_1)
        .build();

    public String sendOrder(String orderJson) {
        SendMessageRequest request = SendMessageRequest.builder()
            .queueUrl(QUEUE_URL)
            .messageBody(orderJson)
            // Optional: delay this message by 5 seconds
            .delaySeconds(0)
            .build();

        SendMessageResponse response = sqsClient.sendMessage(request);

        String messageId = response.messageId();
        System.out.println("Message sent! ID: " + messageId);
        return messageId;
    }

    public static void main(String[] args) {
        OrderProducer producer = new OrderProducer();

        String orderJson = """
            {
                "orderId": "ORD-001",
                "customerId": "CUST-789",
                "totalAmount": 59.99
            }
            """;

        producer.sendOrder(orderJson);
    }
}
```

Consumer — Receive and Process Messages

```java
import software.amazon.awssdk.services.sqs.model.*;
import java.util.List;

public class OrderConsumer {

    private static final String QUEUE_URL =
        "https://sqs.ap-south-1.amazonaws.com/123456789012/my-order-queue";

    private SqsClient sqsClient = SqsClient.builder()
        .region(Region.AP_SOUTH_1)
        .build();

    public void pollAndProcess() {
        System.out.println("Worker started...");

        while (true) {
            // Step 1: Request messages from SQS
            ReceiveMessageRequest receiveRequest = ReceiveMessageRequest.builder()
                .queueUrl(QUEUE_URL)
                .maxNumberOfMessages(10)   // up to 10 per call
                .waitTimeSeconds(20)       // long polling
                .visibilityTimeout(30)     // hide for 30 seconds
                .build();

            List<Message> messages = sqsClient
                .receiveMessage(receiveRequest)
                .messages();

            if (messages.isEmpty()) {
                System.out.println("No messages. Waiting...");
                continue;
            }

            // Step 2: Process each message
            for (Message message : messages) {
                String messageId     = message.messageId();
                String receiptHandle = message.receiptHandle();
                String body          = message.body();

                try {
                    // Your processing logic here
                    processOrder(body);

                    // Step 3: Delete after successful processing
                    sqsClient.deleteMessage(DeleteMessageRequest.builder()
                        .queueUrl(QUEUE_URL)
                        .receiptHandle(receiptHandle)
                        .build());

                    System.out.println("Processed and deleted: " + messageId);

                } catch (Exception e) {
                    // DO NOT delete — let it retry
                    System.err.println("Processing failed: " + e.getMessage());
                }
            }
        }
    }

    private void processOrder(String orderJson) {
        // Parse JSON and handle order
        System.out.println("Processing: " + orderJson);
        // Your business logic here
    }
}
```

---

15. Real World Use Cases
    Use Case 1 — E-Commerce Order Processing

```
Customer places order on website
            │
            ▼
[Order Service] ──sends──▶ [SQS: order-queue]
            │
            │          ┌──▶ [Email Worker]    → sends confirmation email
            │          │
[order-queue] ──fan──▶ ├──▶ [Inventory Worker] → reduces stock count
   via SNS    ─out─    │
                       ├──▶ [Payment Worker]   → charges credit card
                       │
                       └──▶ [Analytics Worker] → logs to data warehouse

Each worker processes independently.
If payment service is slow → other services unaffected.
If inventory service crashes → its messages wait safely in queue.
```

Use Case 2 — Image/Video Processing

```
User uploads video to S3
            │
S3 triggers Lambda
            │
Lambda sends message to [SQS: video-processing-queue]
            │
            ▼
[Worker Fleet — 10 EC2 instances reading from same queue]
  Worker 1 picks up video1 → transcodes to 720p
  Worker 2 picks up video2 → transcodes to 1080p
  Worker 3 picks up video3 → transcodes to 480p
  ...
            │
            ▼
Transcoded video saved to S3
User notified via SNS → email/SMS
```

Use Case 3 — Microservices Communication

```
Service A (User Service)           Service B (Notification Service)
      │                                        │
      │  User registered!                      │
      │──sends──▶ [SQS Queue] ──◀──polls──── │
                                               │
                                   Sends welcome email
                                   Sends SMS verification
                                   Logs to audit trail

Services are decoupled:
- Service A doesn't know Service B exists
- Service B can be updated/restarted without affecting A
- If B is down, messages accumulate safely and sent when B comes back
```

---

16. SQS Pricing
    SQS pricing is based on number of API requests (not messages stored).

```
┌──────────────────────────────────────────────────────────────────┐
│                       SQS PRICING (2024)                         │
├──────────────────────────┬───────────────────────────────────────┤
│ First 1 million          │ FREE every month                      │
│ API requests/month       │                                       │
├──────────────────────────┼───────────────────────────────────────┤
│ Standard Queue           │ $0.40 per million requests            │
│ (after free tier)        │                                       │
├──────────────────────────┼───────────────────────────────────────┤
│ FIFO Queue               │ $0.50 per million requests            │
│ (after free tier)        │                                       │
├──────────────────────────┼───────────────────────────────────────┤
│ Data Transfer            │ Free within same region               │
│                          │ Charged for cross-region              │
└──────────────────────────┴───────────────────────────────────────┘
```

What counts as an API request?

```
SendMessage          = 1 request per message (or 1 per batch up to 256KB)
ReceiveMessage       = 1 request per call (even if 0 messages returned)
DeleteMessage        = 1 request per message
ChangeMessageVisiblty = 1 request per message

Cost-saving tip:
Use BATCH operations wherever possible:
  SendMessageBatch   → send up to 10 messages for cost of 1 request
  DeleteMessageBatch → delete up to 10 messages for cost of 1 request
```

---

17. Common Errors and Fixes
    Error 1 — Messages Being Processed Multiple Times

```
Symptom:  Same order email sent twice, duplicate database records

Cause:    Visibility timeout too short
          Processing takes 60s but timeout is 30s
          Message reappears before processing finishes

Fix:
  1. Increase visibility timeout in queue settings
  2. Call ChangeMessageVisibility to extend timeout dynamically
  3. Make processing idempotent:
     - Check if orderId already processed before doing work
     - Use database unique constraints
     - Use conditional writes
```

Error 2 — Messages Accumulating (Queue Growing)

```
Symptom:  ApproximateNumberOfMessages keeps growing
          Workers can't keep up with incoming messages

Cause:    Producers sending faster than consumers can process

Fix:
  1. Add more consumer instances (horizontal scaling)
  2. Use Auto Scaling based on queue depth:
     CloudWatch metric: ApproximateNumberOfMessages
     Scale out when: messages > 100
     Scale in when: messages < 10
  3. Optimise consumer processing speed
  4. Increase batch size (receive 10 messages per call)
```

Error 3 — Messages Going to DLQ Immediately

```
Symptom:  Messages appear in DLQ right away

Cause 1:  maxReceiveCount = 1 (too low)
Fix:      Increase to 3-5

Cause 2:  Consumer throws exception on every message
Fix:      Check consumer logs, fix the bug
          Common causes:
          - JSON parsing error (bad message format)
          - Database connection failed
          - External API timeout
```

Error 4 — Access Denied

```
Symptom:  AccessDeniedException when sending or receiving

Cause:    IAM user/role missing SQS permissions

Fix: Add this IAM policy to your user/role:
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sqs:SendMessage",
                "sqs:ReceiveMessage",
                "sqs:DeleteMessage",
                "sqs:GetQueueAttributes",
                "sqs:GetQueueUrl"
            ],
            "Resource": "arn:aws:sqs:ap-south-1:123456789012:my-order-queue"
        }
    ]
}
```

Error 5 — ReceiptHandle is Invalid

```
Symptom:  ReceiptHandleIsInvalid when deleting message

Cause 1:  Visibility timeout expired — message was already
          given to another consumer with a NEW receipt handle
Fix:      Increase visibility timeout, delete faster

Cause 2:  Message was already deleted
Fix:      Check your code for double-delete

Cause 3:  Wrong queue URL
Fix:      Verify queue URL is correct
```

---

18. Quick Reference Card

```
┌──────────────────────────────────────────────────────────────────┐
│                    AWS SQS QUICK REFERENCE                       │
├─────────────────────────┬────────────────────────────────────────┤
│ CONCEPT                 │ IN PLAIN ENGLISH                       │
├─────────────────────────┼────────────────────────────────────────┤
│ Queue                   │ A waiting room for messages            │
│ Producer                │ Sends messages to queue                │
│ Consumer                │ Reads messages from queue              │
│ Message                 │ Your data (JSON string, max 256KB)     │
│ Receipt Handle          │ Ticket to delete a message             │
│ Visibility Timeout      │ How long message is hidden after read  │
│ Long Polling            │ Wait up to 20s instead of empty return │
│ Dead Letter Queue       │ Bin for messages that keep failing     │
│ FIFO Queue              │ Guaranteed order + no duplicates       │
│ Standard Queue          │ High throughput, best-effort order     │
├─────────────────────────┼────────────────────────────────────────┤
│ KEY RULES               │                                        │
├─────────────────────────┼────────────────────────────────────────┤
│ Delete message          │ ONLY after successful processing       │
│ Visibility timeout      │ Set 6x your average processing time    │
│ Always use              │ Long polling (WaitTimeSeconds=20)      │
│ FIFO name               │ Must end with .fifo                    │
│ Batch size              │ Up to 10 messages per API call         │
│ Max message size        │ 256 KB (use S3 for larger data)        │
│ Max retention           │ 14 days                                │
├─────────────────────────┼────────────────────────────────────────┤
│ IMPORTANT METRICS       │ CHECK IN CLOUDWATCH                    │
├─────────────────────────┼────────────────────────────────────────┤
│ ApproxNumberOfMessages  │ Messages waiting (queue depth)         │
│ ApproxMsgsNotVisible    │ Messages being processed now           │
│ NumberOfMsgsSent        │ Send rate                              │
│ NumberOfMsgsDeleted     │ Successful processing rate             │
│ ApproxAgeOfOldestMsg    │ How old is oldest unprocessed message  │
└─────────────────────────┴────────────────────────────────────────┘
```

The Three Operations You Will Use 99% of the Time

```bash
# 1. SEND a message
aws sqs send-message --queue-url <URL> --message-body '<json>'

# 2. RECEIVE messages
aws sqs receive-message --queue-url <URL> --wait-time-seconds 20

# 3. DELETE a message (after processing)
aws sqs delete-message --queue-url <URL> --receipt-handle <handle>
```

The Golden Rule of SQS

> **Never delete a message before you have finished processing it successfully.**
>
> Delete = "I am done, remove this from the queue forever."
> If you delete before finishing and then crash → message is gone → work is lost.
> If you do NOT delete and crash → message reappears → another worker retries → safe.

---

Built for beginners. Every concept explained. Every term defined.
Come back anytime — it will always make sense. 📬
