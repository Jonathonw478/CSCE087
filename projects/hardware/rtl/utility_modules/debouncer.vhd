-- File: debouncer.vhd
-- Description:
--   Simple switch debouncer. Generates a single-cycle pulse when
--   a 0->1 transition is detected at input. STAGES must be set to 3 or greater.
--
-- Author:
-- Sanjeev Gunawardena
-- 2021-01-15: initial version
-- 2021-02-21: revised to have a longer delay between button presses

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity debouncer is
  generic (
    COUNTER_WIDTH : integer := 22
  );
  port (
    clk : in std_logic;
    button : in std_logic;
    pulse : out std_logic
  );
end debouncer;

architecture arch_imp of debouncer is
  signal count : std_logic_vector (COUNTER_WIDTH - 1 downto 0) := (others => '0');
  constant all_ones : std_logic_vector (COUNTER_WIDTH - 1 downto 0) := (others => '1');
  signal term : std_logic;
  type state_type is (idle, counting, wait_for_zero);
  signal state : state_type := idle;

begin

  term <= '1' when count = all_ones else '0';

  process (clk) is
  begin
    if (rising_edge (clk)) then
      case (state) is
        when idle =>
          count <= (others => '0');
          if button = '1' then
            state <= counting;
            pulse <= '1';
          else
            pulse <= '0';
          end if;
        when counting =>
          count <= count + 1;
          if term = '1' then
            state <= wait_for_zero;
          end if;
          pulse <= '0';
        when wait_for_zero =>
          if button = '0' then
            state <= idle;
          end if;
        when others =>
          state <= idle;
      end case;
    end if;
  end process;

end arch_imp;