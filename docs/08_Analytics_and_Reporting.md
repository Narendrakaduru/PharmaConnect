# 08. Operational Reports & Executive Dashboards

[← Back to Master Documentation Index](../PharmaConnect_Project_Documentation.md) | [← Prev: 07. Automation & Rules](07_Automation_and_Business_Rules.md) | [Next: 09. Integration Architecture →](09_Integration_Architecture.md)

---

## 1. Operational Reports Portfolio

In your Free Developer Edition Org, create a custom report folder `PharmaConnect Reports` and build standard reports:

| Report Name | Primary Object | Groupings | Summaries / Columns |
| :--- | :--- | :--- | :--- |
| **Providers by Territory & Specialization** | `Healthcare_Provider__c` | 1. Territory<br>2. Specialization | Record Count, Active Status % |
| **Field Visit Call Activity** | `Doctor_Visit__c` | 1. Medical Representative<br>2. Status | Count of Visits, Completed Call Ratio |
| **Monthly Sales Realization** | `Sales_Order__c` | 1. Sales Representative<br>2. Order Month | Total Invoiced Amount, Average Order Value |
| **Sample Distribution Audit** | `Sample_Request__c` | 1. Product<br>2. Healthcare Provider | Sum of Units Distributed, Approval Rate |
| **Overdue Follow-up Actions** | `Follow_Up__c` | 1. Assigned To<br>2. Priority | Due Date, Status, Associated Doctor |

---

## 2. Executive Management Dashboard Layout

The **PharmaConnect Executive Dashboard** gives leaders real-time visibility into field productivity and sales quota attainment.

```text
┌────────────────────────────────────────────────────────────────────────┐
│               PHARMACONNECT EXECUTIVE LEADERSHIP DASHBOARD             │
├─────────────────────┬─────────────────────┬────────────────────────────┤
│   [ KPI METRIC ]    │   [ KPI METRIC ]    │       [ KPI METRIC ]       │
│  MTD Total Sales    │  Calls Completed    │    Active HCP Network      │
│     ₹42,50,000      │      1,420          │           840              │
├─────────────────────┴─────────────────────┴────────────────────────────┤
│  [ BAR CHART: Sales by Territory ]   │  [ DONUT: Detailing by Specialty]│
│  AP-Vijayawada: ████████████         │  Cardiology : 35%                │
│  TS-Hyderabad : ████████████████     │  Pediatrics : 25%                │
│  KA-Bengaluru : ██████████           │  Orthopedics: 20%                │
│  AP-Vizag     : ██████               │  Oncology   : 20%                │
├──────────────────────────────────────┼─────────────────────────────────┤
│  [ GAUGE: Target Realization ]       │  [ LINE: 6-Month Sales Trend ]  │
│         86.4% Achieved               │  Trend: May -> Oct              │
│       [ === 86.4% ===> ]             │  Growth: +14.2% MoM             │
└──────────────────────────────────────┴─────────────────────────────────┘
```

---

[Next: 09. Integration Architecture →](09_Integration_Architecture.md)
