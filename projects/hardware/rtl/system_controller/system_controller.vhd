library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;

use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity system_controller is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 5
	);
	port (
		-- Users to add ports here
		leds: out std_logic_vector(7 downto 0);
		switches: in std_logic_vector(7 downto 0);
		buttons: in std_logic_vector(4 downto 0); -- [up & right & left & down & center]
		reset_0: out std_logic; -- active-high reset
		interrupts: out std_logic_vector(4 downto 0); -- [up & down & left & right & timed]

		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic
	);
end system_controller;

architecture arch_imp of system_controller is

	-- component declaration
	component system_controller_S00_AXI is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 5
		);
		port (
		reset: out std_logic; -- active high reset (activates when '1' is written to slv_reg0(0)
		
		timer0_enable: out std_logic; -- slv_reg0(1)
		timer0_interval:out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0); -- maps to slv_reg1
		
		timer1_enable: out std_logic; -- slv_reg0(2)
		timer1_interval:out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0); -- maps to slv_reg2
		
		led_flash_interval:out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0); -- maps to slv_reg3
		
		switch_states:in std_logic_vector(7 downto 0); -- maps to reg0(15:8)
		
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
		);
	end component system_controller_S00_AXI;
	
	component debouncer is
  generic (
    COUNTER_WIDTH : integer := 22
  );
  port (
    clk : in std_logic;
    button : in std_logic;
    pulse : out std_logic
  );
	end component;
	
	component timer is
	   generic (
	       INTERVAL_WIDTH	: integer	:= 32
	   );
	   port (
	       rst: in std_logic; -- synchronous reset, active high
	       clk: in std_logic;
	       enable: in std_logic;
	       interval: in std_logic_vector(INTERVAL_WIDTH-1 downto 0);
	       pulse: out std_logic -- generates a single-cycle pulse every interval
	   );
    end component;
    
    component pulse_extender is
	generic (
		INTERVAL_WIDTH	: integer	:= 32
	);
	port (
		clk: in std_logic;
		interval: in std_logic_vector(INTERVAL_WIDTH-1 downto 0);
		pulse_in: in std_logic;
		pulse_out: out std_logic -- generates a single-cycle pulse every interval
	);
    end component;
    
    signal reset, software_reset:std_logic;
    
    signal intr_timer_enable:std_logic;
    signal intr_timer_interval:std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
    
    signal led_timer_enable:std_logic;
    signal led_timer_interval:std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
    
    signal led_flash_interval:std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
    
    signal switches_d1:std_logic_vector(7 downto 0);
    
    signal btn_up, btn_right, btn_left, btn_down, btn_center, btn_ord:std_logic;
    signal led_timer_pulse, intr_timer_pulse:std_logic;
    
    signal led_count:std_logic_vector(5 downto 0);
    

begin



-- Instantiation of Axi Bus Interface S00_AXI
system_controller_v1_0_S00_AXI_inst : system_controller_S00_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
	    reset=>software_reset,
		
		timer0_enable =>intr_timer_enable,
		timer0_interval =>intr_timer_interval,
		
		timer1_enable =>led_timer_enable,
		timer1_interval =>led_timer_interval,
		
		led_flash_interval=>led_flash_interval,
		
		switch_states=>switches_d1,
	--
		S_AXI_ACLK	=> s00_axi_aclk,
		S_AXI_ARESETN	=> s00_axi_aresetn,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		S_AXI_WDATA	=> s00_axi_wdata,
		S_AXI_WSTRB	=> s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP	=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RDATA	=> s00_axi_rdata,
		S_AXI_RRESP	=> s00_axi_rresp,
		S_AXI_RVALID	=> s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready
	);

	-- Add user logic here

-- pushbutton debouncers [up & right & left & down & center]
up_debouncer:debouncer
    generic map (COUNTER_WIDTH=>4)
    port map (clk => s00_axi_aclk, button => buttons(4), pulse => btn_up);
    
right_debouncer:debouncer
    generic map (COUNTER_WIDTH=>4)
    port map (clk => s00_axi_aclk, button => buttons(3), pulse => btn_right);
    
left_debouncer:debouncer
    generic map (COUNTER_WIDTH=>4)
    port map (clk => s00_axi_aclk, button => buttons(2), pulse => btn_left);
    
down_debouncer:debouncer
    generic map (COUNTER_WIDTH=>4)
    port map (clk => s00_axi_aclk, button => buttons(1), pulse => btn_down);

center_debouncer:debouncer
    generic map (COUNTER_WIDTH=>4)
    port map (clk => s00_axi_aclk, button => buttons(0), pulse => btn_center);
    
led_flasher:pulse_extender
    generic map(INTERVAL_WIDTH=>C_S00_AXI_DATA_WIDTH)
	port map(
		clk => s00_axi_aclk,
		interval => led_flash_interval,
		pulse_in => btn_ord,
		pulse_out => leds(0)
	);
    
led_timer:timer
	   generic map(INTERVAL_WIDTH => C_S00_AXI_DATA_WIDTH)
	   port map(
	       rst => reset,
	       clk => s00_axi_aclk,
	       enable => led_timer_enable,
	       interval => led_timer_interval,
	       pulse => led_timer_pulse
	   );
	   
interrupt_timer:timer
	   generic map(INTERVAL_WIDTH => C_S00_AXI_DATA_WIDTH)
	   port map(
	       rst => reset,
	       clk => s00_axi_aclk,
	       enable => intr_timer_enable,
	       interval => intr_timer_interval,
	       pulse => intr_timer_pulse
	   );

interrupt_timer_led_flasher:pulse_extender
    generic map(INTERVAL_WIDTH=>C_S00_AXI_DATA_WIDTH)
	port map(
		clk => s00_axi_aclk,
		interval => led_flash_interval,
		pulse_in => intr_timer_pulse,
		pulse_out => leds(1)
	);

    
process( s00_axi_aclk ) is
begin
  if (rising_edge (s00_axi_aclk)) then
    switches_d1<=switches;
    
    reset<=software_reset or btn_center; -- combine hardware and software resets into one
    reset_0<=reset;
    
    btn_ord<=btn_up or btn_right or btn_left or btn_down or btn_center;
    
    interrupts<=btn_up & btn_down & btn_left & btn_right & intr_timer_pulse;
    
    if reset='1' then
        led_count<=(others=>'0');
    elsif led_timer_pulse = '1' then
        led_count<=led_count+1;
    end if;
    
    
    
    
  end if;
end process;

leds(7)<=led_count(5);
leds(6)<=led_count(4);
leds(5)<=led_count(3);
leds(4)<=led_count(2);
leds(3)<=led_count(1);
leds(2)<=led_count(0);



	-- User logic ends

end arch_imp;
