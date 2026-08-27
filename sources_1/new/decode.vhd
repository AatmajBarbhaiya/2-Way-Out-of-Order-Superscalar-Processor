library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decode_stage is
    port (
        clk : in std_logic;
        rst : in std_logic;
        stall : in std_logic;
        redirect_valid : in std_logic;

        instr0 : in std_logic_vector(15 downto 0);
        instr1 : in std_logic_vector(15 downto 0);
        valid0 : in std_logic;
        valid1 : in std_logic;
        pc_in  : in std_logic_vector(15 downto 0);

        dec0_valid : out std_logic;
        dec0_dest_en : out std_logic;
        dec0_is_add : out std_logic;
        dec0_is_nand : out std_logic;
        dec0_is_adi : out std_logic;
        dec0_use_carry : out std_logic;
        dec0_use_zero : out std_logic;
        dec0_write_carry : out std_logic;
        dec0_write_zero : out std_logic;
        dec0_use_complement : out std_logic;
        dec0_imm : out std_logic_vector(15 downto 0);
        dec0_src1 : out std_logic_vector(2 downto 0);
        dec0_src2 : out std_logic_vector(2 downto 0);
        dec0_dest : out std_logic_vector(2 downto 0);
        dec0_lli : out std_logic;
        dec0_load : out std_logic;
        dec0_store : out std_logic;
        dec0_is_branch : out std_logic;
        dec0_branch_type : out std_logic_vector(3 downto 0);
        dec0_pc : out std_logic_vector(15 downto 0);

        dec1_valid : out std_logic;
        dec1_dest_en : out std_logic;
        dec1_is_add : out std_logic;
        dec1_is_nand : out std_logic;
        dec1_is_adi : out std_logic;
        dec1_use_carry : out std_logic;
        dec1_use_zero : out std_logic;
        dec1_write_carry : out std_logic;
        dec1_write_zero : out std_logic;
        dec1_use_complement : out std_logic;
        dec1_imm : out std_logic_vector(15 downto 0);
        dec1_src1 : out std_logic_vector(2 downto 0);
        dec1_src2 : out std_logic_vector(2 downto 0);
        dec1_dest : out std_logic_vector(2 downto 0);
        dec1_lli : out std_logic;
        dec1_load : out std_logic;
        dec1_store : out std_logic;
        dec1_is_branch : out std_logic;
        dec1_branch_type : out std_logic_vector(3 downto 0);
        dec1_pc : out std_logic_vector(15 downto 0)
    );
end entity decode_stage;

architecture rtl of decode_stage is

    function sxt6(x : std_logic_vector(5 downto 0)) return std_logic_vector is
    begin
        return std_logic_vector(resize(signed(x), 16));
    end function;

    function sxt9(x : std_logic_vector(8 downto 0)) return std_logic_vector is
    begin
        return std_logic_vector(resize(signed(x), 16));
    end function;

    signal dec0_temp_valid : std_logic;
    signal dec1_temp_valid : std_logic;

    signal dec0_temp_dest_en : std_logic;
    signal dec1_temp_dest_en : std_logic;

    signal dec0_temp_is_add : std_logic;
    signal dec1_temp_is_add : std_logic;
    signal dec0_temp_is_nand : std_logic;
    signal dec1_temp_is_nand : std_logic;
    signal dec0_temp_is_adi : std_logic;
    signal dec1_temp_is_adi : std_logic;
    signal dec0_temp_use_carry : std_logic;
    signal dec1_temp_use_carry : std_logic;
    signal dec0_temp_use_zero : std_logic;
    signal dec1_temp_use_zero : std_logic;
    signal dec0_temp_write_carry : std_logic;
    signal dec1_temp_write_carry : std_logic;
    signal dec0_temp_write_zero : std_logic;
    signal dec1_temp_write_zero : std_logic;
    signal dec0_temp_use_complement : std_logic;
    signal dec1_temp_use_complement : std_logic;

    signal dec0_temp_imm : std_logic_vector(15 downto 0);
    signal dec1_temp_imm : std_logic_vector(15 downto 0);

    signal dec0_temp_src1 : std_logic_vector(2 downto 0);
    signal dec0_temp_src2 : std_logic_vector(2 downto 0);
    signal dec0_temp_dest : std_logic_vector(2 downto 0);
    signal dec1_temp_src1 : std_logic_vector(2 downto 0);
    signal dec1_temp_src2 : std_logic_vector(2 downto 0);
    signal dec1_temp_dest : std_logic_vector(2 downto 0);

    signal dec0_temp_lli : std_logic;
    signal dec1_temp_lli : std_logic;
    signal dec0_temp_load : std_logic;
    signal dec1_temp_load : std_logic;
    signal dec0_temp_store : std_logic;
    signal dec1_temp_store : std_logic;
    signal dec0_temp_is_branch : std_logic;
    signal dec1_temp_is_branch : std_logic;
    signal dec0_temp_branch_type : std_logic_vector(3 downto 0);
    signal dec1_temp_branch_type : std_logic_vector(3 downto 0);
    signal dec0_temp_pc : std_logic_vector(15 downto 0);
    signal dec1_temp_pc : std_logic_vector(15 downto 0);

begin

    process(instr0, instr1, valid0, valid1, pc_in)
        variable opcode0 : std_logic_vector(3 downto 0);
        variable opcode1 : std_logic_vector(3 downto 0);

        variable func0 : std_logic_vector(2 downto 0);
        variable func1 : std_logic_vector(2 downto 0);

        variable ra0 : std_logic_vector(2 downto 0);
        variable rb0 : std_logic_vector(2 downto 0);
        variable rc0 : std_logic_vector(2 downto 0);

        variable ra1 : std_logic_vector(2 downto 0);
        variable rb1 : std_logic_vector(2 downto 0);
        variable rc1 : std_logic_vector(2 downto 0);

        variable imm6_0 : std_logic_vector(5 downto 0);
        variable imm6_1 : std_logic_vector(5 downto 0);
        variable imm9_0 : std_logic_vector(8 downto 0);
        variable imm9_1 : std_logic_vector(8 downto 0);

        variable v_dec0_valid : std_logic;
        variable v_dec1_valid : std_logic;

        variable v_dec0_dest_en : std_logic;
        variable v_dec1_dest_en : std_logic;

        variable v_dec0_is_add : std_logic;
        variable v_dec1_is_add : std_logic;
        variable v_dec0_is_nand : std_logic;
        variable v_dec1_is_nand : std_logic;
        variable v_dec0_is_adi : std_logic;
        variable v_dec1_is_adi : std_logic;
        variable v_dec0_use_carry : std_logic;
        variable v_dec1_use_carry : std_logic;
        variable v_dec0_use_zero : std_logic;
        variable v_dec1_use_zero : std_logic;
        variable v_dec0_write_carry : std_logic;
        variable v_dec1_write_carry : std_logic;
        variable v_dec0_write_zero : std_logic;
        variable v_dec1_write_zero : std_logic;
        variable v_dec0_use_complement : std_logic;
        variable v_dec1_use_complement : std_logic;

        variable v_dec0_imm : std_logic_vector(15 downto 0);
        variable v_dec1_imm : std_logic_vector(15 downto 0);

        variable v_dec0_src1 : std_logic_vector(2 downto 0);
        variable v_dec0_src2 : std_logic_vector(2 downto 0);
        variable v_dec0_dest : std_logic_vector(2 downto 0);
        variable v_dec1_src1 : std_logic_vector(2 downto 0);
        variable v_dec1_src2 : std_logic_vector(2 downto 0);
        variable v_dec1_dest : std_logic_vector(2 downto 0);

        variable v_dec0_lli : std_logic;
        variable v_dec1_lli : std_logic;
        variable v_dec0_load : std_logic;
        variable v_dec1_load : std_logic;
        variable v_dec0_store : std_logic;
        variable v_dec1_store : std_logic;
        variable v_dec0_is_branch : std_logic;
        variable v_dec1_is_branch : std_logic;
        variable v_dec0_branch_type : std_logic_vector(3 downto 0);
        variable v_dec1_branch_type : std_logic_vector(3 downto 0);
        variable v_dec0_pc : std_logic_vector(15 downto 0);
        variable v_dec1_pc : std_logic_vector(15 downto 0);
    begin
        opcode0 := instr0(15 downto 12);
        ra0 := instr0(11 downto 9);
        rb0 := instr0(8 downto 6);
        rc0 := instr0(5 downto 3);
        func0 := instr0(2 downto 0);
        imm6_0 := instr0(5 downto 0);
        imm9_0 := instr0(8 downto 0);

        opcode1 := instr1(15 downto 12);
        ra1 := instr1(11 downto 9);
        rb1 := instr1(8 downto 6);
        rc1 := instr1(5 downto 3);
        func1 := instr1(2 downto 0);
        imm6_1 := instr1(5 downto 0);
        imm9_1 := instr1(8 downto 0);

        v_dec0_valid := '0';
        v_dec0_dest_en := '0';
        v_dec0_is_add := '0';
        v_dec0_is_nand := '0';
        v_dec0_is_adi := '0';
        v_dec0_use_carry := '0';
        v_dec0_use_zero := '0';
        v_dec0_write_carry := '0';
        v_dec0_write_zero := '0';
        v_dec0_use_complement := '0';
        v_dec0_imm := (others => '0');
        v_dec0_src1 := (others => '0');
        v_dec0_src2 := (others => '0');
        v_dec0_dest := (others => '0');
        v_dec0_lli := '0';
        v_dec0_load := '0';
        v_dec0_store := '0';
        v_dec0_is_branch := '0';
        v_dec0_branch_type := (others => '0');
        v_dec0_pc := pc_in;

        v_dec1_valid := '0';
        v_dec1_dest_en := '0';
        v_dec1_is_add := '0';
        v_dec1_is_nand := '0';
        v_dec1_is_adi := '0';
        v_dec1_use_carry := '0';
        v_dec1_use_zero := '0';
        v_dec1_write_carry := '0';
        v_dec1_write_zero := '0';
        v_dec1_use_complement := '0';
        v_dec1_imm := (others => '0');
        v_dec1_src1 := (others => '0');
        v_dec1_src2 := (others => '0');
        v_dec1_dest := (others => '0');
        v_dec1_lli := '0';
        v_dec1_load := '0';
        v_dec1_store := '0';
        v_dec1_is_branch := '0';
        v_dec1_branch_type := (others => '0');
        v_dec1_pc := std_logic_vector(unsigned(pc_in) + 2);

        if valid0 = '1' then
            case opcode0 is
                when "0001" =>
                    v_dec0_is_add := '1';
                    v_dec0_use_carry := func0(1);
                    v_dec0_use_zero := func0(0);
                    v_dec0_use_complement := func0(2);
                    v_dec0_src1 := ra0;
                    v_dec0_src2 := rb0;
                    -- v_dec0_dest := rc0;
                    -- v_dec0_dest_en := '1';
                    if (rc0 = "000") then
                        v_dec0_is_branch := '1';
                        v_dec0_branch_type := "0001";
                    else
                        v_dec0_dest := rc0;
                        v_dec0_dest_en := '1';
                    end if;
                    v_dec0_write_carry := '1';
                    v_dec0_write_zero := '1';
                when "0000" =>
                    v_dec0_is_add := '1';
                    v_dec0_is_adi := '1';
                    v_dec0_src1 := ra0;
                    v_dec0_src2 := rb0;
                    -- v_dec0_dest := rb0;
                    -- v_dec0_dest_en := '1';
                    if (rb0 = "000") then
                        v_dec0_is_branch := '1';
                        v_dec0_branch_type := "0000";
                    else
                        v_dec0_dest := rb0;
                        v_dec0_dest_en := '1';
                    end if;
                    v_dec0_imm := sxt6(imm6_0);
                when "0010" =>
                    v_dec0_is_nand := '1';
                    v_dec0_use_carry := func0(1);
                    v_dec0_use_zero := func0(0);
                    v_dec0_use_complement := func0(2);
                    v_dec0_src1 := ra0;
                    v_dec0_src2 := rb0;
                    -- v_dec0_dest := rc0;
                    -- v_dec0_dest_en := '1';
                    if (rc0 = "000") then
                        v_dec0_is_branch := '1';
                        v_dec0_branch_type := "0010";
                    else
                        v_dec0_dest := rc0;
                        v_dec0_dest_en := '1';
                    end if;
                    v_dec0_write_zero := '1';
                when "0011" =>
                    v_dec0_lli := '1';
                    -- v_dec0_dest := ra0;
                    -- v_dec0_dest_en := '1';
                    if (ra0 = "000") then
                        v_dec0_is_branch := '1';
                        v_dec0_branch_type := "0011";
                    else
                        v_dec0_dest := ra0;
                        v_dec0_dest_en := '1';
                    end if;
                    v_dec0_imm := sxt9(imm9_0);
                when "0100" =>
                    v_dec0_load := '1';
                    v_dec0_src1 := rb0;
                    -- v_dec0_dest := ra0;
                    -- v_dec0_dest_en := '1';
                    if (ra0 = "000") then
                        v_dec0_is_branch := '1';
                        v_dec0_branch_type := "0100";
                    else
                        v_dec0_dest := ra0;
                        v_dec0_dest_en := '1';
                    end if;
                    v_dec0_write_zero := '1';
                    v_dec0_imm := sxt6(imm6_0);
                when "0101" =>
                    v_dec0_store := '1';
                    v_dec0_src1 := rb0;
                    v_dec0_src2 := ra0;
                    v_dec0_imm := sxt6(imm6_0);
                when "1000" | "1001" | "1010" =>
                    v_dec0_is_branch := '1';
                    v_dec0_branch_type := opcode0;
                    v_dec0_src1 := ra0;
                    v_dec0_src2 := rb0;
                    v_dec0_imm := sxt6(imm6_0);
                when "1100" =>
                    v_dec0_is_branch := '1';
                    v_dec0_branch_type := "1100";
                    v_dec0_dest := ra0;
                    v_dec0_dest_en := '1';
                    v_dec0_imm := sxt9(imm9_0);
                when "1101" =>
                    v_dec0_is_branch := '1';
                    v_dec0_branch_type := "1101";
                    v_dec0_src1 := rb0;
                    v_dec0_dest := ra0;
                    v_dec0_dest_en := '1';
                when "1111" =>
                    v_dec0_is_branch := '1';
                    v_dec0_branch_type := "1111";
                    v_dec0_src1 := ra0;
                    v_dec0_imm := sxt9(imm9_0);
                when others =>
                    null;
            end case;
            v_dec0_valid := '1';
        end if;

        if valid1 = '1' then
            case opcode1 is
                when "0001" =>
                    v_dec1_is_add := '1';
                    v_dec1_use_carry := func1(1);
                    v_dec1_use_zero := func1(0);
                    v_dec1_use_complement := func1(2);
                    v_dec1_src1 := ra1;
                    v_dec1_src2 := rb1;
                    -- v_dec1_dest := rc1;
                    -- v_dec1_dest_en := '1';
                    if (rc1 = "000") then
                        v_dec1_is_branch := '1';
                        v_dec1_branch_type := "0001";
                    else
                        v_dec1_dest := rc1;
                        v_dec1_dest_en := '1';
                    end if;
                    v_dec1_write_carry := '1';
                    v_dec1_write_zero := '1';
                when "0000" =>
                    v_dec1_is_add := '1';
                    v_dec1_is_adi := '1';
                    v_dec1_src1 := ra1;
                    v_dec1_src2 := rb1;
                    -- v_dec1_dest := rb1;
                    -- v_dec1_dest_en := '1';
                    if (rb1 = "000") then
                        v_dec1_is_branch := '1';
                        v_dec1_branch_type := "0000";
                    else
                        v_dec1_dest := rb1;
                        v_dec1_dest_en := '1';
                    end if;
                    v_dec1_imm := sxt6(imm6_1);
                when "0010" =>
                    v_dec1_is_nand := '1';
                    v_dec1_use_carry := func1(1);
                    v_dec1_use_zero := func1(0);
                    v_dec1_use_complement := func1(2);
                    v_dec1_src1 := ra1;
                    v_dec1_src2 := rb1;
                    -- v_dec1_dest := rc1;
                    -- v_dec1_dest_en := '1';
                    if (rc1 = "000") then
                        v_dec1_is_branch := '1';
                        v_dec1_branch_type := "0010";
                    else
                        v_dec1_dest := rc1;
                        v_dec1_dest_en := '1';
                    end if;
                    v_dec1_write_zero := '1';
                when "0011" =>
                    v_dec1_lli := '1';
                    -- v_dec1_dest := ra1;
                    -- v_dec1_dest_en := '1';
                    if (ra1 = "000") then
                        v_dec1_is_branch := '1';
                        v_dec1_branch_type := "0011";
                    else
                        v_dec1_dest := ra1;
                        v_dec1_dest_en := '1';
                    end if;
                    v_dec1_imm := sxt9(imm9_1);
                when "0100" =>
                    v_dec1_load := '1';
                    v_dec1_src1 := rb1;
                    -- v_dec1_dest := ra1;
                    -- v_dec1_dest_en := '1';
                    if (ra1 = "000") then
                        v_dec1_is_branch := '1';
                        v_dec1_branch_type := "0100";
                    else
                        v_dec1_dest := ra1;
                        v_dec1_dest_en := '1';
                    end if;
                    v_dec1_write_zero := '1';
                    v_dec1_imm := sxt6(imm6_1);
                when "0101" =>
                    v_dec1_store := '1';
                    v_dec1_src1 := rb1;
                    v_dec1_src2 := ra1;
                    v_dec1_imm := sxt6(imm6_1);
                when "1000" | "1001" | "1010" =>
                    v_dec1_is_branch := '1';
                    v_dec1_branch_type := opcode1;
                    v_dec1_src1 := ra1;
                    v_dec1_src2 := rb1;
                    v_dec1_imm := sxt6(imm6_1);
                when "1100" =>
                    v_dec1_is_branch := '1';
                    v_dec1_branch_type := "1100";
                    v_dec1_dest := ra1;
                    v_dec1_dest_en := '1';
                    v_dec1_imm := sxt9(imm9_1);
                when "1101" =>
                    v_dec1_is_branch := '1';
                    v_dec1_branch_type := "1101";
                    v_dec1_src1 := rb1;
                    v_dec1_dest := ra1;
                    v_dec1_dest_en := '1';
                when "1111" =>
                    v_dec1_is_branch := '1';
                    v_dec1_branch_type := "1111";
                    v_dec1_src1 := ra1;
                    v_dec1_imm := sxt9(imm9_1);
                when others =>
                    null;
            end case;
            v_dec1_valid := '1';
        end if;

        dec0_temp_valid <= v_dec0_valid;
        dec0_temp_dest_en <= v_dec0_dest_en;
        dec0_temp_is_add <= v_dec0_is_add;
        dec0_temp_is_nand <= v_dec0_is_nand;
        dec0_temp_is_adi <= v_dec0_is_adi;
        dec0_temp_use_carry <= v_dec0_use_carry;
        dec0_temp_use_zero <= v_dec0_use_zero;
        dec0_temp_write_carry <= v_dec0_write_carry;
        dec0_temp_write_zero <= v_dec0_write_zero;
        dec0_temp_use_complement <= v_dec0_use_complement;
        dec0_temp_imm <= v_dec0_imm;
        dec0_temp_src1 <= v_dec0_src1;
        dec0_temp_src2 <= v_dec0_src2;
        dec0_temp_dest <= v_dec0_dest;
        dec0_temp_lli <= v_dec0_lli;
        dec0_temp_load <= v_dec0_load;
        dec0_temp_store <= v_dec0_store;
        dec0_temp_is_branch <= v_dec0_is_branch;
        dec0_temp_branch_type <= v_dec0_branch_type;
        dec0_temp_pc <= v_dec0_pc;

        dec1_temp_valid <= v_dec1_valid;
        dec1_temp_dest_en <= v_dec1_dest_en;
        dec1_temp_is_add <= v_dec1_is_add;
        dec1_temp_is_nand <= v_dec1_is_nand;
        dec1_temp_is_adi <= v_dec1_is_adi;
        dec1_temp_use_carry <= v_dec1_use_carry;
        dec1_temp_use_zero <= v_dec1_use_zero;
        dec1_temp_write_carry <= v_dec1_write_carry;
        dec1_temp_write_zero <= v_dec1_write_zero;
        dec1_temp_use_complement <= v_dec1_use_complement;
        dec1_temp_imm <= v_dec1_imm;
        dec1_temp_src1 <= v_dec1_src1;
        dec1_temp_src2 <= v_dec1_src2;
        dec1_temp_dest <= v_dec1_dest;
        dec1_temp_lli <= v_dec1_lli;
        dec1_temp_load <= v_dec1_load;
        dec1_temp_store <= v_dec1_store;
        dec1_temp_is_branch <= v_dec1_is_branch;
        dec1_temp_branch_type <= v_dec1_branch_type;
        dec1_temp_pc <= v_dec1_pc;
    end process;

    process(clk, rst)
    begin
        if rst = '1' then
            dec0_valid <= '0';
            dec0_dest_en <= '0';
            dec0_is_add <= '0';
            dec0_is_nand <= '0';
            dec0_is_adi <= '0';
            dec0_use_carry <= '0';
            dec0_use_zero <= '0';
            dec0_write_carry <= '0';
            dec0_write_zero <= '0';
            dec0_use_complement <= '0';
            dec0_imm <= (others => '0');
            dec0_src1 <= (others => '0');
            dec0_src2 <= (others => '0');
            dec0_dest <= (others => '0');
            dec0_lli <= '0';
            dec0_load <= '0';
            dec0_store <= '0';
            dec0_is_branch <= '0';
            dec0_branch_type <= (others => '0');
            dec0_pc <= (others => '0');

            dec1_valid <= '0';
            dec1_dest_en <= '0';
            dec1_is_add <= '0';
            dec1_is_nand <= '0';
            dec1_is_adi <= '0';
            dec1_use_carry <= '0';
            dec1_use_zero <= '0';
            dec1_write_carry <= '0';
            dec1_write_zero <= '0';
            dec1_use_complement <= '0';
            dec1_imm <= (others => '0');
            dec1_src1 <= (others => '0');
            dec1_src2 <= (others => '0');
            dec1_dest <= (others => '0');
            dec1_lli <= '0';
            dec1_load <= '0';
            dec1_store <= '0';
            dec1_is_branch <= '0';
            dec1_branch_type <= (others => '0');
            dec1_pc <= (others => '0');
        elsif rising_edge(clk) then
            if redirect_valid = '1' then
                dec0_valid <= '0';
                dec0_dest_en <= '0';
                dec0_is_add <= '0';
                dec0_is_nand <= '0';
                dec0_is_adi <= '0';
                dec0_use_carry <= '0';
                dec0_use_zero <= '0';
                dec0_write_carry <= '0';
                dec0_write_zero <= '0';
                dec0_use_complement <= '0';
                dec0_imm <= (others => '0');
                dec0_src1 <= (others => '0');
                dec0_src2 <= (others => '0');
                dec0_dest <= (others => '0');
                dec0_lli <= '0';
                dec0_load <= '0';
                dec0_store <= '0';
                dec0_is_branch <= '0';
                dec0_branch_type <= (others => '0');
                dec0_pc <= (others => '0');

                dec1_valid <= '0';
                dec1_dest_en <= '0';
                dec1_is_add <= '0';
                dec1_is_nand <= '0';
                dec1_is_adi <= '0';
                dec1_use_carry <= '0';
                dec1_use_zero <= '0';
                dec1_write_carry <= '0';
                dec1_write_zero <= '0';
                dec1_use_complement <= '0';
                dec1_imm <= (others => '0');
                dec1_src1 <= (others => '0');
                dec1_src2 <= (others => '0');
                dec1_dest <= (others => '0');
                dec1_lli <= '0';
                dec1_load <= '0';
                dec1_store <= '0';
                dec1_is_branch <= '0';
                dec1_branch_type <= (others => '0');
                dec1_pc <= (others => '0');
            elsif stall = '0' then
                dec0_valid <= dec0_temp_valid;
                dec0_dest_en <= dec0_temp_dest_en;
                dec0_is_add <= dec0_temp_is_add;
                dec0_is_nand <= dec0_temp_is_nand;
                dec0_is_adi <= dec0_temp_is_adi;
                dec0_use_carry <= dec0_temp_use_carry;
                dec0_use_zero <= dec0_temp_use_zero;
                dec0_write_carry <= dec0_temp_write_carry;
                dec0_write_zero <= dec0_temp_write_zero;
                dec0_use_complement <= dec0_temp_use_complement;
                dec0_imm <= dec0_temp_imm;
                dec0_src1 <= dec0_temp_src1;
                dec0_src2 <= dec0_temp_src2;
                dec0_dest <= dec0_temp_dest;
                dec0_lli <= dec0_temp_lli;
                dec0_load <= dec0_temp_load;
                dec0_store <= dec0_temp_store;
                dec0_is_branch <= dec0_temp_is_branch;
                dec0_branch_type <= dec0_temp_branch_type;
                dec0_pc <= dec0_temp_pc;

                dec1_valid <= dec1_temp_valid;
                dec1_dest_en <= dec1_temp_dest_en;
                dec1_is_add <= dec1_temp_is_add;
                dec1_is_nand <= dec1_temp_is_nand;
                dec1_is_adi <= dec1_temp_is_adi;
                dec1_use_carry <= dec1_temp_use_carry;
                dec1_use_zero <= dec1_temp_use_zero;
                dec1_write_carry <= dec1_temp_write_carry;
                dec1_write_zero <= dec1_temp_write_zero;
                dec1_use_complement <= dec1_temp_use_complement;
                dec1_imm <= dec1_temp_imm;
                dec1_src1 <= dec1_temp_src1;
                dec1_src2 <= dec1_temp_src2;
                dec1_dest <= dec1_temp_dest;
                dec1_lli <= dec1_temp_lli;
                dec1_load <= dec1_temp_load;
                dec1_store <= dec1_temp_store;
                dec1_is_branch <= dec1_temp_is_branch;
                dec1_branch_type <= dec1_temp_branch_type;
                dec1_pc <= dec1_temp_pc;
            end if;
        end if;
    end process;

end architecture rtl;