library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dmem is
    port (
        clk     : in  std_logic;

        rd_en   : in  std_logic;
        rd_addr : in  std_logic_vector(15 downto 0);
        rd_data : out std_logic_vector(15 downto 0);

        wr_en   : in  std_logic;
        wr_addr : in  std_logic_vector(15 downto 0);
        wr_data : in  std_logic_vector(15 downto 0)
    );
end entity;

architecture rtl of dmem is

    type mem_array_t is array (0 to 511) of std_logic_vector(7 downto 0);
    signal mem : mem_array_t := (others => x"00");

begin
    process(clk)
        variable base : integer;
    begin
        if rising_edge(clk) then
            if wr_en = '1' then
                base := to_integer(unsigned(wr_addr(8 downto 0)));
                mem(base)     <= wr_data(7 downto 0);
                mem((base + 1) mod 512) <= wr_data(15 downto 8);
            end if;
        end if;
    end process;
    
    rd_data <= mem((to_integer(unsigned(rd_addr(8 downto 0))) + 1) mod 512) &
               mem(to_integer(unsigned(rd_addr(8 downto 0))))
               when rd_en = '1'
               else (others => '0');

end architecture;