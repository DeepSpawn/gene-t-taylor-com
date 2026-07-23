---
title: "The industrial origins of modern code review"
description: "Modern code review inherited several different jobs from formal software inspections. What happens when AI replaces only one of them?"
pubDate: 2026-07-18
tags: []
feature: "coding-924920_1280.jpg"
series:
  name: "The End of Code Review?"
  slug: "end-of-code-review"
  part: 1
  total: 3
---

If AI makes code generation effectively abundant while trustworthy human attention remains scarce, code review becomes the bottleneck. The obvious conclusion is that review needs to be automated or abandoned. This conclusion assumes we know what code review is actually for. This three-part series traces how formal inspection evolved into modern code review, why so many different responsibilities got bundled into the pull request, and which of these responsibilities AI can or cannot easily replace.

## Before Pull Requests

It was 1976. 

A computer looked something like this
![Illustration of an IBM System/370 configuration — central processor and console, tape and disk storage, and card equipment, with operators at their consoles](/images/end-of-code-review/ibm-system-370.png)

IT professionals, at least at IBM, looked something like:
![IBM staff in dark suits and ties reviewing page proofs of IBM News, 1972](/images/end-of-code-review/ibm-news-1972-professionals.png#medium)

Steve Jobs and Steve Wozniak just founded Apple, Micro-soft has become Microsoft and the cutting edge of large-scale software development belongs to companies like IBM.

Large system development was commonly organised as a sequence of formal phases and handoffs: design, implementation, integration and test.

In many development environments code still passed through punch cards and batch processing workflows. Compilation and testing of code involved scarce compute resources and could involve delays of hours or, in the worst case, overnight.

Unsurprisingly people were not writing flawless code, and defects (unhandled edge cases, missed requirements, off-by-one errors, etc.) would end up in codebases. If you were lucky they would get found in test, otherwise error reports from the field would trickle back in and a lot of time and money would have to go into tracking down and fixing the mistake.

As part of IBM’s broader software-quality effort, Michael Fagan formalised a method of structured design and code inspections which he documented in a 1976 paper.

## IBM Code Inspections
*M. E. Fagan, ["Design and code inspections to reduce errors in program development,"](https://doi.org/10.1147/sj.153.0182) IBM Systems Journal, vol. 15, no. 3 (1976), pp. 182–211.*
![Opening paragraph of the paper, with the thesis highlighted: managing a process requires planning, measurement, and control](/images/end-of-code-review/fagan-paper-intro-highlighted.png)

Software development was to be treated as a process like any other: a series of operations with defined exit criteria. Inspections inserted measurement and quality control into that process, allowing IBM to use their findings to manage it.

The paper describes two formal inspection stages: a design inspection before coding and a code inspection before testing. The aim was to have all instructions in the program covered by at least one of these inspections.

In a world before Git, when you thought the work was ready you would convene a coding inspection panel of 4 people. Each person in your code inspection had a dedicated role:

* Moderator: Leads the inspection and ensures the process is followed. Ideally from an unrelated project. He should be trained, and some soft skills are required.
* Designer: The programmer responsible for producing the program design.
* Coder/Implementor: The programmer responsible for translating the design into code.
* Tester: The programmer responsible for writing and/or executing test cases.

The inspection process would then run as follows:

1. Overview (whole team, sync) - The designer describes the overall area being addressed, then covers the specific area he has designed in detail including logic and dependencies. At this point documentation of the design is distributed to all inspection participants.

2. Preparation (individual, async) - The participants are expected to go away and do some homework and read over the design documentation to understand its intent.

3. Inspection (whole team, sync) - During the design inspection the reader reconstructed the design logic, while during the code inspection the reader would walk-through the implementation.

4. Rework (individual, async) - Rework and resolve errors found by inspection; time in the schedule needs to be budgeted for this.

5. Follow-up - The moderator is responsible for ensuring that all issues, problems, and concerns discovered in the inspection operation have been resolved by the designer. If more than 5% of material was reworked, another full inspection is scheduled; otherwise it's at his discretion to verify the quality of the rework.

The inspection meeting had one immediate objective: finding errors. This is normally done during the reader's explanation. Participants raised questions and pursued them until the group either identified an error or satisfied itself that the implementation matched the specification.

An error, once found, is noted and categorized by the moderator, at which point the inspection would continue.

At the end of the inspection the moderator would produce a written report of the inspection and its findings. This is to ensure all issues raised are followed up and reworked, and also to update running statistics about errors.

If this process sounds heavy, you have the correct impression. Fagan notes that people were really only effective at doing this for a block of up to two hours. The pace was also slow, proceeding at between 150 and 500 lines of code an hour depending on the type of code under review. The context-building overview and preparation for the meeting could take half as long again as the meeting itself.

![Fagan Table 3 — the inspection process operations, their rate of progress, and the objective of each](/images/end-of-code-review/fagan-table3-inspection-rate-of-progress.png)
*Table 3: rate of progress for each operation (loc/hr), for design (I₁) and code (I₂).*

Inspection was more than a meeting; it was a closed control loop where defects were recorded, corrected, then independently verified.

## Why inspections worked: early defect detection

The pitch for Fagan Inspections was pretty simple: the practice was very effective at finding errors, and the earlier you found errors the cheaper they were to fix.

![Figure 11, new approach — inspections give a first quantitative indication of quality far earlier](/images/end-of-code-review/fagan-fig11-process-management-new.png)

In modern language it was a very effective way of left-shifting a significant fraction of the overall error count.
Why was it so important to left-shift the catching of errors?

![Highlighted quote: purging errors early is 10 to 100 times less expensive than late rework](/images/end-of-code-review/fagan-quote-purging-errors-cost.png#medium)

This number sounds high; the exact multiplier is likely specific to the IBM context, but the mechanism is easy enough to understand. If you look at the errors reported in the paper, one of the main error classes was missing logic rather than incorrect statements. Missing logic could be introduced in the design or specification and then propagated consistently through implementation and tests, and dependent modules might start relying on this behavior. The visible fault might only appear at some distance from the point of origin. Finding and fixing it could involve very extensive diagnostic work to track down, and the fix could involve unwinding all of the work that had accumulated around that assumption.

In IBM's environment the avoided downstream rework was large enough to more than justify putting four people in a room to inspect the design and implementation end to end.

This was driven by people being pretty good at finding errors if you give them technical context, no distractions and a single focus on finding errors: 
![Fagan: approximately two thirds of all errors reported during development are found by I₁ and I₂ inspections prior to machine testing](/images/end-of-code-review/fagan-quote-two-thirds-before-testing.png#medium)

This is also revealing of the development environment: IBM was prepared to conduct a full design inspection followed by a full code inspection *before running the program on a machine.*


The experience of Standard Bank of South Africa provides some contemporary corroborating evidence that the process produced maintainable systems. The bank credited it with producing tangibly cleaner systems — at one point a maintenance group of just 21% of staff was keeping 31 live systems (1,036 programs, 525,000 lines of code) running (Crossman, [*Some Experiences in the Use of Inspection Teams*](https://doi.org/10.1145/800100.803241), The Standard Bank of South Africa).

## Inspection as a learning system

### Individual learning  

Beyond finding errors, these inspections were a great source of learning.

Then, as now, individuals would learn a lot from the review process. People writing code would very quickly learn what kind of errors are being found in inspection so they could apply that knowledge to avoid those errors in future inspections. Fagan makes it clear that people who were skeptical of the value of the process soon came around once they had experienced this learning process first-hand. 

### Team learning  

At the next layer up, the team would be able to get a lot of shared context and shared heuristics. The overview and preparation steps would explicitly socialize knowledge over a wider group of people, bringing the designer, coder and tester together in a room much earlier in the process. Design intent could be distributed well before it was translated into code, and the tester could stress test edge cases before it was handed off for machine testing. 

The formal inspection process would build up a rich dataset on the errors that were found during an inspection:
![Figure 7B — an example code inspection report / module detail form](/images/end-of-code-review/fagan-fig7b-code-inspection-report.png)

Errors would be counted by type and module, and this data would be made available to raise the future quality of the product. This information would be available at the team level, where ranked error frequency from recent inspections would be used as an input in future inspections. Knowing the kind of errors that have been found helps you be more effective at looking for those problems in the future.

This was explicitly contrasted with the desk "walk-through" practice of the day, where people would run through code at someone's desk. This would find errors, but this would be a one-time improvement rather than improving quality on an ongoing basis (sound familiar?). How many modern reviews catch a problem in one pull request without turning the lesson into a test, linter, checklist or documented engineering standard?

### Organizational learning 

Finally, at the organization level, the outputs from inspection could be used to help drive quality for the entire org. Error frequencies allowed error checklists to be produced and updated. Here is an example of the kind of inspection checklists produced by IBM at this time:
![The I1 logic checklist, grouped into Missing, Wrong, and Extra categories](/images/end-of-code-review/fagan-i1-logic-checklist.png)
*The I1 logic checklist*

These statistics also allowed the organization to identify particularly error-prone modules so they could be given special attention.
For an example of how clustered the defects could be, [Watts Humphrey](https://en.wikipedia.org/wiki/Watts_Humphrey) recounted one example where in a codebase of around half a million lines of code split over 1,600 modules, something like 14% of the modules were responsible for all of the errors and the worst 3% of modules were responsible for 50% of the errors ([Oral History of Watts Humphrey](https://archive.computerhistory.org/resources/text/Oral_History/Humphrey_Watts/102702107.05.01.acc.pdf), interviewed by Grady Booch, Computer History Museum, 2009).

IBM and Fagan were thinking about this as a continual learning process, where inspection and analysis were part of feedback and feedforward quality loops.
![Figure B — the feedback and feed-forward loops that make inspection a learning process](/images/end-of-code-review/fagan-figB-feedback-feedforward.png)

## One process, separate objectives 

The overall purpose was better quality software, but the system also produced valuable secondary effects such as learning and knowledge transfer. What is interesting is that, given this, Fagan was still very regimented in the process and gave each step a clear operational objective:

![The paper's summary — a numbered list of steps for running design and code inspections with process control](/images/end-of-code-review/fagan-summary.png)

Groups are more effective when they have a single objective, which is why he is adamant that the sync inspection meeting required people to be locked in on finding errors. This is the only thing the should be focusse on. It is not there for people to redesign, evaluate alternative solutions, or attempt to find fixes for the errors that have been identified.

Contrast this with modern code review, where one async comment thread may potentially cover all of the following: 

* “Can I merge this change?”
* “Does this work?”
* “Is this the right design?”
* “Can you explain this subsystem to me?”
* “Does this match our style?”
* “Have we accepted the operational risk?”
* “Can I teach you a better approach?”

## Conclusions

I am not about to make my team don on a shirt and tie then convene a four-person inspection panel. But Fagan’s process exposes something important about modern code review.

The Fagan inspection was not merely a manual bug detector. It was a deliberately structured system for finding defects, transferring knowledge and converting local mistakes into organizational learning. You can find some of the same feedback-loop ambitions of the Fagan inspection process in the modern DevOps movement, but it's worth thinking about what things we may have lost over the years - how many organizations are keeping track of mistakes by category for things caught in the peer review stage?

Modern code review retained several of these functions but compressed them into a single asynchronous approval workflow.
These bundled functions help explain why the prospect of ending code review produces several different anxieties. Some are concerned that AI is not yet good enough at the quality-control part of the process, while others are more concerned about the education and socialization aspects being lost. 

Even if AI can find an increasing share of defects, what will take the place of the rest of the system?

To answer that, we first need to understand how those functions became bundled into modern code review.