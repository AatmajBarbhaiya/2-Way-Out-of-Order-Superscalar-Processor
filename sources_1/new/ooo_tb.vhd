library ieee;
use ieee.std_logic_1164.all;

entity ooo_tb is
end entity;

architecture tb of ooo_tb is
    signal clk : std_logic;
    signal rst : std_logic;
begin
    dut: entity work.ooo
        port map (
            clk => clk,
            rst => rst
        );

    process
    begin
        clk <= '0';
        wait for 5 ns;
        while true loop
            clk <= not clk;
            wait for 5 ns;
        end loop;
    end process;

    process
    begin
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        wait;
    end process;

    process
    begin
        wait for 1000 ns;
        assert false report "Simulation Finished" severity failure;
    end process;
end architecture;