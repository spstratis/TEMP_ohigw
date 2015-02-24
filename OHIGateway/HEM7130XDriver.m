//
//  HEM7130XDriver.m
//  Bi-LINK Gateway
//
//  Created by S.Stratis on 8/21/14.
//  Copyright (c) 2014 Justin Helmick. All rights reserved.
//

#import "HEM7130XDriver.h"
#include <CoreFoundation/CoreFoundation.h>
#include <string.h>
#include "hidapi.h"
#include "cencode.h"
#include "cdecode.h"
#import "GWUtilities.h"

@implementation HEM7130XDriver
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
    static const UInt32 GDHEM7130XProductID = 0x0090;
    static const UInt32 GDHEM7130XVendorID = 0x0590;
    static const int timeout = 3000;
    
    int response;
    bool found = FALSE;
    unsigned char data[64];
    int i;
    size_t buffer_length = 0;
    NSUInteger size = 2846;
    unsigned char buffer[size];
    
    response = hid_init();
    
    /** Handle device matching **/
    struct hid_device_info *devs, *cur_dev;
    devs = hid_enumerate(GDHEM7130XVendorID, GDHEM7130XProductID);
    cur_dev = devs;
    hid_free_enumeration(devs);
    
    /** Open matched device **/
    device = hid_open(GDHEM7130XVendorID, GDHEM7130XProductID, NULL);
    if (device == NULL){
        printf("[HEM7130XDriver] - Device not found\n");
        hid_close(device);
        hid_exit();
        
        return DeviceNotFound;
    }
    hid_set_nonblocking(device, 0);
    
    /** Setup Access Start command, attempt to send for 20 seconds **/
    for (i = 0; i < 24; i++)
    {
        printf("\n[HEM7130XDriver] - Sending AccessStart Command\n");
        
        data[0] = 0x02; // reportID
        data[1] = 0x08;
        data[2] = 0x00;
        data[3] = 0x00;
        data[4] = 0x00;
        data[5] = 0x00;
        data[6] = 0x10;
        data[7] = 0x00;
        data[8] = 0x18;
        
        printf("\n[HEM7130XDriver] - Bytes to Write \n");
        for (size_t i = 0; i < sizeof(data); i++) {
            printf("%02X ", data[i]);
        }
        
        /** Write report to the device, must include length as last param. **/
        bool result = hid_write(device, data, 9);
        if (!result) {
            printf("[HEM7130XDriver] - Device Error");
            printf("[HEM7130XDriver] - Error: %ls\n", hid_error(device));
            hid_close(device);
            hid_exit();
            
            return DeviceError;
        }
        
        /** Read response from device, must pass in response length **/
        response = hid_read_timeout(device, data, sizeof(data), timeout);
        if (response == -1) {
            hid_close(device);
            hid_exit();
            
            return TimedOut;
        }
        
        printf("\n");
        printf("\n[HEM7130XDriver] - Response Size: %i\n", response);
        for (size_t i = 0; i < sizeof(data); i++){
            printf("%02X ", data[i]);
        }
        
        if (response < 0) {
            printf("[HEM7130XDriver] - Unable to read()\n");
        }
        
        if (data[2] == 0xFF) {
            printf("[HEM7130XDriver] - Device Error data[2] == 0xFF");
            printf("[HEM7130XDriver] - Error: %ls\n", hid_error(device));
            hid_close(device);
            hid_exit();
            
            return DeviceError;
        }
        
        /** Check Device Model **/
        if (data[7]  != 0x00 ||
            data[8]  != 0x00 ||
            data[9]  != 0x00 ||
            data[10] != 0x90 ||
            data[11] != 0x02 ||
            (data[12] != 0x09 && data[13] != 0x12))
        {
            printf("[HEM7130XDriver] - Unknown model \n");
            printf("[HEM7130XDriver] - Error:  %ls\n", hid_error(device));
            hid_close(device);
            hid_exit();
            
            return UnkownModel;
        }
        
        found = TRUE;
        
        /** Add bytes to the buffer array **/
        memcpy(buffer + buffer_length, data + 7, 16);
        buffer_length += 16;
        
        break;
    }
    
    /** If device isn't located stop process **/
    if (!found) {
        printf("\n[HEM7130XDriver] - Device not found \n");
        hid_close(device);
        hid_exit();
        
        return DeviceNotFound;
    }
    
    /** Set up setting index report **/
    if (found)
    {
        printf("\n[HEM7130XDriver] - Reading setting index \n");
        
        data[0] = 0x02; // reportID
        data[1] = 0x08;
        data[2] = 0x01;
        data[3] = 0x00;
        data[4] = 0x02;
        data[5] = 0x60;
        data[6] = 0x26; // 38 bytes
        data[7] = 0x00;
        data[8] = 0x4d;
        
        // TODO: Check for Cancellation
        
        printf("[HEM7130XDriver] - Bytes to write for setting index: \n");
        for (size_t i = 0; i < sizeof(data); i++) {
            printf("%02X ", data[i]);
        }
        
        /** Send setting index report **/
        bool result = hid_write(device, data, 9);
        if (!result) {
            printf("[HEM7130XDriver] - Device Error result from write failed");
            printf("[HEM7130XDriver] - Error: %ls\n", hid_error(device));
            hid_close(device);
            hid_exit();
            
            return DeviceError;
        }
        
        // TODO: Check For Cancellation
        
        /** Read setting index report **/
        response = hid_read_timeout(device, data, sizeof(data), timeout);
        if (response == -1) {
            hid_close(device);
            hid_exit();
            
            return TimedOut;
        }
        
        printf("\n");
        printf("[HEM7130XDriver] - Bytes read from setting index \n");
        for (size_t i = 0; i < sizeof(data); i++) {
            printf("%02X ", data[i]);
        }
        
        // TODO: Check For Cancellation
        
        if (data[2] == 0xFF) {
            printf("\n[HEM7130XDriver] - Device Error on setting index read\n");
            printf("[HEM7130XDriver] - Error: %ls\n", hid_error(device));
            hid_close(device);
            hid_exit();
            
            return DeviceError;
        }
        
        /** Add setting index bytes to the buffer **/
        memcpy(buffer + buffer_length, data + 7, 38);
        buffer_length += 38;
    }
    
    /** 
     *   Setup report to get measurements from device
     *   - int numMeasurements should be updated for other models (120 or 200, else you have to recalc step int)
     *   - int step 40 is the largest number that evenly divides both 120*14 and 200*14
     **/
    
    int startAddress = 0x02AC;
    int numMeasurements = 120;
    int step = 40;
    
    for (int address = startAddress; address < startAddress + 14 * numMeasurements; address += step)
    {
        printf("\n[HEM7130XDriver] - Reading Data: 0x%04x \n", address);
        
        data[0] = 0x02; // ReportID
        data[1] = 0x08;
        data[2] = 0x01;
        data[3] = 0x00;
        data[4] = (address >> 8) & 0xff;
        data[5] = (address & 0xff);
        data[6] = step;
        data[7] = 0x00;
        data[8] = (data[1] ^ data[2] ^ data[3] ^ data[4] ^ data[5] ^ data[6] ^ data[7]);
        
        printf("\n[HEM7130XDriver] - Bytes to write for reading data: \n");
        for (size_t i = 0; i < sizeof(data); i++) {
            printf("%02X ", data[i]);
        }
        
        /** Send report to the device **/
        bool result = hid_write(device, data, 9);
        if (!result) {
            printf("[HEM7130XDriver] - Device Error result from write failed");
            printf("[HEM7130XDriver] - Error: %ls\n", hid_error(device));
            hid_close(device);
            hid_exit();
            
            return DeviceError;
        }
        
        /** Read the response report **/
        response = hid_read_timeout(device, data, sizeof(data), timeout);
        if (response == -1) {
            hid_close(device);
            hid_exit();
            
            return TimedOut;
        }
        
        printf("\n");
        printf("\n[HEM7130XDriver] - Read Data response size: %i\n", response);
        for (size_t i = 0; i < sizeof(data); i++) {
            printf("%02X ", data[i]);
        }
        
        
        if (data[2] == 0xFF) {
            printf("[HEM7130XDriver] - read data device error");
            hid_close(device);
            hid_exit();
            
            return DeviceError;
        }
        
        /** Add data elements to the buffer array **/
        memcpy(buffer + buffer_length, data + 7, step);
        buffer_length += step;
        printf("\n[HEM7130XDriver] - buffer_length = %zu \n", buffer_length);
    }
    
    if (user == 1)
    {
        /* Zero out setting index, block 0, bytes 3 and 4 */
        for (size_t i = 16 + 2; i < 16 + 2 + 2; i++){
            buffer[i] = 0x00;
        }
        
        /* Zero out setting index, block 0, bytes 7 and 8 */
        for (size_t i = 16 + 6; i < 16 + 6 + 2; i++){
            buffer[i] = 0x00;
        }
        
        /* Zero out setting index, block 2 */
        for (size_t i = 16 + 8 + 6; i < 16 + 8 + 6 + 6; i++){
            buffer[i] = 0x00;
        }
        
        /* Zero out user2 blood pressure data */
        for (size_t i = 16 + 38 + 14 * numMeasurements / 2; i < 16 + 38 + 14 * numMeasurements; i++){
            buffer[i] = 0x00;
        }
        /* Log out the buffer */
        for (size_t i= 0; i < sizeof(buffer); i++) {
            printf("%02X ", buffer[i]);
        }
        /* log out data object */
        NSData* data = [NSData dataWithBytes:(const void*)buffer length:sizeof(unsigned char)*size];
        NSLog(@"\n[HEM7130XDriver] - User 1 NSData object :\n %@", data);
        
        /**
         * Set deviceData property to our encoded buffer
         * and log out data as encoded string
         */
        self.deviceData = [GWUtilities base64forData:data];
        NSLog(@"\n[HEM7130XDriver] - driver property encoded buffer %@\n", self.deviceData);
    }
    else
    {
        /* Zero out setting index, block 0, bytes 1 and 2 */
        for (size_t i = 16 + 4; i < 16 + 4 + 2; i++){
            buffer[i] = 0x00;
        }
        
        /* Zero out setting index, block 0, bytes 5 and 6 */
        for (size_t i = 16 + 4; i < 16 + 4 + 2; i++){
            buffer[i] = 0x00;
        }
        
        /* Zero out setting index, block 1 */
        for (size_t i = 16 + 8; i < 16 + 8 + 6; i++){
            buffer[i] = 0x00;
        }
        
        // Zero out user1 blood pressure data
        for (size_t i = 16 + 38; i < 16 + 38 + 14 * numMeasurements / 2; i++){
            buffer[i] = 0x00;
        }
        // Log out the buffer
        for (size_t i= 0; i < sizeof(buffer); i++) {
            printf("%02X ", buffer[i]);
        }
        /* log out data object */
        NSData* data = [NSData dataWithBytes:(const void*)buffer length:sizeof(unsigned char)*size];
        NSLog(@"\n[HEM7130XDriver] - User 2 NSData object :\n %@", data);
        
        /* Set deviceData property to our encoded buffer
         * and log out data as encoded string
         */
        self.deviceData = [GWUtilities base64forData:data];
        NSLog(@"\n[HEM7130XDriver] - driver property encoded buffer %@\n", self.deviceData);
    }
    
    return Success;
}

-(enum Status) closeDevice: (BOOL)success user: (int)user
{
    unsigned char data[64];
    int response;
    
    if (success) {
        NSLog(@"\n[HEM7130XDriver] - Writing settings index block0");
        
        for (int s = 0; s < sizeof(data); s++) {
            data[s] = 0;
        }
        
        data[0] = 0x2; // ReportID
        data[1] = 0x10;
        data[2] = 0x01;
        data[3] = 0xC0;
        data[4] = 0x02;
        data[5] = 0x86;
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
        
        
        /* Log out our the report */
        printf("\n[HEM7130XDriver] - Bytes to write for close device setting index: \n");
        for (size_t i = 0; i < sizeof(data); i++) {
            printf("%02X ", data[i]);
        }
        
        /* Send report to the device */
        bool result = hid_write(device, data, 9);
        if (!result) {
            printf("\n[HEM7130XDriver] - Device Error result from settings index block0 write failed");
            printf("Error: %ls\n", hid_error(device));
            hid_close(device);
            hid_exit();
            
            return DeviceError;
        }
        
        /* Handle the response */
        response = hid_read(device, data, sizeof(data));
        if (response < 0) {
            NSLog(@"\n[HEM7130XDriver] - close device setting index response error");
            hid_close(device);
            hid_exit();
            return DeviceError;
        }
        
        printf("[HEM7130XDriver] - close device setting index Bytes read: \n");
        for (size_t i = 0; i < sizeof(data); i++) {
            printf("%02X", data[i]);
        }
        
        if (data[2] == 0xFF) {
            NSLog(@"[HEM7130XDriver] - close device setting index error");
            hid_close(device);
            hid_exit();
            return DeviceError;
        }
    }
    
    /* Setup Access End command */
    if (true)
    {
        printf("\n[HEM7130XDriver] - Sending AccessEnd Command \n");
        
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
        
        
        /* Write the end commmand to device */
        bool result = hid_write(device, data, 9);
        if (!result){
            printf("[HEM7130XDriver] - Device Error writing AccessEnd Command");
            hid_close(device);
            hid_exit();
            
            return DeviceError;
        }
        
        /* Read end command Response & log it */
        response = hid_read(device, data, sizeof(data));
        if (response == -1) {
            hid_close(device);
            hid_exit();
            
            return TimedOut;
        }
        if (data[2] == 0xFF){
            printf("\n[HEM7130XDriver] - Device error in AccessEnd Command \n");
            hid_close(device);
            hid_exit();
            
            return DeviceError;
        }
        
        printf("[HEM7130XDriver] - Closing Device");
    }
    hid_close(device);
    hid_exit();
    
    return Success;
}
@end