library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity issue_stage is
    port (
        clk : in std_logic;
        rst : in std_logic;
        redirect_valid : in std_logic;

        rs_count : out std_logic_vector(4 downto 0);

        d0_alu_fire : in std_logic;
        d0_is_add : in std_logic;
        d0_is_nand : in std_logic;
        d0_lli : in std_logic;
        d0_is_adi : in std_logic;
        d0_use_carry : in std_logic;
        d0_use_zero : in std_logic;
        d0_use_complement : in std_logic;
        d0_imm : in std_logic_vector(15 downto 0);
        d0_dest_tag : in std_logic_vector(3 downto 0);
        d0_dest_carry_tag : in std_logic_vector(3 downto 0);
        d0_dest_zero_tag : in std_logic_vector(3 downto 0);
        d0_rob_idx : in std_logic_vector(3 downto 0);
        d0_src1_rrf : in std_logic;
        d0_src1_ready : in std_logic;
        d0_src1_tag : in std_logic_vector(3 downto 0);
        d0_src1_value : in std_logic_vector(15 downto 0);
        d0_src2_rrf : in std_logic;
        d0_src2_ready : in std_logic;
        d0_src2_tag : in std_logic_vector(3 downto 0);
        d0_src2_value : in std_logic_vector(15 downto 0);
        d0_carry_rrf : in std_logic;
        d0_carry_ready : in std_logic;
        d0_carry_tag : in std_logic_vector(3 downto 0);
        d0_carry_value : in std_logic;
        d0_zero_rrf : in std_logic;
        d0_zero_ready : in std_logic;
        d0_zero_tag : in std_logic_vector(3 downto 0);
        d0_zero_value : in std_logic;
        d0_is_branch : in std_logic;
        d0_branch_type : in std_logic_vector(3 downto 0);
        d0_pc : in std_logic_vector(15 downto 0);

        d1_alu_fire : in std_logic;
        d1_is_add : in std_logic;
        d1_is_nand : in std_logic;
        d1_lli : in std_logic;
        d1_is_adi : in std_logic;
        d1_use_carry : in std_logic;
        d1_use_zero : in std_logic;
        d1_use_complement : in std_logic;
        d1_imm : in std_logic_vector(15 downto 0);
        d1_dest_tag : in std_logic_vector(3 downto 0);
        d1_dest_carry_tag : in std_logic_vector(3 downto 0);
        d1_dest_zero_tag : in std_logic_vector(3 downto 0);
        d1_rob_idx : in std_logic_vector(3 downto 0);
        d1_src1_rrf : in std_logic;
        d1_src1_ready : in std_logic;
        d1_src1_tag : in std_logic_vector(3 downto 0);
        d1_src1_value : in std_logic_vector(15 downto 0);
        d1_src2_rrf : in std_logic;
        d1_src2_ready : in std_logic;
        d1_src2_tag : in std_logic_vector(3 downto 0);
        d1_src2_value : in std_logic_vector(15 downto 0);
        d1_carry_rrf : in std_logic;
        d1_carry_ready : in std_logic;
        d1_carry_tag : in std_logic_vector(3 downto 0);
        d1_carry_value : in std_logic;
        d1_zero_rrf : in std_logic;
        d1_zero_ready : in std_logic;
        d1_zero_tag : in std_logic_vector(3 downto 0);
        d1_zero_value : in std_logic;
        d1_is_branch : in std_logic;
        d1_branch_type : in std_logic_vector(3 downto 0);
        d1_pc : in std_logic_vector(15 downto 0);

        wb0_valid : in std_logic;
        wb0_tag : in std_logic_vector(3 downto 0);
        wb0_data : in std_logic_vector(15 downto 0);
        wb1_valid : in std_logic;
        wb1_tag : in std_logic_vector(3 downto 0);
        wb1_data : in std_logic_vector(15 downto 0);
        wb2_valid : in std_logic;
        wb2_tag : in std_logic_vector(3 downto 0);
        wb2_data : in std_logic_vector(15 downto 0);

        wb_cf0_valid : in std_logic;
        wb_cf0_tag : in std_logic_vector(3 downto 0);
        wb_cf0_data : in std_logic;
        wb_cf1_valid : in std_logic;
        wb_cf1_tag : in std_logic_vector(3 downto 0);
        wb_cf1_data : in std_logic;
        wb_cf2_valid : in std_logic;
        wb_cf2_tag : in std_logic_vector(3 downto 0);
        wb_cf2_data : in std_logic;

        wb_zf0_valid : in std_logic;
        wb_zf0_tag : in std_logic_vector(3 downto 0);
        wb_zf0_data : in std_logic;
        wb_zf1_valid : in std_logic;
        wb_zf1_tag : in std_logic_vector(3 downto 0);
        wb_zf1_data : in std_logic;
        wb_zf2_valid : in std_logic;
        wb_zf2_tag : in std_logic_vector(3 downto 0);
        wb_zf2_data : in std_logic;

        issue_alu0_valid : out std_logic;
        issue_alu1_valid : out std_logic;

        issue_alu0_is_add : out std_logic;
        issue_alu0_is_nand : out std_logic;
        issue_alu0_lli : out std_logic;
        issue_alu0_is_adi : out std_logic;
        issue_alu0_use_carry : out std_logic;
        issue_alu0_use_zero : out std_logic;
        issue_alu0_use_complement : out std_logic;
        issue_alu0_imm : out std_logic_vector(15 downto 0);
        issue_alu0_src1_value : out std_logic_vector(15 downto 0);
        issue_alu0_src2_value : out std_logic_vector(15 downto 0);
        issue_alu0_dest_tag : out std_logic_vector(3 downto 0);
        issue_alu0_rob_idx : out std_logic_vector(3 downto 0);
        issue_alu0_carry_tag : out std_logic_vector(3 downto 0);
        issue_alu0_carry_value : out std_logic;
        issue_alu0_zero_tag : out std_logic_vector(3 downto 0);
        issue_alu0_zero_value : out std_logic;
        issue_alu0_is_branch : out std_logic;
        issue_alu0_branch_type : out std_logic_vector(3 downto 0);
        issue_alu0_pc : out std_logic_vector(15 downto 0);

        issue_alu1_is_add : out std_logic;
        issue_alu1_is_nand : out std_logic;
        issue_alu1_lli : out std_logic;
        issue_alu1_is_adi : out std_logic;
        issue_alu1_use_carry : out std_logic;
        issue_alu1_use_zero : out std_logic;
        issue_alu1_use_complement : out std_logic;
        issue_alu1_imm : out std_logic_vector(15 downto 0);
        issue_alu1_src1_value : out std_logic_vector(15 downto 0);
        issue_alu1_src2_value : out std_logic_vector(15 downto 0);
        issue_alu1_dest_tag : out std_logic_vector(3 downto 0);
        issue_alu1_rob_idx : out std_logic_vector(3 downto 0);
        issue_alu1_carry_tag : out std_logic_vector(3 downto 0);
        issue_alu1_carry_value : out std_logic;
        issue_alu1_zero_tag : out std_logic_vector(3 downto 0);
        issue_alu1_zero_value : out std_logic;
        issue_alu1_is_branch : out std_logic;
        issue_alu1_branch_type : out std_logic_vector(3 downto 0);
        issue_alu1_pc : out std_logic_vector(15 downto 0)
    );
end issue_stage;

architecture rtl of issue_stage is
    constant RS_DEPTH : integer := 16;
    constant RS_PTR_W : integer := 4;

    constant ZERO_16 : std_logic_vector(15 downto 0) := (others => '0');
    constant ZERO_4 : std_logic_vector(3 downto 0) := (others => '0');

    subtype ptr_t is unsigned(RS_PTR_W - 1 downto 0);
    subtype count_t is unsigned(4 downto 0);

    type rs_entry_t is record
        valid : std_logic;
        ready : std_logic;

        is_add : std_logic;
        is_nand : std_logic;
        lli : std_logic;
        is_adi : std_logic;
        use_carry : std_logic;
        use_zero : std_logic;
        use_complement : std_logic;
        imm : std_logic_vector(15 downto 0);

        dest_tag : std_logic_vector(3 downto 0);
        dest_carry_tag : std_logic_vector(3 downto 0);
        dest_zero_tag : std_logic_vector(3 downto 0);
        rob_idx : std_logic_vector(3 downto 0);

        src1_rrf : std_logic;
        src1_ready : std_logic;
        src1_tag : std_logic_vector(3 downto 0);
        src1_value : std_logic_vector(15 downto 0);

        src2_rrf : std_logic;
        src2_ready : std_logic;
        src2_tag : std_logic_vector(3 downto 0);
        src2_value : std_logic_vector(15 downto 0);

        carry_rrf : std_logic;
        carry_ready : std_logic;
        carry_tag : std_logic_vector(3 downto 0);
        carry_value : std_logic;

        zero_rrf : std_logic;
        zero_ready : std_logic;
        zero_tag : std_logic_vector(3 downto 0);
        zero_value : std_logic;

        is_branch : std_logic;
        branch_type : std_logic_vector(3 downto 0);
        pc : std_logic_vector(15 downto 0);
    end record;

    type issue_bundle_t is record
        valid : std_logic;
        is_add : std_logic;
        is_nand : std_logic;
        lli : std_logic;
        is_adi : std_logic;
        use_carry : std_logic;
        use_zero : std_logic;
        use_complement : std_logic;
        imm : std_logic_vector(15 downto 0);
        src1_value : std_logic_vector(15 downto 0);
        src2_value : std_logic_vector(15 downto 0);
        dest_tag : std_logic_vector(3 downto 0);
        rob_idx : std_logic_vector(3 downto 0);
        carry_tag : std_logic_vector(3 downto 0);
        carry_value : std_logic;
        zero_tag : std_logic_vector(3 downto 0);
        zero_value : std_logic;
        is_branch : std_logic;
        branch_type : std_logic_vector(3 downto 0);
        pc : std_logic_vector(15 downto 0);
    end record;

    type rs_entry_array_t is array (0 to RS_DEPTH - 1) of rs_entry_t;
    type fl_array_t is array (0 to RS_DEPTH - 1) of ptr_t;

    signal rs_q : rs_entry_array_t;
    signal rs_d : rs_entry_array_t;

    signal fl_q : fl_array_t;
    signal fl_d : fl_array_t;

    signal fl_head_q : ptr_t;
    signal fl_head_d : ptr_t;

    signal fl_tail_q : ptr_t;
    signal fl_tail_d : ptr_t;

    signal fl_count_q : count_t;
    signal fl_count_d : count_t;

    signal issue0_d : issue_bundle_t;
    signal issue1_d : issue_bundle_t;

    function zero_rs_entry return rs_entry_t is
        variable r : rs_entry_t;
    begin
        r.valid := '0';
        r.ready := '0';

        r.is_add := '0';
        r.is_nand := '0';
        r.lli := '0';
        r.is_adi := '0';
        r.use_carry := '0';
        r.use_zero := '0';
        r.use_complement := '0';
        r.imm := ZERO_16;

        r.dest_tag := ZERO_4;
        r.dest_carry_tag := ZERO_4;
        r.dest_zero_tag := ZERO_4;
        r.rob_idx := ZERO_4;

        r.src1_rrf := '0';
        r.src1_ready := '0';
        r.src1_tag := ZERO_4;
        r.src1_value := ZERO_16;

        r.src2_rrf := '0';
        r.src2_ready := '0';
        r.src2_tag := ZERO_4;
        r.src2_value := ZERO_16;

        r.carry_rrf := '0';
        r.carry_ready := '0';
        r.carry_tag := ZERO_4;
        r.carry_value := '0';

        r.zero_rrf := '0';
        r.zero_ready := '0';
        r.zero_tag := ZERO_4;
        r.zero_value := '0';

        r.is_branch := '0';
        r.branch_type := ZERO_4;
        r.pc := ZERO_16;
        return r;
    end function;

    function zero_issue_bundle return issue_bundle_t is
        variable r : issue_bundle_t;
    begin
        r.valid := '0';
        r.is_add := '0';
        r.is_nand := '0';
        r.lli := '0';
        r.is_adi := '0';
        r.use_carry := '0';
        r.use_zero := '0';
        r.use_complement := '0';
        r.imm := ZERO_16;
        r.src1_value := ZERO_16;
        r.src2_value := ZERO_16;
        r.dest_tag := ZERO_4;
        r.rob_idx := ZERO_4;
        r.carry_tag := ZERO_4;
        r.carry_value := '0';
        r.zero_tag := ZERO_4;
        r.zero_value := '0';
        r.is_branch := '0';
        r.branch_type := ZERO_4;
        r.pc := ZERO_16;
        return r;
    end function;

    function wb_hit(
        src_rrf : std_logic;
        src_ready : std_logic;
        src_tag : std_logic_vector(3 downto 0);
        wb_valid : std_logic;
        wb_tag : std_logic_vector(3 downto 0)
    ) return boolean is
    begin
        return (src_rrf = '1') and
               (src_ready = '0') and
               (wb_valid = '1') and
               (src_tag = wb_tag);
    end function;

    function resolve_ready_int(
        src_rrf : std_logic;
        src_ready : std_logic;
        src_tag : std_logic_vector(3 downto 0);
        wb0_valid : std_logic;
        wb0_tag : std_logic_vector(3 downto 0);
        wb1_valid : std_logic;
        wb1_tag : std_logic_vector(3 downto 0);
        wb2_valid : std_logic;
        wb2_tag : std_logic_vector(3 downto 0)
    ) return std_logic is
    begin
        if (src_ready = '1') or
           wb_hit(src_rrf, src_ready, src_tag, wb0_valid, wb0_tag) or
           wb_hit(src_rrf, src_ready, src_tag, wb1_valid, wb1_tag) or
           wb_hit(src_rrf, src_ready, src_tag, wb2_valid, wb2_tag) then
            return '1';
        else
            return '0';
        end if;
    end function;

    function resolve_value_int(
        src_rrf : std_logic;
        src_ready : std_logic;
        src_tag : std_logic_vector(3 downto 0);
        src_value : std_logic_vector(15 downto 0);
        wb0_valid : std_logic;
        wb0_tag : std_logic_vector(3 downto 0);
        wb0_data : std_logic_vector(15 downto 0);
        wb1_valid : std_logic;
        wb1_tag : std_logic_vector(3 downto 0);
        wb1_data : std_logic_vector(15 downto 0);
        wb2_valid : std_logic;
        wb2_tag : std_logic_vector(3 downto 0);
        wb2_data : std_logic_vector(15 downto 0)
    ) return std_logic_vector is
    begin
        if wb_hit(src_rrf, src_ready, src_tag, wb0_valid, wb0_tag) then
            return wb0_data;
        elsif wb_hit(src_rrf, src_ready, src_tag, wb1_valid, wb1_tag) then
            return wb1_data;
        elsif wb_hit(src_rrf, src_ready, src_tag, wb2_valid, wb2_tag) then
            return wb2_data;
        else
            return src_value;
        end if;
    end function;

    function resolve_ready_cf(
        src_rrf : std_logic;
        src_ready : std_logic;
        src_tag : std_logic_vector(3 downto 0);
        wb0_valid : std_logic;
        wb0_tag : std_logic_vector(3 downto 0);
        wb1_valid : std_logic;
        wb1_tag : std_logic_vector(3 downto 0);
        wb2_valid : std_logic;
        wb2_tag : std_logic_vector(3 downto 0)
    ) return std_logic is
    begin
        if (src_ready = '1') or
           wb_hit(src_rrf, src_ready, src_tag, wb0_valid, wb0_tag) or
           wb_hit(src_rrf, src_ready, src_tag, wb1_valid, wb1_tag) or
           wb_hit(src_rrf, src_ready, src_tag, wb2_valid, wb2_tag) then
            return '1';
        else
            return '0';
        end if;
    end function;

    function resolve_value_cf(
        src_rrf : std_logic;
        src_ready : std_logic;
        src_tag : std_logic_vector(3 downto 0);
        src_value : std_logic;
        wb0_valid : std_logic;
        wb0_tag : std_logic_vector(3 downto 0);
        wb0_data : std_logic;
        wb1_valid : std_logic;
        wb1_tag : std_logic_vector(3 downto 0);
        wb1_data : std_logic;
        wb2_valid : std_logic;
        wb2_tag : std_logic_vector(3 downto 0);
        wb2_data : std_logic
    ) return std_logic is
    begin
        if wb_hit(src_rrf, src_ready, src_tag, wb0_valid, wb0_tag) then
            return wb0_data;
        elsif wb_hit(src_rrf, src_ready, src_tag, wb1_valid, wb1_tag) then
            return wb1_data;
        elsif wb_hit(src_rrf, src_ready, src_tag, wb2_valid, wb2_tag) then
            return wb2_data;
        else
            return src_value;
        end if;
    end function;

    function bundle_from_rs(rs_src : rs_entry_t) return issue_bundle_t is
        variable b : issue_bundle_t;
    begin
        b := zero_issue_bundle;
        b.valid := '1';
        b.is_add := rs_src.is_add;
        b.is_nand := rs_src.is_nand;
        b.lli := rs_src.lli;
        b.is_adi := rs_src.is_adi;
        b.use_carry := rs_src.use_carry;
        b.use_zero := rs_src.use_zero;
        b.use_complement := rs_src.use_complement;
        b.imm := rs_src.imm;
        b.src1_value := rs_src.src1_value;
        b.src2_value := rs_src.src2_value;
        b.dest_tag := rs_src.dest_tag;
        b.rob_idx := rs_src.rob_idx;
        b.carry_tag := rs_src.dest_carry_tag;
        b.carry_value := rs_src.carry_value;
        b.zero_tag := rs_src.dest_zero_tag;
        b.zero_value := rs_src.zero_value;
        b.is_branch := rs_src.is_branch;
        b.branch_type := rs_src.branch_type;
        b.pc := rs_src.pc;
        return b;
    end function;

begin

    process(
        clk, rst, redirect_valid,
        rs_q, fl_q, fl_head_q, fl_tail_q, fl_count_q,
        d0_alu_fire, d0_is_add, d0_is_nand, d0_lli, d0_is_adi, d0_use_carry, d0_use_zero, d0_use_complement, d0_imm,
        d0_dest_tag, d0_dest_carry_tag, d0_dest_zero_tag, d0_rob_idx,
        d0_src1_rrf, d0_src1_ready, d0_src1_tag, d0_src1_value,
        d0_src2_rrf, d0_src2_ready, d0_src2_tag, d0_src2_value,
        d0_carry_rrf, d0_carry_ready, d0_carry_tag, d0_carry_value,
        d0_zero_rrf, d0_zero_ready, d0_zero_tag, d0_zero_value,
        d0_is_branch, d0_branch_type, d0_pc,
        d1_alu_fire, d1_is_add, d1_is_nand, d1_lli, d1_is_adi, d1_use_carry, d1_use_zero, d1_use_complement, d1_imm,
        d1_dest_tag, d1_dest_carry_tag, d1_dest_zero_tag, d1_rob_idx,
        d1_src1_rrf, d1_src1_ready, d1_src1_tag, d1_src1_value,
        d1_src2_rrf, d1_src2_ready, d1_src2_tag, d1_src2_value,
        d1_carry_rrf, d1_carry_ready, d1_carry_tag, d1_carry_value,
        d1_zero_rrf, d1_zero_ready, d1_zero_tag, d1_zero_value,
        d1_is_branch, d1_branch_type, d1_pc,
        wb0_valid, wb0_tag, wb0_data,
        wb1_valid, wb1_tag, wb1_data,
        wb2_valid, wb2_tag, wb2_data,
        wb_cf0_valid, wb_cf0_tag, wb_cf0_data,
        wb_cf1_valid, wb_cf1_tag, wb_cf1_data,
        wb_cf2_valid, wb_cf2_tag, wb_cf2_data,
        wb_zf0_valid, wb_zf0_tag, wb_zf0_data,
        wb_zf1_valid, wb_zf1_tag, wb_zf1_data,
        wb_zf2_valid, wb_zf2_tag, wb_zf2_data
    )
        variable rs_v : rs_entry_array_t;
        variable fl_v : fl_array_t;
        variable fl_head_v : ptr_t;
        variable fl_tail_v : ptr_t;
        variable fl_count_v : count_t;
        variable issue_taken_v : std_logic_vector(RS_DEPTH - 1 downto 0);
        variable alu_issue_count_v : integer;
        variable alloc_count_v : integer;
        variable fl_enq_count_v : integer;
        variable d0_idx_v : integer;
        variable d1_idx_v : integer;
        variable d1_actual_idx_v : integer;
    begin
        issue0_d <= zero_issue_bundle;
        issue1_d <= zero_issue_bundle;

        rs_v := rs_q;
        fl_v := fl_q;
        fl_head_v := fl_head_q;
        fl_tail_v := fl_tail_q;
        fl_count_v := fl_count_q;

        issue_taken_v := (others => '0');
        alu_issue_count_v := 0;
        alloc_count_v := 0;
        fl_enq_count_v := 0;

        d0_idx_v := to_integer(unsigned(fl_q(to_integer(fl_head_q))));
        d1_idx_v := to_integer(unsigned(fl_q(to_integer(fl_head_q + to_unsigned(1, RS_PTR_W)))));
        d1_actual_idx_v := d0_idx_v;

        if (rst = '0') and (redirect_valid = '0') then
            if wb0_valid = '1' then
                for i in 0 to RS_DEPTH - 1 loop
                    if (rs_v(i).valid = '1') and
                       (rs_v(i).src1_rrf = '1') and
                       (rs_v(i).src1_ready = '0') and
                       (rs_v(i).src1_tag = wb0_tag) then
                        rs_v(i).src1_ready := '1';
                        rs_v(i).src1_value := wb0_data;
                        rs_v(i).ready := rs_v(i).src1_ready and rs_v(i).src2_ready and rs_v(i).carry_ready and rs_v(i).zero_ready;
                    end if;
                    if (rs_v(i).valid = '1') and
                       (rs_v(i).src2_rrf = '1') and
                       (rs_v(i).src2_ready = '0') and
                       (rs_v(i).src2_tag = wb0_tag) then
                        rs_v(i).src2_ready := '1';
                        rs_v(i).src2_value := wb0_data;
                        rs_v(i).ready := rs_v(i).src1_ready and rs_v(i).src2_ready and rs_v(i).carry_ready and rs_v(i).zero_ready;
                    end if;
                end loop;
            end if;

            if wb1_valid = '1' then
                for i in 0 to RS_DEPTH - 1 loop
                    if (rs_v(i).valid = '1') and
                       (rs_v(i).src1_rrf = '1') and
                       (rs_v(i).src1_ready = '0') and
                       (rs_v(i).src1_tag = wb1_tag) then
                        rs_v(i).src1_ready := '1';
                        rs_v(i).src1_value := wb1_data;
                        rs_v(i).ready := rs_v(i).src1_ready and rs_v(i).src2_ready and rs_v(i).carry_ready and rs_v(i).zero_ready;
                    end if;
                    if (rs_v(i).valid = '1') and
                       (rs_v(i).src2_rrf = '1') and
                       (rs_v(i).src2_ready = '0') and
                       (rs_v(i).src2_tag = wb1_tag) then
                        rs_v(i).src2_ready := '1';
                        rs_v(i).src2_value := wb1_data;
                        rs_v(i).ready := rs_v(i).src1_ready and rs_v(i).src2_ready and rs_v(i).carry_ready and rs_v(i).zero_ready;
                    end if;
                end loop;
            end if;

            if wb2_valid = '1' then
                for i in 0 to RS_DEPTH - 1 loop
                    if (rs_v(i).valid = '1') and
                       (rs_v(i).src1_rrf = '1') and
                       (rs_v(i).src1_ready = '0') and
                       (rs_v(i).src1_tag = wb2_tag) then
                        rs_v(i).src1_ready := '1';
                        rs_v(i).src1_value := wb2_data;
                        rs_v(i).ready := rs_v(i).src1_ready and rs_v(i).src2_ready and rs_v(i).carry_ready and rs_v(i).zero_ready;
                    end if;
                    if (rs_v(i).valid = '1') and
                       (rs_v(i).src2_rrf = '1') and
                       (rs_v(i).src2_ready = '0') and
                       (rs_v(i).src2_tag = wb2_tag) then
                        rs_v(i).src2_ready := '1';
                        rs_v(i).src2_value := wb2_data;
                        rs_v(i).ready := rs_v(i).src1_ready and rs_v(i).src2_ready and rs_v(i).carry_ready and rs_v(i).zero_ready;
                    end if;
                end loop;
            end if;

            if wb_cf0_valid = '1' then
                for i in 0 to RS_DEPTH - 1 loop
                    if (rs_v(i).valid = '1') and
                       (rs_v(i).carry_rrf = '1') and
                       (rs_v(i).carry_ready = '0') and
                       (rs_v(i).carry_tag = wb_cf0_tag) then
                        rs_v(i).carry_ready := '1';
                        rs_v(i).carry_value := wb_cf0_data;
                        rs_v(i).ready := rs_v(i).src1_ready and rs_v(i).src2_ready and rs_v(i).carry_ready and rs_v(i).zero_ready;
                    end if;
                end loop;
            end if;

            if wb_cf1_valid = '1' then
                for i in 0 to RS_DEPTH - 1 loop
                    if (rs_v(i).valid = '1') and
                       (rs_v(i).carry_rrf = '1') and
                       (rs_v(i).carry_ready = '0') and
                       (rs_v(i).carry_tag = wb_cf1_tag) then
                        rs_v(i).carry_ready := '1';
                        rs_v(i).carry_value := wb_cf1_data;
                        rs_v(i).ready := rs_v(i).src1_ready and rs_v(i).src2_ready and rs_v(i).carry_ready and rs_v(i).zero_ready;
                    end if;
                end loop;
            end if;

            if wb_cf2_valid = '1' then
                for i in 0 to RS_DEPTH - 1 loop
                    if (rs_v(i).valid = '1') and
                       (rs_v(i).carry_rrf = '1') and
                       (rs_v(i).carry_ready = '0') and
                       (rs_v(i).carry_tag = wb_cf2_tag) then
                        rs_v(i).carry_ready := '1';
                        rs_v(i).carry_value := wb_cf2_data;
                        rs_v(i).ready := rs_v(i).src1_ready and rs_v(i).src2_ready and rs_v(i).carry_ready and rs_v(i).zero_ready;
                    end if;
                end loop;
            end if;

            if wb_zf0_valid = '1' then
                for i in 0 to RS_DEPTH - 1 loop
                    if (rs_v(i).valid = '1') and
                       (rs_v(i).zero_rrf = '1') and
                       (rs_v(i).zero_ready = '0') and
                       (rs_v(i).zero_tag = wb_zf0_tag) then
                        rs_v(i).zero_ready := '1';
                        rs_v(i).zero_value := wb_zf0_data;
                        rs_v(i).ready := rs_v(i).src1_ready and rs_v(i).src2_ready and rs_v(i).carry_ready and rs_v(i).zero_ready;
                    end if;
                end loop;
            end if;

            if wb_zf1_valid = '1' then
                for i in 0 to RS_DEPTH - 1 loop
                    if (rs_v(i).valid = '1') and
                       (rs_v(i).zero_rrf = '1') and
                       (rs_v(i).zero_ready = '0') and
                       (rs_v(i).zero_tag = wb_zf1_tag) then
                        rs_v(i).zero_ready := '1';
                        rs_v(i).zero_value := wb_zf1_data;
                        rs_v(i).ready := rs_v(i).src1_ready and rs_v(i).src2_ready and rs_v(i).carry_ready and rs_v(i).zero_ready;
                    end if;
                end loop;
            end if;

            if wb_zf2_valid = '1' then
                for i in 0 to RS_DEPTH - 1 loop
                    if (rs_v(i).valid = '1') and
                       (rs_v(i).zero_rrf = '1') and
                       (rs_v(i).zero_ready = '0') and
                       (rs_v(i).zero_tag = wb_zf2_tag) then
                        rs_v(i).zero_ready := '1';
                        rs_v(i).zero_value := wb_zf2_data;
                        rs_v(i).ready := rs_v(i).src1_ready and rs_v(i).src2_ready and rs_v(i).carry_ready and rs_v(i).zero_ready;
                    end if;
                end loop;
            end if;

            for i in 0 to RS_DEPTH - 1 loop
                if (rs_q(i).valid = '1') and (rs_q(i).ready = '1') and (issue_taken_v(i) = '0') then
                    if alu_issue_count_v < 2 then
                        if alu_issue_count_v = 0 then
                            issue0_d <= bundle_from_rs(rs_q(i));
                        else
                            issue1_d <= bundle_from_rs(rs_q(i));
                        end if;

                        alu_issue_count_v := alu_issue_count_v + 1;
                        issue_taken_v(i) := '1';
                    end if;
                end if;
            end loop;

            for i in 0 to RS_DEPTH - 1 loop
                if issue_taken_v(i) = '1' then
                    rs_v(i).valid := '0';
                    rs_v(i).ready := '0';
                    fl_v(to_integer(fl_tail_q + to_unsigned(fl_enq_count_v, RS_PTR_W))) := to_unsigned(i, RS_PTR_W);
                    fl_enq_count_v := fl_enq_count_v + 1;
                end if;
            end loop;

            d1_actual_idx_v := d0_idx_v;
            if d0_alu_fire = '1' then
                d1_actual_idx_v := d1_idx_v;
            end if;

            if d0_alu_fire = '1' then
                rs_v(d0_idx_v).valid := '1';
                rs_v(d0_idx_v).is_add := d0_is_add;
                rs_v(d0_idx_v).is_nand := d0_is_nand;
                rs_v(d0_idx_v).lli := d0_lli;
                rs_v(d0_idx_v).is_adi := d0_is_adi;
                rs_v(d0_idx_v).use_carry := d0_use_carry;
                rs_v(d0_idx_v).use_zero := d0_use_zero;
                rs_v(d0_idx_v).use_complement := d0_use_complement;
                rs_v(d0_idx_v).imm := d0_imm;
                rs_v(d0_idx_v).dest_tag := d0_dest_tag;
                rs_v(d0_idx_v).dest_carry_tag := d0_dest_carry_tag;
                rs_v(d0_idx_v).dest_zero_tag := d0_dest_zero_tag;
                rs_v(d0_idx_v).rob_idx := d0_rob_idx;

                rs_v(d0_idx_v).src1_rrf := d0_src1_rrf;
                rs_v(d0_idx_v).src1_ready := resolve_ready_int(
                    d0_src1_rrf, d0_src1_ready, d0_src1_tag,
                    wb0_valid, wb0_tag,
                    wb1_valid, wb1_tag,
                    wb2_valid, wb2_tag
                );
                rs_v(d0_idx_v).src1_tag := d0_src1_tag;
                rs_v(d0_idx_v).src1_value := resolve_value_int(
                    d0_src1_rrf, d0_src1_ready, d0_src1_tag, d0_src1_value,
                    wb0_valid, wb0_tag, wb0_data,
                    wb1_valid, wb1_tag, wb1_data,
                    wb2_valid, wb2_tag, wb2_data
                );

                rs_v(d0_idx_v).src2_rrf := d0_src2_rrf;
                rs_v(d0_idx_v).src2_ready := resolve_ready_int(
                    d0_src2_rrf, d0_src2_ready, d0_src2_tag,
                    wb0_valid, wb0_tag,
                    wb1_valid, wb1_tag,
                    wb2_valid, wb2_tag
                );
                rs_v(d0_idx_v).src2_tag := d0_src2_tag;
                rs_v(d0_idx_v).src2_value := resolve_value_int(
                    d0_src2_rrf, d0_src2_ready, d0_src2_tag, d0_src2_value,
                    wb0_valid, wb0_tag, wb0_data,
                    wb1_valid, wb1_tag, wb1_data,
                    wb2_valid, wb2_tag, wb2_data
                );

                rs_v(d0_idx_v).carry_rrf := d0_carry_rrf;
                rs_v(d0_idx_v).carry_ready := resolve_ready_cf(
                    d0_carry_rrf, d0_carry_ready, d0_carry_tag,
                    wb_cf0_valid, wb_cf0_tag,
                    wb_cf1_valid, wb_cf1_tag,
                    wb_cf2_valid, wb_cf2_tag
                );
                rs_v(d0_idx_v).carry_tag := d0_carry_tag;
                rs_v(d0_idx_v).carry_value := resolve_value_cf(
                    d0_carry_rrf, d0_carry_ready, d0_carry_tag, d0_carry_value,
                    wb_cf0_valid, wb_cf0_tag, wb_cf0_data,
                    wb_cf1_valid, wb_cf1_tag, wb_cf1_data,
                    wb_cf2_valid, wb_cf2_tag, wb_cf2_data
                );

                rs_v(d0_idx_v).zero_rrf := d0_zero_rrf;
                rs_v(d0_idx_v).zero_ready := resolve_ready_cf(
                    d0_zero_rrf, d0_zero_ready, d0_zero_tag,
                    wb_zf0_valid, wb_zf0_tag,
                    wb_zf1_valid, wb_zf1_tag,
                    wb_zf2_valid, wb_zf2_tag
                );
                rs_v(d0_idx_v).zero_tag := d0_zero_tag;
                rs_v(d0_idx_v).zero_value := resolve_value_cf(
                    d0_zero_rrf, d0_zero_ready, d0_zero_tag, d0_zero_value,
                    wb_zf0_valid, wb_zf0_tag, wb_zf0_data,
                    wb_zf1_valid, wb_zf1_tag, wb_zf1_data,
                    wb_zf2_valid, wb_zf2_tag, wb_zf2_data
                );

                rs_v(d0_idx_v).is_branch := d0_is_branch;
                rs_v(d0_idx_v).branch_type := d0_branch_type;
                rs_v(d0_idx_v).pc := d0_pc;
                rs_v(d0_idx_v).ready := rs_v(d0_idx_v).src1_ready and rs_v(d0_idx_v).src2_ready and rs_v(d0_idx_v).carry_ready and rs_v(d0_idx_v).zero_ready;
            end if;

            if d1_alu_fire = '1' then
                rs_v(d1_actual_idx_v).valid := '1';
                rs_v(d1_actual_idx_v).is_add := d1_is_add;
                rs_v(d1_actual_idx_v).is_nand := d1_is_nand;
                rs_v(d1_actual_idx_v).lli := d1_lli;
                rs_v(d1_actual_idx_v).is_adi := d1_is_adi;
                rs_v(d1_actual_idx_v).use_carry := d1_use_carry;
                rs_v(d1_actual_idx_v).use_zero := d1_use_zero;
                rs_v(d1_actual_idx_v).use_complement := d1_use_complement;
                rs_v(d1_actual_idx_v).imm := d1_imm;
                rs_v(d1_actual_idx_v).dest_tag := d1_dest_tag;
                rs_v(d1_actual_idx_v).dest_carry_tag := d1_dest_carry_tag;
                rs_v(d1_actual_idx_v).dest_zero_tag := d1_dest_zero_tag;
                rs_v(d1_actual_idx_v).rob_idx := d1_rob_idx;

                rs_v(d1_actual_idx_v).src1_rrf := d1_src1_rrf;
                rs_v(d1_actual_idx_v).src1_ready := resolve_ready_int(
                    d1_src1_rrf, d1_src1_ready, d1_src1_tag,
                    wb0_valid, wb0_tag,
                    wb1_valid, wb1_tag,
                    wb2_valid, wb2_tag
                );
                rs_v(d1_actual_idx_v).src1_tag := d1_src1_tag;
                rs_v(d1_actual_idx_v).src1_value := resolve_value_int(
                    d1_src1_rrf, d1_src1_ready, d1_src1_tag, d1_src1_value,
                    wb0_valid, wb0_tag, wb0_data,
                    wb1_valid, wb1_tag, wb1_data,
                    wb2_valid, wb2_tag, wb2_data
                );

                rs_v(d1_actual_idx_v).src2_rrf := d1_src2_rrf;
                rs_v(d1_actual_idx_v).src2_ready := resolve_ready_int(
                    d1_src2_rrf, d1_src2_ready, d1_src2_tag,
                    wb0_valid, wb0_tag,
                    wb1_valid, wb1_tag,
                    wb2_valid, wb2_tag
                );
                rs_v(d1_actual_idx_v).src2_tag := d1_src2_tag;
                rs_v(d1_actual_idx_v).src2_value := resolve_value_int(
                    d1_src2_rrf, d1_src2_ready, d1_src2_tag, d1_src2_value,
                    wb0_valid, wb0_tag, wb0_data,
                    wb1_valid, wb1_tag, wb1_data,
                    wb2_valid, wb2_tag, wb2_data
                );

                rs_v(d1_actual_idx_v).carry_rrf := d1_carry_rrf;
                rs_v(d1_actual_idx_v).carry_ready := resolve_ready_cf(
                    d1_carry_rrf, d1_carry_ready, d1_carry_tag,
                    wb_cf0_valid, wb_cf0_tag,
                    wb_cf1_valid, wb_cf1_tag,
                    wb_cf2_valid, wb_cf2_tag
                );
                rs_v(d1_actual_idx_v).carry_tag := d1_carry_tag;
                rs_v(d1_actual_idx_v).carry_value := resolve_value_cf(
                    d1_carry_rrf, d1_carry_ready, d1_carry_tag, d1_carry_value,
                    wb_cf0_valid, wb_cf0_tag, wb_cf0_data,
                    wb_cf1_valid, wb_cf1_tag, wb_cf1_data,
                    wb_cf2_valid, wb_cf2_tag, wb_cf2_data
                );

                rs_v(d1_actual_idx_v).zero_rrf := d1_zero_rrf;
                rs_v(d1_actual_idx_v).zero_ready := resolve_ready_cf(
                    d1_zero_rrf, d1_zero_ready, d1_zero_tag,
                    wb_zf0_valid, wb_zf0_tag,
                    wb_zf1_valid, wb_zf1_tag,
                    wb_zf2_valid, wb_zf2_tag
                );
                rs_v(d1_actual_idx_v).zero_tag := d1_zero_tag;
                rs_v(d1_actual_idx_v).zero_value := resolve_value_cf(
                    d1_zero_rrf, d1_zero_ready, d1_zero_tag, d1_zero_value,
                    wb_zf0_valid, wb_zf0_tag, wb_zf0_data,
                    wb_zf1_valid, wb_zf1_tag, wb_zf1_data,
                    wb_zf2_valid, wb_zf2_tag, wb_zf2_data
                );

                rs_v(d1_actual_idx_v).is_branch := d1_is_branch;
                rs_v(d1_actual_idx_v).branch_type := d1_branch_type;
                rs_v(d1_actual_idx_v).pc := d1_pc;
                rs_v(d1_actual_idx_v).ready := rs_v(d1_actual_idx_v).src1_ready and rs_v(d1_actual_idx_v).src2_ready and rs_v(d1_actual_idx_v).carry_ready and rs_v(d1_actual_idx_v).zero_ready;
            end if;

            if d0_alu_fire = '1' then
                alloc_count_v := alloc_count_v + 1;
            end if;
            if d1_alu_fire = '1' then
                alloc_count_v := alloc_count_v + 1;
            end if;

            fl_head_v := fl_head_q + to_unsigned(alloc_count_v, RS_PTR_W);
            fl_tail_v := fl_tail_q + to_unsigned(fl_enq_count_v, RS_PTR_W);
            fl_count_v := fl_count_q + to_unsigned(fl_enq_count_v, 5) - to_unsigned(alloc_count_v, 5);
        else
            for i in 0 to RS_DEPTH - 1 loop
                rs_v(i) := zero_rs_entry;
                fl_v(i) := to_unsigned(i, RS_PTR_W);
            end loop;
            fl_head_v := (others => '0');
            fl_tail_v := (others => '0');
            fl_count_v := to_unsigned(RS_DEPTH, 5);
        end if;

        rs_d <= rs_v;
        fl_d <= fl_v;
        fl_head_d <= fl_head_v;
        fl_tail_d <= fl_tail_v;
        fl_count_d <= fl_count_v;
        rs_count <= std_logic_vector(fl_count_v);
    end process;

    process(clk, rst)
    begin
        if rst = '1' then
            for i in 0 to RS_DEPTH - 1 loop
                rs_q(i) <= zero_rs_entry;
                fl_q(i) <= to_unsigned(i, RS_PTR_W);
            end loop;

            fl_head_q <= (others => '0');
            fl_tail_q <= (others => '0');
            fl_count_q <= to_unsigned(RS_DEPTH, 5);

            issue_alu0_valid <= '0';
            issue_alu1_valid <= '0';

            issue_alu0_is_add <= '0';
            issue_alu0_is_nand <= '0';
            issue_alu0_lli <= '0';
            issue_alu0_is_adi <= '0';
            issue_alu0_use_carry <= '0';
            issue_alu0_use_zero <= '0';
            issue_alu0_use_complement <= '0';
            issue_alu0_imm <= ZERO_16;
            issue_alu0_src1_value <= ZERO_16;
            issue_alu0_src2_value <= ZERO_16;
            issue_alu0_dest_tag <= ZERO_4;
            issue_alu0_rob_idx <= ZERO_4;
            issue_alu0_carry_tag <= ZERO_4;
            issue_alu0_carry_value <= '0';
            issue_alu0_zero_tag <= ZERO_4;
            issue_alu0_zero_value <= '0';
            issue_alu0_is_branch <= '0';
            issue_alu0_branch_type <= ZERO_4;
            issue_alu0_pc <= ZERO_16;

            issue_alu1_is_add <= '0';
            issue_alu1_is_nand <= '0';
            issue_alu1_lli <= '0';
            issue_alu1_is_adi <= '0';
            issue_alu1_use_carry <= '0';
            issue_alu1_use_zero <= '0';
            issue_alu1_use_complement <= '0';
            issue_alu1_imm <= ZERO_16;
            issue_alu1_src1_value <= ZERO_16;
            issue_alu1_src2_value <= ZERO_16;
            issue_alu1_dest_tag <= ZERO_4;
            issue_alu1_rob_idx <= ZERO_4;
            issue_alu1_carry_tag <= ZERO_4;
            issue_alu1_carry_value <= '0';
            issue_alu1_zero_tag <= ZERO_4;
            issue_alu1_zero_value <= '0';
            issue_alu1_is_branch <= '0';
            issue_alu1_branch_type <= ZERO_4;
            issue_alu1_pc <= ZERO_16;
        elsif rising_edge(clk) then
            if redirect_valid = '1' then
                for i in 0 to RS_DEPTH - 1 loop
                    rs_q(i) <= zero_rs_entry;
                    fl_q(i) <= to_unsigned(i, RS_PTR_W);
                end loop;

                fl_head_q <= (others => '0');
                fl_tail_q <= (others => '0');
                fl_count_q <= to_unsigned(RS_DEPTH, 5);

                issue_alu0_valid <= '0';
                issue_alu1_valid <= '0';

                issue_alu0_is_add <= '0';
                issue_alu0_is_nand <= '0';
                issue_alu0_lli <= '0';
                issue_alu0_is_adi <= '0';
                issue_alu0_use_carry <= '0';
                issue_alu0_use_zero <= '0';
                issue_alu0_use_complement <= '0';
                issue_alu0_imm <= ZERO_16;
                issue_alu0_src1_value <= ZERO_16;
                issue_alu0_src2_value <= ZERO_16;
                issue_alu0_dest_tag <= ZERO_4;
                issue_alu0_rob_idx <= ZERO_4;
                issue_alu0_carry_tag <= ZERO_4;
                issue_alu0_carry_value <= '0';
                issue_alu0_zero_tag <= ZERO_4;
                issue_alu0_zero_value <= '0';
                issue_alu0_is_branch <= '0';
                issue_alu0_branch_type <= ZERO_4;
                issue_alu0_pc <= ZERO_16;

                issue_alu1_is_add <= '0';
                issue_alu1_is_nand <= '0';
                issue_alu1_lli <= '0';
                issue_alu1_is_adi <= '0';
                issue_alu1_use_carry <= '0';
                issue_alu1_use_zero <= '0';
                issue_alu1_use_complement <= '0';
                issue_alu1_imm <= ZERO_16;
                issue_alu1_src1_value <= ZERO_16;
                issue_alu1_src2_value <= ZERO_16;
                issue_alu1_dest_tag <= ZERO_4;
                issue_alu1_rob_idx <= ZERO_4;
                issue_alu1_carry_tag <= ZERO_4;
                issue_alu1_carry_value <= '0';
                issue_alu1_zero_tag <= ZERO_4;
                issue_alu1_zero_value <= '0';
                issue_alu1_is_branch <= '0';
                issue_alu1_branch_type <= ZERO_4;
                issue_alu1_pc <= ZERO_16;
            else
                for i in 0 to RS_DEPTH - 1 loop
                    rs_q(i) <= rs_d(i);
                    fl_q(i) <= fl_d(i);
                end loop;

                fl_head_q <= fl_head_d;
                fl_tail_q <= fl_tail_d;
                fl_count_q <= fl_count_d;

                issue_alu0_valid <= issue0_d.valid;
                issue_alu1_valid <= issue1_d.valid;

                issue_alu0_is_add <= issue0_d.is_add;
                issue_alu0_is_nand <= issue0_d.is_nand;
                issue_alu0_lli <= issue0_d.lli;
                issue_alu0_is_adi <= issue0_d.is_adi;
                issue_alu0_use_carry <= issue0_d.use_carry;
                issue_alu0_use_zero <= issue0_d.use_zero;
                issue_alu0_use_complement <= issue0_d.use_complement;
                issue_alu0_imm <= issue0_d.imm;
                issue_alu0_src1_value <= issue0_d.src1_value;
                issue_alu0_src2_value <= issue0_d.src2_value;
                issue_alu0_dest_tag <= issue0_d.dest_tag;
                issue_alu0_rob_idx <= issue0_d.rob_idx;
                issue_alu0_carry_tag <= issue0_d.carry_tag;
                issue_alu0_carry_value <= issue0_d.carry_value;
                issue_alu0_zero_tag <= issue0_d.zero_tag;
                issue_alu0_zero_value <= issue0_d.zero_value;
                issue_alu0_is_branch <= issue0_d.is_branch;
                issue_alu0_branch_type <= issue0_d.branch_type;
                issue_alu0_pc <= issue0_d.pc;

                issue_alu1_is_add <= issue1_d.is_add;
                issue_alu1_is_nand <= issue1_d.is_nand;
                issue_alu1_lli <= issue1_d.lli;
                issue_alu1_is_adi <= issue1_d.is_adi;
                issue_alu1_use_carry <= issue1_d.use_carry;
                issue_alu1_use_zero <= issue1_d.use_zero;
                issue_alu1_use_complement <= issue1_d.use_complement;
                issue_alu1_imm <= issue1_d.imm;
                issue_alu1_src1_value <= issue1_d.src1_value;
                issue_alu1_src2_value <= issue1_d.src2_value;
                issue_alu1_dest_tag <= issue1_d.dest_tag;
                issue_alu1_rob_idx <= issue1_d.rob_idx;
                issue_alu1_carry_tag <= issue1_d.carry_tag;
                issue_alu1_carry_value <= issue1_d.carry_value;
                issue_alu1_zero_tag <= issue1_d.zero_tag;
                issue_alu1_zero_value <= issue1_d.zero_value;
                issue_alu1_is_branch <= issue1_d.is_branch;
                issue_alu1_branch_type <= issue1_d.branch_type;
                issue_alu1_pc <= issue1_d.pc;
            end if;
        end if;
    end process;

end rtl;