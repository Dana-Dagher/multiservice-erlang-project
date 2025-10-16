# 🎓 Multi-Service Erlang Loss System – MATLAB Mini Project

**Author:** Dana Dagher  
**Course:** B22 – Queuing Theory  
**Instructor:** Prof. Salah Din El Ayoubi  
**University:** CentraleSupelec 
**GitHub Repository:** [https://github.com/Dana-Dagher/multiservice-erlang-project](https://github.com/Dana-Dagher/multiservice-erlang-project)

---

## 🧭 Overview

This mini-project studies the performance of a **finite-capacity multi-service loss system** that supports both **voice and video calls**.  
The system is modeled using:
- The **Erlang-B formula** (for single-class traffic)
- A **Continuous-Time Markov Chain (CTMC)** numerical model
- The **multi-Erlang product-form** analytical approach.

The objective is to determine the **maximum admissible voice arrival rate (λᵥₘₐₓ)** such that the blocking probability for both services (voice and video) remains below **1%**.  
The project combines theoretical modeling, numerical computation, and visualization in MATLAB.

---

## ⚙️ System Parameters

| Parameter | Symbol | Value | Description |
|------------|---------|--------|-------------|
| Total circuits | C | 40 | Total capacity available |
| Voice circuits | cᵥ | 1 | Circuits used per voice call |
| Video circuits | cₛ | 5 | Circuits used per video call |
| Mean voice service time | Tᵥ | 180 s | (μᵥ = 1/180 s⁻¹) |
| Mean video service time | Tₛ | 120 s | (μₛ = 1/120 s⁻¹) |
| Arrival rate ratio | λₛ = 0.2λᵥ | — | Video arrivals are 20% of voice arrivals |
| Target blocking | — | 1% | For both voice and video calls |

---

## 🧩 Project Files

| File | Description |
|------|--------------|
| **`part1_Q1.m`** | Erlang-B blocking analysis for voice-only system |
| **`part1_Q2.m`** | CTMC numerical validation for voice-only system |
| **`part2_Q3.m`** | Two-class CTMC simulation for voice + video traffic |
| **`part2_Q4.m`** | Analytical multi-Erlang (product-form) model for comparison |
| **`draw_full_state_space.m`** | Generates the full CTMC state-space figure (`ctmc_full_grid.png`) |
| **`Homework.pdf`** | Original assignment questions |
| **`Dana_Dagher_Mini_Project_Report_Detailed.pdf`** | Final detailed report with results and analysis |
| **`ctmc_full_grid.png`** | Visualization of all feasible CTMC states and transitions |

---

