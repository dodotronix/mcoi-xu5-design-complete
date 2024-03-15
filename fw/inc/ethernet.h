#ifndef ETHERNET_H_ 
#define ETHERNET_H_

#include <string.h>

#include "platform_config.h"
#include "xil_printf.h"
#include "netif/xadapter.h"
#include "lwip/sockets.h"
#include "netif/xadapter.h"
#include "lwipopts.h"
#include "lwip/init.h"


#if LWIP_IPV6==1
#include "lwip/ip.h"
#else
#if LWIP_DHCP==1
#include "lwip/dhcp.h"
#endif
#endif

#define MAX_CONNECTIONS 8
#define THREAD_STACKSIZE 1024

int main_thread();
void print_echo_app_header();
void echo_application_thread();
void process_echo_request(void *p);
void print_echo_app_header();

#endif /* ETHERNET_H_ */
