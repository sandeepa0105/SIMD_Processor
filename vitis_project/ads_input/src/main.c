/******************************************************************************
 * Copyright (C) 2010 - 2022 Xilinx, Inc.  All rights reserved.
 * Copyright (C) 2022 - 2023 Advanced Micro Devices, Inc.  All rights reserved.
 * SPDX-License-Identifier: MIT
 ******************************************************************************/

/*****************************************************************************/
/**
 *
 * @file xaxidma_example_simple_intr.c
 *
 * This file demonstrates how to use the xaxidma driver on the Xilinx AXI
 * DMA core (AXIDMA) to transfer packets.in interrupt mode when the AXIDMA core
 * is configured in simple mode
 *
 * This code assumes a loopback hardware widget is connected to the AXI DMA
 * core for data packet loopback.
 *
 * To see the debug print, you need a Uart16550 or uartlite in your system,
 * and please set "-DDEBUG" in your compiler options. You need to rebuild your
 * software executable.
 *
 *
 * <pre>
 * MODIFICATION HISTORY:
 *
 * Ver   Who  Date     Changes
 * ----- ---- -------- -------------------------------------------------------
 * 4.00a rkv  02/22/11 New example created for simple DMA, this example is for
 *       	       simple DMA,Added interrupt support for Zynq.
 * 4.00a srt  08/04/11 Changed a typo in the RxIntrHandler, changed
 *		       XAXIDMA_DMA_TO_DEVICE to XAXIDMA_DEVICE_TO_DMA
 * 5.00a srt  03/06/12 Added Flushing and Invalidation of Caches to fix CRs
 *		       648103, 648701.
 *		       Added V7 DDR Base Address to fix CR 649405.
 * 6.00a srt  03/27/12 Changed API calls to support MCDMA driver.
 * 7.00a srt  06/18/12 API calls are reverted back for backward compatibility.
 * 7.01a srt  11/02/12 Buffer sizes (Tx and Rx) are modified to meet maximum
 *		       DDR memory limit of the h/w system built with Area mode
 * 7.02a srt  03/01/13 Updated DDR base address for IPI designs (CR 703656).
 * 9.1   adk  01/07/16 Updated DDR base address for Ultrascale (CR 799532) and
 *		       removed the defines for S6/V6.
 * 9.2   vak  15/04/16 Fixed compilation warnings in the example
 * 9.3   ms   01/23/17 Modified xil_printf statement in main function to
 *                     ensure that "Successfully ran" and "Failed" strings are
 *                     available in all examples. This is a fix for CR-965028.
 * 9.6   rsp  02/14/18 Support data buffers above 4GB.Use UINTPTR for
 *typecasting buffer address (CR-992638). 9.9   rsp  01/21/19 Fix use of #elif
 *check in deriving DDR_BASE_ADDR. 9.10  rsp  09/17/19 Fix cache maintenance ops
 *for source and dest buffer. 9.14  sk   03/08/22 Delete DDR memory limits
 *comments as they are not relevant to this driver version. 9.15  sa   08/12/22
 *Updated the example to use latest MIG cannoical define i.e
 *XPAR_MIG_0_C0_DDR4_MEMORY_MAP_BASEADDR. 9.16  sa   09/29/22 Fix infinite loops
 *in the example.
 * </pre>
 *
 * ***************************************************************************
 */

/***************************** Include Files *********************************/

#include "stdlib.h"
#include "time.h"
#include "xaxidma.h"
#include "xdebug.h"
#include "xil_exception.h"
#include "xil_util.h"
#include "xparameters.h"

#ifdef XPAR_UARTNS550_0_BASEADDR
#include "xuartns550_l.h" /* to use uartns550 */
#endif

#ifdef XPAR_INTC_0_DEVICE_ID
#include "xintc.h"
#else
#include "xscugic.h"
#endif

/************************** Constant Definitions *****************************/

/*
 * Device hardware build related constants.
 */

#define DMA_DEV_ID XPAR_AXIDMA_0_DEVICE_ID

#ifdef XPAR_AXI_7SDDR_0_S_AXI_BASEADDR
#define DDR_BASE_ADDR XPAR_AXI_7SDDR_0_S_AXI_BASEADDR
#elif defined(XPAR_MIG7SERIES_0_BASEADDR)
#define DDR_BASE_ADDR XPAR_MIG7SERIES_0_BASEADDR
#elif defined(XPAR_MIG_0_C0_DDR4_MEMORY_MAP_BASEADDR)
#define DDR_BASE_ADDR XPAR_MIG_0_C0_DDR4_MEMORY_MAP_BASEADDR
#elif defined(XPAR_PSU_DDR_0_S_AXI_BASEADDR)
#define DDR_BASE_ADDR XPAR_PSU_DDR_0_S_AXI_BASEADDR
#endif

#ifndef DDR_BASE_ADDR
#warning CHECK FOR THE VALID DDR ADDRESS IN XPARAMETERS.H, \
		DEFAULT SET TO 0x01000000
#define MEM_BASE_ADDR 0x01000000
#else
#define MEM_BASE_ADDR (DDR_BASE_ADDR + 0x1000000)
#endif

#ifdef XPAR_INTC_0_DEVICE_ID
#define RX_INTR_ID XPAR_INTC_0_AXIDMA_0_S2MM_INTROUT_VEC_ID
#define TX_INTR_ID XPAR_INTC_0_AXIDMA_0_MM2S_INTROUT_VEC_ID
#else
#define RX_INTR_ID XPAR_FABRIC_AXIDMA_0_S2MM_INTROUT_VEC_ID
#define TX_INTR_ID XPAR_FABRIC_AXIDMA_0_MM2S_INTROUT_VEC_ID
#endif

#define TX_BUFFER_BASE (MEM_BASE_ADDR + 0x00100000)
#define RX_BUFFER_BASE (MEM_BASE_ADDR + 0x00300000)
#define RX_BUFFER_HIGH (MEM_BASE_ADDR + 0x004FFFFF)

#ifdef XPAR_INTC_0_DEVICE_ID
#define INTC_DEVICE_ID XPAR_INTC_0_DEVICE_ID
#else
#define INTC_DEVICE_ID XPAR_SCUGIC_SINGLE_DEVICE_ID
#endif

#ifdef XPAR_INTC_0_DEVICE_ID
#define INTC XIntc
#define INTC_HANDLER XIntc_InterruptHandler
#else
#define INTC XScuGic
#define INTC_HANDLER XScuGic_InterruptHandler
#endif

/* Timeout loop counter for reset
 */
#define RESET_TIMEOUT_COUNTER 10000

#define TEST_START_VALUE 0xC
/*
 * Buffer and Buffer Descriptor related constant definition
 */
#define MAX_PKT_LEN 0x100

#define NUMBER_OF_TRANSFERS 10
#define POLL_TIMEOUT_COUNTER 1000000U
#define NUMBER_OF_EVENTS 1

#define INS_SIZE 4096
#define OPCODE_WIDTH 4

/* The interrupt coalescing threshold and delay timer threshold
 * Valid range is 1 to 255
 *
 * We set the coalescing threshold to be the total number of packets.
 * The receive side will only get one completion interrupt for this example.
 */

/**************************** Type Definitions *******************************/

/***************** Macros (Inline Functions) Definitions *********************/

/************************** Function Prototypes ******************************/
#ifndef DEBUG
extern void xil_printf(const char *format, ...);
#endif

#ifdef XPAR_UARTNS550_0_BASEADDR
static void Uart550_Setup(void);
#endif

static int CheckData(int Length, u8 StartValue);
static void TxIntrHandler(void *Callback);
static void RxIntrHandler(void *Callback);

static int SetupIntrSystem(INTC *IntcInstancePtr, XAxiDma *AxiDmaPtr,
                           u16 TxIntrId, u16 RxIntrId);
static void DisableIntrSystem(INTC *IntcInstancePtr, u16 TxIntrId,
                              u16 RxIntrId);
void WriteDMA(u32 *TxBufferPtr, int length);
void ReadDMA(u32 *RxBufferPtr, int length);

/************************** Variable Definitions *****************************/
/*
 * Device instance definitions
 */

static XAxiDma AxiDma; /* Instance of the XAxiDma */

static INTC Intc; /* Instance of the Interrupt Controller */

/*
 * Flags interrupt handlers use to notify the application context the events.
 */
volatile u32 TxDone;
volatile u32 RxDone;
volatile u32 Error;

// OPCODE Definitions
enum Opcode {
    NOP,
    ADD,
    SUB,
    MUL,
    DOT,
    STORE_TMP_I,
    STORE_TMP_F,
    STORE,
    STOP,
    FETCH_A,
    FETCH_B
};

u16 op_mat_mul(u16 *ins, int M, int N, int P, int W) {
    u16 pc = 0;
    ins[pc++] = NOP;

    for (int m = 0; m < M; m++) {
        for (int p = 0; p < P; p += W) {
            for (int w = 0; w < W; w++) {
                for (int n = 0; n < N / W; n++) {
                    ins[pc++] = m * N / W + n << OPCODE_WIDTH | FETCH_A;
                    ins[pc++] = (p + w) * N / W + n << OPCODE_WIDTH | FETCH_B;
                    ins[pc++] = DOT;
                }
                ins[pc++] = STORE_TMP_F;
            }
            ins[pc++] = m * P / W + p / W << OPCODE_WIDTH | STORE;
        }
    }
    ins[pc++] = STOP;
    return pc;
}

/*****************************************************************************/
/**
 *
 * Main function
 *
 * This function is the main entry of the interrupt test. It does the following:
 *	Set up the output terminal if UART16550 is in the hardware build
 *	Initialize the DMA engine
 *	Set up Tx and Rx channels
 *	Set up the interrupt system for the Tx and Rx interrupts
 *	Submit a transfer
 *	Wait for the transfer to finish
 *	Check transfer status
 *	Disable Tx and Rx interrupts
 *	Print test status and exit
 *
 * @param	None
 *
 * @return
 *		- XST_SUCCESS if example finishes successfully
 *		- XST_FAILURE if example fails.
 *
 * @note		None.
 *
 ******************************************************************************/
int main(void) {
    int Status;
    XAxiDma_Config *Config;
    int Tries = NUMBER_OF_TRANSFERS;
    int Index;
    u8 *TxBufferPtr;
    u8 *RxBufferPtr;
    u8 Value;
    u16 ins[INS_SIZE];

    TxBufferPtr = (u8 *)TX_BUFFER_BASE;
    RxBufferPtr = (u8 *)RX_BUFFER_BASE;
    /* Initial setup for Uart16550 */
#ifdef XPAR_UARTNS550_0_BASEADDR

    Uart550_Setup();

#endif

    xil_printf("\r\n--- Entering main() --- \r\n");

    Config = XAxiDma_LookupConfig(DMA_DEV_ID);
    if (!Config) {
        xil_printf("No config found for %d\r\n", DMA_DEV_ID);

        return XST_FAILURE;
    }

    /* Initialize DMA engine */
    Status = XAxiDma_CfgInitialize(&AxiDma, Config);

    if (Status != XST_SUCCESS) {
        xil_printf("Initialization failed %d\r\n", Status);
        return XST_FAILURE;
    }

    if (XAxiDma_HasSg(&AxiDma)) {
        xil_printf("Device configured as SG mode \r\n");
        return XST_FAILURE;
    }

    /* Set up Interrupt system  */
    Status = SetupIntrSystem(&Intc, &AxiDma, TX_INTR_ID, RX_INTR_ID);
    if (Status != XST_SUCCESS) {
        xil_printf("Failed intr setup\r\n");
        return XST_FAILURE;
    }

    /* Disable all interrupts before setup */

    XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);

    XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);

    /* Enable all interrupts */
    XAxiDma_IntrEnable(&AxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);

    XAxiDma_IntrEnable(&AxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);

    /* Disable data cache*/
    Xil_DCacheDisable();

    /* Initialize flags before start transfer test  */
    TxDone = 0;
    RxDone = 0;
    Error = 0;

    Value = TEST_START_VALUE;

    // srand(time(NULL));

    int A_row = 4;
    int A_col = 4;
    int B_col = 4;

    u32 mat_a[4][4] = {
        {1, 0, 0, 0}, 
        {0, 1, 0, 0}, 
        {0, 0, 1, 0}, 
        {0, 0, 0, 1}
    };
    u32 mat_b[4][4] = {
        {1, 2, 3, 4}, 
        {5, 6, 7, 8}, 
        {1, 2, 3, 4}, 
        {5, 6, 7, 8}
    };

    u32 mat_got[A_row][B_col];

    u16 length = op_mat_mul(ins, A_row, A_col, B_col, 4);

    Xil_Out32(XPAR_FETCH_UNIT_0_S00_AXI_BASEADDR + 4, A_row * B_col + 1);
    Xil_Out32(XPAR_FETCH_UNIT_0_S00_AXI_BASEADDR + 8, A_col);
    // Xil_Out32(XPAR_FETCH_UNIT_0_S00_AXI_BASEADDR + 12, B_col);

    /* code */

    Xil_Out32(XPAR_FETCH_UNIT_0_S00_AXI_BASEADDR, 0);
    WriteDMA(mat_a, A_row * A_col);
    Xil_Out32(XPAR_FETCH_UNIT_0_S00_AXI_BASEADDR, 1);
    WriteDMA(mat_b, A_col * B_col);
    Xil_Out32(XPAR_FETCH_UNIT_0_S00_AXI_BASEADDR, 2);
    WriteDMA(ins, length / 2 + 1);

    ReadDMA(mat_got, A_row * B_col + 1);

    // print mat_got
    // u32 *mat_got_ptr = mat_got;


    xil_printf("Result:\n");
    for (int i = 0; i < A_row; i++) {
        for (int j = 0; j < B_col; j++) {
            xil_printf("%d ", mat_got[i][j]);
        }
        xil_printf("\n");
    }


    /* Disable TX and RX Ring interrupts and return success */
    DisableIntrSystem(&Intc, TX_INTR_ID, RX_INTR_ID);

Done:
    xil_printf("--- Exiting main() --- \r\n");

    if (Status != XST_SUCCESS) {
        return XST_FAILURE;
    }

    return XST_SUCCESS;
}

#ifdef XPAR_UARTNS550_0_BASEADDR
/*****************************************************************************/
/*
 *
 * Uart16550 setup routine, need to set baudrate to 9600 and data bits to 8
 *
 * @param	None
 *
 * @return	None
 *
 * @note		None.
 *
 ******************************************************************************/
static void Uart550_Setup(void) {
    XUartNs550_SetBaud(XPAR_UARTNS550_0_BASEADDR, XPAR_XUARTNS550_CLOCK_HZ,
                       9600);

    XUartNs550_SetLineControlReg(XPAR_UARTNS550_0_BASEADDR,
                                 XUN_LCR_8_DATA_BITS);
}
#endif

/*****************************************************************************/
/*
 *
 * This function checks data buffer after the DMA transfer is finished.
 *
 * We use the static tx/rx buffers.
 *
 * @param	Length is the length to check
 * @param	StartValue is the starting value of the first byte
 *
 * @return
 *		- XST_SUCCESS if validation is successful
 *		- XST_FAILURE if validation is failure.
 *
 * @note		None.
 *
 ******************************************************************************/
static int CheckData(int Length, u8 StartValue) {
    u8 *RxPacket;
    int Index = 0;
    u8 Value;

    RxPacket = (u8 *)RX_BUFFER_BASE;
    Value = StartValue;

    /* Invalidate the DestBuffer before receiving the data, in case the
     * Data Cache is enabled
     */
    Xil_DCacheInvalidateRange((UINTPTR)RxPacket, Length);

    for (Index = 0; Index < Length; Index++) {
        if (RxPacket[Index] != Value) {
            xil_printf("Data error %d: %x/%x\r\n", Index, RxPacket[Index],
                       Value);

            return XST_FAILURE;
        }
        Value = (Value + 1) & 0xFF;
    }

    return XST_SUCCESS;
}

/*****************************************************************************/
/*
 *
 * This is the DMA TX Interrupt handler function.
 *
 * It gets the interrupt status from the hardware, acknowledges it, and if any
 * error happens, it resets the hardware. Otherwise, if a completion interrupt
 * is present, then sets the TxDone.flag
 *
 * @param	Callback is a pointer to TX channel of the DMA engine.
 *
 * @return	None.
 *
 * @note		None.
 *
 ******************************************************************************/
static void TxIntrHandler(void *Callback) {
    u32 IrqStatus;
    int TimeOut;
    XAxiDma *AxiDmaInst = (XAxiDma *)Callback;

    /* Read pending interrupts */
    IrqStatus = XAxiDma_IntrGetIrq(AxiDmaInst, XAXIDMA_DMA_TO_DEVICE);

    /* Acknowledge pending interrupts */

    XAxiDma_IntrAckIrq(AxiDmaInst, IrqStatus, XAXIDMA_DMA_TO_DEVICE);

    /*
     * If no interrupt is asserted, we do not do anything
     */
    if (!(IrqStatus & XAXIDMA_IRQ_ALL_MASK)) {
        return;
    }

    /*
     * If error interrupt is asserted, raise error flag, reset the
     * hardware to recover from the error, and return with no further
     * processing.
     */
    if ((IrqStatus & XAXIDMA_IRQ_ERROR_MASK)) {
        Error = 1;

        /*
         * Reset should never fail for transmit channel
         */
        XAxiDma_Reset(AxiDmaInst);

        TimeOut = RESET_TIMEOUT_COUNTER;

        while (TimeOut) {
            if (XAxiDma_ResetIsDone(AxiDmaInst)) {
                break;
            }

            TimeOut -= 1;
        }

        return;
    }

    /*
     * If Completion interrupt is asserted, then set the TxDone flag
     */
    if ((IrqStatus & XAXIDMA_IRQ_IOC_MASK)) {
        TxDone = 1;
    }
}

/*****************************************************************************/
/*
 *
 * This is the DMA RX interrupt handler function
 *
 * It gets the interrupt status from the hardware, acknowledges it, and if any
 * error happens, it resets the hardware. Otherwise, if a completion interrupt
 * is present, then it sets the RxDone flag.
 *
 * @param	Callback is a pointer to RX channel of the DMA engine.
 *
 * @return	None.
 *
 * @note		None.
 *
 ******************************************************************************/
static void RxIntrHandler(void *Callback) {
    u32 IrqStatus;
    int TimeOut;
    XAxiDma *AxiDmaInst = (XAxiDma *)Callback;

    /* Read pending interrupts */
    IrqStatus = XAxiDma_IntrGetIrq(AxiDmaInst, XAXIDMA_DEVICE_TO_DMA);

    /* Acknowledge pending interrupts */
    XAxiDma_IntrAckIrq(AxiDmaInst, IrqStatus, XAXIDMA_DEVICE_TO_DMA);

    /*
     * If no interrupt is asserted, we do not do anything
     */
    if (!(IrqStatus & XAXIDMA_IRQ_ALL_MASK)) {
        return;
    }

    /*
     * If error interrupt is asserted, raise error flag, reset the
     * hardware to recover from the error, and return with no further
     * processing.
     */
    if ((IrqStatus & XAXIDMA_IRQ_ERROR_MASK)) {
        Error = 1;

        /* Reset could fail and hang
         * NEED a way to handle this or do not call it??
         */
        XAxiDma_Reset(AxiDmaInst);

        TimeOut = RESET_TIMEOUT_COUNTER;

        while (TimeOut) {
            if (XAxiDma_ResetIsDone(AxiDmaInst)) {
                break;
            }

            TimeOut -= 1;
        }

        return;
    }

    /*
     * If completion interrupt is asserted, then set RxDone flag
     */
    if ((IrqStatus & XAXIDMA_IRQ_IOC_MASK)) {
        RxDone = 1;
    }
}

/*****************************************************************************/
/*
 *
 * This function setups the interrupt system so interrupts can occur for the
 * DMA, it assumes INTC component exists in the hardware system.
 *
 * @param	IntcInstancePtr is a pointer to the instance of the INTC.
 * @param	AxiDmaPtr is a pointer to the instance of the DMA engine
 * @param	TxIntrId is the TX channel Interrupt ID.
 * @param	RxIntrId is the RX channel Interrupt ID.
 *
 * @return
 *		- XST_SUCCESS if successful,
 *		- XST_FAILURE.if not successful
 *
 * @note		None.
 *
 ******************************************************************************/
static int SetupIntrSystem(INTC *IntcInstancePtr, XAxiDma *AxiDmaPtr,
                           u16 TxIntrId, u16 RxIntrId) {
    int Status;

#ifdef XPAR_INTC_0_DEVICE_ID

    /* Initialize the interrupt controller and connect the ISRs */
    Status = XIntc_Initialize(IntcInstancePtr, INTC_DEVICE_ID);
    if (Status != XST_SUCCESS) {
        xil_printf("Failed init intc\r\n");
        return XST_FAILURE;
    }

    Status = XIntc_Connect(IntcInstancePtr, TxIntrId,
                           (XInterruptHandler)TxIntrHandler, AxiDmaPtr);
    if (Status != XST_SUCCESS) {
        xil_printf("Failed tx connect intc\r\n");
        return XST_FAILURE;
    }

    Status = XIntc_Connect(IntcInstancePtr, RxIntrId,
                           (XInterruptHandler)RxIntrHandler, AxiDmaPtr);
    if (Status != XST_SUCCESS) {
        xil_printf("Failed rx connect intc\r\n");
        return XST_FAILURE;
    }

    /* Start the interrupt controller */
    Status = XIntc_Start(IntcInstancePtr, XIN_REAL_MODE);
    if (Status != XST_SUCCESS) {
        xil_printf("Failed to start intc\r\n");
        return XST_FAILURE;
    }

    XIntc_Enable(IntcInstancePtr, TxIntrId);
    XIntc_Enable(IntcInstancePtr, RxIntrId);

#else

    XScuGic_Config *IntcConfig;

    /*
     * Initialize the interrupt controller driver so that it is ready to
     * use.
     */
    IntcConfig = XScuGic_LookupConfig(INTC_DEVICE_ID);
    if (NULL == IntcConfig) {
        return XST_FAILURE;
    }

    Status = XScuGic_CfgInitialize(IntcInstancePtr, IntcConfig,
                                   IntcConfig->CpuBaseAddress);
    if (Status != XST_SUCCESS) {
        return XST_FAILURE;
    }

    XScuGic_SetPriorityTriggerType(IntcInstancePtr, TxIntrId, 0xA0, 0x3);

    XScuGic_SetPriorityTriggerType(IntcInstancePtr, RxIntrId, 0xA0, 0x3);
    /*
     * Connect the device driver handler that will be called when an
     * interrupt for the device occurs, the handler defined above performs
     * the specific interrupt processing for the device.
     */
    Status = XScuGic_Connect(IntcInstancePtr, TxIntrId,
                             (Xil_InterruptHandler)TxIntrHandler, AxiDmaPtr);
    if (Status != XST_SUCCESS) {
        return Status;
    }

    Status = XScuGic_Connect(IntcInstancePtr, RxIntrId,
                             (Xil_InterruptHandler)RxIntrHandler, AxiDmaPtr);
    if (Status != XST_SUCCESS) {
        return Status;
    }

    XScuGic_Enable(IntcInstancePtr, TxIntrId);
    XScuGic_Enable(IntcInstancePtr, RxIntrId);

#endif

    /* Enable interrupts from the hardware */

    Xil_ExceptionInit();
    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
                                 (Xil_ExceptionHandler)INTC_HANDLER,
                                 (void *)IntcInstancePtr);

    Xil_ExceptionEnable();

    return XST_SUCCESS;
}

/*****************************************************************************/
/**
 *
 * This function disables the interrupts for DMA engine.
 *
 * @param	IntcInstancePtr is the pointer to the INTC component instance
 * @param	TxIntrId is interrupt ID associated w/ DMA TX channel
 * @param	RxIntrId is interrupt ID associated w/ DMA RX channel
 *
 * @return	None.
 *
 * @note		None.
 *
 ******************************************************************************/
static void DisableIntrSystem(INTC *IntcInstancePtr, u16 TxIntrId,
                              u16 RxIntrId) {
#ifdef XPAR_INTC_0_DEVICE_ID
    /* Disconnect the interrupts for the DMA TX and RX channels */
    XIntc_Disconnect(IntcInstancePtr, TxIntrId);
    XIntc_Disconnect(IntcInstancePtr, RxIntrId);
#else
    XScuGic_Disconnect(IntcInstancePtr, TxIntrId);
    XScuGic_Disconnect(IntcInstancePtr, RxIntrId);
#endif
}

void WriteDMA(u32 *TxBufferPtr, int length) {
    int Status;
    Status = XAxiDma_SimpleTransfer(&AxiDma, (UINTPTR)TxBufferPtr, length * 4,
                                    XAXIDMA_DMA_TO_DEVICE);

    if (Status != XST_SUCCESS) {
        return XST_FAILURE;
    }

    Status =
        Xil_WaitForEventSet(POLL_TIMEOUT_COUNTER, NUMBER_OF_EVENTS, &Error);
    if (Status == XST_SUCCESS) {
        if (!TxDone) {
            xil_printf("Transmit error %d\r\n", Status);
        } else if (Status == XST_SUCCESS && !RxDone) {
            xil_printf("Receive error %d\r\n", Status);
        }
    }

    /*
     * Wait for TX done or timeout
     */
    Status =
        Xil_WaitForEventSet(POLL_TIMEOUT_COUNTER, NUMBER_OF_EVENTS, &TxDone);
    if (Status != XST_SUCCESS) {
        xil_printf("Transmit failed %d\r\n", Status);
    }
}

void ReadDMA(u32 *RxBufferPtr, int length) {
    int Status;
    Status = XAxiDma_SimpleTransfer(&AxiDma, (UINTPTR)RxBufferPtr, length * 4,
                                    XAXIDMA_DEVICE_TO_DMA);

    if (Status != XST_SUCCESS) {
        return XST_FAILURE;
    }

    Status =
        Xil_WaitForEventSet(POLL_TIMEOUT_COUNTER, NUMBER_OF_EVENTS, &Error);
    if (Status == XST_SUCCESS) {
        if (!TxDone) {
            xil_printf("Transmit error %d\r\n", Status);
        } else if (Status == XST_SUCCESS && !RxDone) {
            xil_printf("Receive error %d\r\n", Status);
        }
    }

    Status =
        Xil_WaitForEventSet(POLL_TIMEOUT_COUNTER, NUMBER_OF_EVENTS, &RxDone);
    if (Status != XST_SUCCESS) {
        xil_printf("Receive failed %d\r\n", Status);
    }
}
