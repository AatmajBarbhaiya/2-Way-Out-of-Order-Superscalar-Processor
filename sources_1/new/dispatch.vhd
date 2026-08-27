library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dispatch_stage is
    port (
        clk : in std_logic;
        rst : in std_logic;
        redirect_valid : in std_logic;

        dec0_valid : in std_logic;
        dec0_dest_en : in std_logic;
        dec0_is_add : in std_logic;
        dec0_is_nand : in std_logic;
        dec0_is_adi : in std_logic;
        dec0_use_carry : in std_logic;
        dec0_use_zero : in std_logic;
        dec0_write_carry : in std_logic;
        dec0_write_zero : in std_logic;
        dec0_use_complement : in std_logic;
        dec0_imm : in std_logic_vector(15 downto 0);
        dec0_src1 : in std_logic_vector(2 downto 0);
        dec0_src2 : in std_logic_vector(2 downto 0);
        dec0_dest : in std_logic_vector(2 downto 0);
        dec0_lli : in std_logic;
        dec0_load : in std_logic;
        dec0_store : in std_logic;
        dec0_is_branch : in std_logic;
        dec0_branch_type : in std_logic_vector(3 downto 0);
        dec0_pc : in std_logic_vector(15 downto 0);

        dec1_valid : in std_logic;
        dec1_dest_en : in std_logic;
        dec1_is_add : in std_logic;
        dec1_is_nand : in std_logic;
        dec1_is_adi : in std_logic;
        dec1_use_carry : in std_logic;
        dec1_use_zero : in std_logic;
        dec1_write_carry : in std_logic;
        dec1_write_zero : in std_logic;
        dec1_use_complement : in std_logic;
        dec1_imm : in std_logic_vector(15 downto 0);
        dec1_src1 : in std_logic_vector(2 downto 0);
        dec1_src2 : in std_logic_vector(2 downto 0);
        dec1_dest : in std_logic_vector(2 downto 0);
        dec1_lli : in std_logic;
        dec1_load : in std_logic;
        dec1_store : in std_logic;
        dec1_is_branch : in std_logic;
        dec1_branch_type : in std_logic_vector(3 downto 0);
        dec1_pc : in std_logic_vector(15 downto 0);

        s0_1_rrf : in std_logic;
        s0_1_tag : in std_logic_vector(3 downto 0);
        s0_1_ready : in std_logic;
        s0_1_val : in std_logic_vector(15 downto 0);

        s0_2_rrf : in std_logic;
        s0_2_tag : in std_logic_vector(3 downto 0);
        s0_2_ready : in std_logic;
        s0_2_val : in std_logic_vector(15 downto 0);

        s1_1_rrf : in std_logic;
        s1_1_tag : in std_logic_vector(3 downto 0);
        s1_1_ready : in std_logic;
        s1_1_val : in std_logic_vector(15 downto 0);

        s1_2_rrf : in std_logic;
        s1_2_tag : in std_logic_vector(3 downto 0);
        s1_2_ready : in std_logic;
        s1_2_val : in std_logic_vector(15 downto 0);

        s0_cf_rrf : in std_logic;
        s0_cf_tag : in std_logic_vector(3 downto 0);
        s0_cf_ready : in std_logic;
        s0_cf_val : in std_logic;

        s0_zf_rrf : in std_logic;
        s0_zf_tag : in std_logic_vector(3 downto 0);
        s0_zf_ready : in std_logic;
        s0_zf_val : in std_logic;

        s1_cf_rrf : in std_logic;
        s1_cf_tag : in std_logic_vector(3 downto 0);
        s1_cf_ready : in std_logic;
        s1_cf_val : in std_logic;

        s1_zf_rrf : in std_logic;
        s1_zf_tag : in std_logic_vector(3 downto 0);
        s1_zf_ready : in std_logic;
        s1_zf_val : in std_logic;

        rename0_tag : in std_logic_vector(3 downto 0);
        rename1_tag : in std_logic_vector(3 downto 0);
        rename0_arch : out std_logic_vector(2 downto 0);
        rename1_arch : out std_logic_vector(2 downto 0);
        rename0_fire : out std_logic;
        rename1_fire : out std_logic;

        rename0_cf_fire : out std_logic;
        rename1_cf_fire : out std_logic;

        rename0_cf_tag : in std_logic_vector(3 downto 0);
        rename1_cf_tag : in std_logic_vector(3 downto 0);

        rename0_zf_fire : out std_logic;
        rename1_zf_fire : out std_logic;

        rename0_zf_tag : in std_logic_vector(3 downto 0);
        rename1_zf_tag : in std_logic_vector(3 downto 0);

        rob_0_idx : in std_logic_vector(3 downto 0);
        rob_1_idx : in std_logic_vector(3 downto 0);
        rob_0_query : out std_logic_vector(3 downto 0);
        rob_1_query : out std_logic_vector(3 downto 0);

        rob_count : in std_logic_vector(4 downto 0);
        rs_count : in std_logic_vector(4 downto 0);
        rrf_count : in std_logic_vector(4 downto 0);
        lsu_count : in std_logic_vector(4 downto 0);
        zf_free_count : in std_logic_vector(4 downto 0);
        cf_free_count : in std_logic_vector(4 downto 0);

        d0_fire : out std_logic;
        d1_fire : out std_logic;
        d0_alu_fire : out std_logic;
        d1_alu_fire : out std_logic;
        d0_lsu_fire : out std_logic;
        d1_lsu_fire : out std_logic;
        d0_src1_rrf : out std_logic;
        d0_src2_rrf : out std_logic;
        d1_src1_rrf : out std_logic;
        d1_src2_rrf : out std_logic;

        d0_src1_ready : out std_logic;
        d0_src2_ready : out std_logic;
        d1_src1_ready : out std_logic;
        d1_src2_ready : out std_logic;

        d0_src1_tag : out std_logic_vector(3 downto 0);
        d0_src2_tag : out std_logic_vector(3 downto 0);
        d1_src1_tag : out std_logic_vector(3 downto 0);
        d1_src2_tag : out std_logic_vector(3 downto 0);

        d0_src1_value : out std_logic_vector(15 downto 0);
        d0_src2_value : out std_logic_vector(15 downto 0);
        d1_src1_value : out std_logic_vector(15 downto 0);
        d1_src2_value : out std_logic_vector(15 downto 0);

        d0_cf_rrf : out std_logic;
        d0_cf_tag : out std_logic_vector(3 downto 0);
        d0_cf_ready : out std_logic;
        d0_cf_val : out std_logic;

        d0_zf_rrf : out std_logic;
        d0_zf_tag : out std_logic_vector(3 downto 0);
        d0_zf_ready : out std_logic;
        d0_zf_val : out std_logic;

        d1_cf_rrf : out std_logic;
        d1_cf_tag : out std_logic_vector(3 downto 0);
        d1_cf_ready : out std_logic;
        d1_cf_val : out std_logic;

        d1_zf_rrf : out std_logic;
        d1_zf_tag : out std_logic_vector(3 downto 0);
        d1_zf_ready : out std_logic;
        d1_zf_val : out std_logic;

        d0_dest_tag : out std_logic_vector(3 downto 0);
        d1_dest_tag : out std_logic_vector(3 downto 0);
        d0_dest_arch : out std_logic_vector(2 downto 0);
        d1_dest_arch : out std_logic_vector(2 downto 0);
        d0_dest_en : out std_logic;
        d1_dest_en : out std_logic;

        d0_carry_tag : out std_logic_vector(3 downto 0);
        d1_carry_tag : out std_logic_vector(3 downto 0);
        d0_carry_en : out std_logic;
        d1_carry_en : out std_logic;

        d0_zero_tag : out std_logic_vector(3 downto 0);
        d1_zero_tag : out std_logic_vector(3 downto 0);
        d0_zero_en : out std_logic;
        d1_zero_en : out std_logic;

        d0_rob_idx : out std_logic_vector(3 downto 0);
        d1_rob_idx : out std_logic_vector(3 downto 0);

        d0_is_add : out std_logic;
        d0_is_nand : out std_logic;
        d0_lli : out std_logic;
        d0_is_adi : out std_logic;
        d0_use_carry : out std_logic;
        d0_use_zero : out std_logic;
        d0_use_complement : out std_logic;
        d0_imm : out std_logic_vector(15 downto 0);
        d0_load : out std_logic;
        d0_store : out std_logic;
        d0_is_branch : out std_logic;
        d0_branch_type : out std_logic_vector(3 downto 0);
        d0_pc : out std_logic_vector(15 downto 0);

        d1_is_add : out std_logic;
        d1_is_nand : out std_logic;
        d1_lli : out std_logic;
        d1_is_adi : out std_logic;
        d1_use_carry : out std_logic;
        d1_use_zero : out std_logic;
        d1_use_complement : out std_logic;
        d1_imm : out std_logic_vector(15 downto 0);
        d1_load : out std_logic;
        d1_store : out std_logic;
        d1_is_branch : out std_logic;
        d1_branch_type : out std_logic_vector(3 downto 0);
        d1_pc : out std_logic_vector(15 downto 0);

        stall : out std_logic
    );
end dispatch_stage;

architecture rtl of dispatch_stage is

    function to_slv(val : integer; width : natural) return std_logic_vector is
    begin
        return std_logic_vector(to_unsigned(val, width));
    end function;

    signal d0_fire_temp : std_logic;
    signal d0_alu_fire_temp : std_logic;
    signal d0_lsu_fire_temp : std_logic;
    signal d0_src1_rrf_temp : std_logic;
    signal d0_src2_rrf_temp : std_logic;
    signal d0_src1_ready_temp : std_logic;
    signal d0_src2_ready_temp : std_logic;
    signal d0_cf_rrf_temp : std_logic;
    signal d0_cf_ready_temp : std_logic;
    signal d0_cf_val_temp : std_logic;
    signal d0_zf_rrf_temp : std_logic;
    signal d0_zf_ready_temp : std_logic;
    signal d0_zf_val_temp : std_logic;
    signal d0_is_add_temp : std_logic;
    signal d0_is_nand_temp : std_logic;
    signal d0_lli_temp : std_logic;
    signal d0_is_adi_temp : std_logic;
    signal d0_use_carry_temp : std_logic;
    signal d0_use_zero_temp : std_logic;
    signal d0_use_complement_temp : std_logic;
    signal d0_load_temp : std_logic;
    signal d0_store_temp : std_logic;
    signal d0_is_branch_temp : std_logic;
    signal d0_src1_tag_temp : std_logic_vector(3 downto 0);
    signal d0_src2_tag_temp : std_logic_vector(3 downto 0);
    signal d0_cf_tag_temp : std_logic_vector(3 downto 0);
    signal d0_zf_tag_temp : std_logic_vector(3 downto 0);
    signal d0_rob_idx_temp : std_logic_vector(3 downto 0);
    signal d0_branch_type_temp : std_logic_vector(3 downto 0);
    signal d0_src1_value_temp : std_logic_vector(15 downto 0);
    signal d0_src2_value_temp : std_logic_vector(15 downto 0);
    signal d0_imm_temp : std_logic_vector(15 downto 0);
    signal d0_pc_temp : std_logic_vector(15 downto 0);
    signal d1_fire_temp : std_logic;
    signal d1_alu_fire_temp : std_logic;
    signal d1_lsu_fire_temp : std_logic;
    signal d1_src1_rrf_temp : std_logic;
    signal d1_src2_rrf_temp : std_logic;
    signal d1_src1_ready_temp : std_logic;
    signal d1_src2_ready_temp : std_logic;
    signal d1_cf_rrf_temp : std_logic;
    signal d1_cf_ready_temp : std_logic;
    signal d1_cf_val_temp : std_logic;
    signal d1_zf_rrf_temp : std_logic;
    signal d1_zf_ready_temp : std_logic;
    signal d1_zf_val_temp : std_logic;
    signal d1_is_add_temp : std_logic;
    signal d1_is_nand_temp : std_logic;
    signal d1_lli_temp : std_logic;
    signal d1_is_adi_temp : std_logic;
    signal d1_use_carry_temp : std_logic;
    signal d1_use_zero_temp : std_logic;
    signal d1_use_complement_temp : std_logic;
    signal d1_load_temp : std_logic;
    signal d1_store_temp : std_logic;
    signal d1_is_branch_temp : std_logic;
    signal d1_src1_tag_temp : std_logic_vector(3 downto 0);
    signal d1_src2_tag_temp : std_logic_vector(3 downto 0);
    signal d1_cf_tag_temp : std_logic_vector(3 downto 0);
    signal d1_zf_tag_temp : std_logic_vector(3 downto 0);
    signal d1_rob_idx_temp : std_logic_vector(3 downto 0);
    signal d1_branch_type_temp : std_logic_vector(3 downto 0);
    signal d1_src1_value_temp : std_logic_vector(15 downto 0);
    signal d1_src2_value_temp : std_logic_vector(15 downto 0);
    signal d1_imm_temp : std_logic_vector(15 downto 0);
    signal d1_pc_temp : std_logic_vector(15 downto 0);

    signal rename0_arch_i : std_logic_vector(2 downto 0);
    signal rename1_arch_i : std_logic_vector(2 downto 0);
    signal rename0_fire_i : std_logic;
    signal rename1_fire_i : std_logic;
    signal rename0_cf_fire_i : std_logic;
    signal rename1_cf_fire_i : std_logic;
    signal rename0_zf_fire_i : std_logic;
    signal rename1_zf_fire_i : std_logic;
    signal rob_0_query_i : std_logic_vector(3 downto 0);
    signal rob_1_query_i : std_logic_vector(3 downto 0);
    signal stall_i : std_logic;

begin

    rename0_arch <= rename0_arch_i;
    rename1_arch <= rename1_arch_i;
    rename0_fire <= rename0_fire_i;
    rename1_fire <= rename1_fire_i;
    rename0_cf_fire <= rename0_cf_fire_i;
    rename1_cf_fire <= rename1_cf_fire_i;
    rename0_zf_fire <= rename0_zf_fire_i;
    rename1_zf_fire <= rename1_zf_fire_i;
    rob_0_query <= rob_0_query_i;
    rob_1_query <= rob_1_query_i;
    stall <= stall_i;

    process(redirect_valid, dec0_valid, dec0_dest_en, 
    dec0_is_add, dec0_is_nand, dec0_is_adi, dec0_use_carry, 
    dec0_use_zero, dec0_write_carry, dec0_write_zero, 
    dec0_use_complement, dec0_imm, dec0_src1, dec0_src2,
     dec0_dest, dec0_lli, dec0_load, dec0_store, dec0_is_branch, 
     dec0_branch_type, dec0_pc, dec1_valid, dec1_dest_en, 
     dec1_is_add, dec1_is_nand, dec1_is_adi, dec1_use_carry, 
     dec1_use_zero, dec1_write_carry, dec1_write_zero, 
     dec1_use_complement, dec1_imm, dec1_src1, dec1_src2, 
     dec1_dest, dec1_lli, dec1_load, dec1_store, dec1_is_branch, 
     dec1_branch_type, dec1_pc, s0_1_rrf, s0_1_tag, s0_1_ready, 
     s0_1_val, s0_2_rrf, s0_2_tag, s0_2_ready, s0_2_val, s1_1_rrf, 
     s1_1_tag, s1_1_ready, s1_1_val, s1_2_rrf, s1_2_tag, s1_2_ready, 
     s1_2_val, s0_cf_rrf, s0_cf_tag, s0_cf_ready, s0_cf_val, s0_zf_rrf, 
     s0_zf_tag, s0_zf_ready, s0_zf_val, s1_cf_rrf, s1_cf_tag, s1_cf_ready, 
     s1_cf_val, s1_zf_rrf, s1_zf_tag, s1_zf_ready, s1_zf_val, rename0_tag, 
     rename1_tag, rename0_cf_tag, rename1_cf_tag, rename0_zf_tag, 
     rename1_zf_tag, rob_0_idx, rob_1_idx, rob_count, rs_count, 
     rrf_count, lsu_count, zf_free_count, cf_free_count)
        variable v_d0_fire : std_logic;
        variable v_d1_fire : std_logic;
        variable v_d0_alu_fire : std_logic;
        variable v_d1_alu_fire : std_logic;
        variable v_d0_lsu_fire : std_logic;
        variable v_d1_lsu_fire : std_logic;
        variable v_d0_src1_rrf : std_logic;
        variable v_d0_src2_rrf : std_logic;
        variable v_d0_src1_ready : std_logic;
        variable v_d0_src2_ready : std_logic;
        variable v_d0_cf_rrf : std_logic;
        variable v_d0_cf_ready : std_logic;
        variable v_d0_cf_val : std_logic;
        variable v_d0_zf_rrf : std_logic;
        variable v_d0_zf_ready : std_logic;
        variable v_d0_zf_val : std_logic;
        variable v_d0_is_add : std_logic;
        variable v_d0_is_nand : std_logic;
        variable v_d0_lli : std_logic;
        variable v_d0_is_adi : std_logic;
        variable v_d0_use_carry : std_logic;
        variable v_d0_use_zero : std_logic;
        variable v_d0_use_complement : std_logic;
        variable v_d0_load : std_logic;
        variable v_d0_store : std_logic;
        variable v_d0_is_branch : std_logic;
        variable v_d0_src1_tag : std_logic_vector(3 downto 0);
        variable v_d0_src2_tag : std_logic_vector(3 downto 0);
        variable v_d0_cf_tag : std_logic_vector(3 downto 0);
        variable v_d0_zf_tag : std_logic_vector(3 downto 0);
        variable v_d0_rob_idx : std_logic_vector(3 downto 0);
        variable v_d0_branch_type : std_logic_vector(3 downto 0);
        variable v_d0_src1_value : std_logic_vector(15 downto 0);
        variable v_d0_src2_value : std_logic_vector(15 downto 0);
        variable v_d0_imm : std_logic_vector(15 downto 0);
        variable v_d0_pc : std_logic_vector(15 downto 0);
        variable v_d1_src1_rrf : std_logic;
        variable v_d1_src2_rrf : std_logic;
        variable v_d1_src1_ready : std_logic;
        variable v_d1_src2_ready : std_logic;
        variable v_d1_cf_rrf : std_logic;
        variable v_d1_cf_ready : std_logic;
        variable v_d1_cf_val : std_logic;
        variable v_d1_zf_rrf : std_logic;
        variable v_d1_zf_ready : std_logic;
        variable v_d1_zf_val : std_logic;
        variable v_d1_is_add : std_logic;
        variable v_d1_is_nand : std_logic;
        variable v_d1_lli : std_logic;
        variable v_d1_is_adi : std_logic;
        variable v_d1_use_carry : std_logic;
        variable v_d1_use_zero : std_logic;
        variable v_d1_use_complement : std_logic;
        variable v_d1_load : std_logic;
        variable v_d1_store : std_logic;
        variable v_d1_is_branch : std_logic;
        variable v_d1_src1_tag : std_logic_vector(3 downto 0);
        variable v_d1_src2_tag : std_logic_vector(3 downto 0);
        variable v_d1_cf_tag : std_logic_vector(3 downto 0);
        variable v_d1_zf_tag : std_logic_vector(3 downto 0);
        variable v_d1_rob_idx : std_logic_vector(3 downto 0);
        variable v_d1_branch_type : std_logic_vector(3 downto 0);
        variable v_d1_src1_value : std_logic_vector(15 downto 0);
        variable v_d1_src2_value : std_logic_vector(15 downto 0);
        variable v_d1_imm : std_logic_vector(15 downto 0);
        variable v_d1_pc : std_logic_vector(15 downto 0);
        variable v_rename0_arch : std_logic_vector(2 downto 0);
        variable v_rename1_arch : std_logic_vector(2 downto 0);
        variable v_rename0_fire : std_logic;
        variable v_rename1_fire : std_logic;
        variable v_rename0_cf_fire : std_logic;
        variable v_rename1_cf_fire : std_logic;
        variable v_rename0_zf_fire : std_logic;
        variable v_rename1_zf_fire : std_logic;
        variable v_rob_0_query : std_logic_vector(3 downto 0);
        variable v_rob_1_query : std_logic_vector(3 downto 0);
        variable v_stall : std_logic;
        variable v_rob_need : integer;
        variable v_rs_need : integer;
        variable v_lsu_need : integer;
        variable v_rrf_need : integer;
        variable v_cf_need : integer;
        variable v_zf_need : integer;
        variable v_can_dispatch : boolean;
        variable v_bypass1 : boolean;
        variable v_bypass2 : boolean;
        variable v_bypass_cf : boolean;
        variable v_bypass_zf : boolean;
    begin
        v_rename0_arch := to_slv(0, 3);
        v_rename1_arch := to_slv(0, 3);
        v_rename0_fire := '0';
        v_rename1_fire := '0';
        v_rename0_cf_fire := '0';
        v_rename1_cf_fire := '0';
        v_rename0_zf_fire := '0';
        v_rename1_zf_fire := '0';
        v_d0_fire := '0';
        v_d0_alu_fire := '0';
        v_d0_lsu_fire := '0';
        v_d0_src1_rrf := '0';
        v_d0_src2_rrf := '0';
        v_d0_src1_ready := '0';
        v_d0_src2_ready := '0';
        v_d0_src1_tag := to_slv(0, 4);
        v_d0_src2_tag := to_slv(0, 4);
        v_d0_src1_value := to_slv(0, 16);
        v_d0_src2_value := to_slv(0, 16);
        v_d0_cf_rrf := '0';
        v_d0_cf_tag := to_slv(0, 4);
        v_d0_cf_ready := '0';
        v_d0_cf_val := '0';
        v_d0_zf_rrf := '0';
        v_d0_zf_tag := to_slv(0, 4);
        v_d0_zf_ready := '0';
        v_d0_zf_val := '0';
        v_d0_rob_idx := to_slv(0, 4);
        v_d0_is_add := '0';
        v_d0_is_nand := '0';
        v_d0_lli := '0';
        v_d0_is_adi := '0';
        v_d0_use_carry := '0';
        v_d0_use_zero := '0';
        v_d0_use_complement := '0';
        v_d0_imm := to_slv(0, 16);
        v_d0_load := '0';
        v_d0_store := '0';
        v_d0_is_branch := '0';
        v_d0_branch_type := to_slv(0, 4);
        v_d0_pc := to_slv(0, 16);
        v_d1_fire := '0';
        v_d1_alu_fire := '0';
        v_d1_lsu_fire := '0';
        v_d1_src1_rrf := '0';
        v_d1_src2_rrf := '0';
        v_d1_src1_ready := '0';
        v_d1_src2_ready := '0';
        v_d1_src1_tag := to_slv(0, 4);
        v_d1_src2_tag := to_slv(0, 4);
        v_d1_src1_value := to_slv(0, 16);
        v_d1_src2_value := to_slv(0, 16);
        v_d1_cf_rrf := '0';
        v_d1_cf_tag := to_slv(0, 4);
        v_d1_cf_ready := '0';
        v_d1_cf_val := '0';
        v_d1_zf_rrf := '0';
        v_d1_zf_tag := to_slv(0, 4);
        v_d1_zf_ready := '0';
        v_d1_zf_val := '0';
        v_d1_rob_idx := to_slv(0, 4);
        v_d1_is_add := '0';
        v_d1_is_nand := '0';
        v_d1_lli := '0';
        v_d1_is_adi := '0';
        v_d1_use_carry := '0';
        v_d1_use_zero := '0';
        v_d1_use_complement := '0';
        v_d1_imm := to_slv(0, 16);
        v_d1_load := '0';
        v_d1_store := '0';
        v_d1_is_branch := '0';
        v_d1_branch_type := to_slv(0, 4);
        v_d1_pc := to_slv(0, 16);
        v_rob_0_query := to_slv(0, 4);
        v_rob_1_query := to_slv(0, 4);
        v_rob_need := 0;
        v_rs_need := 0;
        v_lsu_need := 0;
        v_rrf_need := 0;
        v_cf_need := 0;
        v_zf_need := 0;
        v_can_dispatch := false;
        v_bypass1 := false;
        v_bypass2 := false;
        v_bypass_cf := false;
        v_bypass_zf := false;
        v_stall := '0';
        if dec0_valid = '1' then
            v_rob_need := v_rob_need + 1;
            if (dec0_load = '0') and (dec0_store = '0') then
                v_rs_need := v_rs_need + 1;
            else
                v_lsu_need := v_lsu_need + 1;
            end if;
            if dec0_dest_en = '1' then
                v_rrf_need := v_rrf_need + 1;
            end if;
            if dec0_write_carry = '1' then
                v_cf_need := v_cf_need + 1;
            end if;
            if dec0_write_zero = '1' then
                v_zf_need := v_zf_need + 1;
            end if;
        end if;
        if dec1_valid = '1' then
            v_rob_need := v_rob_need + 1;
            if (dec1_load = '0') and (dec1_store = '0') then
                v_rs_need := v_rs_need + 1;
            else
                v_lsu_need := v_lsu_need + 1;
            end if;
            if dec1_dest_en = '1' then
                v_rrf_need := v_rrf_need + 1;
            end if;
            if dec1_write_carry = '1' then
                v_cf_need := v_cf_need + 1;
            end if;
            if dec1_write_zero = '1' then
                v_zf_need := v_zf_need + 1;
            end if;
        end if;
        if (redirect_valid = '0') and
           (unsigned(rob_count) >= to_unsigned(v_rob_need, rob_count'length)) and
           (unsigned(rs_count) >= to_unsigned(v_rs_need, rs_count'length)) and
           (unsigned(lsu_count) >= to_unsigned(v_lsu_need, lsu_count'length)) and
           (unsigned(rrf_count) >= to_unsigned(v_rrf_need, rrf_count'length)) and
           (unsigned(cf_free_count) >= to_unsigned(v_cf_need, cf_free_count'length)) and
           (unsigned(zf_free_count) >= to_unsigned(v_zf_need, zf_free_count'length)) then
            v_can_dispatch := true;
        end if;
        if (redirect_valid = '0') and ((dec0_valid = '1') or (dec1_valid = '1')) and (not v_can_dispatch) then
            v_stall := '1';
        end if;
        if v_can_dispatch then
            if dec0_valid = '1' then
                if (dec0_load = '1') or (dec0_store = '1') then
                    v_d0_alu_fire := '0';
                    v_d0_lsu_fire := '1';
                else
                    v_d0_alu_fire := '1';
                    v_d0_lsu_fire := '0';
                end if;
                v_d0_fire := '1';
                v_rename0_fire := dec0_dest_en;
                v_rename0_arch := dec0_dest;
                v_rename0_cf_fire := dec0_write_carry;
                v_rename0_zf_fire := dec0_write_zero;
                v_rob_0_query := to_slv(1, 4);
                v_d0_rob_idx := rob_0_idx;
                v_d0_is_add := dec0_is_add;
                v_d0_is_nand := dec0_is_nand;
                v_d0_lli := dec0_lli;
                v_d0_is_adi := dec0_is_adi;
                v_d0_use_carry := dec0_use_carry;
                v_d0_use_zero := dec0_use_zero;
                v_d0_use_complement := dec0_use_complement;
                v_d0_imm := dec0_imm;
                v_d0_load := dec0_load;
                v_d0_store := dec0_store;
                v_d0_is_branch := dec0_is_branch;
                v_d0_branch_type := dec0_branch_type;
                v_d0_pc := dec0_pc;
                if ((dec0_is_add = '1') or (dec0_is_nand = '1')) and (dec0_is_adi = '0') and (dec0_use_carry = '1') then
                    v_d0_cf_rrf := s0_cf_rrf;
                    v_d0_cf_tag := s0_cf_tag;
                    v_d0_cf_ready := s0_cf_ready;
                    v_d0_cf_val := s0_cf_val;
                else
                    v_d0_cf_rrf := '0';
                    v_d0_cf_tag := to_slv(0, 4);
                    v_d0_cf_ready := '1';
                    v_d0_cf_val := '0';
                end if;
                if ((dec0_is_add = '1') or (dec0_is_nand = '1')) and (dec0_is_adi = '0') and (dec0_use_zero = '1') then
                    v_d0_zf_rrf := s0_zf_rrf;
                    v_d0_zf_tag := s0_zf_tag;
                    v_d0_zf_ready := s0_zf_ready;
                    v_d0_zf_val := s0_zf_val;
                else
                    v_d0_zf_rrf := '0';
                    v_d0_zf_tag := to_slv(0, 4);
                    v_d0_zf_ready := '1';
                    v_d0_zf_val := '0';
                end if;
                if (dec0_lli = '1') or ((dec0_is_branch = '1') and (dec0_branch_type = to_slv(12, 4))) then
                    v_d0_src1_rrf := '0';
                    v_d0_src1_ready := '1';
                    v_d0_src1_tag := to_slv(0, 4);
                    v_d0_src1_value := to_slv(0, 16);
                    v_d0_src2_rrf := '0';
                    v_d0_src2_ready := '1';
                    v_d0_src2_tag := to_slv(0, 4);
                    v_d0_src2_value := to_slv(0, 16);
                else
                    if (dec0_src1 = "000") then
                        v_d0_src1_rrf := '0';
                        v_d0_src1_ready := '1';
                        v_d0_src1_tag := to_slv(0, 4);
                        v_d0_src1_value := dec0_pc;
                    else
                        v_d0_src1_rrf := s0_1_rrf;
                        v_d0_src1_ready := s0_1_ready;
                        v_d0_src1_tag := s0_1_tag;
                        v_d0_src1_value := s0_1_val;
                    end if;
                    if (dec0_load = '1') or (dec0_is_adi = '1') or ((dec0_is_branch = '1') and (dec0_branch_type = to_slv(13, 4))) or ((dec0_is_branch = '1') and (dec0_branch_type = to_slv(15, 4))) then
                        v_d0_src2_rrf := '0';
                        v_d0_src2_ready := '1';
                        v_d0_src2_tag := to_slv(0, 4);
                        v_d0_src2_value := to_slv(0, 16);
                    else
                        if (dec0_src2 = "000") then
                            v_d0_src2_rrf := '0';
                            v_d0_src2_ready := '1';
                            v_d0_src2_tag := to_slv(0, 4);
                            v_d0_src2_value := dec0_pc;
                        else
                            v_d0_src2_rrf := s0_2_rrf;
                            v_d0_src2_ready := s0_2_ready;
                            v_d0_src2_tag := s0_2_tag;
                            v_d0_src2_value := s0_2_val;
                        end if;
                    end if;
                end if;
            end if;
            if dec1_valid = '1' then
                if (dec1_load = '1') or (dec1_store = '1') then
                    v_d1_alu_fire := '0';
                    v_d1_lsu_fire := '1';
                else
                    v_d1_alu_fire := '1';
                    v_d1_lsu_fire := '0';
                end if;
                v_d1_fire := '1';
                v_rename1_fire := dec1_dest_en;
                v_rename1_arch := dec1_dest;
                v_rename1_cf_fire := dec1_write_carry;
                v_rename1_zf_fire := dec1_write_zero;
                v_rob_1_query := to_slv(1, 4);
                v_d1_rob_idx := rob_1_idx;
                v_d1_is_add := dec1_is_add;
                v_d1_is_nand := dec1_is_nand;
                v_d1_lli := dec1_lli;
                v_d1_is_adi := dec1_is_adi;
                v_d1_use_carry := dec1_use_carry;
                v_d1_use_zero := dec1_use_zero;
                v_d1_use_complement := dec1_use_complement;
                v_d1_imm := dec1_imm;
                v_d1_load := dec1_load;
                v_d1_store := dec1_store;
                v_d1_is_branch := dec1_is_branch;
                v_d1_branch_type := dec1_branch_type;
                v_d1_pc := dec1_pc;
                if ((dec1_is_add = '1') or (dec1_is_nand = '1')) and (dec1_is_adi = '0') and (dec1_use_carry = '1') then
                    v_d1_cf_rrf := s1_cf_rrf;
                    v_d1_cf_tag := s1_cf_tag;
                    v_d1_cf_ready := s1_cf_ready;
                    v_d1_cf_val := s1_cf_val;
                else
                    v_d1_cf_rrf := '0';
                    v_d1_cf_tag := to_slv(0, 4);
                    v_d1_cf_ready := '1';
                    v_d1_cf_val := '0';
                end if;
                if ((dec1_is_add = '1') or (dec1_is_nand = '1')) and (dec1_is_adi = '0') and (dec1_use_zero = '1') then
                    v_d1_zf_rrf := s1_zf_rrf;
                    v_d1_zf_tag := s1_zf_tag;
                    v_d1_zf_ready := s1_zf_ready;
                    v_d1_zf_val := s1_zf_val;
                else
                    v_d1_zf_rrf := '0';
                    v_d1_zf_tag := to_slv(0, 4);
                    v_d1_zf_ready := '1';
                    v_d1_zf_val := '0';
                end if;
                if (dec1_lli = '1') or ((dec1_is_branch = '1') and (dec1_branch_type = to_slv(12, 4))) then
                    v_d1_src1_rrf := '0';
                    v_d1_src1_ready := '1';
                    v_d1_src1_tag := to_slv(0, 4);
                    v_d1_src1_value := to_slv(0, 16);
                    v_d1_src2_rrf := '0';
                    v_d1_src2_ready := '1';
                    v_d1_src2_tag := to_slv(0, 4);
                    v_d1_src2_value := to_slv(0, 16);
                else
                    if (dec1_src1 = "000") then
                        v_d1_src1_rrf := '0';
                        v_d1_src1_ready := '1';
                        v_d1_src1_tag := to_slv(0, 4);
                        v_d1_src1_value := dec1_pc;
                    else
                        v_d1_src1_rrf := s1_1_rrf;
                        v_d1_src1_ready := s1_1_ready;
                        v_d1_src1_tag := s1_1_tag;
                        v_d1_src1_value := s1_1_val;
                    end if;
                    if (dec1_load = '1') or (dec1_is_adi = '1') or ((dec1_is_branch = '1') and (dec1_branch_type = to_slv(13, 4))) or ((dec1_is_branch = '1') and (dec1_branch_type = to_slv(15, 4))) then
                        v_d1_src2_rrf := '0';
                        v_d1_src2_ready := '1';
                        v_d1_src2_tag := to_slv(0, 4);
                        v_d1_src2_value := to_slv(0, 16);
                    else
                        if (dec1_src2 = "000") then
                            v_d1_src2_rrf := '0';
                            v_d1_src2_ready := '1';
                            v_d1_src2_tag := to_slv(0, 4);
                            v_d1_src2_value := dec1_pc;
                        else
                            v_d1_src2_rrf := s1_2_rrf;
                            v_d1_src2_ready := s1_2_ready;
                            v_d1_src2_tag := s1_2_tag;
                            v_d1_src2_value := s1_2_val;
                        end if;
                    end if;
                end if;
            end if;
            v_bypass1 := (v_d0_fire = '1') and (v_rename0_fire = '1') and (dec0_dest_en = '1') and (dec1_valid = '1') and not ((dec1_lli = '1') or ((dec1_is_branch = '1') and (dec1_branch_type = to_slv(12, 4)))) and (dec1_src1 = dec0_dest);
            v_bypass2 := (v_d0_fire = '1') and (v_rename0_fire = '1') and (dec0_dest_en = '1') and (dec1_valid = '1') and not ((dec1_lli = '1') or ((dec1_is_branch = '1') and (dec1_branch_type = to_slv(12, 4)))) and not ((dec1_load = '1') or (dec1_is_adi = '1') or ((dec1_is_branch = '1') and (dec1_branch_type = to_slv(13, 4))) or ((dec1_is_branch = '1') and (dec1_branch_type = to_slv(15, 4)))) and (dec1_src2 = dec0_dest);
            if v_bypass1 then
                v_d1_src1_rrf := '1';
                v_d1_src1_ready := '0';
                v_d1_src1_tag := rename0_tag;
                v_d1_src1_value := to_slv(0, 16);
            end if;
            if v_bypass2 then
                v_d1_src2_rrf := '1';
                v_d1_src2_ready := '0';
                v_d1_src2_tag := rename0_tag;
                v_d1_src2_value := to_slv(0, 16);
            end if;
            v_bypass_cf := (v_d0_fire = '1') and (v_rename0_cf_fire = '1') and (dec0_write_carry = '1') and (dec1_valid = '1') and ((dec1_is_add = '1') or (dec1_is_nand = '1')) and (dec1_is_adi = '0') and (dec1_use_carry = '1');
            if v_bypass_cf then
                v_d1_cf_rrf := '1';
                v_d1_cf_ready := '0';
                v_d1_cf_tag := rename0_cf_tag;
                v_d1_cf_val := '0';
            end if;
            v_bypass_zf := (v_d0_fire = '1') and (v_rename0_zf_fire = '1') and (dec0_write_zero = '1') and (dec1_valid = '1') and ((dec1_is_add = '1') or (dec1_is_nand = '1')) and (dec1_is_adi = '0') and (dec1_use_zero = '1');
            if v_bypass_zf then
                v_d1_zf_rrf := '1';
                v_d1_zf_ready := '0';
                v_d1_zf_tag := rename0_zf_tag;
                v_d1_zf_val := '0';
            end if;
        end if;
        rename0_arch_i <= v_rename0_arch;
        rename1_arch_i <= v_rename1_arch;
        rename0_fire_i <= v_rename0_fire;
        rename1_fire_i <= v_rename1_fire;
        rename0_cf_fire_i <= v_rename0_cf_fire;
        rename1_cf_fire_i <= v_rename1_cf_fire;
        rename0_zf_fire_i <= v_rename0_zf_fire;
        rename1_zf_fire_i <= v_rename1_zf_fire;
        rob_0_query_i <= v_rob_0_query;
        rob_1_query_i <= v_rob_1_query;
        stall_i <= v_stall;
        d0_fire_temp <= v_d0_fire;
        d0_alu_fire_temp <= v_d0_alu_fire;
        d0_lsu_fire_temp <= v_d0_lsu_fire;
        d0_src1_rrf_temp <= v_d0_src1_rrf;
        d0_src2_rrf_temp <= v_d0_src2_rrf;
        d0_src1_ready_temp <= v_d0_src1_ready;
        d0_src2_ready_temp <= v_d0_src2_ready;
        d0_src1_tag_temp <= v_d0_src1_tag;
        d0_src2_tag_temp <= v_d0_src2_tag;
        d0_src1_value_temp <= v_d0_src1_value;
        d0_src2_value_temp <= v_d0_src2_value;
        d0_cf_rrf_temp <= v_d0_cf_rrf;
        d0_cf_tag_temp <= v_d0_cf_tag;
        d0_cf_ready_temp <= v_d0_cf_ready;
        d0_cf_val_temp <= v_d0_cf_val;
        d0_zf_rrf_temp <= v_d0_zf_rrf;
        d0_zf_tag_temp <= v_d0_zf_tag;
        d0_zf_ready_temp <= v_d0_zf_ready;
        d0_zf_val_temp <= v_d0_zf_val;
        d0_rob_idx_temp <= v_d0_rob_idx;
        d0_is_add_temp <= v_d0_is_add;
        d0_is_nand_temp <= v_d0_is_nand;
        d0_lli_temp <= v_d0_lli;
        d0_is_adi_temp <= v_d0_is_adi;
        d0_use_carry_temp <= v_d0_use_carry;
        d0_use_zero_temp <= v_d0_use_zero;
        d0_use_complement_temp <= v_d0_use_complement;
        d0_imm_temp <= v_d0_imm;
        d0_load_temp <= v_d0_load;
        d0_store_temp <= v_d0_store;
        d0_is_branch_temp <= v_d0_is_branch;
        d0_branch_type_temp <= v_d0_branch_type;
        d0_pc_temp <= v_d0_pc;
        d1_fire_temp <= v_d1_fire;
        d1_alu_fire_temp <= v_d1_alu_fire;
        d1_lsu_fire_temp <= v_d1_lsu_fire;
        d1_src1_rrf_temp <= v_d1_src1_rrf;
        d1_src2_rrf_temp <= v_d1_src2_rrf;
        d1_src1_ready_temp <= v_d1_src1_ready;
        d1_src2_ready_temp <= v_d1_src2_ready;
        d1_src1_tag_temp <= v_d1_src1_tag;
        d1_src2_tag_temp <= v_d1_src2_tag;
        d1_src1_value_temp <= v_d1_src1_value;
        d1_src2_value_temp <= v_d1_src2_value;
        d1_cf_rrf_temp <= v_d1_cf_rrf;
        d1_cf_tag_temp <= v_d1_cf_tag;
        d1_cf_ready_temp <= v_d1_cf_ready;
        d1_cf_val_temp <= v_d1_cf_val;
        d1_zf_rrf_temp <= v_d1_zf_rrf;
        d1_zf_tag_temp <= v_d1_zf_tag;
        d1_zf_ready_temp <= v_d1_zf_ready;
        d1_zf_val_temp <= v_d1_zf_val;
        d1_rob_idx_temp <= v_d1_rob_idx;
        d1_is_add_temp <= v_d1_is_add;
        d1_is_nand_temp <= v_d1_is_nand;
        d1_lli_temp <= v_d1_lli;
        d1_is_adi_temp <= v_d1_is_adi;
        d1_use_carry_temp <= v_d1_use_carry;
        d1_use_zero_temp <= v_d1_use_zero;
        d1_use_complement_temp <= v_d1_use_complement;
        d1_imm_temp <= v_d1_imm;
        d1_load_temp <= v_d1_load;
        d1_store_temp <= v_d1_store;
        d1_is_branch_temp <= v_d1_is_branch;
        d1_branch_type_temp <= v_d1_branch_type;
        d1_pc_temp <= v_d1_pc;
    end process;

    process(clk, rst)
    begin
        if rst = '1' then
            d0_fire <= '0';
            d1_fire <= '0';
            d0_alu_fire <= '0';
            d1_alu_fire <= '0';
            d0_lsu_fire <= '0';
            d1_lsu_fire <= '0';
            d0_src1_rrf <= '0';
            d0_src2_rrf <= '0';
            d1_src1_rrf <= '0';
            d1_src2_rrf <= '0';
            d0_src1_ready <= '0';
            d0_src2_ready <= '0';
            d1_src1_ready <= '0';
            d1_src2_ready <= '0';
            d0_src1_tag <= (others => '0');
            d0_src2_tag <= (others => '0');
            d1_src1_tag <= (others => '0');
            d1_src2_tag <= (others => '0');
            d0_src1_value <= (others => '0');
            d0_src2_value <= (others => '0');
            d1_src1_value <= (others => '0');
            d1_src2_value <= (others => '0');
            d0_cf_rrf <= '0';
            d0_cf_tag <= (others => '0');
            d0_cf_ready <= '0';
            d0_cf_val <= '0';
            d0_zf_rrf <= '0';
            d0_zf_tag <= (others => '0');
            d0_zf_ready <= '0';
            d0_zf_val <= '0';
            d1_cf_rrf <= '0';
            d1_cf_tag <= (others => '0');
            d1_cf_ready <= '0';
            d1_cf_val <= '0';
            d1_zf_rrf <= '0';
            d1_zf_tag <= (others => '0');
            d1_zf_ready <= '0';
            d1_zf_val <= '0';
            d0_dest_tag <= (others => '0');
            d1_dest_tag <= (others => '0');
            d0_dest_arch <= (others => '0');
            d1_dest_arch <= (others => '0');
            d0_dest_en <= '0';
            d1_dest_en <= '0';
            d0_carry_tag <= (others => '0');
            d1_carry_tag <= (others => '0');
            d0_carry_en <= '0';
            d1_carry_en <= '0';
            d0_zero_tag <= (others => '0');
            d1_zero_tag <= (others => '0');
            d0_zero_en <= '0';
            d1_zero_en <= '0';
            d0_rob_idx <= (others => '0');
            d1_rob_idx <= (others => '0');
            d0_is_add <= '0';
            d0_is_nand <= '0';
            d0_lli <= '0';
            d0_is_adi <= '0';
            d0_use_carry <= '0';
            d0_use_zero <= '0';
            d0_use_complement <= '0';
            d0_imm <= (others => '0');
            d0_load <= '0';
            d0_store <= '0';
            d0_is_branch <= '0';
            d0_branch_type <= (others => '0');
            d0_pc <= (others => '0');
            d1_is_add <= '0';
            d1_is_nand <= '0';
            d1_lli <= '0';
            d1_is_adi <= '0';
            d1_use_carry <= '0';
            d1_use_zero <= '0';
            d1_use_complement <= '0';
            d1_imm <= (others => '0');
            d1_load <= '0';
            d1_store <= '0';
            d1_is_branch <= '0';
            d1_branch_type <= (others => '0');
            d1_pc <= (others => '0');
        elsif rising_edge(clk) then
            if (redirect_valid = '1') or (stall_i = '1') then
                d0_fire <= '0';
                d1_fire <= '0';
                d0_alu_fire <= '0';
                d1_alu_fire <= '0';
                d0_lsu_fire <= '0';
                d1_lsu_fire <= '0';
                d0_src1_rrf <= '0';
                d0_src2_rrf <= '0';
                d1_src1_rrf <= '0';
                d1_src2_rrf <= '0';
                d0_src1_ready <= '0';
                d0_src2_ready <= '0';
                d1_src1_ready <= '0';
                d1_src2_ready <= '0';
                d0_src1_tag <= (others => '0');
                d0_src2_tag <= (others => '0');
                d1_src1_tag <= (others => '0');
                d1_src2_tag <= (others => '0');
                d0_src1_value <= (others => '0');
                d0_src2_value <= (others => '0');
                d1_src1_value <= (others => '0');
                d1_src2_value <= (others => '0');
                d0_cf_rrf <= '0';
                d0_cf_tag <= (others => '0');
                d0_cf_ready <= '0';
                d0_cf_val <= '0';
                d0_zf_rrf <= '0';
                d0_zf_tag <= (others => '0');
                d0_zf_ready <= '0';
                d0_zf_val <= '0';
                d1_cf_rrf <= '0';
                d1_cf_tag <= (others => '0');
                d1_cf_ready <= '0';
                d1_cf_val <= '0';
                d1_zf_rrf <= '0';
                d1_zf_tag <= (others => '0');
                d1_zf_ready <= '0';
                d1_zf_val <= '0';
                d0_dest_tag <= (others => '0');
                d1_dest_tag <= (others => '0');
                d0_dest_arch <= (others => '0');
                d1_dest_arch <= (others => '0');
                d0_dest_en <= '0';
                d1_dest_en <= '0';
                d0_carry_tag <= (others => '0');
                d1_carry_tag <= (others => '0');
                d0_carry_en <= '0';
                d1_carry_en <= '0';
                d0_zero_tag <= (others => '0');
                d1_zero_tag <= (others => '0');
                d0_zero_en <= '0';
                d1_zero_en <= '0';
                d0_rob_idx <= (others => '0');
                d1_rob_idx <= (others => '0');
                d0_is_add <= '0';
                d0_is_nand <= '0';
                d0_lli <= '0';
                d0_is_adi <= '0';
                d0_use_carry <= '0';
                d0_use_zero <= '0';
                d0_use_complement <= '0';
                d0_imm <= (others => '0');
                d0_load <= '0';
                d0_store <= '0';
                d0_is_branch <= '0';
                d0_branch_type <= (others => '0');
                d0_pc <= (others => '0');
                d1_is_add <= '0';
                d1_is_nand <= '0';
                d1_lli <= '0';
                d1_is_adi <= '0';
                d1_use_carry <= '0';
                d1_use_zero <= '0';
                d1_use_complement <= '0';
                d1_imm <= (others => '0');
                d1_load <= '0';
                d1_store <= '0';
                d1_is_branch <= '0';
                d1_branch_type <= (others => '0');
                d1_pc <= (others => '0');
            else
                d0_fire <= d0_fire_temp;
                d1_fire <= d1_fire_temp;
                d0_alu_fire <= d0_alu_fire_temp;
                d1_alu_fire <= d1_alu_fire_temp;
                d0_lsu_fire <= d0_lsu_fire_temp;
                d1_lsu_fire <= d1_lsu_fire_temp;
                d0_src1_rrf <= d0_src1_rrf_temp;
                d0_src2_rrf <= d0_src2_rrf_temp;
                d1_src1_rrf <= d1_src1_rrf_temp;
                d1_src2_rrf <= d1_src2_rrf_temp;
                d0_src1_ready <= d0_src1_ready_temp;
                d0_src2_ready <= d0_src2_ready_temp;
                d1_src1_ready <= d1_src1_ready_temp;
                d1_src2_ready <= d1_src2_ready_temp;
                d0_src1_tag <= d0_src1_tag_temp;
                d0_src2_tag <= d0_src2_tag_temp;
                d1_src1_tag <= d1_src1_tag_temp;
                d1_src2_tag <= d1_src2_tag_temp;
                d0_src1_value <= d0_src1_value_temp;
                d0_src2_value <= d0_src2_value_temp;
                d1_src1_value <= d1_src1_value_temp;
                d1_src2_value <= d1_src2_value_temp;
                d0_cf_rrf <= d0_cf_rrf_temp;
                d0_cf_tag <= d0_cf_tag_temp;
                d0_cf_ready <= d0_cf_ready_temp;
                d0_cf_val <= d0_cf_val_temp;
                d0_zf_rrf <= d0_zf_rrf_temp;
                d0_zf_tag <= d0_zf_tag_temp;
                d0_zf_ready <= d0_zf_ready_temp;
                d0_zf_val <= d0_zf_val_temp;
                d1_cf_rrf <= d1_cf_rrf_temp;
                d1_cf_tag <= d1_cf_tag_temp;
                d1_cf_ready <= d1_cf_ready_temp;
                d1_cf_val <= d1_cf_val_temp;
                d1_zf_rrf <= d1_zf_rrf_temp;
                d1_zf_tag <= d1_zf_tag_temp;
                d1_zf_ready <= d1_zf_ready_temp;
                d1_zf_val <= d1_zf_val_temp;
                d0_dest_tag <= rename0_tag;
                d1_dest_tag <= rename1_tag;
                d0_dest_en <= rename0_fire_i;
                d1_dest_en <= rename1_fire_i;
                d0_dest_arch <= rename0_arch_i;
                d1_dest_arch <= rename1_arch_i;
                d0_carry_tag <= rename0_cf_tag;
                d1_carry_tag <= rename1_cf_tag;
                d0_carry_en <= rename0_cf_fire_i;
                d1_carry_en <= rename1_cf_fire_i;
                d0_zero_tag <= rename0_zf_tag;
                d1_zero_tag <= rename1_zf_tag;
                d0_zero_en <= rename0_zf_fire_i;
                d1_zero_en <= rename1_zf_fire_i;
                d0_rob_idx <= d0_rob_idx_temp;
                d1_rob_idx <= d1_rob_idx_temp;
                d0_is_add <= d0_is_add_temp;
                d0_is_nand <= d0_is_nand_temp;
                d0_lli <= d0_lli_temp;
                d0_is_adi <= d0_is_adi_temp;
                d0_use_carry <= d0_use_carry_temp;
                d0_use_zero <= d0_use_zero_temp;
                d0_use_complement <= d0_use_complement_temp;
                d0_imm <= d0_imm_temp;
                d0_load <= d0_load_temp;
                d0_store <= d0_store_temp;
                d0_is_branch <= d0_is_branch_temp;
                d0_branch_type <= d0_branch_type_temp;
                d0_pc <= d0_pc_temp;
                d1_is_add <= d1_is_add_temp;
                d1_is_nand <= d1_is_nand_temp;
                d1_lli <= d1_lli_temp;
                d1_is_adi <= d1_is_adi_temp;
                d1_use_carry <= d1_use_carry_temp;
                d1_use_zero <= d1_use_zero_temp;
                d1_use_complement <= d1_use_complement_temp;
                d1_imm <= d1_imm_temp;
                d1_load <= d1_load_temp;
                d1_store <= d1_store_temp;
                d1_is_branch <= d1_is_branch_temp;
                d1_branch_type <= d1_branch_type_temp;
                d1_pc <= d1_pc_temp;
            end if;
        end if;
    end process;

end architecture rtl;