
/*
 Project2 device driver implementation for System Controller

 2021-01-15
 Sanjeev Gunawardena

 */

#include "system_controller.h"
#include "xparameters.h"
#include "xil_io.h"

void system_controller_reset(){

	u32 state = SYSTEM_CONTROLLER_mReadReg(XPAR_SYSTEM_CONTROLLER_0_BASEADDR, SYSTEM_CONTROLLER_CONFIG_OFFSET);

	u32 val = state & BIT_RESET;
	SYSTEM_CONTROLLER_mWriteReg(XPAR_SYSTEM_CONTROLLER_0_BASEADDR, SYSTEM_CONTROLLER_CONFIG_OFFSET, val);

	val = state | BIT_RESET;
	SYSTEM_CONTROLLER_mWriteReg(XPAR_SYSTEM_CONTROLLER_0_BASEADDR, SYSTEM_CONTROLLER_CONFIG_OFFSET, val);
	SYSTEM_CONTROLLER_mWriteReg(XPAR_SYSTEM_CONTROLLER_0_BASEADDR, SYSTEM_CONTROLLER_CONFIG_OFFSET, state);
}

void system_controller_set_led_flash_interval(u32 interval_milliseconds){
	u32 interval_cycles = interval_milliseconds*50000;

	SYSTEM_CONTROLLER_mWriteReg(XPAR_SYSTEM_CONTROLLER_0_BASEADDR,
			SYSTEM_CONTROLLER_LED_FLASH_INTERVAL_OFFSET, interval_cycles);
}

void system_controller_led_timer_enable(u32 interval_milliseconds){

	u32 interval_cycles = interval_milliseconds*50000;

	// set the timer interval
	SYSTEM_CONTROLLER_mWriteReg(XPAR_SYSTEM_CONTROLLER_0_BASEADDR,
			SYSTEM_CONTROLLER_LED_TIMER_OFFSET, interval_cycles);

    // get configuration register state
	u32 state = SYSTEM_CONTROLLER_mReadReg(XPAR_SYSTEM_CONTROLLER_0_BASEADDR, SYSTEM_CONTROLLER_CONFIG_OFFSET);

	// set the enable bit and write it back
	u32 val = state | BIT_LED_TIMER;
	SYSTEM_CONTROLLER_mWriteReg(XPAR_SYSTEM_CONTROLLER_0_BASEADDR, SYSTEM_CONTROLLER_CONFIG_OFFSET, val);
}

void system_controller_interrupt_timer_enable(u32 interval_milliseconds){

	u32 interval_cycles = interval_milliseconds*50000;

	// set the timer interval
	SYSTEM_CONTROLLER_mWriteReg(XPAR_SYSTEM_CONTROLLER_0_BASEADDR,
			SYSTEM_CONTROLLER_INTERRUPT_TIMER_OFFSET, interval_cycles);

    // get configuration register state
	u32 state = SYSTEM_CONTROLLER_mReadReg(XPAR_SYSTEM_CONTROLLER_0_BASEADDR, SYSTEM_CONTROLLER_CONFIG_OFFSET);

	// set the enable bit and write it back
	u32 val = state | BIT_INTERRUPT_TIMER;
	SYSTEM_CONTROLLER_mWriteReg(XPAR_SYSTEM_CONTROLLER_0_BASEADDR, SYSTEM_CONTROLLER_CONFIG_OFFSET, val);
}

u32 system_controller_get_switch_state(){
    // get configuration register state
	u32 state = SYSTEM_CONTROLLER_mReadReg(XPAR_SYSTEM_CONTROLLER_0_BASEADDR, SYSTEM_CONTROLLER_CONFIG_OFFSET);

	state>>=8;
	return state;
}
