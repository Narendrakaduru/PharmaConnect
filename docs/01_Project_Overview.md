# 01. Project Overview & System Architecture

[← Back to Master Documentation Index](../PharmaConnect_Project_Documentation.md)

---

## 1. Executive Summary

**PharmaConnect** is a comprehensive, production-patterned Salesforce CRM application designed specifically to be built, configured, and demonstrated entirely within a **Free Salesforce Developer Edition Org**.

It unifies Healthcare Provider (HCP) relationship management, Medical Representative (MR) field operations, sample distribution tracking, sales order processing, and territory-driven target analytics into a compliant, automated, and secure ecosystem.

---

## 2. Core Business Capabilities

Pharma organizations require field operational tracking and compliance with pharmaceutical regulations (e.g., sample handling limits, accurate detailing records, and auditable visits). **PharmaConnect** centralizes:

* **Healthcare Providers (HCPs):** Doctors, specialists, clinics, hospital departments, and pharmacies.
* **Field Force / Medical Reps:** Daily scheduling, route planning, call logs, and performance tracking.
* **Product Catalog & Detailing:** Approved medicine portfolio, therapeutic classes, brochures, and discussion logging.
* **Compliant Sample Management:** Inventory requests, validation against quota thresholds, and dual-authorization approvals.
* **Order & Target Realization:** Secondary sales order booking, distributor mapping, and quota achievement calculations.
* **Territory & Reporting Insights:** Multi-tier territory roll-ups, executive sales trends, and rep productivity KPIs.

---

## 3. Developer Edition Learning Objectives

* Build a full-scale enterprise application completely within the **Free Salesforce Developer Edition** limits.
* Master **Separation of Concerns (SoC)** in Apex (Controller, Service, Selector, Domain/Handler).
* Implement mobile-responsive **Lightning Web Components (LWC)** communicating reactively with Apex.
* Implement declarative automations (**Record-Triggered Flows**) and programmatic bulkified triggers without recursion.
* Setup automated **CI/CD with GitHub Actions** and **Salesforce CLI** at zero financial cost.

---

## 4. Overall Architecture

```mermaid
flowchart TB
    subgraph UI_Layer ["Presentation Layer (Salesforce Lightning Experience)"]
        LEX["Salesforce Lightning Experience (Desktop & Browser)"]
        LWC["Custom Lightning Web Components (LWC)"]
        LEX --> LWC
    end

    subgraph Controller_Layer ["Controller & State Management"]
        LDS["Lightning Data Service / UI API"]
        ApexCtrl["Apex Controllers (@AuraEnabled)"]
        LWC --> LDS
        LWC --> ApexCtrl
    end

    subgraph Logic_Layer ["Business Logic Layer (Enterprise Pattern)"]
        Service["Service Layer (*Service.cls)"]
        Domain["Domain / Trigger Handler (*TriggerHandler.cls)"]
        Flows["Declarative Automation (Record-Triggered / Scheduled Flows)"]
        ApexCtrl --> Service
        Domain --> Service
    end

    subgraph Data_Access_Layer ["Data Access & Query Layer"]
        Selector["Selector Layer (*Selector.cls)"]
        SOQL["Optimized SOQL / SOSL Queries (WITH USER_MODE)"]
        Service --> Selector
        Selector --> SOQL
    end

    subgraph Persistence_Layer ["Salesforce Multi-Tenant Database (Dev Org Limit: 5MB Storage)"]
        StandardObj[("Standard Objects: Account, Contact, Product2")]
        CustomObj[("Custom Objects: Healthcare_Provider__c, Doctor_Visit__c, etc.")]
        MDT[("Custom Metadata: Pharma_Business_Rule__mdt")]
        SOQL --> StandardObj
        SOQL --> CustomObj
        SOQL --> MDT
        Flows --> CustomObj
    end

    subgraph Integration_Layer ["External Integration Layer (Zero-Cost Mock)"]
        NC["Named Credentials / External Credentials"]
        REST["REST Callout Services (JSON API)"]
        MockAPI["Free Mock API (Beeceptor / Mockoon / Postman Mock Server)"]
        Service --> REST
        REST --> NC
        NC --> MockAPI
    end
```

---

## 5. Business Domain Mindmap

```mermaid
mindmap
  root((PharmaConnect))
    ["1. Healthcare Provider Management"]
      ["Profiling & Medical Accreditation"]
      ["Specialization & Key Opinion Leader (KOL) Tagging"]
      ["Clinic / Hospital Affiliations"]
      ["Territory Mapping"]
    ["2. Medical Representative Management"]
      ["Rep Profiling & User Linkage"]
      ["Target Quota Allocation"]
      ["Daily Route Planning"]
      ["Activity Tracking"]
    ["3. Product & Portfolio Management"]
      ["Medicines & Formulations (Product2)"]
      ["Digital Detailing Notes"]
      ["Sample Allocation Checking"]
    ["4. Field Visit & Detailing Management"]
      ["Pre-Call Planning"]
      ["In-Call Detailing & Discussion Log"]
      ["Competitor Intelligence Capture"]
      ["Automated Next-Call Follow-up"]
    ["5. Compliant Sample Management"]
      ["Sample Requisition"]
      ["Area Manager Approval Workflow"]
      ["Compliance Limits via Custom Metadata"]
    ["6. Sales Orders & Target Tracking"]
      ["Secondary Order Booking"]
      ["Distributor / Clinic Linkage"]
      ["Real-Time Target vs. Achievement Engine"]
    ["7. Analytics & Executive Dashboards"]
      ["Territory Heatmaps"]
      ["Rep Productivity Index"]
      ["Target Achievement Gauges"]
```

---

[Next: 02. User Roles & Security Setup →](02_User_Roles_and_Security.md)
