library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lsu_stage is
    port (
        clk            : in  std_logic;
        rst            : in  std_logic;
        redirect_valid : in  std_logic;

        rob_head_valid   : in  std_logic;
        rob_head_is_store: in  std_logic;
        rob_head_idx     : in  std_logic_vector(3 downto 0);

        wb0_valid : in  std_logic;
        wb0_tag   : in  std_logic_vector(3 downto 0);
        wb0_data  : in  std_logic_vector(15 downto 0);

        wb1_valid : in  std_logic;
        wb1_tag   : in  std_logic_vector(3 downto 0);
        wb1_data  : in  std_logic_vector(15 downto 0);

        wb2_valid : in  std_logic;
        wb2_tag   : in  std_logic_vector(3 downto 0);
        wb2_data  : in  std_logic_vector(15 downto 0);

        d0_lsu_fire   : in  std_logic;
        d0_is_load    : in  std_logic;
        d0_is_store   : in  std_logic;
        d0_src1_rrf   : in  std_logic;
        d0_src1_ready : in  std_logic;
        d0_src1_tag   : in  std_logic_vector(3 downto 0);
        d0_src1_value : in  std_logic_vector(15 downto 0);
        d0_src2_rrf   : in  std_logic;
        d0_src2_ready : in  std_logic;
        d0_src2_tag   : in  std_logic_vector(3 downto 0);
        d0_src2_value : in  std_logic_vector(15 downto 0);
        d0_imm        : in  std_logic_vector(15 downto 0);
        d0_dest_tag   : in  std_logic_vector(3 downto 0);
        d0_rob_idx    : in  std_logic_vector(3 downto 0);
        d0_is_branch  : in std_logic;

        d1_lsu_fire   : in  std_logic;
        d1_is_load    : in  std_logic;
        d1_is_store   : in  std_logic;
        d1_src1_rrf   : in  std_logic;
        d1_src1_ready : in  std_logic;
        d1_src1_tag   : in  std_logic_vector(3 downto 0);
        d1_src1_value : in  std_logic_vector(15 downto 0);
        d1_src2_rrf   : in  std_logic;
        d1_src2_ready : in  std_logic;
        d1_src2_tag   : in  std_logic_vector(3 downto 0);
        d1_src2_value : in  std_logic_vector(15 downto 0);
        d1_imm        : in  std_logic_vector(15 downto 0);
        d1_dest_tag   : in  std_logic_vector(3 downto 0);
        d1_rob_idx    : in  std_logic_vector(3 downto 0);
        d1_is_branch  : in std_logic;

        wb_valid   : out std_logic;
        wb_tag     : out std_logic_vector(3 downto 0);
        wb_data    : out std_logic_vector(15 downto 0);

        wb_zf_valid : out std_logic;
        wb_zf_tag   : out std_logic_vector(3 downto 0);
        wb_zf_data  : out std_logic;

        wb_cf_valid : out std_logic;
        wb_cf_tag   : out std_logic_vector(3 downto 0);
        wb_cf_data  : out std_logic;

        ex_valid : out std_logic;
        ex_idx   : out std_logic_vector(3 downto 0);
        ex_is_branch     : out std_logic;
        ex_branch_taken  : out std_logic;
        ex_branch_target : out std_logic_vector(15 downto 0);

        lsq_count : out std_logic_vector(4 downto 0)
    );
end entity lsu_stage;

architecture rtl of lsu_stage is
    constant IDX_W   : integer := 4;
    constant COUNT_W : integer := 5;
    constant DEPTH   : integer := 16;

    subtype idx_t is std_logic_vector(IDX_W-1 downto 0);
    subtype count_t is unsigned(COUNT_W-1 downto 0);

    type entry_t is record
        valid     : std_logic;
        is_load   : std_logic;
        is_store  : std_logic;
        done      : std_logic;

        src1_rrf   : std_logic;
        src1_ready : std_logic;
        src1_tag   : idx_t;
        src1_value : std_logic_vector(15 downto 0);

        src2_rrf   : std_logic;
        src2_ready : std_logic;
        src2_tag   : idx_t;
        src2_value : std_logic_vector(15 downto 0);

        imm       : std_logic_vector(15 downto 0);
        addr      : std_logic_vector(15 downto 0);
        data      : std_logic_vector(15 downto 0);

        dest_tag  : idx_t;
        rob_idx   : idx_t;
        dest_pc   : std_logic;
    end record;

    type entry_array_t is array (0 to DEPTH-1) of entry_t;
    type idx_array_t   is array (0 to DEPTH-1) of idx_t;

    signal lsq_q : entry_array_t;
    signal lsq_d : entry_array_t;

    signal free_q : idx_array_t;
    signal free_d : idx_array_t;

    signal free_head_q : integer range 0 to DEPTH-1;
    signal free_tail_q : integer range 0 to DEPTH-1;
    signal free_head_d : integer range 0 to DEPTH-1;
    signal free_tail_d : integer range 0 to DEPTH-1;

    signal free_count_q : count_t;
    signal free_count_d : count_t;

    signal wb_valid_n   : std_logic;
    signal wb_tag_n     : idx_t;
    signal wb_data_n    : std_logic_vector(15 downto 0);

    signal wb_zf_valid_n : std_logic;
    signal wb_zf_tag_n   : idx_t;
    signal wb_zf_data_n  : std_logic;

    signal wb_cf_valid_n : std_logic;
    signal wb_cf_tag_n   : idx_t;
    signal wb_cf_data_n  : std_logic;

    signal ex_valid_n : std_logic;
    signal ex_idx_n   : idx_t;
    signal ex_is_branch_n     : std_logic;
    signal ex_branch_taken_n  : std_logic;
    signal ex_branch_target_n : std_logic_vector(15 downto 0);

    signal rd_en   : std_logic;
    signal wr_en   : std_logic;
    signal rd_addr : std_logic_vector(15 downto 0);
    signal wr_addr : std_logic_vector(15 downto 0);
    signal wr_data : std_logic_vector(15 downto 0);
    signal rd_data : std_logic_vector(15 downto 0);

    constant ZERO_COUNT : count_t := (others => '0');

    component dmem is
        port (
            clk     : in  std_logic;
            rd_en   : in  std_logic;
            rd_addr : in  std_logic_vector(15 downto 0);
            rd_data : out std_logic_vector(15 downto 0);
            wr_en   : in  std_logic;
            wr_addr : in  std_logic_vector(15 downto 0);
            wr_data : in  std_logic_vector(15 downto 0)
        );
    end component;

    function wb_hit(
        src_rrf   : std_logic;
        src_ready : std_logic;
        src_tag   : idx_t;
        wb_valid  : std_logic;
        wb_tag    : idx_t
    ) return std_logic is
    begin
        if (src_rrf = '1') and (src_ready = '0') and (wb_valid = '1') and (src_tag = wb_tag) then
            return '1';
        else
            return '0';
        end if;
    end function;

    function resolve_ready_int(
        src_rrf   : std_logic;
        src_ready : std_logic;
        src_tag   : idx_t;
        wb0_valid : std_logic;
        wb0_tag   : idx_t;
        wb1_valid : std_logic;
        wb1_tag   : idx_t;
        wb2_valid : std_logic;
        wb2_tag   : idx_t
    ) return std_logic is
    begin
        if (src_ready = '1') then
            return '1';
        elsif wb_hit(src_rrf, src_ready, src_tag, wb0_valid, wb0_tag) = '1' then
            return '1';
        elsif wb_hit(src_rrf, src_ready, src_tag, wb1_valid, wb1_tag) = '1' then
            return '1';
        elsif wb_hit(src_rrf, src_ready, src_tag, wb2_valid, wb2_tag) = '1' then
            return '1';
        else
            return '0';
        end if;
    end function;

    function resolve_value_int(
        src_rrf    : std_logic;
        src_ready  : std_logic;
        src_tag    : idx_t;
        src_value  : std_logic_vector(15 downto 0);
        wb0_valid  : std_logic;
        wb0_tag    : idx_t;
        wb0_data   : std_logic_vector(15 downto 0);
        wb1_valid  : std_logic;
        wb1_tag    : idx_t;
        wb1_data   : std_logic_vector(15 downto 0);
        wb2_valid  : std_logic;
        wb2_tag    : idx_t;
        wb2_data   : std_logic_vector(15 downto 0)
    ) return std_logic_vector is
    begin
        if wb_hit(src_rrf, src_ready, src_tag, wb0_valid, wb0_tag) = '1' then
            return wb0_data;
        elsif wb_hit(src_rrf, src_ready, src_tag, wb1_valid, wb1_tag) = '1' then
            return wb1_data;
        elsif wb_hit(src_rrf, src_ready, src_tag, wb2_valid, wb2_tag) = '1' then
            return wb2_data;
        else
            return src_value;
        end if;
    end function;

    function inc_idx(v : integer) return integer is
    begin
        if v = DEPTH-1 then
            return 0;
        else
            return v + 1;
        end if;
    end function;

    function age_from_head(
        idx  : idx_t;
        head : idx_t
    ) return integer is
        variable idx_i  : integer;
        variable head_i : integer;
    begin
        idx_i  := to_integer(unsigned(idx));
        head_i := to_integer(unsigned(head));

        if idx_i >= head_i then
            return idx_i - head_i;
        else
            return idx_i + DEPTH - head_i;
        end if;
    end function;

begin
    u_dmem : component dmem
        port map (
            clk     => clk,
            rd_en   => rd_en,
            rd_addr => rd_addr,
            rd_data => rd_data,
            wr_en   => wr_en,
            wr_addr => wr_addr,
            wr_data => wr_data
        );

    process(
        lsq_q,
        free_q,
        free_head_q,
        free_tail_q,
        free_count_q,
        rob_head_valid,
        rob_head_is_store,
        rob_head_idx,
        wb0_valid,
        wb0_tag,
        wb0_data,
        wb1_valid,
        wb1_tag,
        wb1_data,
        wb2_valid,
        wb2_tag,
        wb2_data,
        d0_lsu_fire,
        d0_is_load,
        d0_is_store,
        d0_src1_rrf,
        d0_src1_ready,
        d0_src1_tag,
        d0_src1_value,
        d0_src2_rrf,
        d0_src2_ready,
        d0_src2_tag,
        d0_src2_value,
        d0_imm,
        d0_dest_tag,
        d0_rob_idx,
        d1_lsu_fire,
        d1_is_load,
        d1_is_store,
        d1_src1_rrf,
        d1_src1_ready,
        d1_src1_tag,
        d1_src1_value,
        d1_src2_rrf,
        d1_src2_ready,
        d1_src2_tag,
        d1_src2_value,
        d1_imm,
        d1_dest_tag,
        d1_rob_idx,
        rd_data
    )
        variable lsq_v : entry_array_t;
        variable free_v : idx_array_t;

        variable free_head_v : integer range 0 to DEPTH-1;
        variable free_tail_v : integer range 0 to DEPTH-1;
        variable free_count_v : count_t;

        variable wb_valid_v   : std_logic;
        variable wb_tag_v     : idx_t;
        variable wb_data_v    : std_logic_vector(15 downto 0);

        variable wb_zf_valid_v : std_logic;
        variable wb_zf_tag_v   : idx_t;
        variable wb_zf_data_v  : std_logic;

        variable wb_cf_valid_v : std_logic;
        variable wb_cf_tag_v   : idx_t;
        variable wb_cf_data_v  : std_logic;

        variable ex_valid_v : std_logic;
        variable ex_idx_v   : idx_t;
        variable ex_is_branch_v     : std_logic;
        variable ex_branch_taken_v  : std_logic;
        variable ex_branch_target_v : std_logic_vector(15 downto 0);

        variable rd_en_v   : std_logic;
        variable wr_en_v   : std_logic;
        variable rd_addr_v : std_logic_vector(15 downto 0);
        variable wr_addr_v : std_logic_vector(15 downto 0);
        variable wr_data_v : std_logic_vector(15 downto 0);

        variable alloc_idx     : integer range 0 to DEPTH-1;
        variable exec_idx_v    : integer range 0 to DEPTH-1;
        variable best_load_idx : integer range 0 to DEPTH-1;
        variable retire_idx_v  : integer range 0 to DEPTH-1;

        variable exec_found   : boolean;
        variable load_found   : boolean;
        variable retire_found : boolean;
        variable blocked_v    : boolean;

        variable load_age     : integer;
        variable best_load_age: integer;
        variable store_age    : integer;

        variable load_addr_v  : std_logic_vector(15 downto 0);
        variable store_addr_v : std_logic_vector(15 downto 0);

        variable src1_ready_v : std_logic;
        variable src2_ready_v : std_logic;
        variable src1_value_v : std_logic_vector(15 downto 0);
        variable src2_value_v : std_logic_vector(15 downto 0);
    begin
        for i in 0 to DEPTH-1 loop
            lsq_v(i) := lsq_q(i);
            free_v(i) := free_q(i);
        end loop;

        free_head_v  := free_head_q;
        free_tail_v  := free_tail_q;
        free_count_v := free_count_q;

        wb_valid_v := '0';
        wb_tag_v   := (others => '0');
        wb_data_v  := (others => '0');

        wb_zf_valid_v := '0';
        wb_zf_tag_v   := (others => '0');
        wb_zf_data_v  := '0';

        wb_cf_valid_v := '0';
        wb_cf_tag_v   := (others => '0');
        wb_cf_data_v  := '0';

        ex_valid_v := '0';
        ex_idx_v   := (others => '0');
        ex_is_branch_v     := '0';
        ex_branch_taken_v  := '0';
        ex_branch_target_v := (others => '0');

        rd_en_v   := '0';
        wr_en_v   := '0';
        rd_addr_v := (others => '0');
        wr_addr_v := (others => '0');
        wr_data_v := (others => '0');

        for i in 0 to DEPTH-1 loop
            if lsq_v(i).valid = '1' then
                if (lsq_v(i).src1_rrf = '1') and (lsq_v(i).src1_ready = '0') then
                    if (wb0_valid = '1') and (lsq_v(i).src1_tag = wb0_tag) then
                        lsq_v(i).src1_ready := '1';
                        lsq_v(i).src1_value := wb0_data;
                    elsif (wb1_valid = '1') and (lsq_v(i).src1_tag = wb1_tag) then
                        lsq_v(i).src1_ready := '1';
                        lsq_v(i).src1_value := wb1_data;
                    elsif (wb2_valid = '1') and (lsq_v(i).src1_tag = wb2_tag) then
                        lsq_v(i).src1_ready := '1';
                        lsq_v(i).src1_value := wb2_data;
                    end if;
                end if;

                if (lsq_v(i).src2_rrf = '1') and (lsq_v(i).src2_ready = '0') then
                    if (wb0_valid = '1') and (lsq_v(i).src2_tag = wb0_tag) then
                        lsq_v(i).src2_ready := '1';
                        lsq_v(i).src2_value := wb0_data;
                    elsif (wb1_valid = '1') and (lsq_v(i).src2_tag = wb1_tag) then
                        lsq_v(i).src2_ready := '1';
                        lsq_v(i).src2_value := wb1_data;
                    elsif (wb2_valid = '1') and (lsq_v(i).src2_tag = wb2_tag) then
                        lsq_v(i).src2_ready := '1';
                        lsq_v(i).src2_value := wb2_data;
                    end if;
                end if;
            end if;
        end loop;

        retire_found := false;
        retire_idx_v := 0;

        if (rob_head_valid = '1') and (rob_head_is_store = '1') then
            for i in 0 to DEPTH-1 loop
                if (not retire_found) and
                   (lsq_v(i).valid = '1') and
                   (lsq_v(i).is_store = '1') and
                   (lsq_v(i).done = '1') and
                   (lsq_v(i).rob_idx = rob_head_idx) then
                    retire_found := true;
                    retire_idx_v := i;
                end if;
            end loop;
        end if;

        if retire_found then
            lsq_v(retire_idx_v).valid := '0';
            free_v(free_tail_v) := std_logic_vector(to_unsigned(retire_idx_v, IDX_W));
            free_tail_v := inc_idx(free_tail_v);
            free_count_v := free_count_v + 1;
        end if;

        exec_found    := false;
        load_found    := false;
        exec_idx_v    := 0;
        best_load_idx := 0;
        best_load_age  := DEPTH + 1;

        if (rob_head_valid = '1') and (rob_head_is_store = '1') then
            for i in 0 to DEPTH-1 loop
                if (lsq_v(i).valid = '1') and
                   (lsq_v(i).is_store = '1') and
                   (lsq_v(i).done = '0') and
                   (lsq_v(i).rob_idx = rob_head_idx) then

                    if (resolve_ready_int(
                            lsq_v(i).src1_rrf, lsq_v(i).src1_ready, lsq_v(i).src1_tag,
                            wb0_valid, wb0_tag,
                            wb1_valid, wb1_tag,
                            wb2_valid, wb2_tag) = '1') and
                       (resolve_ready_int(
                            lsq_v(i).src2_rrf, lsq_v(i).src2_ready, lsq_v(i).src2_tag,
                            wb0_valid, wb0_tag,
                            wb1_valid, wb1_tag,
                            wb2_valid, wb2_tag) = '1') then
                        exec_found := true;
                        exec_idx_v := i;
                    end if;
                end if;
            end loop;
        end if;

        if not exec_found then
            for i in 0 to DEPTH-1 loop
                if (lsq_v(i).valid = '1') and (lsq_v(i).is_load = '1') then
                    if resolve_ready_int(
                           lsq_v(i).src1_rrf, lsq_v(i).src1_ready, lsq_v(i).src1_tag,
                           wb0_valid, wb0_tag,
                           wb1_valid, wb1_tag,
                           wb2_valid, wb2_tag) = '1' then

                        load_addr_v := std_logic_vector(
                            unsigned(resolve_value_int(
                                lsq_v(i).src1_rrf, lsq_v(i).src1_ready, lsq_v(i).src1_tag, lsq_v(i).src1_value,
                                wb0_valid, wb0_tag, wb0_data,
                                wb1_valid, wb1_tag, wb1_data,
                                wb2_valid, wb2_tag, wb2_data
                            )) + unsigned(lsq_v(i).imm)
                        );

                        blocked_v := false;

                        for j in 0 to DEPTH-1 loop
                            if (lsq_v(j).valid = '1') and
                               (lsq_v(j).is_store = '1') and
                               (lsq_v(j).done = '0') then
                                if rob_head_valid = '1' then
                                    load_age := age_from_head(lsq_v(i).rob_idx, rob_head_idx);
                                    store_age := age_from_head(lsq_v(j).rob_idx, rob_head_idx);

                                    if store_age < load_age then
                                        if resolve_ready_int(
                                               lsq_v(j).src1_rrf, lsq_v(j).src1_ready, lsq_v(j).src1_tag,
                                               wb0_valid, wb0_tag,
                                               wb1_valid, wb1_tag,
                                               wb2_valid, wb2_tag) = '0' then
                                            blocked_v := true;
                                        else
                                            store_addr_v := std_logic_vector(
                                                unsigned(resolve_value_int(
                                                    lsq_v(j).src1_rrf, lsq_v(j).src1_ready, lsq_v(j).src1_tag, lsq_v(j).src1_value,
                                                    wb0_valid, wb0_tag, wb0_data,
                                                    wb1_valid, wb1_tag, wb1_data,
                                                    wb2_valid, wb2_tag, wb2_data
                                                )) + unsigned(lsq_v(j).imm)
                                            );

                                            if store_addr_v = load_addr_v then
                                                blocked_v := true;
                                            end if;
                                        end if;
                                    end if;
                                else
                                    blocked_v := true;
                                end if;
                            end if;
                        end loop;

                        if not blocked_v then
                            if not load_found then
                                load_found    := true;
                                best_load_idx := i;
                                if rob_head_valid = '1' then
                                    best_load_age := age_from_head(lsq_v(i).rob_idx, rob_head_idx);
                                else
                                    best_load_age := 0;
                                end if;
                            elsif rob_head_valid = '1' then
                                load_age := age_from_head(lsq_v(i).rob_idx, rob_head_idx);
                                if load_age < best_load_age then
                                    best_load_idx := i;
                                    best_load_age := load_age;
                                end if;
                            end if;
                        end if;
                    end if;
                end if;
            end loop;

            if load_found then
                exec_found := true;
                exec_idx_v := best_load_idx;
            end if;
        end if;

        if exec_found then
            ex_valid_v := '1';
            ex_idx_v   := lsq_v(exec_idx_v).rob_idx;

            if lsq_v(exec_idx_v).is_load = '1' then
                rd_en_v := '1';
                rd_addr_v := std_logic_vector(
                    unsigned(resolve_value_int(
                        lsq_v(exec_idx_v).src1_rrf,
                        lsq_v(exec_idx_v).src1_ready,
                        lsq_v(exec_idx_v).src1_tag,
                        lsq_v(exec_idx_v).src1_value,
                        wb0_valid, wb0_tag, wb0_data,
                        wb1_valid, wb1_tag, wb1_data,
                        wb2_valid, wb2_tag, wb2_data
                    )) + unsigned(lsq_v(exec_idx_v).imm)
                );

                wb_valid_v := not lsq_v(exec_idx_v).dest_pc;
                wb_tag_v   := lsq_v(exec_idx_v).dest_tag;
                wb_data_v  := rd_data;

                ex_is_branch_v     := lsq_v(exec_idx_v).dest_pc;
                ex_branch_taken_v  := lsq_v(exec_idx_v).dest_pc;
                ex_branch_target_v := rd_data;

                wb_zf_valid_v := '1';
                wb_zf_tag_v   := lsq_v(exec_idx_v).dest_tag;
                if rd_data = x"0000" then
                    wb_zf_data_v := '1';
                else
                    wb_zf_data_v := '0';
                end if;

                lsq_v(exec_idx_v).valid := '0';
                free_v(free_tail_v) := std_logic_vector(to_unsigned(exec_idx_v, IDX_W));
                free_tail_v := inc_idx(free_tail_v);
                free_count_v := free_count_v + 1;

            elsif lsq_v(exec_idx_v).is_store = '1' then
                wr_en_v := '1';
                wr_addr_v := std_logic_vector(
                    unsigned(resolve_value_int(
                        lsq_v(exec_idx_v).src1_rrf,
                        lsq_v(exec_idx_v).src1_ready,
                        lsq_v(exec_idx_v).src1_tag,
                        lsq_v(exec_idx_v).src1_value,
                        wb0_valid, wb0_tag, wb0_data,
                        wb1_valid, wb1_tag, wb1_data,
                        wb2_valid, wb2_tag, wb2_data
                    )) + unsigned(lsq_v(exec_idx_v).imm)
                );

                wr_data_v := resolve_value_int(
                    lsq_v(exec_idx_v).src2_rrf,
                    lsq_v(exec_idx_v).src2_ready,
                    lsq_v(exec_idx_v).src2_tag,
                    lsq_v(exec_idx_v).src2_value,
                    wb0_valid, wb0_tag, wb0_data,
                    wb1_valid, wb1_tag, wb1_data,
                    wb2_valid, wb2_tag, wb2_data
                );

                lsq_v(exec_idx_v).done := '1';
            end if;
        end if;

        if (d0_lsu_fire = '1') and (free_count_v > ZERO_COUNT) then
            alloc_idx := to_integer(unsigned(free_v(free_head_v)));
            free_head_v := inc_idx(free_head_v);
            free_count_v := free_count_v - 1;

            lsq_v(alloc_idx).valid    := '1';
            lsq_v(alloc_idx).is_load  := d0_is_load;
            lsq_v(alloc_idx).is_store := d0_is_store;
            lsq_v(alloc_idx).done     := '0';

            lsq_v(alloc_idx).src1_rrf := d0_src1_rrf;
            src1_ready_v := resolve_ready_int(
                d0_src1_rrf, d0_src1_ready, d0_src1_tag,
                wb0_valid, wb0_tag,
                wb1_valid, wb1_tag,
                wb2_valid, wb2_tag
            );
            lsq_v(alloc_idx).src1_ready := src1_ready_v;
            src1_value_v := resolve_value_int(
                d0_src1_rrf, d0_src1_ready, d0_src1_tag, d0_src1_value,
                wb0_valid, wb0_tag, wb0_data,
                wb1_valid, wb1_tag, wb1_data,
                wb2_valid, wb2_tag, wb2_data
            );
            lsq_v(alloc_idx).src1_tag   := d0_src1_tag;
            lsq_v(alloc_idx).src1_value := src1_value_v;

            if d0_is_store = '1' then
                lsq_v(alloc_idx).src2_rrf := d0_src2_rrf;
                src2_ready_v := resolve_ready_int(
                    d0_src2_rrf, d0_src2_ready, d0_src2_tag,
                    wb0_valid, wb0_tag,
                    wb1_valid, wb1_tag,
                    wb2_valid, wb2_tag
                );
                lsq_v(alloc_idx).src2_ready := src2_ready_v;
                src2_value_v := resolve_value_int(
                    d0_src2_rrf, d0_src2_ready, d0_src2_tag, d0_src2_value,
                    wb0_valid, wb0_tag, wb0_data,
                    wb1_valid, wb1_tag, wb1_data,
                    wb2_valid, wb2_tag, wb2_data
                );
                lsq_v(alloc_idx).src2_tag   := d0_src2_tag;
                lsq_v(alloc_idx).src2_value := src2_value_v;
            else
                lsq_v(alloc_idx).src2_rrf   := '0';
                lsq_v(alloc_idx).src2_ready := '1';
                lsq_v(alloc_idx).src2_tag   := (others => '0');
                lsq_v(alloc_idx).src2_value := (others => '0');
            end if;

            lsq_v(alloc_idx).imm      := d0_imm;
            lsq_v(alloc_idx).addr     := (others => '0');
            lsq_v(alloc_idx).data     := (others => '0');
            lsq_v(alloc_idx).dest_tag := d0_dest_tag;
            lsq_v(alloc_idx).rob_idx  := d0_rob_idx;
            lsq_v(alloc_idx).dest_pc  := d0_is_branch;
        end if;

        if (d1_lsu_fire = '1') and (free_count_v > ZERO_COUNT) then
            alloc_idx := to_integer(unsigned(free_v(free_head_v)));
            free_head_v := inc_idx(free_head_v);
            free_count_v := free_count_v - 1;

            lsq_v(alloc_idx).valid    := '1';
            lsq_v(alloc_idx).is_load  := d1_is_load;
            lsq_v(alloc_idx).is_store := d1_is_store;
            lsq_v(alloc_idx).done     := '0';

            lsq_v(alloc_idx).src1_rrf := d1_src1_rrf;
            src1_ready_v := resolve_ready_int(
                d1_src1_rrf, d1_src1_ready, d1_src1_tag,
                wb0_valid, wb0_tag,
                wb1_valid, wb1_tag,
                wb2_valid, wb2_tag
            );
            lsq_v(alloc_idx).src1_ready := src1_ready_v;
            src1_value_v := resolve_value_int(
                d1_src1_rrf, d1_src1_ready, d1_src1_tag, d1_src1_value,
                wb0_valid, wb0_tag, wb0_data,
                wb1_valid, wb1_tag, wb1_data,
                wb2_valid, wb2_tag, wb2_data
            );
            lsq_v(alloc_idx).src1_tag   := d1_src1_tag;
            lsq_v(alloc_idx).src1_value := src1_value_v;

            if d1_is_store = '1' then
                lsq_v(alloc_idx).src2_rrf := d1_src2_rrf;
                src2_ready_v := resolve_ready_int(
                    d1_src2_rrf, d1_src2_ready, d1_src2_tag,
                    wb0_valid, wb0_tag,
                    wb1_valid, wb1_tag,
                    wb2_valid, wb2_tag
                );
                lsq_v(alloc_idx).src2_ready := src2_ready_v;
                src2_value_v := resolve_value_int(
                    d1_src2_rrf, d1_src2_ready, d1_src2_tag, d1_src2_value,
                    wb0_valid, wb0_tag, wb0_data,
                    wb1_valid, wb1_tag, wb1_data,
                    wb2_valid, wb2_tag, wb2_data
                );
                lsq_v(alloc_idx).src2_tag   := d1_src2_tag;
                lsq_v(alloc_idx).src2_value := src2_value_v;
            else
                lsq_v(alloc_idx).src2_rrf   := '0';
                lsq_v(alloc_idx).src2_ready := '1';
                lsq_v(alloc_idx).src2_tag   := (others => '0');
                lsq_v(alloc_idx).src2_value := (others => '0');
            end if;

            lsq_v(alloc_idx).imm      := d1_imm;
            lsq_v(alloc_idx).addr     := (others => '0');
            lsq_v(alloc_idx).data     := (others => '0');
            lsq_v(alloc_idx).dest_tag := d1_dest_tag;
            lsq_v(alloc_idx).rob_idx  := d1_rob_idx;
            lsq_v(alloc_idx).dest_pc  := d1_is_branch;
        end if;

        lsq_d <= lsq_v;
        free_d <= free_v;

        free_head_d  <= free_head_v;
        free_tail_d  <= free_tail_v;
        free_count_d <= free_count_v;

        wb_valid_n   <= wb_valid_v;
        wb_tag_n     <= wb_tag_v;
        wb_data_n    <= wb_data_v;

        wb_zf_valid_n <= wb_zf_valid_v;
        wb_zf_tag_n   <= wb_zf_tag_v;
        wb_zf_data_n  <= wb_zf_data_v;

        wb_cf_valid_n <= wb_cf_valid_v;
        wb_cf_tag_n   <= wb_cf_tag_v;
        wb_cf_data_n  <= wb_cf_data_v;

        ex_valid_n <= ex_valid_v;
        ex_idx_n   <= ex_idx_v;
        ex_is_branch_n     <= ex_is_branch_v;
        ex_branch_taken_n  <= ex_branch_taken_v;
        ex_branch_target_n <= ex_branch_target_v;

        rd_en   <= rd_en_v;
        rd_addr <= rd_addr_v;
        wr_en   <= wr_en_v;
        wr_addr <= wr_addr_v;
        wr_data <= wr_data_v;

        lsq_count <= std_logic_vector(free_count_v);
    end process;

    process(clk, rst)
    begin
        if (rst = '1') or (redirect_valid = '1') then
            free_head_q  <= 0;
            free_tail_q  <= 0;
            free_count_q <= to_unsigned(DEPTH, COUNT_W);

            wb_valid   <= '0';
            wb_tag     <= (others => '0');
            wb_data    <= (others => '0');

            wb_zf_valid <= '0';
            wb_zf_tag   <= (others => '0');
            wb_zf_data  <= '0';

            wb_cf_valid <= '0';
            wb_cf_tag   <= (others => '0');
            wb_cf_data  <= '0';

            ex_valid <= '0';
            ex_idx   <= (others => '0');

            for k in 0 to DEPTH-1 loop
                lsq_q(k)  <= (valid     => '0',
                              is_load   => '0',
                              is_store  => '0',
                              done      => '0',
                              src1_rrf   => '0',
                              src1_ready => '0',
                              src1_tag   => (others => '0'),
                              src1_value => (others => '0'),
                              src2_rrf   => '0',
                              src2_ready => '0',
                              src2_tag   => (others => '0'),
                              src2_value => (others => '0'),
                              imm       => (others => '0'),
                              addr      => (others => '0'),
                              data      => (others => '0'),
                              dest_tag  => (others => '0'),
                              rob_idx   => (others => '0'),
                              dest_pc   => '0');
                free_q(k) <= std_logic_vector(to_unsigned(k, IDX_W));
            end loop;
        elsif rising_edge(clk) then
            free_head_q  <= free_head_d;
            free_tail_q  <= free_tail_d;
            free_count_q <= free_count_d;

            wb_valid <= wb_valid_n;
            wb_tag   <= wb_tag_n;
            wb_data  <= wb_data_n;

            wb_zf_valid <= wb_zf_valid_n;
            wb_zf_tag   <= wb_zf_tag_n;
            wb_zf_data  <= wb_zf_data_n;

            wb_cf_valid <= wb_cf_valid_n;
            wb_cf_tag   <= wb_cf_tag_n;
            wb_cf_data  <= wb_cf_data_n;

            ex_valid <= ex_valid_n;
            ex_idx   <= ex_idx_n;
            ex_is_branch     <= ex_is_branch_n;
            ex_branch_taken  <= ex_branch_taken_n;
            ex_branch_target <= ex_branch_target_n;

            for k in 0 to DEPTH-1 loop
                lsq_q(k)  <= lsq_d(k);
                free_q(k) <= free_d(k);
            end loop;
        end if;
    end process;
end architecture rtl;