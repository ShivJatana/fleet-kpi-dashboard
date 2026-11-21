# Findings & recommendations

*Synthetic data, 30 trucks, 26 weeks, 5,335 loads, 167 maintenance events. Queries: [`sql/01_kpis.sql`](sql/01_kpis.sql).*

## Summary
After dispatch schedules were re-sequenced and a preventive-maintenance program started on April 7, on-time delivery rose from **77.9% to 90.7%**. Unplanned downtime fell **36%**, and total maintenance cost fell 8%, even though four times as many PM services were done. Truck productivity (loads per truck) held steady.

## 1. Re-sequencing fixed the worst lanes first
**Evidence:** Cross-border lanes went from 61.9% to 80.9% on time and local GTA runs from 76.0% to 90.9%, the two biggest gains. Before the change, Detroit (60.2%) and Buffalo (63.4%) were the weakest lanes. (Queries 1.3, 1.4)
**Recommendation:** Keep cross-border departures early enough to clear the border before the afternoon crossing peaks. Keep GTA runs outside rush hour, and review lane on-time weekly.

## 2. Preventive maintenance pays for itself
**Evidence:** PM services rose from 22 to 84. Breakdowns fell from 36 to 25, and unplanned downtime from 1,144 to 730 hours. PM cost rose by $53K, but unplanned repair costs fell by $74K. (Query 2.1)
**Recommendation:** Keep PM on fixed intervals tracked in the telematics system. Planned downtime (428 hours) can be scheduled on weekends, when demand is lower.

## 3. Tires are the biggest breakdown cost
**Evidence:** Tires caused 23 of 61 breakdowns and about $144K in costs, more than any other category. (Query 2.2)
**Recommendation:** Add tread-depth and pressure checks to pre-trip inspections and PM-A services, and consider tire-pressure monitoring on long-haul units.

## 4. The oldest trucks break down most
**Evidence:** 2016–2018 trucks averaged 3.3 breakdowns each, versus 1.3 for 2021–2023. T26 (2016 International LT) alone lost 215 hours. (Queries 2.3, 3.2)
**Recommendation:** Prioritize T26 and T23 for replacement in the next capital cycle, and shorten PM intervals for trucks older than 6 years until then.

## Caveat
Both changes started on the same day, so this before/after comparison can't separate the effect of re-sequencing from the effect of PM. With real data, I'd roll out one change at a time, or compare against a control group of trucks.
