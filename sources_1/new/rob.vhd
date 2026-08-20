library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rob_stage is
    port (
        clk  : in  std_logic;
        rst  : in  std_logic;

        alloc0_fire  : in  std_logic;
        alloc1_fire  : in  std_logic;
        alloc0_query : in  std_logic_vector(3 downto 0);
        alloc1_query : in  std_logic_vector(3 downto 0);

        rob_count  : out std_logic_vector(4 downto 0);
        alloc0_idx : out std_logic_vector(3 downto 0);
        alloc1_idx : out std_logic_vector(3 downto 0);

        alloc0_dest_en  : in std_logic;
        alloc1_dest_en  : in std_logic;
        alloc0_arch     : in std_logic_vector(2 downto 0);
        alloc1_arch     : in std_logic_vector(2 downto 0);
        alloc0_dest_tag : in std_logic_vector(3 downto 0);
        alloc1_dest_tag : in std_logic_vector(3 downto 0);

        alloc0_carry_en  : in std_logic;
        alloc1_carry_en  : in std_logic;
        alloc0_carry_tag : in std_logic_vector(3 downto 0);
        alloc1_carry_tag : in std_logic_vector(3 downto 0);
        alloc0_zero_en   : in std_logic;
        alloc1_zero_en   : in std_logic;
        alloc0_zero_tag  : in std_logic_vector(3 downto 0);
        alloc1_zero_tag  : in std_logic_vector(3 downto 0);

        alloc0_is_store  : in std_logic;
        alloc1_is_store  : in std_logic;
        alloc0_is_load   : in std_logic;
        alloc1_is_load   : in std_logic;
        alloc0_is_branch : in std_logic;
        alloc1_is_branch : in std_logic;

        ex0_valid         : in std_logic;
        ex0_idx           : in std_logic_vector(3 downto 0);
        ex0_is_branch     : in std_logic;
        ex0_branch_taken  : in std_logic;
        ex0_branch_target : in std_logic_vector(15 downto 0);

        ex1_valid         : in std_logic;
        ex1_idx           : in std_logic_vector(3 downto 0);
        ex1_is_branch     : in std_logic;
        ex1_branch_taken  : in std_logic;
        ex1_branch_target : in std_logic_vector(15 downto 0);

        ex2_valid         : in std_logic;
        ex2_idx           : in std_logic_vector(3 downto 0);
        ex2_is_branch     : in std_logic;
        ex2_branch_taken  : in std_logic;
        ex2_branch_target : in std_logic_vector(15 downto 0);

        commit0_valid : out std_logic;
        commit0_arch  : out std_logic_vector(2 downto 0);
        commit0_tag   : out std_logic_vector(3 downto 0);

        commit1_valid : out std_logic;
        commit1_arch  : out std_logic_vector(2 downto 0);
        commit1_tag   : out std_logic_vector(3 downto 0);

        commit0_cf_valid : out std_logic;
        commit0_cf_tag   : out std_logic_vector(3 downto 0);
        commit1_cf_valid : out std_logic;
        commit1_cf_tag   : out std_logic_vector(3 downto 0);

        commit0_zf_valid : out std_logic;
        commit0_zf_tag   : out std_logic_vector(3 downto 0);
        commit1_zf_valid : out std_logic;
        commit1_zf_tag   : out std_logic_vector(3 downto 0);

        rob_head_valid   : out std_logic;
        rob_head_idx     : out std_logic_vector(3 downto 0);
        rob_head_is_store : out std_logic;

        redirect_valid  : out std_logic;
        redirect_target : out std_logic_vector(15 downto 0)
    );
end entity rob_stage;

architecture rtl of rob_stage is
    constant ROB_DEPTH : integer := 16;

    subtype rob_ptr_t   is unsigned(3 downto 0);
    subtype rob_count_t is unsigned(4 downto 0);

    type rob_row_t is record
        valid         : std_logic;
        ready         : std_logic;
        dest_en       : std_logic;
        rd_arch       : std_logic_vector(2 downto 0);
        dest_tag      : std_logic_vector(3 downto 0);
        carry_en      : std_logic;
        carry_tag     : std_logic_vector(3 downto 0);
        zero_en       : std_logic;
        zero_tag      : std_logic_vector(3 downto 0);
        is_store      : std_logic;
        is_load       : std_logic;
        is_branch     : std_logic;
        branch_taken  : std_logic;
        branch_target : std_logic_vector(15 downto 0);
    end record;

    type rob_mem_t is array (0 to ROB_DEPTH - 1) of rob_row_t;

    signal rob_r : rob_mem_t;
    signal head_ptr_r : rob_ptr_t;
    signal tail_ptr_r : rob_ptr_t;
    signal count_r : rob_count_t;

    signal rob_n : rob_mem_t;
    signal head_ptr_n : rob_ptr_t;
    signal tail_ptr_n : rob_ptr_t;
    signal count_n : rob_count_t;

    signal commit0_valid_r : std_logic;
    signal commit0_arch_r  : std_logic_vector(2 downto 0);
    signal commit0_tag_r   : std_logic_vector(3 downto 0);
    signal commit1_valid_r : std_logic;
    signal commit1_arch_r  : std_logic_vector(2 downto 0);
    signal commit1_tag_r   : std_logic_vector(3 downto 0);

    signal commit0_cf_valid_r : std_logic;
    signal commit0_cf_tag_r   : std_logic_vector(3 downto 0);
    signal commit1_cf_valid_r : std_logic;
    signal commit1_cf_tag_r   : std_logic_vector(3 downto 0);

    signal commit0_zf_valid_r : std_logic;
    signal commit0_zf_tag_r   : std_logic_vector(3 downto 0);
    signal commit1_zf_valid_r : std_logic;
    signal commit1_zf_tag_r   : std_logic_vector(3 downto 0);

    signal commit0_valid_n : std_logic;
    signal commit0_arch_n  : std_logic_vector(2 downto 0);
    signal commit0_tag_n   : std_logic_vector(3 downto 0);
    signal commit1_valid_n : std_logic;
    signal commit1_arch_n  : std_logic_vector(2 downto 0);
    signal commit1_tag_n   : std_logic_vector(3 downto 0);

    signal commit0_cf_valid_n : std_logic;
    signal commit0_cf_tag_n   : std_logic_vector(3 downto 0);
    signal commit1_cf_valid_n : std_logic;
    signal commit1_cf_tag_n   : std_logic_vector(3 downto 0);

    signal commit0_zf_valid_n : std_logic;
    signal commit0_zf_tag_n   : std_logic_vector(3 downto 0);
    signal commit1_zf_valid_n : std_logic;
    signal commit1_zf_tag_n   : std_logic_vector(3 downto 0);

    signal redirect_valid_n  : std_logic;
    signal redirect_target_n : std_logic_vector(15 downto 0);
    signal redirect_valid_r  : std_logic;
    signal redirect_target_r : std_logic_vector(15 downto 0);

begin
    commit0_valid <= commit0_valid_r;
    commit0_arch  <= commit0_arch_r;
    commit0_tag   <= commit0_tag_r;
    commit1_valid <= commit1_valid_r;
    commit1_arch  <= commit1_arch_r;
    commit1_tag   <= commit1_tag_r;

    commit0_cf_valid <= commit0_cf_valid_r;
    commit0_cf_tag   <= commit0_cf_tag_r;
    commit1_cf_valid <= commit1_cf_valid_r;
    commit1_cf_tag   <= commit1_cf_tag_r;

    commit0_zf_valid <= commit0_zf_valid_r;
    commit0_zf_tag   <= commit0_zf_tag_r;
    commit1_zf_valid <= commit1_zf_valid_r;
    commit1_zf_tag   <= commit1_zf_tag_r;

    redirect_valid  <= redirect_valid_r;
    redirect_target <= redirect_target_r;

    process(rob_r, head_ptr_r, tail_ptr_r, count_r,
            alloc0_fire, alloc1_fire,
            alloc0_query, alloc1_query,
            alloc0_dest_en, alloc1_dest_en,
            alloc0_arch, alloc1_arch,
            alloc0_dest_tag, alloc1_dest_tag,
            alloc0_carry_en, alloc1_carry_en,
            alloc0_carry_tag, alloc1_carry_tag,
            alloc0_zero_en, alloc1_zero_en,
            alloc0_zero_tag, alloc1_zero_tag,
            alloc0_is_store, alloc1_is_store,
            alloc0_is_load, alloc1_is_load,
            alloc0_is_branch, alloc1_is_branch,
            ex0_valid, ex0_idx, ex0_is_branch, ex0_branch_taken, ex0_branch_target,
            ex1_valid, ex1_idx, ex1_is_branch, ex1_branch_taken, ex1_branch_target,
            ex2_valid, ex2_idx, ex2_is_branch, ex2_branch_taken, ex2_branch_target)
        variable v_rob : rob_mem_t;
        variable v_head_ptr : rob_ptr_t;
        variable v_tail_ptr : rob_ptr_t;
        variable v_count : rob_count_t;
        variable v_head_row_idx : rob_ptr_t;
        variable v_head1_row_idx : rob_ptr_t;
        variable v_head_row : rob_row_t;
        variable v_head1_row : rob_row_t;
        variable v_commit0_valid : std_logic;
        variable v_commit0_arch  : std_logic_vector(2 downto 0);
        variable v_commit0_tag   : std_logic_vector(3 downto 0);
        variable v_commit1_valid : std_logic;
        variable v_commit1_arch  : std_logic_vector(2 downto 0);
        variable v_commit1_tag   : std_logic_vector(3 downto 0);
        variable v_commit0_cf_valid : std_logic;
        variable v_commit0_cf_tag   : std_logic_vector(3 downto 0);
        variable v_commit1_cf_valid : std_logic;
        variable v_commit1_cf_tag   : std_logic_vector(3 downto 0);
        variable v_commit0_zf_valid : std_logic;
        variable v_commit0_zf_tag   : std_logic_vector(3 downto 0);
        variable v_commit1_zf_valid : std_logic;
        variable v_commit1_zf_tag   : std_logic_vector(3 downto 0);
        variable v_redirect_valid  : std_logic;
        variable v_redirect_target : std_logic_vector(15 downto 0);
        variable v_alloc_used : rob_ptr_t;
    begin
        v_rob := rob_r;
        v_head_ptr := head_ptr_r;
        v_tail_ptr := tail_ptr_r;
        v_count := count_r;

        v_head_row_idx := head_ptr_r;
        v_head1_row_idx := head_ptr_r + to_unsigned(1, 4);

        v_head_row := v_rob(to_integer(v_head_row_idx));
        v_head1_row := v_rob(to_integer(v_head1_row_idx));

        v_commit0_valid := '0';
        v_commit0_arch  := (others => '0');
        v_commit0_tag   := (others => '0');
        v_commit1_valid := '0';
        v_commit1_arch  := (others => '0');
        v_commit1_tag   := (others => '0');

        v_commit0_cf_valid := '0';
        v_commit0_cf_tag   := (others => '0');
        v_commit1_cf_valid := '0';
        v_commit1_cf_tag   := (others => '0');

        v_commit0_zf_valid := '0';
        v_commit0_zf_tag   := (others => '0');
        v_commit1_zf_valid := '0';
        v_commit1_zf_tag   := (others => '0');

        v_redirect_valid  := '0';
        v_redirect_target := (others => '0');
        v_alloc_used := (others => '0');

        if (v_count /= 0 and v_head_row.valid = '1') then
            rob_head_valid <= '1';
        else
            rob_head_valid <= '0';
        end if;
        rob_head_idx <= std_logic_vector(v_head_row_idx);
        rob_head_is_store <= v_head_row.is_store;

        if (v_head_row.valid = '1' and v_head_row.ready = '1' and v_head_row.is_branch = '1') then
            v_redirect_valid := v_head_row.branch_taken;
            v_redirect_target := v_head_row.branch_target;

            v_commit0_valid := v_head_row.dest_en;
            v_commit0_arch  := v_head_row.rd_arch;
            v_commit0_tag   := v_head_row.dest_tag;

            v_commit0_cf_valid := v_head_row.carry_en;
            v_commit0_cf_tag   := v_head_row.carry_tag;

            v_commit0_zf_valid := v_head_row.zero_en;
            v_commit0_zf_tag   := v_head_row.zero_tag;

            for v_idx in 0 to ROB_DEPTH - 1 loop
                v_rob(v_idx).valid := '0';
                v_rob(v_idx).ready := '0';
                v_rob(v_idx).dest_en := '0';
                v_rob(v_idx).rd_arch := (others => '0');
                v_rob(v_idx).dest_tag := (others => '0');
                v_rob(v_idx).carry_en := '0';
                v_rob(v_idx).carry_tag := (others => '0');
                v_rob(v_idx).zero_en := '0';
                v_rob(v_idx).zero_tag := (others => '0');
                v_rob(v_idx).is_store := '0';
                v_rob(v_idx).is_load := '0';
                v_rob(v_idx).is_branch := '0';
                v_rob(v_idx).branch_taken := '0';
                v_rob(v_idx).branch_target := (others => '0');
            end loop;

            v_count := (others => '0');
            v_head_ptr := (others => '0');
            v_tail_ptr := (others => '0');
        elsif (v_head_row.valid = '1' and v_head_row.ready = '1' and v_head_row.is_branch = '0') then
            v_rob(to_integer(v_head_row_idx)).valid := '0';
            v_head_ptr := v_head_ptr + to_unsigned(1, 4);
            v_count := v_count - to_unsigned(1, 5);

            v_commit0_valid := v_head_row.dest_en;
            v_commit0_arch  := v_head_row.rd_arch;
            v_commit0_tag   := v_head_row.dest_tag;

            v_commit0_cf_valid := v_head_row.carry_en;
            v_commit0_cf_tag   := v_head_row.carry_tag;

            v_commit0_zf_valid := v_head_row.zero_en;
            v_commit0_zf_tag   := v_head_row.zero_tag;

            if (v_head1_row.valid = '1' and v_head1_row.ready = '1' and v_head1_row.is_branch = '0' and v_head1_row.is_store = '0') then
                v_rob(to_integer(v_head1_row_idx)).valid := '0';
                v_head_ptr := v_head_ptr + to_unsigned(1, 4);
                v_count := v_count - to_unsigned(1, 5);

                v_commit1_valid := v_head1_row.dest_en;
                v_commit1_arch  := v_head1_row.rd_arch;
                v_commit1_tag   := v_head1_row.dest_tag;

                v_commit1_cf_valid := v_head1_row.carry_en;
                v_commit1_cf_tag   := v_head1_row.carry_tag;

                v_commit1_zf_valid := v_head1_row.zero_en;
                v_commit1_zf_tag   := v_head1_row.zero_tag;
            end if;
        end if;

        if (alloc0_fire = '1') then
            v_rob(to_integer(v_tail_ptr)).valid := '1';
            v_rob(to_integer(v_tail_ptr)).ready := '0';
            v_rob(to_integer(v_tail_ptr)).dest_en := alloc0_dest_en;
            v_rob(to_integer(v_tail_ptr)).rd_arch := alloc0_arch;
            v_rob(to_integer(v_tail_ptr)).dest_tag := alloc0_dest_tag;
            v_rob(to_integer(v_tail_ptr)).carry_en := alloc0_carry_en;
            v_rob(to_integer(v_tail_ptr)).carry_tag := alloc0_carry_tag;
            v_rob(to_integer(v_tail_ptr)).zero_en := alloc0_zero_en;
            v_rob(to_integer(v_tail_ptr)).zero_tag := alloc0_zero_tag;
            v_rob(to_integer(v_tail_ptr)).is_store := alloc0_is_store;
            v_rob(to_integer(v_tail_ptr)).is_load := alloc0_is_load;
            v_rob(to_integer(v_tail_ptr)).is_branch := alloc0_is_branch;
            v_rob(to_integer(v_tail_ptr)).branch_taken := '0';
            v_rob(to_integer(v_tail_ptr)).branch_target := (others => '0');
            v_alloc_used := v_alloc_used + to_unsigned(1, 4);
        end if;

        if (alloc1_fire = '1') then
            v_rob(to_integer(v_tail_ptr + v_alloc_used)).valid := '1';
            v_rob(to_integer(v_tail_ptr + v_alloc_used)).ready := '0';
            v_rob(to_integer(v_tail_ptr + v_alloc_used)).dest_en := alloc1_dest_en;
            v_rob(to_integer(v_tail_ptr + v_alloc_used)).rd_arch := alloc1_arch;
            v_rob(to_integer(v_tail_ptr + v_alloc_used)).dest_tag := alloc1_dest_tag;
            v_rob(to_integer(v_tail_ptr + v_alloc_used)).carry_en := alloc1_carry_en;
            v_rob(to_integer(v_tail_ptr + v_alloc_used)).carry_tag := alloc1_carry_tag;
            v_rob(to_integer(v_tail_ptr + v_alloc_used)).zero_en := alloc1_zero_en;
            v_rob(to_integer(v_tail_ptr + v_alloc_used)).zero_tag := alloc1_zero_tag;
            v_rob(to_integer(v_tail_ptr + v_alloc_used)).is_store := alloc1_is_store;
            v_rob(to_integer(v_tail_ptr + v_alloc_used)).is_load := alloc1_is_load;
            v_rob(to_integer(v_tail_ptr + v_alloc_used)).is_branch := alloc1_is_branch;
            v_rob(to_integer(v_tail_ptr + v_alloc_used)).branch_taken := '0';
            v_rob(to_integer(v_tail_ptr + v_alloc_used)).branch_target := (others => '0');
            v_alloc_used := v_alloc_used + to_unsigned(1, 4);
        end if;

        v_tail_ptr := v_tail_ptr + v_alloc_used;
        v_count := v_count + resize(v_alloc_used, 5);

        if (ex0_valid = '1') then
            v_rob(to_integer(unsigned(ex0_idx))).ready := '1';
            if (ex0_is_branch = '1') then
                v_rob(to_integer(unsigned(ex0_idx))).branch_taken := ex0_branch_taken;
                v_rob(to_integer(unsigned(ex0_idx))).branch_target := ex0_branch_target;
            end if;
        end if;

        if (ex1_valid = '1') then
            v_rob(to_integer(unsigned(ex1_idx))).ready := '1';
            if (ex1_is_branch = '1') then
                v_rob(to_integer(unsigned(ex1_idx))).branch_taken := ex1_branch_taken;
                v_rob(to_integer(unsigned(ex1_idx))).branch_target := ex1_branch_target;
            end if;
        end if;

        if (ex2_valid = '1') then
            v_rob(to_integer(unsigned(ex2_idx))).ready := '1';
            if (ex2_is_branch = '1') then
                v_rob(to_integer(unsigned(ex2_idx))).branch_taken := ex2_branch_taken;
                v_rob(to_integer(unsigned(ex2_idx))).branch_target := ex2_branch_target;
            end if;
        end if;

        rob_count <= std_logic_vector(to_unsigned(ROB_DEPTH, 5) - v_count);
        alloc0_idx <= std_logic_vector(v_tail_ptr);
        alloc1_idx <= std_logic_vector(v_tail_ptr + unsigned(alloc0_query and alloc1_query));

        rob_n <= v_rob;
        head_ptr_n <= v_head_ptr;
        tail_ptr_n <= v_tail_ptr;
        count_n <= v_count;

        commit0_valid_n <= v_commit0_valid;
        commit0_arch_n  <= v_commit0_arch;
        commit0_tag_n   <= v_commit0_tag;
        commit1_valid_n <= v_commit1_valid;
        commit1_arch_n  <= v_commit1_arch;
        commit1_tag_n   <= v_commit1_tag;

        commit0_cf_valid_n <= v_commit0_cf_valid;
        commit0_cf_tag_n   <= v_commit0_cf_tag;
        commit1_cf_valid_n <= v_commit1_cf_valid;
        commit1_cf_tag_n   <= v_commit1_cf_tag;

        commit0_zf_valid_n <= v_commit0_zf_valid;
        commit0_zf_tag_n   <= v_commit0_zf_tag;
        commit1_zf_valid_n <= v_commit1_zf_valid;
        commit1_zf_tag_n   <= v_commit1_zf_tag;

        redirect_valid_n  <= v_redirect_valid;
        redirect_target_n <= v_redirect_target;
    end process;

    process(clk, rst)
    begin
        if (rst = '1') then
            count_r <= (others => '0');
            head_ptr_r <= (others => '0');
            tail_ptr_r <= (others => '0');

            commit0_valid_r <= '0';
            commit0_arch_r  <= (others => '0');
            commit0_tag_r   <= (others => '0');
            commit1_valid_r <= '0';
            commit1_arch_r  <= (others => '0');
            commit1_tag_r   <= (others => '0');

            commit0_cf_valid_r <= '0';
            commit0_cf_tag_r   <= (others => '0');
            commit1_cf_valid_r <= '0';
            commit1_cf_tag_r   <= (others => '0');

            commit0_zf_valid_r <= '0';
            commit0_zf_tag_r   <= (others => '0');
            commit1_zf_valid_r <= '0';
            commit1_zf_tag_r   <= (others => '0');

            redirect_valid_r  <= '0';
            redirect_target_r <= (others => '0');

            for v_idx in 0 to ROB_DEPTH - 1 loop
                rob_r(v_idx).valid <= '0';
                rob_r(v_idx).ready <= '0';
                rob_r(v_idx).dest_en <= '0';
                rob_r(v_idx).rd_arch <= (others => '0');
                rob_r(v_idx).dest_tag <= (others => '0');
                rob_r(v_idx).carry_en <= '0';
                rob_r(v_idx).carry_tag <= (others => '0');
                rob_r(v_idx).zero_en <= '0';
                rob_r(v_idx).zero_tag <= (others => '0');
                rob_r(v_idx).is_store <= '0';
                rob_r(v_idx).is_load <= '0';
                rob_r(v_idx).is_branch <= '0';
                rob_r(v_idx).branch_taken <= '0';
                rob_r(v_idx).branch_target <= (others => '0');
            end loop;
        elsif (clk'event and clk = '1') then
            if (redirect_valid_r = '1') then
                count_r <= (others => '0');
                head_ptr_r <= (others => '0');
                tail_ptr_r <= (others => '0');

                commit0_valid_r <= '0';
                commit0_arch_r  <= (others => '0');
                commit0_tag_r   <= (others => '0');
                commit1_valid_r <= '0';
                commit1_arch_r  <= (others => '0');
                commit1_tag_r   <= (others => '0');

                commit0_cf_valid_r <= '0';
                commit0_cf_tag_r   <= (others => '0');
                commit1_cf_valid_r <= '0';
                commit1_cf_tag_r   <= (others => '0');

                commit0_zf_valid_r <= '0';
                commit0_zf_tag_r   <= (others => '0');
                commit1_zf_valid_r <= '0';
                commit1_zf_tag_r   <= (others => '0');

                redirect_valid_r  <= '0';
                redirect_target_r <= (others => '0');

                for v_idx in 0 to ROB_DEPTH - 1 loop
                    rob_r(v_idx).valid <= '0';
                    rob_r(v_idx).ready <= '0';
                    rob_r(v_idx).dest_en <= '0';
                    rob_r(v_idx).rd_arch <= (others => '0');
                    rob_r(v_idx).dest_tag <= (others => '0');
                    rob_r(v_idx).carry_en <= '0';
                    rob_r(v_idx).carry_tag <= (others => '0');
                    rob_r(v_idx).zero_en <= '0';
                    rob_r(v_idx).zero_tag <= (others => '0');
                    rob_r(v_idx).is_store <= '0';
                    rob_r(v_idx).is_load <= '0';
                    rob_r(v_idx).is_branch <= '0';
                    rob_r(v_idx).branch_taken <= '0';
                    rob_r(v_idx).branch_target <= (others => '0');
                end loop;
            else
                count_r <= count_n;
                head_ptr_r <= head_ptr_n;
                tail_ptr_r <= tail_ptr_n;

                commit0_valid_r <= commit0_valid_n;
                commit0_arch_r  <= commit0_arch_n;
                commit0_tag_r   <= commit0_tag_n;
                commit1_valid_r <= commit1_valid_n;
                commit1_arch_r  <= commit1_arch_n;
                commit1_tag_r   <= commit1_tag_n;

                commit0_cf_valid_r <= commit0_cf_valid_n;
                commit0_cf_tag_r   <= commit0_cf_tag_n;
                commit1_cf_valid_r <= commit1_cf_valid_n;
                commit1_cf_tag_r   <= commit1_cf_tag_n;

                commit0_zf_valid_r <= commit0_zf_valid_n;
                commit0_zf_tag_r   <= commit0_zf_tag_n;
                commit1_zf_valid_r <= commit1_zf_valid_n;
                commit1_zf_tag_r   <= commit1_zf_tag_n;

                redirect_valid_r  <= redirect_valid_n;
                redirect_target_r <= redirect_target_n;

                for v_idx in 0 to ROB_DEPTH - 1 loop
                    rob_r(v_idx) <= rob_n(v_idx);
                end loop;
            end if;
        end if;
    end process;
end architecture rtl;