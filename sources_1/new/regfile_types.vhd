library ieee;
use ieee.std_logic_1164.all;

package regfile_types is
    subtype tag_t is std_logic_vector(3 downto 0);
    type tag3_array_t is array (0 to 2) of tag_t;
    type data3_array_t is array (0 to 2) of std_logic_vector(15 downto 0);
end package regfile_types;

package body regfile_types is
end package body regfile_types;