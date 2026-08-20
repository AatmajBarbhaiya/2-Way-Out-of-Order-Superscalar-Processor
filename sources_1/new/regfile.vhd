library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regfile is
    port (
        clk  : in  std_logic;
        rst  : in  std_logic;
        stall : in std_logic;
        redirect_valid : in std_logic;

        free_count : out std_logic_vector(4 downto 0);

        rename0_fire : in std_logic;
        rename1_fire : in std_logic;
        rename0_arch : in std_logic_vector(2 downto 0);
        rename1_arch : in std_logic_vector(2 downto 0);

        src0_1_arch : in std_logic_vector(2 downto 0);
        src0_2_arch : in std_logic_vector(2 downto 0);
        src1_1_arch : in std_logic_vector(2 downto 0);
        src1_2_arch : in std_logic_vector(2 downto 0);

        wb0_valid : in std_logic;
        wb0_tag   : in std_logic_vector(3 downto 0);
        wb0_data  : in std_logic_vector(15 downto 0);
        wb1_valid : in std_logic;
        wb1_tag   : in std_logic_vector(3 downto 0);
        wb1_data  : in std_logic_vector(15 downto 0);
        wb2_valid : in std_logic;
        wb2_tag   : in std_logic_vector(3 downto 0);
        wb2_data  : in std_logic_vector(15 downto 0);

        commit0_valid : in std_logic;
        commit0_arch : in std_logic_vector(2 downto 0);
        commit0_tag : in std_logic_vector(3 downto 0);
        commit1_valid : in std_logic;
        commit1_arch : in std_logic_vector(2 downto 0);
        commit1_tag : in std_logic_vector(3 downto 0);

        rename0_tag : out std_logic_vector(3 downto 0);
        rename1_tag : out std_logic_vector(3 downto 0);

        s0_1_rrf : out std_logic;
        s0_1_tag : out std_logic_vector(3 downto 0);
        s0_1_ready : out std_logic;
        s0_1_val : out std_logic_vector(15 downto 0);

        s0_2_rrf : out std_logic;
        s0_2_tag : out std_logic_vector(3 downto 0);
        s0_2_ready : out std_logic;
        s0_2_val : out std_logic_vector(15 downto 0);

        s1_1_rrf : out std_logic;
        s1_1_tag : out std_logic_vector(3 downto 0);
        s1_1_ready : out std_logic;
        s1_1_val : out std_logic_vector(15 downto 0);

        s1_2_rrf : out std_logic;
        s1_2_tag : out std_logic_vector(3 downto 0);
        s1_2_ready : out std_logic;
        s1_2_val : out std_logic_vector(15 downto 0);

        cf_free_count : out std_logic_vector(4 downto 0);

        rename0_cf_fire : in std_logic;
        rename1_cf_fire : in std_logic;

        wb_cf0_valid : in std_logic;
        wb_cf0_tag   : in std_logic_vector(3 downto 0);
        wb_cf0_data  : in std_logic;
        wb_cf1_valid : in std_logic;
        wb_cf1_tag   : in std_logic_vector(3 downto 0);
        wb_cf1_data  : in std_logic;
        wb_cf2_valid : in std_logic;
        wb_cf2_tag   : in std_logic_vector(3 downto 0);
        wb_cf2_data  : in std_logic;

        commit0_cf_valid : in std_logic;
        commit0_cf_tag : in std_logic_vector(3 downto 0);
        commit1_cf_valid : in std_logic;
        commit1_cf_tag : in std_logic_vector(3 downto 0);

        rename0_cf_tag : out std_logic_vector(3 downto 0);
        rename1_cf_tag : out std_logic_vector(3 downto 0);

        s0_cf_rrf : out std_logic;
        s0_cf_tag : out std_logic_vector(3 downto 0);
        s0_cf_ready : out std_logic;
        s0_cf_val : out std_logic;

        s1_cf_rrf : out std_logic;
        s1_cf_tag : out std_logic_vector(3 downto 0);
        s1_cf_ready : out std_logic;
        s1_cf_val : out std_logic;

        zf_free_count : out std_logic_vector(4 downto 0);

        rename0_zf_fire : in std_logic;
        rename1_zf_fire : in std_logic;

        wb_zf0_valid : in std_logic;
        wb_zf0_tag   : in std_logic_vector(3 downto 0);
        wb_zf0_data  : in std_logic;
        wb_zf1_valid : in std_logic;
        wb_zf1_tag   : in std_logic_vector(3 downto 0);
        wb_zf1_data  : in std_logic;
        wb_zf2_valid : in std_logic;
        wb_zf2_tag   : in std_logic_vector(3 downto 0);
        wb_zf2_data  : in std_logic;

        commit0_zf_valid : in std_logic;
        commit0_zf_tag : in std_logic_vector(3 downto 0);
        commit1_zf_valid : in std_logic;
        commit1_zf_tag : in std_logic_vector(3 downto 0);

        rename0_zf_tag : out std_logic_vector(3 downto 0);
        rename1_zf_tag : out std_logic_vector(3 downto 0);

        s0_zf_rrf : out std_logic;
        s0_zf_tag : out std_logic_vector(3 downto 0);
        s0_zf_ready : out std_logic;
        s0_zf_val : out std_logic;

        s1_zf_rrf : out std_logic;
        s1_zf_tag : out std_logic_vector(3 downto 0);
        s1_zf_ready : out std_logic;
        s1_zf_val : out std_logic
    );
end entity regfile;

architecture rtl of regfile is

    constant NUM_ARF : integer := 8;
    constant NUM_RRF : integer := 16;
    constant NUM_WB  : integer := 3;

    subtype tag_t is std_logic_vector(3 downto 0);

    type sl_array_16_t is array (0 to NUM_RRF - 1) of std_logic;
    type slv16_array_t is array (0 to NUM_RRF - 1) of std_logic_vector(15 downto 0);
    type tag16_array_t is array (0 to NUM_RRF - 1) of tag_t;
    type arf_value_array_t is array (0 to NUM_ARF - 1) of std_logic_vector(15 downto 0);
    type arf_valid_array_t is array (0 to NUM_ARF - 1) of std_logic;
    type tag8_array_t is array (0 to NUM_ARF - 1) of tag_t;

    type tag3_array_t is array (0 to 2) of tag_t;
    type data3_array_t is array (0 to 2) of std_logic_vector(15 downto 0);
    type sl3_array_t is array (0 to 2) of std_logic;

    signal wb_valid_s  : sl3_array_t;
    signal wb_tag_s    : tag3_array_t;
    signal wb_data_s   : data3_array_t;

    signal wb_cf_valid_s : sl3_array_t;
    signal wb_cf_tag_s   : tag3_array_t;
    signal wb_cf_data_s  : sl3_array_t;

    signal wb_zf_valid_s : sl3_array_t;
    signal wb_zf_tag_s   : tag3_array_t;
    signal wb_zf_data_s  : sl3_array_t;

    signal rrf_valid    : sl_array_16_t;
    signal rrf_value    : slv16_array_t;
    signal rrf_busy     : sl_array_16_t;

    signal arf_value    : arf_value_array_t;
    signal arf_valid    : arf_valid_array_t;
    signal arf_last_tag : tag8_array_t;

    signal free_q        : tag16_array_t;
    signal free_d        : tag16_array_t;
    signal free_head_q   : tag_t;
    signal free_head_d   : tag_t;
    signal free_tail_q   : tag_t;
    signal free_tail_d   : tag_t;
    signal free_count_q  : std_logic_vector(4 downto 0);
    signal free_count_d  : std_logic_vector(4 downto 0);

    signal rename0_tag_d : tag_t;
    signal rename1_tag_d : tag_t;

    signal cf_rrf_valid    : sl_array_16_t;
    signal cf_rrf_value    : sl_array_16_t;
    signal cf_rrf_busy     : sl_array_16_t;

    signal cf_arf_value    : std_logic;
    signal cf_arf_valid    : std_logic;
    signal cf_arf_last_tag : tag_t;

    signal cf_free_q        : tag16_array_t;
    signal cf_free_d        : tag16_array_t;
    signal cf_free_head_q   : tag_t;
    signal cf_free_head_d   : tag_t;
    signal cf_free_tail_q   : tag_t;
    signal cf_free_tail_d   : tag_t;
    signal cf_free_count_q  : std_logic_vector(4 downto 0);
    signal cf_free_count_d  : std_logic_vector(4 downto 0);

    signal rename0_cf_tag_d : tag_t;
    signal rename1_cf_tag_d : tag_t;

    signal zf_rrf_valid    : sl_array_16_t;
    signal zf_rrf_value    : sl_array_16_t;
    signal zf_rrf_busy     : sl_array_16_t;

    signal zf_arf_value    : std_logic;
    signal zf_arf_valid    : std_logic;
    signal zf_arf_last_tag : tag_t;

    signal zf_free_q        : tag16_array_t;
    signal zf_free_d        : tag16_array_t;
    signal zf_free_head_q   : tag_t;
    signal zf_free_head_d   : tag_t;
    signal zf_free_tail_q   : tag_t;
    signal zf_free_tail_d   : tag_t;
    signal zf_free_count_q  : std_logic_vector(4 downto 0);
    signal zf_free_count_d  : std_logic_vector(4 downto 0);

    signal rename0_zf_tag_d : tag_t;
    signal rename1_zf_tag_d : tag_t;

    function int_phys_ready(
        tag_i : tag_t;
        rrf_valid_i : sl_array_16_t;
        wb_valid_i : sl3_array_t;
        wb_tag_i : tag3_array_t
    ) return std_logic is
        variable idx : integer;
    begin
        idx := to_integer(unsigned(tag_i));
        if rrf_valid_i(idx) = '1' then
            return '1';
        elsif (wb_valid_i(0) = '1') and (wb_tag_i(0) = tag_i) then
            return '1';
        elsif (wb_valid_i(1) = '1') and (wb_tag_i(1) = tag_i) then
            return '1';
        elsif (wb_valid_i(2) = '1') and (wb_tag_i(2) = tag_i) then
            return '1';
        else
            return '0';
        end if;
    end function;

    function int_phys_value(
        tag_i : tag_t;
        rrf_value_i : slv16_array_t;
        wb_valid_i : sl3_array_t;
        wb_tag_i : tag3_array_t;
        wb_data_i : data3_array_t
    ) return std_logic_vector is
        variable idx : integer;
    begin
        if (wb_valid_i(0) = '1') and (wb_tag_i(0) = tag_i) then
            return wb_data_i(0);
        elsif (wb_valid_i(1) = '1') and (wb_tag_i(1) = tag_i) then
            return wb_data_i(1);
        elsif (wb_valid_i(2) = '1') and (wb_tag_i(2) = tag_i) then
            return wb_data_i(2);
        else
            idx := to_integer(unsigned(tag_i));
            return rrf_value_i(idx);
        end if;
    end function;

    function cf_phys_ready(
        tag_i : tag_t;
        rrf_valid_i : sl_array_16_t;
        wb_valid_i : sl3_array_t;
        wb_tag_i : tag3_array_t
    ) return std_logic is
        variable idx : integer;
    begin
        idx := to_integer(unsigned(tag_i));
        if rrf_valid_i(idx) = '1' then
            return '1';
        elsif (wb_valid_i(0) = '1') and (wb_tag_i(0) = tag_i) then
            return '1';
        elsif (wb_valid_i(1) = '1') and (wb_tag_i(1) = tag_i) then
            return '1';
        elsif (wb_valid_i(2) = '1') and (wb_tag_i(2) = tag_i) then
            return '1';
        else
            return '0';
        end if;
    end function;

    function cf_phys_value(
        tag_i : tag_t;
        rrf_value_i : sl_array_16_t;
        wb_valid_i : sl3_array_t;
        wb_tag_i : tag3_array_t;
        wb_data_i : sl3_array_t
    ) return std_logic is
        variable idx : integer;
    begin
        if (wb_valid_i(0) = '1') and (wb_tag_i(0) = tag_i) then
            return wb_data_i(0);
        elsif (wb_valid_i(1) = '1') and (wb_tag_i(1) = tag_i) then
            return wb_data_i(1);
        elsif (wb_valid_i(2) = '1') and (wb_tag_i(2) = tag_i) then
            return wb_data_i(2);
        else
            idx := to_integer(unsigned(tag_i));
            return rrf_value_i(idx);
        end if;
    end function;

    function zf_phys_ready(
        tag_i : tag_t;
        rrf_valid_i : sl_array_16_t;
        wb_valid_i : sl3_array_t;
        wb_tag_i : tag3_array_t
    ) return std_logic is
        variable idx : integer;
    begin
        idx := to_integer(unsigned(tag_i));
        if rrf_valid_i(idx) = '1' then
            return '1';
        elsif (wb_valid_i(0) = '1') and (wb_tag_i(0) = tag_i) then
            return '1';
        elsif (wb_valid_i(1) = '1') and (wb_tag_i(1) = tag_i) then
            return '1';
        elsif (wb_valid_i(2) = '1') and (wb_tag_i(2) = tag_i) then
            return '1';
        else
            return '0';
        end if;
    end function;

    function zf_phys_value(
        tag_i : tag_t;
        rrf_value_i : sl_array_16_t;
        wb_valid_i : sl3_array_t;
        wb_tag_i : tag3_array_t;
        wb_data_i : sl3_array_t
    ) return std_logic is
        variable idx : integer;
    begin
        if (wb_valid_i(0) = '1') and (wb_tag_i(0) = tag_i) then
            return wb_data_i(0);
        elsif (wb_valid_i(1) = '1') and (wb_tag_i(1) = tag_i) then
            return wb_data_i(1);
        elsif (wb_valid_i(2) = '1') and (wb_tag_i(2) = tag_i) then
            return wb_data_i(2);
        else
            idx := to_integer(unsigned(tag_i));
            return rrf_value_i(idx);
        end if;
    end function;

begin

    wb_valid_s(0) <= wb0_valid;
    wb_valid_s(1) <= wb1_valid;
    wb_valid_s(2) <= wb2_valid;
    wb_tag_s(0) <= wb0_tag;
    wb_tag_s(1) <= wb1_tag;
    wb_tag_s(2) <= wb2_tag;
    wb_data_s(0) <= wb0_data;
    wb_data_s(1) <= wb1_data;
    wb_data_s(2) <= wb2_data;

    wb_cf_valid_s(0) <= wb_cf0_valid;
    wb_cf_valid_s(1) <= wb_cf1_valid;
    wb_cf_valid_s(2) <= wb_cf2_valid;
    wb_cf_tag_s(0) <= wb_cf0_tag;
    wb_cf_tag_s(1) <= wb_cf1_tag;
    wb_cf_tag_s(2) <= wb_cf2_tag;
    wb_cf_data_s(0) <= wb_cf0_data;
    wb_cf_data_s(1) <= wb_cf1_data;
    wb_cf_data_s(2) <= wb_cf2_data;

    wb_zf_valid_s(0) <= wb_zf0_valid;
    wb_zf_valid_s(1) <= wb_zf1_valid;
    wb_zf_valid_s(2) <= wb_zf2_valid;
    wb_zf_tag_s(0) <= wb_zf0_tag;
    wb_zf_tag_s(1) <= wb_zf1_tag;
    wb_zf_tag_s(2) <= wb_zf2_tag;
    wb_zf_data_s(0) <= wb_zf0_data;
    wb_zf_data_s(1) <= wb_zf1_data;
    wb_zf_data_s(2) <= wb_zf2_data;

    process(
        free_q, free_head_q, free_tail_q, free_count_q,
        rename0_fire, rename1_fire, rename0_arch, rename1_arch,
        src0_1_arch, src0_2_arch, src1_1_arch, src1_2_arch,
        wb_valid_s, wb_tag_s, wb_data_s,
        commit0_valid, commit0_arch, commit0_tag, commit1_valid, commit1_arch, commit1_tag,
        arf_valid, arf_value, arf_last_tag, rrf_valid, rrf_value
    )
        variable v_free_d : tag16_array_t;
        variable v_free_head_d : tag_t;
        variable v_free_tail_d : tag_t;
        variable v_free_count_d : std_logic_vector(4 downto 0);
        variable v_rename0_tag_d : tag_t;
        variable v_rename1_tag_d : tag_t;
        variable v_alloc_count : integer range 0 to 2;
        variable v_enq_count : integer range 0 to 2;
        variable idx : integer;
        variable src_idx : integer;
    begin
        for i in 0 to NUM_RRF - 1 loop
            v_free_d(i) := free_q(i);
        end loop;

        v_free_head_d := free_head_q;
        v_free_tail_d := free_tail_q;
        v_free_count_d := free_count_q;

        v_rename0_tag_d := free_q(to_integer(unsigned(free_head_q)));
        v_rename1_tag_d := free_q(to_integer(unsigned(free_head_q) + 1));

        v_alloc_count := 0;
        if rename0_fire = '1' then
            v_alloc_count := v_alloc_count + 1;
        end if;
        if rename1_fire = '1' then
            v_alloc_count := v_alloc_count + 1;
        end if;

        v_enq_count := 0;
        if commit0_valid = '1' then
            v_enq_count := v_enq_count + 1;
        end if;
        if commit1_valid = '1' then
            v_enq_count := v_enq_count + 1;
        end if;

        if commit0_valid = '1' then
            idx := to_integer(unsigned(free_tail_q));
            v_free_d(idx) := commit0_tag;
        end if;

        if commit1_valid = '1' then
            if commit0_valid = '1' then
                idx := to_integer(unsigned(free_tail_q) + 1);
            else
                idx := to_integer(unsigned(free_tail_q));
            end if;
            v_free_d(idx) := commit1_tag;
        end if;

        v_free_tail_d := std_logic_vector(unsigned(free_tail_q) + to_unsigned(v_enq_count, 4));
        v_free_head_d := std_logic_vector(unsigned(free_head_q) + to_unsigned(v_alloc_count, 4));
        v_free_count_d := std_logic_vector(unsigned(free_count_q) + to_unsigned(v_enq_count, 5) - to_unsigned(v_alloc_count, 5));

        free_count <= free_count_q;

        if rename0_fire = '1' then
            rename0_tag <= v_rename0_tag_d;
        else
            rename0_tag <= (others => '0');
        end if;

        if rename1_fire = '1' then
            if rename0_fire = '1' then
                rename1_tag <= v_rename1_tag_d;
            else
                rename1_tag <= v_rename0_tag_d;
            end if;
        else
            rename1_tag <= (others => '0');
        end if;

        if arf_valid(to_integer(unsigned(src0_1_arch))) = '1' then
            src_idx := to_integer(unsigned(src0_1_arch));
            s0_1_rrf <= '0';
            s0_1_tag <= arf_last_tag(src_idx);
            s0_1_ready <= '1';
            s0_1_val <= arf_value(src_idx);
        else
            src_idx := to_integer(unsigned(src0_1_arch));
            s0_1_rrf <= '1';
            s0_1_tag <= arf_last_tag(src_idx);
            s0_1_ready <= int_phys_ready(arf_last_tag(src_idx), rrf_valid, wb_valid_s, wb_tag_s);
            s0_1_val <= int_phys_value(arf_last_tag(src_idx), rrf_value, wb_valid_s, wb_tag_s, wb_data_s);
        end if;

        if arf_valid(to_integer(unsigned(src0_2_arch))) = '1' then
            src_idx := to_integer(unsigned(src0_2_arch));
            s0_2_rrf <= '0';
            s0_2_tag <= arf_last_tag(src_idx);
            s0_2_ready <= '1';
            s0_2_val <= arf_value(src_idx);
        else
            src_idx := to_integer(unsigned(src0_2_arch));
            s0_2_rrf <= '1';
            s0_2_tag <= arf_last_tag(src_idx);
            s0_2_ready <= int_phys_ready(arf_last_tag(src_idx), rrf_valid, wb_valid_s, wb_tag_s);
            s0_2_val <= int_phys_value(arf_last_tag(src_idx), rrf_value, wb_valid_s, wb_tag_s, wb_data_s);
        end if;

        if arf_valid(to_integer(unsigned(src1_1_arch))) = '1' then
            src_idx := to_integer(unsigned(src1_1_arch));
            s1_1_rrf <= '0';
            s1_1_tag <= arf_last_tag(src_idx);
            s1_1_ready <= '1';
            s1_1_val <= arf_value(src_idx);
        else
            src_idx := to_integer(unsigned(src1_1_arch));
            s1_1_rrf <= '1';
            s1_1_tag <= arf_last_tag(src_idx);
            s1_1_ready <= int_phys_ready(arf_last_tag(src_idx), rrf_valid, wb_valid_s, wb_tag_s);
            s1_1_val <= int_phys_value(arf_last_tag(src_idx), rrf_value, wb_valid_s, wb_tag_s, wb_data_s);
        end if;

        if arf_valid(to_integer(unsigned(src1_2_arch))) = '1' then
            src_idx := to_integer(unsigned(src1_2_arch));
            s1_2_rrf <= '0';
            s1_2_tag <= arf_last_tag(src_idx);
            s1_2_ready <= '1';
            s1_2_val <= arf_value(src_idx);
        else
            src_idx := to_integer(unsigned(src1_2_arch));
            s1_2_rrf <= '1';
            s1_2_tag <= arf_last_tag(src_idx);
            s1_2_ready <= int_phys_ready(arf_last_tag(src_idx), rrf_valid, wb_valid_s, wb_tag_s);
            s1_2_val <= int_phys_value(arf_last_tag(src_idx), rrf_value, wb_valid_s, wb_tag_s, wb_data_s);
        end if;

        for i in 0 to NUM_RRF - 1 loop
            free_d(i) <= v_free_d(i);
        end loop;
        free_head_d <= v_free_head_d;
        free_tail_d <= v_free_tail_d;
        free_count_d <= v_free_count_d;
        rename0_tag_d <= v_rename0_tag_d;
        rename1_tag_d <= v_rename1_tag_d;
    end process;

    process(clk, rst)
        variable aidx : integer;
    begin
        if rst = '1' then
            for i in 0 to NUM_RRF - 1 loop
                free_q(i) <= std_logic_vector(to_unsigned(i, 4));
                rrf_value(i) <= (others => '0');
                rrf_busy(i) <= '0';
                rrf_valid(i) <= '0';
            end loop;

            for i in 0 to NUM_ARF - 1 loop
                arf_value(i) <= (others => '0');
                arf_valid(i) <= '1';
                arf_last_tag(i) <= (others => '0');
            end loop;

            free_head_q <= (others => '0');
            free_tail_q <= (others => '0');
            free_count_q <= std_logic_vector(to_unsigned(NUM_RRF, 5));
        elsif clk'event and clk = '1' then
            for i in 0 to NUM_RRF - 1 loop
                free_q(i) <= free_d(i);
            end loop;

            free_head_q <= free_head_d;
            free_tail_q <= free_tail_d;
            free_count_q <= free_count_d;

            if redirect_valid = '1' then
                free_head_q <= (others => '0');
                free_tail_q <= (others => '0');
                free_count_q <= std_logic_vector(to_unsigned(NUM_RRF, 5));

                for i in 0 to NUM_RRF - 1 loop
                    free_q(i) <= std_logic_vector(to_unsigned(i, 4));
                    rrf_busy(i) <= '0';
                    rrf_valid(i) <= '0';
                end loop;

                for i in 0 to NUM_ARF - 1 loop
                    arf_valid(i) <= '1';
                end loop;
            end if;

            for w in 0 to NUM_WB - 1 loop
                if wb_valid_s(w) = '1' then
                    aidx := to_integer(unsigned(wb_tag_s(w)));
                    rrf_value(aidx) <= wb_data_s(w);
                    rrf_valid(aidx) <= '1';
                end if;
            end loop;

            if commit0_valid = '1' then
                aidx := to_integer(unsigned(commit0_arch));
                arf_value(aidx) <= int_phys_value(commit0_tag, rrf_value, wb_valid_s, wb_tag_s, wb_data_s);
                if arf_last_tag(aidx) = commit0_tag then
                    arf_valid(aidx) <= '1';
                end if;
                rrf_busy(to_integer(unsigned(commit0_tag))) <= '0';
                rrf_valid(to_integer(unsigned(commit0_tag))) <= '0';
            end if;

            if commit1_valid = '1' then
                aidx := to_integer(unsigned(commit1_arch));
                arf_value(aidx) <= int_phys_value(commit1_tag, rrf_value, wb_valid_s, wb_tag_s, wb_data_s);
                if arf_last_tag(aidx) = commit1_tag then
                    arf_valid(aidx) <= '1';
                end if;
                rrf_busy(to_integer(unsigned(commit1_tag))) <= '0';
                rrf_valid(to_integer(unsigned(commit1_tag))) <= '0';
            end if;

            if rename0_fire = '1' then
                aidx := to_integer(unsigned(rename0_arch));
                arf_valid(aidx) <= '0';
                arf_last_tag(aidx) <= rename0_tag_d;
                rrf_busy(to_integer(unsigned(rename0_tag_d))) <= '1';
                rrf_valid(to_integer(unsigned(rename0_tag_d))) <= '0';
            end if;

            if rename1_fire = '1' then
                aidx := to_integer(unsigned(rename1_arch));
                arf_valid(aidx) <= '0';
                if rename0_fire = '1' then
                    arf_last_tag(aidx) <= rename1_tag_d;
                    rrf_busy(to_integer(unsigned(rename1_tag_d))) <= '1';
                    rrf_valid(to_integer(unsigned(rename1_tag_d))) <= '0';
                else
                    arf_last_tag(aidx) <= rename0_tag_d;
                    rrf_busy(to_integer(unsigned(rename0_tag_d))) <= '1';
                    rrf_valid(to_integer(unsigned(rename0_tag_d))) <= '0';
                end if;
            end if;
        end if;
    end process;

    process(
        cf_free_q, cf_free_head_q, cf_free_tail_q, cf_free_count_q,
        rename0_cf_fire, rename1_cf_fire,
        wb_cf_valid_s, wb_cf_tag_s, wb_cf_data_s,
        commit0_cf_valid, commit0_cf_tag, commit1_cf_valid, commit1_cf_tag,
        cf_arf_valid, cf_arf_value, cf_arf_last_tag, cf_rrf_valid, cf_rrf_value
    )
        variable v_cf_free_d : tag16_array_t;
        variable v_cf_free_head_d : tag_t;
        variable v_cf_free_tail_d : tag_t;
        variable v_cf_free_count_d : std_logic_vector(4 downto 0);
        variable v_rename0_cf_tag_d : tag_t;
        variable v_rename1_cf_tag_d : tag_t;
        variable v_alloc_count : integer range 0 to 2;
        variable v_enq_count : integer range 0 to 2;
        variable idx : integer;
    begin
        for i in 0 to NUM_RRF - 1 loop
            v_cf_free_d(i) := cf_free_q(i);
        end loop;

        v_cf_free_head_d := cf_free_head_q;
        v_cf_free_tail_d := cf_free_tail_q;
        v_cf_free_count_d := cf_free_count_q;

        v_rename0_cf_tag_d := cf_free_q(to_integer(unsigned(cf_free_head_q)));
        v_rename1_cf_tag_d := cf_free_q(to_integer(unsigned(cf_free_head_q) + 1));

        v_alloc_count := 0;
        if rename0_cf_fire = '1' then
            v_alloc_count := v_alloc_count + 1;
        end if;
        if rename1_cf_fire = '1' then
            v_alloc_count := v_alloc_count + 1;
        end if;

        v_enq_count := 0;
        if commit0_cf_valid = '1' then
            v_enq_count := v_enq_count + 1;
        end if;
        if commit1_cf_valid = '1' then
            v_enq_count := v_enq_count + 1;
        end if;

        if commit0_cf_valid = '1' then
            idx := to_integer(unsigned(cf_free_tail_q));
            v_cf_free_d(idx) := commit0_cf_tag;
        end if;

        if commit1_cf_valid = '1' then
            if commit0_cf_valid = '1' then
                idx := to_integer(unsigned(cf_free_tail_q) + 1);
            else
                idx := to_integer(unsigned(cf_free_tail_q));
            end if;
            v_cf_free_d(idx) := commit1_cf_tag;
        end if;

        v_cf_free_tail_d := std_logic_vector(unsigned(cf_free_tail_q) + to_unsigned(v_enq_count, 4));
        v_cf_free_head_d := std_logic_vector(unsigned(cf_free_head_q) + to_unsigned(v_alloc_count, 4));
        v_cf_free_count_d := std_logic_vector(unsigned(cf_free_count_q) + to_unsigned(v_enq_count, 5) - to_unsigned(v_alloc_count, 5));

        cf_free_count <= cf_free_count_q;

        if rename0_cf_fire = '1' then
            rename0_cf_tag <= v_rename0_cf_tag_d;
        else
            rename0_cf_tag <= (others => '0');
        end if;

        if rename1_cf_fire = '1' then
            if rename0_cf_fire = '1' then
                rename1_cf_tag <= v_rename1_cf_tag_d;
            else
                rename1_cf_tag <= v_rename0_cf_tag_d;
            end if;
        else
            rename1_cf_tag <= (others => '0');
        end if;

        if cf_arf_valid = '1' then
            s0_cf_rrf <= '0';
            s0_cf_tag <= cf_arf_last_tag;
            s0_cf_ready <= '1';
            s0_cf_val <= cf_arf_value;
        else
            s0_cf_rrf <= '1';
            s0_cf_tag <= cf_arf_last_tag;
            s0_cf_ready <= cf_phys_ready(cf_arf_last_tag, cf_rrf_valid, wb_cf_valid_s, wb_cf_tag_s);
            s0_cf_val <= cf_phys_value(cf_arf_last_tag, cf_rrf_value, wb_cf_valid_s, wb_cf_tag_s, wb_cf_data_s);
        end if;

        if cf_arf_valid = '1' then
            s1_cf_rrf <= '0';
            s1_cf_tag <= cf_arf_last_tag;
            s1_cf_ready <= '1';
            s1_cf_val <= cf_arf_value;
        else
            s1_cf_rrf <= '1';
            s1_cf_tag <= cf_arf_last_tag;
            s1_cf_ready <= cf_phys_ready(cf_arf_last_tag, cf_rrf_valid, wb_cf_valid_s, wb_cf_tag_s);
            s1_cf_val <= cf_phys_value(cf_arf_last_tag, cf_rrf_value, wb_cf_valid_s, wb_cf_tag_s, wb_cf_data_s);
        end if;

        for i in 0 to NUM_RRF - 1 loop
            cf_free_d(i) <= v_cf_free_d(i);
        end loop;
        cf_free_head_d <= v_cf_free_head_d;
        cf_free_tail_d <= v_cf_free_tail_d;
        cf_free_count_d <= v_cf_free_count_d;
        rename0_cf_tag_d <= v_rename0_cf_tag_d;
        rename1_cf_tag_d <= v_rename1_cf_tag_d;
    end process;

    process(clk, rst)
        variable aidx : integer;
    begin
        if rst = '1' then
            for i in 0 to NUM_RRF - 1 loop
                cf_free_q(i) <= std_logic_vector(to_unsigned(i, 4));
                cf_rrf_value(i) <= '0';
                cf_rrf_busy(i) <= '0';
                cf_rrf_valid(i) <= '0';
            end loop;

            cf_free_head_q <= (others => '0');
            cf_free_tail_q <= (others => '0');
            cf_free_count_q <= std_logic_vector(to_unsigned(NUM_RRF, 5));
            cf_arf_value <= '0';
            cf_arf_valid <= '1';
            cf_arf_last_tag <= (others => '0');
        elsif clk'event and clk = '1' then
            for i in 0 to NUM_RRF - 1 loop
                cf_free_q(i) <= cf_free_d(i);
            end loop;

            cf_free_head_q <= cf_free_head_d;
            cf_free_tail_q <= cf_free_tail_d;
            cf_free_count_q <= cf_free_count_d;

            if redirect_valid = '1' then
                cf_free_head_q <= (others => '0');
                cf_free_tail_q <= (others => '0');
                cf_free_count_q <= std_logic_vector(to_unsigned(NUM_RRF, 5));
                cf_arf_valid <= '1';

                for i in 0 to NUM_RRF - 1 loop
                    cf_free_q(i) <= std_logic_vector(to_unsigned(i, 4));
                    cf_rrf_busy(i) <= '0';
                    cf_rrf_valid(i) <= '0';
                end loop;
            end if;

            for w in 0 to NUM_WB - 1 loop
                if wb_cf_valid_s(w) = '1' then
                    aidx := to_integer(unsigned(wb_cf_tag_s(w)));
                    cf_rrf_value(aidx) <= wb_cf_data_s(w);
                    cf_rrf_valid(aidx) <= '1';
                end if;
            end loop;

            if commit0_cf_valid = '1' then
                cf_arf_value <= cf_phys_value(commit0_cf_tag, cf_rrf_value, wb_cf_valid_s, wb_cf_tag_s, wb_cf_data_s);
                if cf_arf_last_tag = commit0_cf_tag then
                    cf_arf_valid <= '1';
                end if;
                cf_rrf_busy(to_integer(unsigned(commit0_cf_tag))) <= '0';
                cf_rrf_valid(to_integer(unsigned(commit0_cf_tag))) <= '0';
            end if;

            if commit1_cf_valid = '1' then
                cf_arf_value <= cf_phys_value(commit1_cf_tag, cf_rrf_value, wb_cf_valid_s, wb_cf_tag_s, wb_cf_data_s);
                if cf_arf_last_tag = commit1_cf_tag then
                    cf_arf_valid <= '1';
                end if;
                cf_rrf_busy(to_integer(unsigned(commit1_cf_tag))) <= '0';
                cf_rrf_valid(to_integer(unsigned(commit1_cf_tag))) <= '0';
            end if;

            if rename0_cf_fire = '1' then
                cf_arf_valid <= '0';
                cf_arf_last_tag <= rename0_cf_tag_d;
                cf_rrf_busy(to_integer(unsigned(rename0_cf_tag_d))) <= '1';
                cf_rrf_valid(to_integer(unsigned(rename0_cf_tag_d))) <= '0';
            end if;

            if rename1_cf_fire = '1' then
                cf_arf_valid <= '0';
                if rename0_cf_fire = '1' then
                    cf_arf_last_tag <= rename1_cf_tag_d;
                    cf_rrf_busy(to_integer(unsigned(rename1_cf_tag_d))) <= '1';
                    cf_rrf_valid(to_integer(unsigned(rename1_cf_tag_d))) <= '0';
                else
                    cf_arf_last_tag <= rename0_cf_tag_d;
                    cf_rrf_busy(to_integer(unsigned(rename0_cf_tag_d))) <= '1';
                    cf_rrf_valid(to_integer(unsigned(rename0_cf_tag_d))) <= '0';
                end if;
            end if;
        end if;
    end process;

    process(
        zf_free_q, zf_free_head_q, zf_free_tail_q, zf_free_count_q,
        rename0_zf_fire, rename1_zf_fire,
        wb_zf_valid_s, wb_zf_tag_s, wb_zf_data_s,
        commit0_zf_valid, commit0_zf_tag, commit1_zf_valid, commit1_zf_tag,
        zf_arf_valid, zf_arf_value, zf_arf_last_tag, zf_rrf_valid, zf_rrf_value
    )
        variable v_zf_free_d : tag16_array_t;
        variable v_zf_free_head_d : tag_t;
        variable v_zf_free_tail_d : tag_t;
        variable v_zf_free_count_d : std_logic_vector(4 downto 0);
        variable v_rename0_zf_tag_d : tag_t;
        variable v_rename1_zf_tag_d : tag_t;
        variable v_alloc_count : integer range 0 to 2;
        variable v_enq_count : integer range 0 to 2;
        variable idx : integer;
    begin
        for i in 0 to NUM_RRF - 1 loop
            v_zf_free_d(i) := zf_free_q(i);
        end loop;

        v_zf_free_head_d := zf_free_head_q;
        v_zf_free_tail_d := zf_free_tail_q;
        v_zf_free_count_d := zf_free_count_q;

        v_rename0_zf_tag_d := zf_free_q(to_integer(unsigned(zf_free_head_q)));
        v_rename1_zf_tag_d := zf_free_q(to_integer(unsigned(zf_free_head_q) + 1));

        v_alloc_count := 0;
        if rename0_zf_fire = '1' then
            v_alloc_count := v_alloc_count + 1;
        end if;
        if rename1_zf_fire = '1' then
            v_alloc_count := v_alloc_count + 1;
        end if;

        v_enq_count := 0;
        if commit0_zf_valid = '1' then
            v_enq_count := v_enq_count + 1;
        end if;
        if commit1_zf_valid = '1' then
            v_enq_count := v_enq_count + 1;
        end if;

        if commit0_zf_valid = '1' then
            idx := to_integer(unsigned(zf_free_tail_q));
            v_zf_free_d(idx) := commit0_zf_tag;
        end if;

        if commit1_zf_valid = '1' then
            if commit0_zf_valid = '1' then
                idx := to_integer(unsigned(zf_free_tail_q) + 1);
            else
                idx := to_integer(unsigned(zf_free_tail_q));
            end if;
            v_zf_free_d(idx) := commit1_zf_tag;
        end if;

        v_zf_free_tail_d := std_logic_vector(unsigned(zf_free_tail_q) + to_unsigned(v_enq_count, 4));
        v_zf_free_head_d := std_logic_vector(unsigned(zf_free_head_q) + to_unsigned(v_alloc_count, 4));
        v_zf_free_count_d := std_logic_vector(unsigned(zf_free_count_q) + to_unsigned(v_enq_count, 5) - to_unsigned(v_alloc_count, 5));

        zf_free_count <= zf_free_count_q;

        if rename0_zf_fire = '1' then
            rename0_zf_tag <= v_rename0_zf_tag_d;
        else
            rename0_zf_tag <= (others => '0');
        end if;

        if rename1_zf_fire = '1' then
            if rename0_zf_fire = '1' then
                rename1_zf_tag <= v_rename1_zf_tag_d;
            else
                rename1_zf_tag <= v_rename0_zf_tag_d;
            end if;
        else
            rename1_zf_tag <= (others => '0');
        end if;

        if zf_arf_valid = '1' then
            s0_zf_rrf <= '0';
            s0_zf_tag <= zf_arf_last_tag;
            s0_zf_ready <= '1';
            s0_zf_val <= zf_arf_value;
        else
            s0_zf_rrf <= '1';
            s0_zf_tag <= zf_arf_last_tag;
            s0_zf_ready <= zf_phys_ready(zf_arf_last_tag, zf_rrf_valid, wb_zf_valid_s, wb_zf_tag_s);
            s0_zf_val <= zf_phys_value(zf_arf_last_tag, zf_rrf_value, wb_zf_valid_s, wb_zf_tag_s, wb_zf_data_s);
        end if;

        if zf_arf_valid = '1' then
            s1_zf_rrf <= '0';
            s1_zf_tag <= zf_arf_last_tag;
            s1_zf_ready <= '1';
            s1_zf_val <= zf_arf_value;
        else
            s1_zf_rrf <= '1';
            s1_zf_tag <= zf_arf_last_tag;
            s1_zf_ready <= zf_phys_ready(zf_arf_last_tag, zf_rrf_valid, wb_zf_valid_s, wb_zf_tag_s);
            s1_zf_val <= zf_phys_value(zf_arf_last_tag, zf_rrf_value, wb_zf_valid_s, wb_zf_tag_s, wb_zf_data_s);
        end if;

        for i in 0 to NUM_RRF - 1 loop
            zf_free_d(i) <= v_zf_free_d(i);
        end loop;
        zf_free_head_d <= v_zf_free_head_d;
        zf_free_tail_d <= v_zf_free_tail_d;
        zf_free_count_d <= v_zf_free_count_d;
        rename0_zf_tag_d <= v_rename0_zf_tag_d;
        rename1_zf_tag_d <= v_rename1_zf_tag_d;
    end process;

    process(clk, rst)
        variable aidx : integer;
    begin
        if rst = '1' then
            for i in 0 to NUM_RRF - 1 loop
                zf_free_q(i) <= std_logic_vector(to_unsigned(i, 4));
                zf_rrf_value(i) <= '0';
                zf_rrf_busy(i) <= '0';
                zf_rrf_valid(i) <= '0';
            end loop;

            zf_free_head_q <= (others => '0');
            zf_free_tail_q <= (others => '0');
            zf_free_count_q <= std_logic_vector(to_unsigned(NUM_RRF, 5));
            zf_arf_value <= '0';
            zf_arf_valid <= '1';
            zf_arf_last_tag <= (others => '0');
        elsif clk'event and clk = '1' then
            for i in 0 to NUM_RRF - 1 loop
                zf_free_q(i) <= zf_free_d(i);
            end loop;

            zf_free_head_q <= zf_free_head_d;
            zf_free_tail_q <= zf_free_tail_d;
            zf_free_count_q <= zf_free_count_d;

            if redirect_valid = '1' then
                zf_free_head_q <= (others => '0');
                zf_free_tail_q <= (others => '0');
                zf_free_count_q <= std_logic_vector(to_unsigned(NUM_RRF, 5));
                zf_arf_valid <= '1';

                for i in 0 to NUM_RRF - 1 loop
                    zf_free_q(i) <= std_logic_vector(to_unsigned(i, 4));
                    zf_rrf_busy(i) <= '0';
                    zf_rrf_valid(i) <= '0';
                end loop;
            end if;

            for w in 0 to NUM_WB - 1 loop
                if wb_zf_valid_s(w) = '1' then
                    aidx := to_integer(unsigned(wb_zf_tag_s(w)));
                    zf_rrf_value(aidx) <= wb_zf_data_s(w);
                    zf_rrf_valid(aidx) <= '1';
                end if;
            end loop;

            if commit0_zf_valid = '1' then
                zf_arf_value <= zf_phys_value(commit0_zf_tag, zf_rrf_value, wb_zf_valid_s, wb_zf_tag_s, wb_zf_data_s);
                if zf_arf_last_tag = commit0_zf_tag then
                    zf_arf_valid <= '1';
                end if;
                zf_rrf_busy(to_integer(unsigned(commit0_zf_tag))) <= '0';
                zf_rrf_valid(to_integer(unsigned(commit0_zf_tag))) <= '0';
            end if;

            if commit1_zf_valid = '1' then
                zf_arf_value <= zf_phys_value(commit1_zf_tag, zf_rrf_value, wb_zf_valid_s, wb_zf_tag_s, wb_zf_data_s);
                if zf_arf_last_tag = commit1_zf_tag then
                    zf_arf_valid <= '1';
                end if;
                zf_rrf_busy(to_integer(unsigned(commit1_zf_tag))) <= '0';
                zf_rrf_valid(to_integer(unsigned(commit1_zf_tag))) <= '0';
            end if;

            if rename0_zf_fire = '1' then
                zf_arf_valid <= '0';
                zf_arf_last_tag <= rename0_zf_tag_d;
                zf_rrf_busy(to_integer(unsigned(rename0_zf_tag_d))) <= '1';
                zf_rrf_valid(to_integer(unsigned(rename0_zf_tag_d))) <= '0';
            end if;

            if rename1_zf_fire = '1' then
                zf_arf_valid <= '0';
                if rename0_zf_fire = '1' then
                    zf_arf_last_tag <= rename1_zf_tag_d;
                    zf_rrf_busy(to_integer(unsigned(rename1_zf_tag_d))) <= '1';
                    zf_rrf_valid(to_integer(unsigned(rename1_zf_tag_d))) <= '0';
                else
                    zf_arf_last_tag <= rename0_zf_tag_d;
                    zf_rrf_busy(to_integer(unsigned(rename0_zf_tag_d))) <= '1';
                    zf_rrf_valid(to_integer(unsigned(rename0_zf_tag_d))) <= '0';
                end if;
            end if;
        end if;
    end process;

end architecture rtl;