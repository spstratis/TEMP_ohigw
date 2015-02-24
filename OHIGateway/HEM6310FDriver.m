//
//  HEM6310FDriver.m
//  Omron2
//
//  Created by S.Stratis on 3/12/14.
//  Copyright (c) 2014 Justin Helmick. All rights reserved.
//

#include <CoreFoundation/CoreFoundation.h>
#include <string.h>
#include "hidapi.h"
#include "cencode.h"
#include "cdecode.h"
#import "HEM6310FDriver.h"
#import "GWUtilities.h"

@implementation HEM6310FDriver

/**
 * GetData method inherited from GWDriver protocol.
 * Returns a status and updates the deviceData property
 * on the class.
 *
 * Please note majority of the code below is C.
 *
 */

unsigned char measuredDataPointerBlock[64];
hid_device *device;

-(enum Status) getData: (char*) encodedBuffer user: (int) user{
    static const UInt32 GDHEM6310FProductID = 0x0094;
    static const UInt32 GDHEM6310FVendorID = 0x0590;
    static const int timeout = 3000;
    
    int response;
    bool found = FALSE;
    unsigned char data[64];
    int i;
    size_t buffer_length = 0;
    NSUInteger size = 2846;
    unsigned char buffer[size];
    
    response = hid_init();
    
    /* Handle device matching */
    struct hid_device_info *devs, *cur_dev;
    devs = hid_enumerate(GDHEM6310FVendorID, GDHEM6310FProductID);
    cur_dev = devs;
    hid_free_enumeration(devs);
    
    /* Open matched device */
    device = hid_open(GDHEM6310FVendorID, GDHEM6310FProductID, NULL);
    if (device == NULL){
        printf("NFC Tray not found\n");
        hid_close(device);
        hid_exit();
        
        return DeviceNotFound;
    }
    hid_set_nonblocking(device, 0);
    
    /* Setup Access Start command, attempt to send for 20 seconds */
    for (i = 0; i < 24; i++)
    {
        printf("\nSending AccessStart Command\n");
        
        data[0] = 0x02; // reportID
        data[1] = 0x08;
        data[2] = 0x00;
        data[3] = 0x00;
        data[4] = 0x00;
        data[5] = 0x00;
        data[6] = 0x10;
        data[7] = 0x00;
        data[8] = 0x18;
        
        printf("\nBytes to Write \n");
        for (size_t i = 0; i < sizeof(data); i++) {
            printf("%02X ", data[i]);
        }
        
        /* Write report to the device, must include length as last param. */
        bool result = hid_write(device, data, 9);
        if (!result) {
            printf("Device Error");
            printf("Error: %ls\n", hid_error(device));
            hid_close(device);
            hid_exit();
            
            return DeviceError;
        }
        
        /* Read response from device, must pass in response length */
        response = hid_read_timeout(device, data, sizeof(data), timeout);
        if (response == -1) {
            hid_close(device);
            hid_exit();
            
            return TimedOut;
        }
        
        printf("\n");
        printf("\nResponse Size: %i\n", response);
        for (size_t i = 0; i < sizeof(data); i++){
            printf("%02X ", data[i]);
        }
        
        if (response < 0) {
            printf("Unable to read()\n");
        }
        
        if (data[2] == 0xFF) {
            printf("Device Error data[2] == 0xFF");
            printf("Error: %ls\n", hid_error(device));
            hid_close(device);
            hid_exit();
            
            return DeviceError;
        }
        
        if (data[1] == 0x08 && data[7] == 0x00) {
            printf("Device Error data[1] == 0x08 && data[7] == 0x00 \n");
            printf("Error: %ls\n", hid_error(device));
            hid_close(device);
            hid_exit();
            
            return DeviceError;
        }
        
        if (data[1] != 0x18) {
            
            continue;
        }
        
        if (data[7]  != 0x00 ||
            data[8]  != 0x00 ||
            data[9]  != 0x00 ||
            data[10] != 0x94 ||
            data[11] != 0x00 ||
            data[12] != 0x03 )
        {
            printf("unknown model \n");
            printf("Error:  %ls\n", hid_error(device));
        }
        
        found = TRUE;
        
        /* Add bytes to the datafer array */
        memcpy(buffer + buffer_length, data + 7, 16);
        buffer_length += 16;
        
        break;
    }
    
    if (!found) {
        printf("\nDevice not found \n");
        hid_close(device);
        hid_exit();
        
        return DeviceNotFound;
    }
    
    /* Set up setting index report */
    if (true)
    {
        printf("\nReading setting index \n");
        
        data[0] = 0x02; // reportID
        data[1] = 0x08;
        data[2] = 0x01;
        data[3] = 0x00;
        data[4] = 0x0F;
        data[5] = 0x74;
        data[6] = 0x1E;
        data[7] = 0x00;
        data[8] = 0x6C;
        
        // TODO: Check for Cancellation
        
        printf("Bytes to write for setting index: \n");
        for (size_t i = 0; i < sizeof(data); i++) {
            printf("%02X ", data[i]);
        }
        
        /* Send setting index report */
        bool result = hid_write(device, data, 9);
        if (!result) {
            printf("Device Error result from write failed");
            printf("Error: %ls\n", hid_error(device));
            hid_close(device);
            hid_exit();
            
            return DeviceError;
        }
        
        // TODO: Check For Cancellation
        
        /* Read setting index report */
        response = hid_read_timeout(device, data, sizeof(data), timeout);
        if (response == -1) {
            hid_close(device);
            hid_exit();
            
            return TimedOut;
        }
        
        printf("\n");
        printf("Bytes read from setting index \n");
        for (size_t i = 0; i < sizeof(data); i++) {
            printf("%02X ", data[i]);
        }
        
        // TODO: Check For Cancellation
        
        if (data[2] == 0xFF) {
            printf("\nDevice Error on setting index read\n");
            printf("Error: %ls\n", hid_error(device));
            hid_close(device);
            hid_exit();
            
            return DeviceError;
        }
        
        /* Add setting index bytes to the buffer */
        memcpy(buffer + buffer_length, data + 7, 30);
        buffer_length += 30;
    }
    
    /* Setup report to get measurements from device */
    for (int address = 0x0370; address < 0x0370 + 1400 + 1400; address += 28)
    {
        printf("\nReading Data: 0x%04x \n", address);
        
        data[0] = 0x02;
        data[1] = 0x08;
        data[2] = 0x01;
        data[3] = 0x00;
        data[4] = (address >> 8) & 0xff;
        data[5] = (address & 0xff);
        data[6] = 0x1C;
        data[7] = 0x00;
        data[8] = (data[1] ^ data[2] ^ data[3] ^ data[4] ^ data[5] ^ data[6] ^ data[7]);
        
        // TODO: Check For Cancellation
        
        printf("\nBytes to write for reading data: \n");
        for (size_t i = 0; i < sizeof(data); i++) {
            printf("%02X ", data[i]);
        }
        
        /* Send report to the device */
        bool result = hid_write(device, data, 9);
        if (!result) {
            printf("Device Error result from write failed");
            printf("Error: %ls\n", hid_error(device));
            hid_close(device);
            hid_exit();
            
            return DeviceError;
        }
        
        // TODO: Check For Cancellation
        
        /* Read the response report */
        response = hid_read_timeout(device, data, sizeof(data), timeout);
        if (response == -1) {
            hid_close(device);
            hid_exit();
            
            return TimedOut;
        }
        printf("\n");
        printf("\nRead Data response size: %i\n", response);
        for (size_t i = 0; i < sizeof(data); i++) {
            printf("%02X ", data[i]);
        }
        
        // TODO: Check For Cancellation
        
        if (data[2] == 0xFF) {
            printf("read data device error");
            hid_close(device);
            hid_exit();
            
            return DeviceError;
        }
        
        /* Add data elements to the buffer array */
        memcpy(buffer + buffer_length, data + 7, 28);
        buffer_length += 28;
        printf("\nbuffer_length = %zu \n", buffer_length);
    }
    
    if (user == 1)
    {
        /* Zero out setting index, block 0, bytes 3 and 4 */
        for (size_t i = 16 + 2; i < 16; i++){
            buffer[i] = 0x00;
        }
        
        /* Zero out setting index, block 0, bytes 7 and 8 */
        for (size_t i = 16 + 6; i < 16 + 2; i++){
            buffer[i] = 0x00;
        }
        
        /* Zero out setting index, block 2 */
        for (size_t i = 16 + 8 + 6; i < 16 + 8 + 6 + 6; i++){
            buffer[i] = 0x00;
        }
        
        /* Zero out user2 blood pressure data */
        for (size_t i = 16 + 30 + 1400; i < 16 + 30 + 1400 + 1400; i++){
            buffer[i] = 0x00;
        }
        /* Log out the buffer */
        for (size_t i= 0; i < sizeof(buffer); i++) {
            printf("%02X ", buffer[i]);
        }
        /* log out data object */
        NSData* data = [NSData dataWithBytes:(const void*)buffer length:sizeof(unsigned char)*size];
        NSLog(@"\nNSData object :\n %@", data);
        
        /* Set deviceData property to our encoded buffer
         * and log out data as encoded string
         */
        self.deviceData = [GWUtilities base64forData:data];
        NSLog(@"\ndriver property encoded buffer %@\n", self.deviceData);
    }
    else
    {
        /* Zero out setting index, block 0, bytes 1 and 2 */
        for (size_t i = 16; i < 16 + 2; i++){
            buffer[i] = 0x00;
        }
        
        /* Zero out setting index, block 0, bytes 5 and 6 */
        for (size_t i = 16 + 4; i < 16 + 4 +2; i++){
            buffer[i] = 0x00;
        }
        
        /* Zero out setting index, block 1 */
        for (size_t i = 16 + 8; i < 16 + 8 + 6; i++){
            buffer[i] = 0x00;
        }
        
        // Zero out user1 blood pressure data
        for (size_t i = 16 + 30; i < 16 + 30 + 1400; i++){
            buffer[i] = 0x00;
        }
        // Log out the buffer
        for (size_t i= 0; i < sizeof(buffer); i++) {
            printf("%02X ", buffer[i]);
        }
        /* log out data object */
        NSData* data = [NSData dataWithBytes:(const void*)buffer length:sizeof(unsigned char)*size];
        NSLog(@"\nNSData object :\n %@", data);
        
        /* Set deviceData property to our encoded buffer
         * and log out data as encoded string
         */
        self.deviceData = [GWUtilities base64forData:data];
        NSLog(@"\ndriver property encoded buffer %@\n", self.deviceData);
    }
    
    return Success;
}

-(enum Status) closeDevice: (BOOL)success user: (int)user{
    unsigned char data[64];
    int response;
    
    if (success) {
        NSLog(@"Writing settings index block0");
        
        for (int s = 0; s < sizeof(data); s++) {
            data[s] = 0;
        }
        
        data[0] = 0x2;
        data[1] = 0x10;
        data[2] = 0x01;
        data[3] = 0xC0;
        data[4] = 0x0F;
        data[5] = 0x9A;
        data[6] = 0x08;
        data[7] = measuredDataPointerBlock[0];
        data[8] = measuredDataPointerBlock[1];
        data[9] = measuredDataPointerBlock[2];
        data[10] = measuredDataPointerBlock[3];
        data[11] = (user == 1 ? 0x80 : measuredDataPointerBlock[4]);
        data[12] = (user == 1 ? 0x00 : measuredDataPointerBlock[5]);
        data[13] = (user != 1 ? 0x80 : measuredDataPointerBlock[6]);
        data[14] = (user != 1 ? 0x00 : measuredDataPointerBlock[7]);
        data[15] = 0x00;
        data[16] = (data[1] ^ data[2] ^ data[3] ^ data[4] ^ data[5] ^ data[6] ^
                    data [7] ^ data[8] ^ data[9] ^ data[10] ^ data[11] ^ data[12] ^
                    data[13] ^ data[14] ^ data[15]);
        
        // TODO: Check for cancelation
        
        /* Log out our the report */
        printf("\nBytes to write for close device: \n");
        for (size_t i = 0; i < sizeof(data); i++) {
            printf("%02X ", data[i]);
        }

        /* Send report to the device */
        bool result = hid_write(device, data, 9);
        if (!result) {
            printf("Device Error result from write failed");
            printf("Error: %ls\n", hid_error(device));
            hid_close(device);
            hid_exit();
            
            return DeviceError;
        }
        
        // TODO: Check for cancelation
        
        response = hid_read(device, data, sizeof(data));
        if (response < 0) {
            NSLog(@"device response error");
            hid_close(device);
            hid_exit();
            return DeviceError;
        }
        
        printf("Bytes read: \n");
        for (size_t i = 0; i < sizeof(data); i++) {
            printf("%02X", data[i]);
        }
        
        // TODP: Check for cancelation
        
        if (data[2] == 0xFF) {
            NSLog(@"Device error");
            hid_close(device);
            hid_exit();
            return DeviceError;
        }
        
        
    }
    
    /* Setup Access End command */
    if (true)
    {
        printf("\nSending AccessEnd Command \n");
        
        if (success)
        {
            data[0] = 0x02;
            data[1] = 0x08;
            data[2] = 0x0f;
            data[3] = 0x00;
            data[4] = 0x00;
            data[5] = 0x00;
            data[6] = 0x00;
            data[7] = 0x00;
            data[8] = 0x07;
        }
        else
        {
            data[0] = 0x02;
            data[1] = 0x08;
            data[2] = 0x0f;
            data[3] = 0x0f;
            data[4] = 0x0f;
            data[5] = 0x0f;
            data[6] = 0x00;
            data[7] = 0x00;
            data[8] = 0x08;
        }
        
        
        /* Write Commmand */
        bool result = hid_write(device, data, 9);
        if (!result){
            printf("Device Error writing AccessEnd Command");
            hid_close(device);
            hid_exit();
            
            return DeviceError;
        }
        
        /* Read Response & log it */
        response = hid_read(device, data, sizeof(data));
        if (response == -1) {
            hid_close(device);
            hid_exit();
            
            return TimedOut;
        }
        if (data[2] == 0xFF){
            printf("\nDevice error in AccessEnd Command \n");
            hid_close(device);
            hid_exit();
            
            return DeviceError;
        }
        
        printf("Closing Device");
    }
    hid_close(device);
    hid_exit();
    
    return Success;
}

@end