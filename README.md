# 3-Node OSPF EVPN VXLAN Lab

📖 **Overview**  
This lab emulates a simplified Core/Edge at IXP or RISP fabric using Nokia SROS routers with:

- **OSPF** as the underlay routing protocol  
- **BGP EVPN over VXLAN** as the overlay, providing:
  - **L2 EVPN** (Type-2 MAC/IP)  
  - **L3 EVPN** (Type-5 IP prefix) via R-VPLS + VPRN  
- Coexistence of:
  - Static VXLAN services 
  - EVPN-signaled VXLAN services 

The lab simulates a 3-node core:

- **PE1** – Provider Edge  
- **GW** – Gateway / core node  
- **PE2** – Provider Edge

- OSPF provides reachability to loopbacks and transport links; BGP EVPN handles L2 and L3 overlays.

---

## 🗺️ Lab Topology

![Lab Topology](3node-OSPF-EVPN.png)

### 🔹 Nodes

- **PE1** – Loopback: `1.1.1.1/32`  
- **PE2** – Loopback: `2.2.2.2/32`  
- **GW-PE**  – Loopback: `3.3.3.3/32`
- Nodes can be accessed using device names
- UserID - admin ; password - admin
- To access 'client1' and 'client2': username - root ; password - password

### 🔹 Underlay Links (OSPF)

- **PE1 ↔ GW** – `10.1.1.0/30`  
- **PE2 ↔ GW** – `10.2.2.0/30`  

All three nodes run **OSPF instance 0, area 0.0.0.0** for:

- Loopback reachability  
- Point-to-point transport subnets  

### 🔹 VLAN Segments (Access)

- **VLAN 10** → `192.168.10.0/24` (static VXLAN)  
- **VLAN 20** → `192.168.20.0/24` (static VXLAN)  
- **VLAN 30** → `192.168.30.0/24` (L2 EVPN over VXLAN)  
- **VLAN 40** →  
  - On **PE1**: `192.168.100.0/24` (L3 EVPN – VPRN 100)  
  - On **PE2**: `192.168.200.0/24` (L3 EVPN – VPRN 100)  

### 🔹 VXLAN & EVPN Mapping

| Service | Type       | VLAN | VNI | Control Plane                | Notes                           |
|--------:|------------|------|-----|------------------------------|---------------------------------|
| 10      | VPLS       | 10   | 10  | Static VXLAN flood list      | Simple L2 only                  |
| 20      | VPLS       | 20   | 20  | Static VXLAN flood list      | Simple L2 only                  |
| 30      | VPLS       | 30   | 30  | BGP EVPN (Type-2 MAC/IP)     | L2 EVPN VXLAN (VPLS 30)         |
| 200     | R-VPLS     | —    | 200 | BGP EVPN (Type-5 IP prefix)  | L3 EVPN core (R-VPLS 200)       |
| 100     | VPRN / VRF | 40   | —   | Bound to R-VPLS 200 (Type-5) | L3 EVPN VRF (VPRN 100, VLAN 40) |

- **L2 EVPN**: VPLS 30 – EVPN Type-2 MAC routes, VLAN 30, VNI 30  
- **L3 EVPN**: R-VPLS 200 + VPRN 100 – EVPN Type-5 IP prefixes  
  - PE1: advertises `192.168.100.0/24`  
  - PE2: advertises `192.168.200.0/24`  

---
## 🎯 Lab Objectives

This lab lets you:

- ✅ Establish **OSPF** adjacencies and confirm underlay reachability  
- ✅ Bring up **BGP EVPN** sessions between PE1 / GW / PE2  
- ✅ Verify **L2 EVPN** (Type-2) for VPLS 30 over VXLAN  
- ✅ Verify **L3 EVPN** (Type-5) using R-VPLS 200 + VPRN 100  
- ✅ Confirm end-to-end host connectivity:
  - Same VLAN via L2 EVPN  
  - Different subnets via L3 EVPN  

---
## 📐 Design Principles

- **Underlay**: OSPF area 0 for simplicity and deterministic reachability  
- **Overlay**:
  - Static VXLAN (VPLS 10/20) to mirror the original lab  
  - EVPN-signaled VXLAN (VPLS 30, R-VPLS 200 + VPRN 100)  
- **L2 vs L3**:
  - VPLS 30: pure L2 EVPN (Type-2), VLAN 30  
  - VPRN 100 + R-VPLS 200: pure L3 EVPN (Type-5), VLAN 40 per-site subnets  

---
## 🖥️ Verification & Validation (SR OS)

Use these commands on the SR OS nodes after cloning and deploying the lab.

### 🔍 1. System Health

```text
show router interface
show port

🔍 3. Underlay – OSPF
show router ospf neighbor
show router route-table   # confirm loopbacks and /30 links

🔍 4. BGP EVPN

show router bgp routes evpn mac        # EVPN Type-2 (L2)
show router bgp routes evpn ip-prefix  # EVPN Type-5 (L3)

🔍 5. Services – L2 & L3

L2 EVPN (Type-2) – VPLS 30
edit-config global
info flat configure service vpls 30

L3 EVPN (Type-5) – R-VPLS 200 + VPRN 100
info flat configure service vpls "200"
info flat configure service vprn "100"

🔍 6. Config Inspection (Quick Checks)

Underlay & BGP:
info flat configure router

All services:
info flat configure service

🔍 7. End-to-End Connectivity (Examples)

In VPRN/VRF 100:
From PE1:
ping 192.168.200.1 router-instance "100"

From PE2:
ping 192.168.100.1 router-instance "100"

From client1:
ping 192.168.200.10(Type5)
ping 192.168.30.2(Type2)

From client2:
ping 192.168.100.10(Type5)
ping 192.168.30.1(Type2)
