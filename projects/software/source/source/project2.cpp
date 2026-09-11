/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 Project2 test application

 2021-01-15
 Sanjeev Gunawardena

 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "system_controller.h" // temporary driver for system controller

#define LED_FLASH_INTERVAL_MILLISECONDS 50
#define LED_TIMER_INTERVAL_MILLISECONDS 1000
#define INTERRUPT_TIMER_INTERVAL_MILLISECONDS 500

int main()
{
    init_platform();

    system_controller_reset();
    system_controller_set_led_flash_interval(LED_FLASH_INTERVAL_MILLISECONDS);
    system_controller_interrupt_timer_enable(INTERRUPT_TIMER_INTERVAL_MILLISECONDS);
    system_controller_led_timer_enable(LED_TIMER_INTERVAL_MILLISECONDS);

    // we could run this loop for longer, but over time the lag between when this code was
    // executed verses when it shows up in the serial terminal grows.
    // This issue will be fixed in Project3 with interrupts
    // For now, set the switches to a different state and check it by running the application again
    for(u32 k=0; k<10; k++){
        xil_printf("%u: switch state is: %02X\n\r", k, system_controller_get_switch_state());
    }

    print("Successfully ran Project 2 application");
    cleanup_platform();
    return 0;
}
