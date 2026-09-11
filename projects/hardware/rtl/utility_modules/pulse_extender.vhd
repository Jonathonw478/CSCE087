-- File: pulse_extender.vhd
-- Description:
--   takes a single-cycle pulse and generates a pulse that is interval-cycles long
--   this is typically used to flash LEDs
--
-- Author:
-- Sanjeev Gunawardena
-- 2021-01-15: initial version
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity pulse_extender is
  generic (
    INTERVAL_WIDTH : integer := 32
  );
  port (
    clk : in std_logic;
    interval : in std_logic_vector(INTERVAL_WIDTH - 1 downto 0);
    pulse_in : in std_logic;
    pulse_out : out std_logic -- generates a single-cycle pulse every interval
  );
end pulse_extender;

architecture arch_imp of pulse_extender is
  signal count : std_logic_vector(INTERVAL_WIDTH - 1 downto 0) := (others => '0');
  signal count_enable : std_logic;
  signal term : std_logic;

begin

  process (clk) is
  begin
    if (rising_edge (clk)) then
      if pulse_in = '1' then
        count_enable <= '1';
      elsif count_enable = '1' and term = '1' then
        count_enable <= '0';
      end if;

      pulse_out <= count_enable;

      if term = '1' then
        count <= (others => '0');
      elsif count_enable = '1' then
        count <= count + 1;
      end if;

      if count = interval then
        term <= '1';
      else
        term <= '0';
      end if;
    end if;
  end process;

end arch_imp;
