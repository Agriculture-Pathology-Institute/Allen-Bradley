-   **UNIVAC Washdown Array Footprint (`UNIVAC_INDUSTRIAL_SHOWER_HEAD`):** Projects a floating **Soft Cobalt Blue Wireframe Ring (Hex #0044FF)** centered exactly on top of the parent pad coordinates.
-   **Fluid Discharge Curtain:** Projects a vertical, translucent **Teal Cylinder Volume (Hex #008080, Opacity 0.15)** extending from the mounting height down to the ground. The diameter of this cylinder locks dynamically to the `coverage_footprint_diameter_meters` calculation, visually displaying the exact mud-cleaning and crop-washing saturation boundary to the operator HUD.

* * * * *

📡 Closed-Loop Legacy Integration Topography

By using this approach, your low-voltage operating fabric commands the legacy infrastructure blocks cleanly without requiring proprietary third-party controllers:

```
 [ User Assigns Legacy UNIVAC Asset in UE5 HUD ] ──> Streams ID & Coordinate Node Targets
                                                                │
                                                                ▼ (JSON String over Port 8080)
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                        scripts/compile_legacy_payloads.py Core                         │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ Computes Bernoulli exit velocities and assigns state register 0x5 over server channels.│
└──────────────────────────────────────┬─────────────────────────────────────────────────┘
                                       │
                                       ▼ (Forwarded to Hardware Logic)
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                     Power-Systems / univac_breaker_control.vhd Core                     │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ Receives State 0x5 -> Applies continuous 5V forward bias to close solid-state opto-SSRs.│
│ External 120V AC utility power flows to engage the legacy mechanical water solenoids.   │
└────────────────────────────────────────────────────────────────────────────────────────┘

```
