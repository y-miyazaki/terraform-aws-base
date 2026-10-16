## Incident suppression: RDS / Redshift cron-scheduled stops

Alarms that fire while an RDS instance or Redshift cluster is intentionally stopped by a cron job (planned maintenance) are not failure incidents.

- Target resources: RDS instances, Redshift clusters.
- Excluded alarms: connection errors, timeouts, unreachable endpoints, zero CPU or zero connections, and similar symptoms of a stopped resource.
- Decision criterion: the alarm time overlaps the cron stop schedule of the resource.
- Do not list the alarm as an incident and do not start an investigation.
