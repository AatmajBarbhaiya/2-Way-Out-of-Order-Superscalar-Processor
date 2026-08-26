library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_fu is
    port (
        issue_valid : in std_logic;
        is_add : in std_logic;
        is_nand : in std_logic;
        is_lli : in std_logic;
        is_adi : in std_logic;
        use_carry : in std_logic;
        use_zero : in std_logic;
        use_complement : in std_logic;

        imm : in std_logic_vector(15 downto 0);
        src1_value : in std_logic_vector(15 downto 0);
        src2_value : in std_logic_vector(15 downto 0);

        dest_tag : in std_logic_vector(3 downto 0);
        rob_idx : in std_logic_vector(3 downto 0);

        carry_tag : in std_logic_vector(3 downto 0);
        carry_value : in std_logic;
        zero_tag : in std_logic_vector(3 downto 0);
        zero_value : in std_logic;

        is_branch : in std_logic;
        branch_type : in std_logic_vector(3 downto 0);
        pc : in std_logic_vector(15 downto 0);

        wb_valid : out std_logic;
        wb_tag : out std_logic_vector(3 downto 0);
        wb_data : out std_logic_vector(15 downto 0);

        wb_cf_valid : out std_logic;
        wb_cf_tag : out std_logic_vector(3 downto 0);
        wb_cf_data : out std_logic;

        wb_zf_valid : out std_logic;
        wb_zf_tag : out std_logic_vector(3 downto 0);
        wb_zf_data : out std_logic;

        ex_valid : out std_logic;
        ex_idx : out std_logic_vector(3 downto 0);
        ex_is_branch : out std_logic;
        ex_branch_taken : out std_logic;
        ex_branch_target : out std_logic_vector(15 downto 0)
    );
end entity alu_fu;

architecture rtl of alu_fu is
begin

    process(issue_valid, is_add, is_nand, is_lli, is_adi, use_carry, use_zero, use_complement, imm, src1_value, src2_value, dest_tag, rob_idx, carry_tag, carry_value, zero_tag, zero_value, is_branch, branch_type, pc)
        variable b_u : unsigned(15 downto 0);
        variable add_full_u : unsigned(16 downto 0);
        variable add_res_u : unsigned(15 downto 0);
        variable pc_u : unsigned(15 downto 0);
        variable imm_u : unsigned(15 downto 0);
        variable branch_target_u : unsigned(15 downto 0);
        variable carry_term_u : unsigned(16 downto 0);

        variable v_wb_valid : std_logic;
        variable v_wb_tag : std_logic_vector(3 downto 0);
        variable v_wb_data : std_logic_vector(15 downto 0);

        variable v_wb_cf_valid : std_logic;
        variable v_wb_cf_tag : std_logic_vector(3 downto 0);
        variable v_wb_cf_data : std_logic;

        variable v_wb_zf_valid : std_logic;
        variable v_wb_zf_tag : std_logic_vector(3 downto 0);
        variable v_wb_zf_data : std_logic;

        variable v_ex_valid : std_logic;
        variable v_ex_idx : std_logic_vector(3 downto 0);
        variable v_ex_is_branch : std_logic;
        variable v_ex_branch_taken : std_logic;
        variable v_ex_branch_target : std_logic_vector(15 downto 0);
    begin
        v_wb_valid := '0';
        v_wb_tag := dest_tag;
        v_wb_data := (others => '0');

        v_wb_cf_valid := '0';
        v_wb_cf_tag := carry_tag;
        v_wb_cf_data := '0';

        v_wb_zf_valid := '0';
        v_wb_zf_tag := zero_tag;
        v_wb_zf_data := '0';

        v_ex_valid := '0';
        v_ex_idx := rob_idx;
        v_ex_is_branch := '0';
        v_ex_branch_taken := '0';
        v_ex_branch_target := (others => '0');

        pc_u := unsigned(pc);
        imm_u := unsigned(imm);

        if is_adi = '1' then
            b_u := imm_u;
        else
            b_u := unsigned(src2_value);
        end if;

        if use_complement = '1' then
            b_u := not b_u;
        end if;

        carry_term_u := (others => '0');
        if use_carry = '1' and use_zero = '1' then
            if carry_value = '1' then
                carry_term_u(0) := '1';
            end if;
        end if;

        add_full_u := ('0' & unsigned(src1_value)) + ('0' & b_u) + carry_term_u;
        add_res_u := add_full_u(15 downto 0);

        if issue_valid = '1' then
            v_ex_valid := '1';
            v_ex_idx := rob_idx;

            if is_lli = '1' then
                v_wb_valid := '1';
                v_wb_data := imm;
            elsif is_nand = '1' then
                if use_carry = '1' and use_zero = '0' then
                    if carry_value = '1' then
                        v_wb_valid := '1';
                        v_wb_data := not (src1_value and src2_value);
                    end if;
                elsif use_carry = '0' and use_zero = '1' then
                    if zero_value = '1' then
                        v_wb_valid := '1';
                        v_wb_data := not (src1_value and src2_value);
                    end if;
                else
                    v_wb_valid := '1';
                    v_wb_data := not (src1_value and src2_value);
                end if;

                v_wb_zf_valid := '1';
                if unsigned(not (src1_value and src2_value)) = 0 then
                    v_wb_zf_data := '1';
                else
                    v_wb_zf_data := '0';
                end if;
            elsif is_add = '1' then
                if use_carry = '1' and use_zero = '0' then
                    if carry_value = '1' then
                        v_wb_valid := '1';
                        v_wb_data := std_logic_vector(add_res_u);
                    end if;
                elsif use_carry = '0' and use_zero = '1' then
                    if zero_value = '1' then
                        v_wb_valid := '1';
                        v_wb_data := std_logic_vector(add_res_u);
                    end if;
                else
                    v_wb_valid := '1';
                    v_wb_data := std_logic_vector(add_res_u);
                end if;

                v_wb_cf_valid := '1';
                v_wb_cf_data := add_full_u(16);

                v_wb_zf_valid := '1';
                if add_res_u = 0 then
                    v_wb_zf_data := '1';
                else
                    v_wb_zf_data := '0';
                end if;
            elsif is_adi = '1' then
                v_wb_valid := '1';
                v_wb_data := std_logic_vector(add_res_u);

                v_wb_cf_valid := '1';
                v_wb_cf_data := add_full_u(16);

                v_wb_zf_valid := '1';
                if add_res_u = 0 then
                    v_wb_zf_data := '1';
                else
                    v_wb_zf_data := '0';
                end if;
            end if;

            if is_branch = '1' then
                v_ex_is_branch := '1';
                branch_target_u := pc_u + shift_left(imm_u, 1);

                case branch_type is
                    when "0000" | "0001" | "0010"  | "0011" =>
                        v_ex_branch_taken := v_wb_valid;
                        v_ex_branch_target := v_wb_data;
                    when "1000" =>
                        if src1_value = src2_value then
                            v_ex_branch_taken := '1';
                        else
                            v_ex_branch_taken := '0';
                        end if;
                        v_ex_branch_target := std_logic_vector(branch_target_u);

                    when "1001" =>
                        if signed(src1_value) < signed(src2_value) then
                            v_ex_branch_taken := '1';
                        else
                            v_ex_branch_taken := '0';
                        end if;
                        v_ex_branch_target := std_logic_vector(branch_target_u);

                    when "1010" =>
                        if signed(src1_value) <= signed(src2_value) then
                            v_ex_branch_taken := '1';
                        else
                            v_ex_branch_taken := '0';
                        end if;
                        v_ex_branch_target := std_logic_vector(branch_target_u);

                    when "1100" =>
                        v_ex_branch_taken := '1';
                        v_ex_branch_target := std_logic_vector(branch_target_u);
                        v_wb_valid := '1';
                        v_wb_data := std_logic_vector(pc_u + 2);

                    when "1101" =>
                        v_ex_branch_taken := '1';
                        v_ex_branch_target := src1_value;
                        v_wb_valid := '1';
                        v_wb_data := std_logic_vector(pc_u + 2);

                    when "1111" =>
                        v_ex_branch_taken := '1';
                        v_ex_branch_target := std_logic_vector(unsigned(src1_value) + shift_left(imm_u, 1));

                    when others =>
                        v_ex_branch_taken := '0';
                        v_ex_branch_target := std_logic_vector(pc_u + 2);
                end case;
            end if;
        end if;

        wb_valid <= v_wb_valid;
        wb_tag <= v_wb_tag;
        wb_data <= v_wb_data;

        wb_cf_valid <= v_wb_cf_valid;
        wb_cf_tag <= v_wb_cf_tag;
        wb_cf_data <= v_wb_cf_data;

        wb_zf_valid <= v_wb_zf_valid;
        wb_zf_tag <= v_wb_zf_tag;
        wb_zf_data <= v_wb_zf_data;

        ex_valid <= v_ex_valid;
        ex_idx <= v_ex_idx;
        ex_is_branch <= v_ex_is_branch;
        ex_branch_taken <= v_ex_branch_taken;
        ex_branch_target <= v_ex_branch_target;
    end process;

end architecture rtl;