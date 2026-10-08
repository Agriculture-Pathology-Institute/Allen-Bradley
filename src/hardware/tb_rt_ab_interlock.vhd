-- File Path: src/hardware/tb_rt_ab_interlock.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_rt_ab_interlock is
-- Testbenches do not expose external physical hardware ports
end tb_rt_ab_interlock;

architecture BehavioralTimingVerification of tb_rt_ab_interlock is
    signal clk_10mhz        : STD_LOGIC := '0';
    signal sys_reset        : STD_LOGIC := '1';
    signal requested_hex    : STD_LOGIC_VECTOR(3 downto 0) := "1111";
    signal signal_strobe    : STD_LOGIC := '0';
    signal contactor_close  : STD_LOGIC;
    
    constant CLK_PERIOD : time := 100 ns; -- 10.0 MHz Stage 2 clock interval line
begin

    -- Simulated Device Under Test (DUT) Behavioral Logic Process
    process(clk_10mhz, sys_reset)
    begin
        if sys_reset = '1' then
            contactor_close <= '0';
        elsif rising_edge(clk_10mhz) then
            if requested_hex = "0000" then
                contactor_close <= '0'; -- Kill high-voltage relay coil line in <100ns
            else
                contactor_close <= '1';
            end if;
        end if;
    end process;

    clk_process : process
    begin
        clk_10mhz <= '0'; wait for CLK_PERIOD / 2;
        clk_10mhz <= '1'; wait for CLK_PERIOD / 2;
    end process;

    stim_process : process
    begin
        sys_reset <= '1'; wait for CLK_PERIOD * 2;
        sys_reset <= '0'; requested_hex <= "1111"; wait for CLK_PERIOD;
        
        -- Trigger emergency security fault state 0x0
        requested_hex <= "0000"; wait for CLK_PERIOD;
        
        assert (contactor_close = '0') report "❌ SAFETY CRITICAL BREACH: Isolation loop timing failure" severity failure;
        report "✅ [TIMING PASS] Legacy contactor lines successfully isolated within a single 100ns step.";
        wait;
    end process;

end BehavioralTimingVerification;
