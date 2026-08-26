library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fetch_stage is
    port (
        clk             : in  std_logic;
        rst             : in  std_logic;
        stall           : in  std_logic;

        redirect_valid  : in  std_logic;
        redirect_target : in  std_logic_vector(15 downto 0);

        instr0          : out std_logic_vector(15 downto 0);
        instr1          : out std_logic_vector(15 downto 0);
        valid0          : out std_logic;
        valid1          : out std_logic;

        pc_out          : out std_logic_vector(15 downto 0)
    );
end entity;

architecture rtl of fetch_stage is

    signal pc : std_logic_vector(15 downto 0);

    -- IMEM wires
    signal imem_instr0 : std_logic_vector(15 downto 0);
    signal imem_instr1 : std_logic_vector(15 downto 0);

    -- Redirect tracking
    signal redirect_pending : std_logic;
    signal redirect_odd     : std_logic;

    -- Valid signals
    signal imem_valid0 : std_logic;
    signal imem_valid1 : std_logic;

begin
    imem_inst : entity work.instr_mems
        port map (
            addr   => pc,
            instr0 => imem_instr0,
            instr1 => imem_instr1
        );

    imem_valid0 <= '1' when imem_instr0 /= x"0000" else '0';
    imem_valid1 <= '1' when imem_instr1 /= x"0000" else '0';

    process(clk, rst)
    begin
        if rst = '1' then
            redirect_pending <= '0';
            redirect_odd     <= '0';
        elsif rising_edge(clk) then
            if redirect_valid = '1' then
                redirect_pending <= '1';
                redirect_odd     <= redirect_target(1);
            else
                redirect_pending <= '0';
            end if;
        end if;
    end process;

    process(clk, rst)
    begin
        if rst = '1' then
            instr0 <= (others => '0');
            instr1 <= (others => '0');
            valid0 <= '0';
            valid1 <= '0';
            pc_out <= (others => '0');

        elsif rising_edge(clk) then

            if redirect_valid = '1' then
                -- squash current cycle
                instr0 <= (others => '0');
                instr1 <= (others => '0');
                valid0 <= '0';
                valid1 <= '0';
                pc_out <= pc;

            elsif stall = '0' then
                instr0 <= imem_instr0;
                instr1 <= imem_instr1;
                pc_out <= pc;

                if redirect_pending = '1' then
                    valid1 <= imem_valid1;
                    if redirect_odd = '1' then
                        valid0 <= '0';
                    else
                        valid0 <= imem_valid0;
                    end if;
                else
                    valid0 <= imem_valid0;
                    valid1 <= imem_valid1;
                end if;

            end if;
        end if;
    end process;

    process(clk, rst)
    begin
        if rst = '1' then
            pc <= (others => '0');

        elsif rising_edge(clk) then

            if redirect_valid = '1' then
                pc <= redirect_target(15 downto 1) & "0";

            elsif stall = '0' then
                pc <= std_logic_vector(unsigned(pc) + 4);
            end if;

        end if;
    end process;

end architecture;