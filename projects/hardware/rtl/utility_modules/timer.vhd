-- File: timer.vhd
-- Description:
--   simple timer that produces a single-cycle output pulse every interval
--   when enabled.
--
-- Author:
-- Sanjeev Gunawardena
-- 2021-01-15: initial version
-- 2021-02-21: revised to use INTERVAL_WIDTH generic
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity timer is
  generic (
    INTERVAL_WIDTH : integer := 32
  );
  port (
    rst : in std_logic; -- synchronous reset, active high
    clk : in std_logic;
    enable : in std_logic;
    interval : in std_logic_vector(INTERVAL_WIDTH - 1 downto 0);
    pulse : out std_logic -- generates a single-cycle pulse every interval
  );
end timer;

architecture arch_imp of timer is
  signal count : std_logic_vector(INTERVAL_WIDTH - 1 downto 0);
  signal term : std_logic;

begin

  term <= '1' when count = interval else '0';

  process (clk) is
  begin
    if (rising_edge (clk)) then
      pulse <= term;
      if rst = '1' then
        count <= (others => '0');
      elsif enable = '1' then
        if term = '1' then
          count <= (others => '0');
        else
          count <= count + 1;
        end if;
      end if;

    end if;
  end process;
end arch_imp;