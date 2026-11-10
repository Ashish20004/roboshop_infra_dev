# ACM Infrastructure

## Overview

This directory provisions an AWS Certificate Manager (ACM) SSL/TLS certificate and validates domain ownership using Amazon Route53.

The issued certificate is used by the Application Load Balancer to terminate HTTPS traffic.

---

## Resources

This infrastructure creates:

- AWS ACM Certificate
- Route53 DNS Validation Records
- ACM Certificate Validation

---

## Workflow

```text
Request ACM Certificate
          │
          ▼
Generate Domain Validation Records
          │
          ▼
Create Route53 CNAME Records
          │
          ▼
Validate Domain Ownership
          │
          ▼
Certificate Issued
          │
          ▼
Attach Certificate to ALB HTTPS Listener