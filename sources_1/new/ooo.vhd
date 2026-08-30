library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ooo is
    port (
        clk : in std_logic;
        rst : in std_logic
    );
end entity ooo;

architecture rtl of ooo is
    subtype word16_t is std_logic_vector(15 downto 0);
    subtype word5_t  is std_logic_vector(4 downto 0);
    subtype word4_t  is std_logic_vector(3 downto 0);
    subtype word3_t  is std_logic_vector(2 downto 0);
    subtype word12_t is std_logic_vector(11 downto 0);
    subtype word48_t is std_logic_vector(47 downto 0);

    signal redirect_valid  : std_logic;
    signal redirect_target  : word16_t;

    signal fetch_instr0     : word16_t;
    signal fetch_instr1     : word16_t;
    signal fetch_valid0     : std_logic;
    signal fetch_valid1     : std_logic;
    signal fetch_pc_out     : word16_t;
    signal stall            : std_logic;
    signal stall_fetch      : std_logic;

    signal dec0_valid          : std_logic;
    signal dec0_dest_en        : std_logic;
    signal dec0_is_add         : std_logic;
    signal dec0_is_nand        : std_logic;
    signal dec0_is_adi         : std_logic;
    signal dec0_use_carry      : std_logic;
    signal dec0_use_zero       : std_logic;
    signal dec0_write_carry    : std_logic;
    signal dec0_write_zero     : std_logic;
    signal dec0_use_complement : std_logic;
    signal dec0_imm            : word16_t;
    signal dec0_src1           : word3_t;
    signal dec0_src2           : word3_t;
    signal dec0_dest           : word3_t;
    signal dec0_lli             : std_logic;
    signal dec0_load            : std_logic;
    signal dec0_store           : std_logic;
    signal dec0_is_branch       : std_logic;
    signal dec0_branch_type     : word4_t;
    signal dec0_pc              : word16_t;

    signal dec1_valid          : std_logic;
    signal dec1_dest_en        : std_logic;
    signal dec1_is_add         : std_logic;
    signal dec1_is_nand        : std_logic;
    signal dec1_is_adi         : std_logic;
    signal dec1_use_carry      : std_logic;
    signal dec1_use_zero       : std_logic;
    signal dec1_write_carry    : std_logic;
    signal dec1_write_zero     : std_logic;
    signal dec1_use_complement : std_logic;
    signal dec1_imm            : word16_t;
    signal dec1_src1           : word3_t;
    signal dec1_src2           : word3_t;
    signal dec1_dest           : word3_t;
    signal dec1_lli             : std_logic;
    signal dec1_load            : std_logic;
    signal dec1_store           : std_logic;
    signal dec1_is_branch       : std_logic;
    signal dec1_branch_type     : word4_t;
    signal dec1_pc              : word16_t;

    signal decoder_busy : std_logic;

    signal rrf_count     : word5_t;
    signal cf_free_count : word5_t;
    signal zf_free_count : word5_t;

    signal rename0_fire      : std_logic;
    signal rename1_fire      : std_logic;
    signal rename0_cf_fire   : std_logic;
    signal rename1_cf_fire   : std_logic;
    signal rename0_zf_fire   : std_logic;
    signal rename1_zf_fire   : std_logic;

    signal rename0_tag      : word4_t;
    signal rename1_tag      : word4_t;
    signal rename0_arch     : word3_t;
    signal rename1_arch     : word3_t;

    signal rename0_cf_tag   : word4_t;
    signal rename1_cf_tag   : word4_t;
    signal rename0_zf_tag   : word4_t;
    signal rename1_zf_tag   : word4_t;

    signal s0_1_rrf   : std_logic;
    signal s0_1_tag   : word4_t;
    signal s0_1_ready : std_logic;
    signal s0_1_val   : word16_t;

    signal s0_2_rrf   : std_logic;
    signal s0_2_tag   : word4_t;
    signal s0_2_ready : std_logic;
    signal s0_2_val   : word16_t;

    signal s1_1_rrf   : std_logic;
    signal s1_1_tag   : word4_t;
    signal s1_1_ready : std_logic;
    signal s1_1_val   : word16_t;

    signal s1_2_rrf   : std_logic;
    signal s1_2_tag   : word4_t;
    signal s1_2_ready : std_logic;
    signal s1_2_val   : word16_t;

    signal s0_cf_rrf   : std_logic;
    signal s0_cf_tag   : word4_t;
    signal s0_cf_ready : std_logic;
    signal s0_cf_val   : std_logic;

    signal s0_zf_rrf   : std_logic;
    signal s0_zf_tag   : word4_t;
    signal s0_zf_ready : std_logic;
    signal s0_zf_val   : std_logic;

    signal s1_cf_rrf   : std_logic;
    signal s1_cf_tag   : word4_t;
    signal s1_cf_ready : std_logic;
    signal s1_cf_val   : std_logic;

    signal s1_zf_rrf   : std_logic;
    signal s1_zf_tag   : word4_t;
    signal s1_zf_ready : std_logic;
    signal s1_zf_val   : std_logic;

    signal d0_fire      : std_logic;
    signal d1_fire      : std_logic;
    signal d0_alu_fire  : std_logic;
    signal d1_alu_fire  : std_logic;
    signal d0_lsu_fire  : std_logic;
    signal d1_lsu_fire  : std_logic;

    signal d0_src1_rrf  : std_logic;
    signal d0_src2_rrf  : std_logic;
    signal d1_src1_rrf  : std_logic;
    signal d1_src2_rrf  : std_logic;

    signal d0_src1_ready : std_logic;
    signal d0_src2_ready : std_logic;
    signal d1_src1_ready : std_logic;
    signal d1_src2_ready : std_logic;

    signal d0_src1_tag : word4_t;
    signal d0_src2_tag : word4_t;
    signal d1_src1_tag : word4_t;
    signal d1_src2_tag : word4_t;

    signal d0_src1_value : word16_t;
    signal d0_src2_value : word16_t;
    signal d1_src1_value : word16_t;
    signal d1_src2_value : word16_t;

    signal d0_cf_rrf  : std_logic;
    signal d0_cf_ready : std_logic;
    signal d0_cf_val  : std_logic;
    signal d0_cf_tag  : word4_t;
    signal d0_zf_rrf  : std_logic;
    signal d0_zf_ready : std_logic;
    signal d0_zf_val  : std_logic;
    signal d0_zf_tag  : word4_t;

    signal d1_cf_rrf  : std_logic;
    signal d1_cf_ready : std_logic;
    signal d1_cf_val  : std_logic;
    signal d1_cf_tag  : word4_t;
    signal d1_zf_rrf  : std_logic;
    signal d1_zf_ready : std_logic;
    signal d1_zf_val  : std_logic;
    signal d1_zf_tag  : word4_t;

    signal d0_dest_tag  : word4_t;
    signal d1_dest_tag  : word4_t;
    signal d0_dest_arch : word3_t;
    signal d1_dest_arch : word3_t;
    signal d0_dest_en   : std_logic;
    signal d1_dest_en   : std_logic;

    signal d0_carry_tag : word4_t;
    signal d1_carry_tag : word4_t;
    signal d0_carry_en  : std_logic;
    signal d1_carry_en  : std_logic;

    signal d0_zero_tag : word4_t;
    signal d1_zero_tag : word4_t;
    signal d0_zero_en  : std_logic;
    signal d1_zero_en  : std_logic;

    signal d0_rob_idx : word4_t;
    signal d1_rob_idx : word4_t;

    signal d0_is_add         : std_logic;
    signal d0_is_nand        : std_logic;
    signal d0_lli             : std_logic;
    signal d0_is_adi         : std_logic;
    signal d0_use_carry      : std_logic;
    signal d0_use_zero       : std_logic;
    signal d0_use_complement : std_logic;
    signal d0_imm            : word16_t;
    signal d0_load           : std_logic;
    signal d0_store          : std_logic;
    signal d0_is_branch      : std_logic;
    signal d0_branch_type    : word4_t;
    signal d0_pc             : word16_t;

    signal d1_is_add         : std_logic;
    signal d1_is_nand        : std_logic;
    signal d1_lli             : std_logic;
    signal d1_is_adi         : std_logic;
    signal d1_use_carry      : std_logic;
    signal d1_use_zero       : std_logic;
    signal d1_use_complement : std_logic;
    signal d1_imm            : word16_t;
    signal d1_load           : std_logic;
    signal d1_store          : std_logic;
    signal d1_is_branch      : std_logic;
    signal d1_branch_type    : word4_t;
    signal d1_pc             : word16_t;

    signal rob_count : word5_t;
    signal rs_count    : word5_t;
    signal lsu_count    : word5_t;

    signal issue_alu0_valid         : std_logic;
    signal issue_alu1_valid         : std_logic;
    signal issue_alu0_is_add        : std_logic;
    signal issue_alu0_is_nand       : std_logic;
    signal issue_alu0_lli           : std_logic;
    signal issue_alu0_is_adi        : std_logic;
    signal issue_alu0_use_carry     : std_logic;
    signal issue_alu0_use_zero      : std_logic;
    signal issue_alu0_use_complement : std_logic;
    signal issue_alu0_imm           : word16_t;
    signal issue_alu0_src1_value    : word16_t;
    signal issue_alu0_src2_value    : word16_t;
    signal issue_alu0_dest_tag      : word4_t;
    signal issue_alu0_rob_idx       : word4_t;
    signal issue_alu0_carry_tag     : word4_t;
    signal issue_alu0_carry_value   : std_logic;
    signal issue_alu0_zero_tag      : word4_t;
    signal issue_alu0_zero_value    : std_logic;
    signal issue_alu0_is_branch     : std_logic;
    signal issue_alu0_branch_type   : word4_t;
    signal issue_alu0_pc            : word16_t;

    signal issue_alu1_is_add        : std_logic;
    signal issue_alu1_is_nand       : std_logic;
    signal issue_alu1_lli           : std_logic;
    signal issue_alu1_is_adi        : std_logic;
    signal issue_alu1_use_carry     : std_logic;
    signal issue_alu1_use_zero      : std_logic;
    signal issue_alu1_use_complement : std_logic;
    signal issue_alu1_imm           : word16_t;
    signal issue_alu1_src1_value    : word16_t;
    signal issue_alu1_src2_value    : word16_t;
    signal issue_alu1_dest_tag      : word4_t;
    signal issue_alu1_rob_idx       : word4_t;
    signal issue_alu1_carry_tag     : word4_t;
    signal issue_alu1_carry_value   : std_logic;
    signal issue_alu1_zero_tag      : word4_t;
    signal issue_alu1_zero_value    : std_logic;
    signal issue_alu1_is_branch     : std_logic;
    signal issue_alu1_branch_type   : word4_t;
    signal issue_alu1_pc            : word16_t;

    signal alu0_wb_valid      : std_logic;
    signal alu0_wb_tag        : word4_t;
    signal alu0_wb_data       : word16_t;
    signal alu0_wb_cf_valid   : std_logic;
    signal alu0_wb_cf_tag     : word4_t;
    signal alu0_wb_cf_data    : std_logic;
    signal alu0_wb_zf_valid   : std_logic;
    signal alu0_wb_zf_tag     : word4_t;
    signal alu0_wb_zf_data    : std_logic;
    signal alu0_ex_valid      : std_logic;
    signal alu0_ex_idx        : word4_t;
    signal alu0_ex_is_branch  : std_logic;
    signal alu0_ex_branch_taken : std_logic;
    signal alu0_ex_branch_target : word16_t;

    signal alu1_wb_valid      : std_logic;
    signal alu1_wb_tag        : word4_t;
    signal alu1_wb_data       : word16_t;
    signal alu1_wb_cf_valid   : std_logic;
    signal alu1_wb_cf_tag     : word4_t;
    signal alu1_wb_cf_data    : std_logic;
    signal alu1_wb_zf_valid   : std_logic;
    signal alu1_wb_zf_tag     : word4_t;
    signal alu1_wb_zf_data    : std_logic;
    signal alu1_ex_valid      : std_logic;
    signal alu1_ex_idx        : word4_t;
    signal alu1_ex_is_branch  : std_logic;
    signal alu1_ex_branch_taken : std_logic;
    signal alu1_ex_branch_target : word16_t;

    signal lsu_wb_valid     : std_logic;
    signal lsu_wb_tag       : word4_t;
    signal lsu_wb_data      : word16_t;
    signal lsu_wb_zf_valid  : std_logic;
    signal lsu_wb_zf_tag    : word4_t;
    signal lsu_wb_zf_data   : std_logic;
    signal lsu_wb_cf_valid  : std_logic;
    signal lsu_wb_cf_tag    : word4_t;
    signal lsu_wb_cf_data   : std_logic;
    signal lsu_ex_valid     : std_logic;
    signal lsu_ex_idx       : word4_t;
    signal lsu_ex_is_branch     :std_logic;
    signal lsu_ex_branch_taken  :std_logic;
    signal lsu_ex_branch_target :std_logic_vector(15 downto 0);

    signal rob_head_valid_s    : std_logic;
    signal rob_head_idx_s      : word4_t;
    signal rob_head_is_store_s : std_logic;

    signal rob_0_idx   : word4_t;
    signal rob_1_idx   : word4_t;
    signal rob_0_query : word4_t;
    signal rob_1_query : word4_t;

    signal commit0_valid_s : std_logic;
    signal commit0_arch_s   : word3_t;
    signal commit0_tag_s    : word4_t;
    signal commit1_valid_s  : std_logic;
    signal commit1_arch_s   : word3_t;
    signal commit1_tag_s    : word4_t;

    signal commit0_cf_valid_s : std_logic;
    signal commit0_cf_tag_s   : word4_t;
    signal commit1_cf_valid_s : std_logic;
    signal commit1_cf_tag_s   : word4_t;

    signal commit0_zf_valid_s : std_logic;
    signal commit0_zf_tag_s   : word4_t;
    signal commit1_zf_valid_s : std_logic;
    signal commit1_zf_tag_s   : word4_t;
begin

    stall_fetch <= stall or decoder_busy;

    u_fetch_stage : entity work.fetch_stage
        port map (
            clk             => clk,
            rst             => rst,
            stall           => stall_fetch,
            redirect_valid  => redirect_valid,
            redirect_target => redirect_target,
            instr0          => fetch_instr0,
            instr1          => fetch_instr1,
            valid0          => fetch_valid0,
            valid1          => fetch_valid1,
            pc_out          => fetch_pc_out
        );

    u_decode_stage : entity work.decode_stage
        port map (
            clk                 => clk,
            rst                 => rst,
            stall               => stall,
            redirect_valid      => redirect_valid,
            instr0              => fetch_instr0,
            instr1              => fetch_instr1,
            valid0              => fetch_valid0,
            valid1              => fetch_valid1,
            pc_in               => fetch_pc_out,
            dec0_valid          => dec0_valid,
            dec0_dest_en        => dec0_dest_en,
            dec0_is_add         => dec0_is_add,
            dec0_is_nand        => dec0_is_nand,
            dec0_is_adi         => dec0_is_adi,
            dec0_use_carry      => dec0_use_carry,
            dec0_use_zero       => dec0_use_zero,
            dec0_write_carry    => dec0_write_carry,
            dec0_write_zero     => dec0_write_zero,
            dec0_use_complement => dec0_use_complement,
            dec0_imm            => dec0_imm,
            dec0_src1           => dec0_src1,
            dec0_src2           => dec0_src2,
            dec0_dest           => dec0_dest,
            dec0_lli            => dec0_lli,
            dec0_load           => dec0_load,
            dec0_store          => dec0_store,
            dec0_is_branch      => dec0_is_branch,
            dec0_branch_type    => dec0_branch_type,
            dec0_pc             => dec0_pc,
            dec1_valid          => dec1_valid,
            dec1_dest_en        => dec1_dest_en,
            dec1_is_add         => dec1_is_add,
            dec1_is_nand        => dec1_is_nand,
            dec1_is_adi         => dec1_is_adi,
            dec1_use_carry      => dec1_use_carry,
            dec1_use_zero       => dec1_use_zero,
            dec1_write_carry    => dec1_write_carry,
            dec1_write_zero     => dec1_write_zero,
            dec1_use_complement => dec1_use_complement,
            dec1_imm            => dec1_imm,
            dec1_src1           => dec1_src1,
            dec1_src2           => dec1_src2,
            dec1_dest           => dec1_dest,
            dec1_lli            => dec1_lli,
            dec1_load           => dec1_load,
            dec1_store          => dec1_store,
            dec1_is_branch      => dec1_is_branch,
            dec1_branch_type    => dec1_branch_type,
            dec1_pc             => dec1_pc,
            decoder_busy        => decoder_busy
        );

    u_regfile : entity work.regfile
        port map (
            clk             => clk,
            rst             => rst,
            redirect_valid   => redirect_valid,
            stall           => stall,
            free_count      => rrf_count,
            rename0_fire    => rename0_fire,
            rename1_fire    => rename1_fire,
            rename0_arch    => rename0_arch,
            rename1_arch    => rename1_arch,
            src0_1_arch     => dec0_src1,
            src0_2_arch     => dec0_src2,
            src1_1_arch     => dec1_src1,
            src1_2_arch     => dec1_src2,
            wb0_valid => alu1_wb_valid,
            wb0_tag   => alu1_wb_tag,
            wb0_data  => alu1_wb_data,
            wb1_valid => alu0_wb_valid,
            wb1_tag   => alu0_wb_tag,
            wb1_data  => alu0_wb_data,
            wb2_valid => lsu_wb_valid,
            wb2_tag   => lsu_wb_tag,
            wb2_data  => lsu_wb_data,
            commit0_valid   => commit0_valid_s,
            commit0_arch    => commit0_arch_s,
            commit0_tag     => commit0_tag_s,
            commit1_valid   => commit1_valid_s,
            commit1_arch    => commit1_arch_s,
            commit1_tag     => commit1_tag_s,
            rename0_tag     => rename0_tag,
            rename1_tag     => rename1_tag,
            s0_1_rrf        => s0_1_rrf,
            s0_1_tag        => s0_1_tag,
            s0_1_ready      => s0_1_ready,
            s0_1_val        => s0_1_val,
            s0_2_rrf        => s0_2_rrf,
            s0_2_tag        => s0_2_tag,
            s0_2_ready      => s0_2_ready,
            s0_2_val        => s0_2_val,
            s1_1_rrf        => s1_1_rrf,
            s1_1_tag        => s1_1_tag,
            s1_1_ready      => s1_1_ready,
            s1_1_val        => s1_1_val,
            s1_2_rrf        => s1_2_rrf,
            s1_2_tag        => s1_2_tag,
            s1_2_ready      => s1_2_ready,
            s1_2_val        => s1_2_val,
            cf_free_count   => cf_free_count,
            rename0_cf_fire => rename0_cf_fire,
            rename1_cf_fire => rename1_cf_fire,
            wb_cf0_valid => alu1_wb_cf_valid,
            wb_cf0_tag   => alu1_wb_cf_tag,
            wb_cf0_data  => alu1_wb_cf_data,
            wb_cf1_valid => alu0_wb_cf_valid,
            wb_cf1_tag   => alu0_wb_cf_tag,
            wb_cf1_data  => alu0_wb_cf_data,
            wb_cf2_valid => lsu_wb_cf_valid,
            wb_cf2_tag   => lsu_wb_cf_tag,
            wb_cf2_data  => lsu_wb_cf_data,
            commit0_cf_valid => commit0_cf_valid_s,
            commit0_cf_tag   => commit0_cf_tag_s,
            commit1_cf_valid => commit1_cf_valid_s,
            commit1_cf_tag   => commit1_cf_tag_s,
            rename0_cf_tag   => rename0_cf_tag,
            rename1_cf_tag   => rename1_cf_tag,
            s0_cf_rrf        => s0_cf_rrf,
            s0_cf_tag        => s0_cf_tag,
            s0_cf_ready      => s0_cf_ready,
            s0_cf_val        => s0_cf_val,
            s1_cf_rrf        => s1_cf_rrf,
            s1_cf_tag        => s1_cf_tag,
            s1_cf_ready      => s1_cf_ready,
            s1_cf_val        => s1_cf_val,
            zf_free_count    => zf_free_count,
            rename0_zf_fire  => rename0_zf_fire,
            rename1_zf_fire  => rename1_zf_fire,
            wb_zf0_valid => alu1_wb_zf_valid,
            wb_zf0_tag   => alu1_wb_zf_tag,
            wb_zf0_data  => alu1_wb_zf_data,
            wb_zf1_valid => alu0_wb_zf_valid,
            wb_zf1_tag   => alu0_wb_zf_tag,
            wb_zf1_data  => alu0_wb_zf_data,
            wb_zf2_valid => lsu_wb_zf_valid,
            wb_zf2_tag   => lsu_wb_zf_tag,
            wb_zf2_data  => lsu_wb_zf_data,
            commit0_zf_valid => commit0_zf_valid_s,
            commit0_zf_tag   => commit0_zf_tag_s,
            commit1_zf_valid => commit1_zf_valid_s,
            commit1_zf_tag   => commit1_zf_tag_s,
            rename0_zf_tag   => rename0_zf_tag,
            rename1_zf_tag   => rename1_zf_tag,
            s0_zf_rrf        => s0_zf_rrf,
            s0_zf_tag        => s0_zf_tag,
            s0_zf_ready      => s0_zf_ready,
            s0_zf_val        => s0_zf_val,
            s1_zf_rrf        => s1_zf_rrf,
            s1_zf_tag        => s1_zf_tag,
            s1_zf_ready      => s1_zf_ready,
            s1_zf_val        => s1_zf_val
        );

    u_dispatch_stage : entity work.dispatch_stage
        port map (
            clk                 => clk,
            rst                 => rst,
            redirect_valid      => redirect_valid,
            dec0_valid          => dec0_valid,
            dec0_dest_en        => dec0_dest_en,
            dec0_is_add         => dec0_is_add,
            dec0_is_nand        => dec0_is_nand,
            dec0_is_adi         => dec0_is_adi,
            dec0_use_carry      => dec0_use_carry,
            dec0_use_zero       => dec0_use_zero,
            dec0_write_carry    => dec0_write_carry,
            dec0_write_zero     => dec0_write_zero,
            dec0_use_complement => dec0_use_complement,
            dec0_imm            => dec0_imm,
            dec0_src1           => dec0_src1,
            dec0_src2           => dec0_src2,
            dec0_dest           => dec0_dest,
            dec0_lli            => dec0_lli,
            dec0_load           => dec0_load,
            dec0_store          => dec0_store,
            dec0_is_branch      => dec0_is_branch,
            dec0_branch_type    => dec0_branch_type,
            dec0_pc             => dec0_pc,
            dec1_valid          => dec1_valid,
            dec1_dest_en        => dec1_dest_en,
            dec1_is_add         => dec1_is_add,
            dec1_is_nand        => dec1_is_nand,
            dec1_is_adi         => dec1_is_adi,
            dec1_use_carry      => dec1_use_carry,
            dec1_use_zero       => dec1_use_zero,
            dec1_write_carry    => dec1_write_carry,
            dec1_write_zero     => dec1_write_zero,
            dec1_use_complement => dec1_use_complement,
            dec1_imm            => dec1_imm,
            dec1_src1           => dec1_src1,
            dec1_src2           => dec1_src2,
            dec1_dest           => dec1_dest,
            dec1_lli            => dec1_lli,
            dec1_load           => dec1_load,
            dec1_store          => dec1_store,
            dec1_is_branch      => dec1_is_branch,
            dec1_branch_type    => dec1_branch_type,
            dec1_pc             => dec1_pc,
            s0_1_rrf            => s0_1_rrf,
            s0_1_tag            => s0_1_tag,
            s0_1_ready          => s0_1_ready,
            s0_1_val            => s0_1_val,
            s0_2_rrf            => s0_2_rrf,
            s0_2_tag            => s0_2_tag,
            s0_2_ready          => s0_2_ready,
            s0_2_val            => s0_2_val,
            s1_1_rrf            => s1_1_rrf,
            s1_1_tag            => s1_1_tag,
            s1_1_ready          => s1_1_ready,
            s1_1_val            => s1_1_val,
            s1_2_rrf            => s1_2_rrf,
            s1_2_tag            => s1_2_tag,
            s1_2_ready          => s1_2_ready,
            s1_2_val            => s1_2_val,
            s0_cf_rrf           => s0_cf_rrf,
            s0_cf_tag           => s0_cf_tag,
            s0_cf_ready         => s0_cf_ready,
            s0_cf_val           => s0_cf_val,
            s0_zf_rrf           => s0_zf_rrf,
            s0_zf_tag           => s0_zf_tag,
            s0_zf_ready         => s0_zf_ready,
            s0_zf_val           => s0_zf_val,
            s1_cf_rrf           => s1_cf_rrf,
            s1_cf_tag           => s1_cf_tag,
            s1_cf_ready         => s1_cf_ready,
            s1_cf_val           => s1_cf_val,
            s1_zf_rrf           => s1_zf_rrf,
            s1_zf_tag           => s1_zf_tag,
            s1_zf_ready         => s1_zf_ready,
            s1_zf_val           => s1_zf_val,
            rename0_tag         => rename0_tag,
            rename1_tag         => rename1_tag,
            rename0_arch        => rename0_arch,
            rename1_arch        => rename1_arch,
            rename0_fire        => rename0_fire,
            rename1_fire        => rename1_fire,
            rename0_cf_fire     => rename0_cf_fire,
            rename1_cf_fire     => rename1_cf_fire,
            rename0_cf_tag      => rename0_cf_tag,
            rename1_cf_tag      => rename1_cf_tag,
            rename0_zf_fire     => rename0_zf_fire,
            rename1_zf_fire     => rename1_zf_fire,
            rename0_zf_tag      => rename0_zf_tag,
            rename1_zf_tag      => rename1_zf_tag,
            rob_count           => rob_count,
            rob_0_idx           => rob_0_idx,
            rob_1_idx           => rob_1_idx,
            rob_0_query         => rob_0_query,
            rob_1_query         => rob_1_query,
            rs_count            => rs_count,
            rrf_count           => rrf_count,
            lsu_count           => lsu_count,
            zf_free_count       => zf_free_count,
            cf_free_count       => cf_free_count,
            d0_fire             => d0_fire,
            d1_fire             => d1_fire,
            d0_alu_fire         => d0_alu_fire,
            d1_alu_fire         => d1_alu_fire,
            d0_lsu_fire         => d0_lsu_fire,
            d1_lsu_fire         => d1_lsu_fire,
            d0_src1_rrf         => d0_src1_rrf,
            d0_src2_rrf         => d0_src2_rrf,
            d1_src1_rrf         => d1_src1_rrf,
            d1_src2_rrf         => d1_src2_rrf,
            d0_src1_ready       => d0_src1_ready,
            d0_src2_ready       => d0_src2_ready,
            d1_src1_ready       => d1_src1_ready,
            d1_src2_ready       => d1_src2_ready,
            d0_src1_tag         => d0_src1_tag,
            d0_src2_tag         => d0_src2_tag,
            d1_src1_tag         => d1_src1_tag,
            d1_src2_tag         => d1_src2_tag,
            d0_src1_value       => d0_src1_value,
            d0_src2_value       => d0_src2_value,
            d1_src1_value       => d1_src1_value,
            d1_src2_value       => d1_src2_value,
            d0_cf_rrf           => d0_cf_rrf,
            d0_cf_tag           => d0_cf_tag,
            d0_cf_ready         => d0_cf_ready,
            d0_cf_val           => d0_cf_val,
            d0_zf_rrf           => d0_zf_rrf,
            d0_zf_tag           => d0_zf_tag,
            d0_zf_ready         => d0_zf_ready,
            d0_zf_val           => d0_zf_val,
            d1_cf_rrf           => d1_cf_rrf,
            d1_cf_tag           => d1_cf_tag,
            d1_cf_ready         => d1_cf_ready,
            d1_cf_val           => d1_cf_val,
            d1_zf_rrf           => d1_zf_rrf,
            d1_zf_tag           => d1_zf_tag,
            d1_zf_ready         => d1_zf_ready,
            d1_zf_val           => d1_zf_val,
            d0_dest_tag         => d0_dest_tag,
            d1_dest_tag         => d1_dest_tag,
            d0_dest_arch        => d0_dest_arch,
            d1_dest_arch        => d1_dest_arch,
            d0_dest_en          => d0_dest_en,
            d1_dest_en          => d1_dest_en,
            d0_carry_tag        => d0_carry_tag,
            d1_carry_tag        => d1_carry_tag,
            d0_carry_en         => d0_carry_en,
            d1_carry_en         => d1_carry_en,
            d0_zero_tag         => d0_zero_tag,
            d1_zero_tag         => d1_zero_tag,
            d0_zero_en          => d0_zero_en,
            d1_zero_en          => d1_zero_en,
            d0_rob_idx          => d0_rob_idx,
            d1_rob_idx          => d1_rob_idx,
            d0_is_add           => d0_is_add,
            d0_is_nand          => d0_is_nand,
            d0_lli              => d0_lli,
            d0_is_adi           => d0_is_adi,
            d0_use_carry        => d0_use_carry,
            d0_use_zero         => d0_use_zero,
            d0_use_complement   => d0_use_complement,
            d0_imm              => d0_imm,
            d0_load             => d0_load,
            d0_store            => d0_store,
            d0_is_branch        => d0_is_branch,
            d0_branch_type      => d0_branch_type,
            d0_pc               => d0_pc,
            d1_is_add           => d1_is_add,
            d1_is_nand          => d1_is_nand,
            d1_lli              => d1_lli,
            d1_is_adi           => d1_is_adi,
            d1_use_carry        => d1_use_carry,
            d1_use_zero         => d1_use_zero,
            d1_use_complement   => d1_use_complement,
            d1_imm              => d1_imm,
            d1_load             => d1_load,
            d1_store            => d1_store,
            d1_is_branch        => d1_is_branch,
            d1_branch_type      => d1_branch_type,
            d1_pc               => d1_pc,
            stall               => stall
        );

    u_issue_stage : entity work.issue_stage
        port map (
            clk                  => clk,
            rst                  => rst,
            redirect_valid       => redirect_valid,
            rs_count             => rs_count,
            d0_alu_fire          => d0_alu_fire,
            d0_is_add            => d0_is_add,
            d0_is_nand           => d0_is_nand,
            d0_lli               => d0_lli,
            d0_is_adi            => d0_is_adi,
            d0_use_carry         => d0_use_carry,
            d0_use_zero          => d0_use_zero,
            d0_use_complement    => d0_use_complement,
            d0_imm               => d0_imm,
            d0_dest_tag          => d0_dest_tag,
            d0_dest_carry_tag    => d0_carry_tag,
            d0_dest_zero_tag     => d0_zero_tag,
            d0_rob_idx           => d0_rob_idx,
            d0_src1_rrf          => d0_src1_rrf,
            d0_src1_ready        => d0_src1_ready,
            d0_src1_tag          => d0_src1_tag,
            d0_src1_value        => d0_src1_value,
            d0_src2_rrf          => d0_src2_rrf,
            d0_src2_ready        => d0_src2_ready,
            d0_src2_tag          => d0_src2_tag,
            d0_src2_value        => d0_src2_value,
            d0_carry_rrf         => d0_cf_rrf,
            d0_carry_ready       => d0_cf_ready,
            d0_carry_tag         => d0_cf_tag,
            d0_carry_value       => d0_cf_val,
            d0_zero_rrf          => d0_zf_rrf,
            d0_zero_ready        => d0_zf_ready,
            d0_zero_tag          => d0_zf_tag,
            d0_zero_value        => d0_zf_val,
            d0_is_branch         => d0_is_branch,
            d0_branch_type       => d0_branch_type,
            d0_pc                => d0_pc,
            d1_alu_fire          => d1_alu_fire,
            d1_is_add            => d1_is_add,
            d1_is_nand           => d1_is_nand,
            d1_lli               => d1_lli,
            d1_is_adi            => d1_is_adi,
            d1_use_carry         => d1_use_carry,
            d1_use_zero          => d1_use_zero,
            d1_use_complement    => d1_use_complement,
            d1_imm               => d1_imm,
            d1_dest_tag          => d1_dest_tag,
            d1_dest_carry_tag    => d1_carry_tag,
            d1_dest_zero_tag     => d1_zero_tag,
            d1_rob_idx           => d1_rob_idx,
            d1_src1_rrf          => d1_src1_rrf,
            d1_src1_ready        => d1_src1_ready,
            d1_src1_tag          => d1_src1_tag,
            d1_src1_value        => d1_src1_value,
            d1_src2_rrf          => d1_src2_rrf,
            d1_src2_ready        => d1_src2_ready,
            d1_src2_tag          => d1_src2_tag,
            d1_src2_value        => d1_src2_value,
            d1_carry_rrf         => d1_cf_rrf,
            d1_carry_ready       => d1_cf_ready,
            d1_carry_tag         => d1_cf_tag,
            d1_carry_value       => d1_cf_val,
            d1_zero_rrf          => d1_zf_rrf,
            d1_zero_ready        => d1_zf_ready,
            d1_zero_tag          => d1_zf_tag,
            d1_zero_value        => d1_zf_val,
            d1_is_branch         => d1_is_branch,
            d1_branch_type       => d1_branch_type,
            d1_pc                => d1_pc,
            wb0_valid            => alu0_wb_valid,
            wb0_tag              => alu0_wb_tag,
            wb0_data             => alu0_wb_data,
            wb1_valid            => alu1_wb_valid,
            wb1_tag              => alu1_wb_tag,
            wb1_data             => alu1_wb_data,
            wb2_valid            => lsu_wb_valid,
            wb2_tag              => lsu_wb_tag,
            wb2_data             => lsu_wb_data,
            wb_cf0_valid         => alu0_wb_cf_valid,
            wb_cf0_tag           => alu0_wb_cf_tag,
            wb_cf0_data          => alu0_wb_cf_data,
            wb_cf1_valid         => alu1_wb_cf_valid,
            wb_cf1_tag           => alu1_wb_cf_tag,
            wb_cf1_data          => alu1_wb_cf_data,
            wb_cf2_valid         => '0',
            wb_cf2_tag           => (others => '0'),
            wb_cf2_data          => '0',
            wb_zf0_valid         => alu0_wb_zf_valid,
            wb_zf0_tag           => alu0_wb_zf_tag,
            wb_zf0_data          => alu0_wb_zf_data,
            wb_zf1_valid         => alu1_wb_zf_valid,
            wb_zf1_tag           => alu1_wb_zf_tag,
            wb_zf1_data          => alu1_wb_zf_data,
            wb_zf2_valid         => lsu_wb_zf_valid,
            wb_zf2_tag           => lsu_wb_zf_tag,
            wb_zf2_data          => lsu_wb_zf_data,
            issue_alu0_valid     => issue_alu0_valid,
            issue_alu1_valid     => issue_alu1_valid,
            issue_alu0_is_add    => issue_alu0_is_add,
            issue_alu0_is_nand   => issue_alu0_is_nand,
            issue_alu0_lli       => issue_alu0_lli,
            issue_alu0_is_adi    => issue_alu0_is_adi,
            issue_alu0_use_carry => issue_alu0_use_carry,
            issue_alu0_use_zero  => issue_alu0_use_zero,
            issue_alu0_use_complement => issue_alu0_use_complement,
            issue_alu0_imm       => issue_alu0_imm,
            issue_alu0_src1_value => issue_alu0_src1_value,
            issue_alu0_src2_value => issue_alu0_src2_value,
            issue_alu0_dest_tag   => issue_alu0_dest_tag,
            issue_alu0_rob_idx    => issue_alu0_rob_idx,
            issue_alu0_carry_tag  => issue_alu0_carry_tag,
            issue_alu0_carry_value => issue_alu0_carry_value,
            issue_alu0_zero_tag   => issue_alu0_zero_tag,
            issue_alu0_zero_value => issue_alu0_zero_value,
            issue_alu0_is_branch  => issue_alu0_is_branch,
            issue_alu0_branch_type => issue_alu0_branch_type,
            issue_alu0_pc         => issue_alu0_pc,
            issue_alu1_is_add     => issue_alu1_is_add,
            issue_alu1_is_nand    => issue_alu1_is_nand,
            issue_alu1_lli        => issue_alu1_lli,
            issue_alu1_is_adi     => issue_alu1_is_adi,
            issue_alu1_use_carry  => issue_alu1_use_carry,
            issue_alu1_use_zero   => issue_alu1_use_zero,
            issue_alu1_use_complement => issue_alu1_use_complement,
            issue_alu1_imm        => issue_alu1_imm,
            issue_alu1_src1_value => issue_alu1_src1_value,
            issue_alu1_src2_value => issue_alu1_src2_value,
            issue_alu1_dest_tag   => issue_alu1_dest_tag,
            issue_alu1_rob_idx    => issue_alu1_rob_idx,
            issue_alu1_carry_tag  => issue_alu1_carry_tag,
            issue_alu1_carry_value => issue_alu1_carry_value,
            issue_alu1_zero_tag   => issue_alu1_zero_tag,
            issue_alu1_zero_value => issue_alu1_zero_value,
            issue_alu1_is_branch  => issue_alu1_is_branch,
            issue_alu1_branch_type => issue_alu1_branch_type,
            issue_alu1_pc         => issue_alu1_pc
        );

    u_alu_fu0 : entity work.alu_fu
        port map (
            issue_valid       => issue_alu0_valid,
            is_add            => issue_alu0_is_add,
            is_nand           => issue_alu0_is_nand,
            is_lli            => issue_alu0_lli,
            is_adi            => issue_alu0_is_adi,
            use_carry         => issue_alu0_use_carry,
            use_zero          => issue_alu0_use_zero,
            use_complement    => issue_alu0_use_complement,
            imm               => issue_alu0_imm,
            src1_value        => issue_alu0_src1_value,
            src2_value        => issue_alu0_src2_value,
            dest_tag          => issue_alu0_dest_tag,
            rob_idx           => issue_alu0_rob_idx,
            carry_tag         => issue_alu0_carry_tag,
            carry_value       => issue_alu0_carry_value,
            zero_tag          => issue_alu0_zero_tag,
            zero_value        => issue_alu0_zero_value,
            is_branch         => issue_alu0_is_branch,
            branch_type       => issue_alu0_branch_type,
            pc                => issue_alu0_pc,
            wb_valid          => alu0_wb_valid,
            wb_tag            => alu0_wb_tag,
            wb_data           => alu0_wb_data,
            wb_cf_valid       => alu0_wb_cf_valid,
            wb_cf_tag         => alu0_wb_cf_tag,
            wb_cf_data        => alu0_wb_cf_data,
            wb_zf_valid       => alu0_wb_zf_valid,
            wb_zf_tag         => alu0_wb_zf_tag,
            wb_zf_data        => alu0_wb_zf_data,
            ex_valid          => alu0_ex_valid,
            ex_idx            => alu0_ex_idx,
            ex_is_branch      => alu0_ex_is_branch,
            ex_branch_taken   => alu0_ex_branch_taken,
            ex_branch_target  => alu0_ex_branch_target
        );

    u_alu_fu1 : entity work.alu_fu
        port map (
            issue_valid       => issue_alu1_valid,
            is_add            => issue_alu1_is_add,
            is_nand           => issue_alu1_is_nand,
            is_lli            => issue_alu1_lli,
            is_adi            => issue_alu1_is_adi,
            use_carry         => issue_alu1_use_carry,
            use_zero          => issue_alu1_use_zero,
            use_complement    => issue_alu1_use_complement,
            imm               => issue_alu1_imm,
            src1_value        => issue_alu1_src1_value,
            src2_value        => issue_alu1_src2_value,
            dest_tag          => issue_alu1_dest_tag,
            rob_idx           => issue_alu1_rob_idx,
            carry_tag         => issue_alu1_carry_tag,
            carry_value       => issue_alu1_carry_value,
            zero_tag          => issue_alu1_zero_tag,
            zero_value        => issue_alu1_zero_value,
            is_branch         => issue_alu1_is_branch,
            branch_type       => issue_alu1_branch_type,
            pc                => issue_alu1_pc,
            wb_valid          => alu1_wb_valid,
            wb_tag            => alu1_wb_tag,
            wb_data           => alu1_wb_data,
            wb_cf_valid       => alu1_wb_cf_valid,
            wb_cf_tag         => alu1_wb_cf_tag,
            wb_cf_data        => alu1_wb_cf_data,
            wb_zf_valid       => alu1_wb_zf_valid,
            wb_zf_tag         => alu1_wb_zf_tag,
            wb_zf_data        => alu1_wb_zf_data,
            ex_valid          => alu1_ex_valid,
            ex_idx            => alu1_ex_idx,
            ex_is_branch      => alu1_ex_is_branch,
            ex_branch_taken   => alu1_ex_branch_taken,
            ex_branch_target  => alu1_ex_branch_target
        );

    u_lsu_stage : entity work.lsu_stage
        port map (
            clk               => clk,
            rst               => rst,
            redirect_valid    => redirect_valid,
            rob_head_valid    => rob_head_valid_s,
            rob_head_idx      => rob_head_idx_s,
            rob_head_is_store => rob_head_is_store_s,
            wb0_valid         => alu0_wb_valid,
            wb0_tag           => alu0_wb_tag,
            wb0_data          => alu0_wb_data,
            wb1_valid         => alu1_wb_valid,
            wb1_tag           => alu1_wb_tag,
            wb1_data          => alu1_wb_data,
            wb2_valid         => lsu_wb_valid,
            wb2_tag           => lsu_wb_tag,
            wb2_data          => lsu_wb_data,
            d0_lsu_fire       => d0_lsu_fire,
            d0_is_load        => d0_load,
            d0_is_store       => d0_store,
            d0_src1_rrf       => d0_src1_rrf,
            d0_src1_ready     => d0_src1_ready,
            d0_src1_tag       => d0_src1_tag,
            d0_src1_value     => d0_src1_value,
            d0_src2_rrf       => d0_src2_rrf,
            d0_src2_ready     => d0_src2_ready,
            d0_src2_tag       => d0_src2_tag,
            d0_src2_value     => d0_src2_value,
            d0_imm            => d0_imm,
            d0_dest_tag       => d0_dest_tag,
            d0_rob_idx        => d0_rob_idx,
            d0_is_branch      => d0_is_branch,
            d1_lsu_fire       => d1_lsu_fire,
            d1_is_load        => d1_load,
            d1_is_store       => d1_store,
            d1_src1_rrf       => d1_src1_rrf,
            d1_src1_ready     => d1_src1_ready,
            d1_src1_tag       => d1_src1_tag,
            d1_src1_value     => d1_src1_value,
            d1_src2_rrf       => d1_src2_rrf,
            d1_src2_ready     => d1_src2_ready,
            d1_src2_tag       => d1_src2_tag,
            d1_src2_value     => d1_src2_value,
            d1_imm            => d1_imm,
            d1_dest_tag       => d1_dest_tag,
            d1_rob_idx        => d1_rob_idx,
            d1_is_branch      => d1_is_branch,
            wb_valid          => lsu_wb_valid,
            wb_tag            => lsu_wb_tag,
            wb_data           => lsu_wb_data,
            wb_zf_valid       => lsu_wb_zf_valid,
            wb_zf_tag         => lsu_wb_zf_tag,
            wb_zf_data        => lsu_wb_zf_data,
            wb_cf_valid       => lsu_wb_cf_valid,
            wb_cf_tag         => lsu_wb_cf_tag,
            wb_cf_data        => lsu_wb_cf_data,
            ex_valid          => lsu_ex_valid,
            ex_idx            => lsu_ex_idx,
            ex_is_branch      => lsu_ex_is_branch,
            ex_branch_taken   => lsu_ex_branch_taken,
            ex_branch_target  => lsu_ex_branch_target,
            lsq_count         => lsu_count
        );

    u_rob_stage : entity work.rob_stage
        port map (
            clk                => clk,
            rst                => rst,
            alloc0_fire        => d0_fire,
            alloc1_fire        => d1_fire,
            alloc0_query       => rob_0_query,
            alloc1_query       => rob_1_query,
            rob_count          => rob_count,
            alloc0_idx         => rob_0_idx,
            alloc1_idx         => rob_1_idx,
            alloc0_dest_en     => d0_dest_en,
            alloc1_dest_en     => d1_dest_en,
            alloc0_arch        => d0_dest_arch,
            alloc1_arch        => d1_dest_arch,
            alloc0_dest_tag    => d0_dest_tag,
            alloc1_dest_tag    => d1_dest_tag,
            alloc0_carry_en    => d0_carry_en,
            alloc1_carry_en    => d0_carry_en,
            alloc0_carry_tag   => d0_carry_tag,
            alloc1_carry_tag   => d0_carry_tag,
            alloc0_zero_en     => d0_zero_en,
            alloc1_zero_en     => d0_zero_en,
            alloc0_zero_tag    => d0_zero_tag,
            alloc1_zero_tag    => d0_zero_tag,
            alloc0_is_store    => d0_store,
            alloc1_is_store    => d1_store,
            alloc0_is_load     => d0_load,
            alloc1_is_load     => d1_load,
            alloc0_is_branch   => d0_is_branch,
            alloc1_is_branch   => d1_is_branch,
            ex0_valid          => alu0_ex_valid,
            ex0_idx            => alu0_ex_idx,
            ex0_is_branch      => alu0_ex_is_branch,
            ex0_branch_taken   => alu0_ex_branch_taken,
            ex0_branch_target  => alu0_ex_branch_target,
            ex1_valid          => alu1_ex_valid,
            ex1_idx            => alu1_ex_idx,
            ex1_is_branch      => alu1_ex_is_branch,
            ex1_branch_taken   => alu1_ex_branch_taken,
            ex1_branch_target  => alu1_ex_branch_target,
            ex2_valid          => lsu_ex_valid,
            ex2_idx            => lsu_ex_idx,
            ex2_is_branch      => lsu_ex_is_branch,
            ex2_branch_taken   => lsu_ex_branch_taken,
            ex2_branch_target  => lsu_ex_branch_target,
            commit0_valid      => commit0_valid_s,
            commit0_arch       => commit0_arch_s,
            commit0_tag        => commit0_tag_s,
            commit1_valid      => commit1_valid_s,
            commit1_arch       => commit1_arch_s,
            commit1_tag        => commit1_tag_s,
            commit0_cf_valid   => commit0_cf_valid_s,
            commit0_cf_tag     => commit0_cf_tag_s,
            commit1_cf_valid   => commit1_cf_valid_s,
            commit1_cf_tag     => commit1_cf_tag_s,
            commit0_zf_valid   => commit0_zf_valid_s,
            commit0_zf_tag     => commit0_zf_tag_s,
            commit1_zf_valid   => commit1_zf_valid_s,
            commit1_zf_tag     => commit1_zf_tag_s,
            rob_head_valid     => rob_head_valid_s,
            rob_head_idx       => rob_head_idx_s,
            rob_head_is_store  => rob_head_is_store_s,
            redirect_valid     => redirect_valid,
            redirect_target    => redirect_target
        );
end architecture rtl;