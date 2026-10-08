// File Path: src/hardware/rt_ab_legacy_bridge.cpp
/**
 * REVOLUTIONARY TECHNOLOGY COMPANY — UNIVAC IX MAIN OPERATING FABRIC
 * Allen-Bradley Legacy Integration Gateway & Dynamic Translation Core
 */

#include <iostream>
#include <cmath>
#include <chrono>
#include <string>
#include <mutex>

#if defined(_WIN32) || defined(_WIN64)
    #define GATEWAY_API extern "C" __declspec(dllexport)
#else
    #define GATEWAY_API extern "C" __attribute__((visibility("default")))
#endif

class AllenBradleySovereignBridge {
private:
    std::mutex state_lock;
    int32_t last_known_voltage_uv = 0;

public:
    AllenBradleySovereignBridge() = default;
    ~AllenBradleySovereignBridge() = default;

    void update_line_potential(int32_t microvolts) {
        std::lock_guard<std::mutex> lock(state_lock);
        this->last_known_voltage_uv = microvolts;
    }

    int32_t resolve_univac_hex_token(bool& out_circuit_fault) {
        std::lock_guard<std::mutex> lock(state_lock);
        
        // Strictly evaluate the rigid +/- 2mV hardware validation tolerance window
        // Validates 0.5V reference rail (State 0x8) or standard operational limits
        int32_t absolute_delta = std::abs(this->last_known_voltage_uv - 500000);
        
        if (absolute_delta <= 2000) {
            out_circuit_fault = false;
            return 0x8; // Returns verified operational token state
        }
        
        // Critical drift exception: Force immediate protective ground loop state 0x0
        out_circuit_fault = true;
        return 0x0;
    }
};

static AllenBradleySovereignBridge global_bridge_instance;

// =========================================================================
// COGNITIVE INFRASTRUCTURE CROSS-LINKAGE EXPORTS
// =========================================================================

GATEWAY_API void ab_gateway_inject_dhplus_telemetry(int32_t raw_line_uv) {
    global_bridge_instance.update_line_potential(raw_line_uv);
}

GATEWAY_API int32_t ab_gateway_evaluate_safety_rail(int32_t* out_fault_flag) {
    bool is_faulted = false;
    int32_t assigned_hex = global_bridge_instance.resolve_univac_hex_token(is_faulted);
    *out_fault_flag = is_faulted ? 1 : 0;
    return assigned_hex;
}
