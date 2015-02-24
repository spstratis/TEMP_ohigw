//
//  HJ322UDriver.m
//  Omron Bi-LINK Gateway
//
//  Created by S.Stratis on 12/17/14.
//  Copyright (c) 2014 Justin Helmick. All rights reserved.
//

#import "HJ322UDriver.h"
#include <CoreFoundation/CoreFoundation.h>
#include <string.h>
#include "hidapi.h"
#include "cencode.h"
#include "cdecode.h"
#import "GWUtilities.h"

@implementation HJ322UDriver

unsigned char measuredDataPointerBlock[64];
hid_device *device;

static const UInt32 kProductID  = 0x0095;
static const UInt32 kVendorID   = 0x0590;
static const int    kTimeout    = 1000;

- (enum Status)getData:(char*)encodedBuffer user:(int)user{
    int response;
    unsigned char data[64];
    //int i;
    size_t buffer_length = 0;
    NSUInteger size = 800;
    unsigned char buffer[size];
    
    response = hid_init();
    
    /** Handles Device Search & Matching **/
    struct hid_device_info *devs, *cur_dev;
    devs = hid_enumerate(kVendorID, kProductID);
    cur_dev = devs;
    hid_free_enumeration(devs);
    
    /** Open Matched Device **/
    device = hid_open(kVendorID, kProductID, NULL);
    if (device == NULL)
    {
        printf("[HJ322Driver] - Device not found\n");
        hid_close(device);
        hid_exit();
        
        return DeviceNotFound;
    }

    
    if (true)
    {
        printf("[HJ322Driver] - Sending Start Command\n");
        
        data[0] = 0x02;
        data[1] = 0x08;
        data[2] = 0x00;
        data[3] = 0x00;
        data[4] = 0x00;
        data[5] = 0x00;
        data[6] = 0x10;
        data[7] = 0x00;
        data[8] = 0x18;
        
        printf("\n[HJ322UDriver] - Bytes to Write \n");
        
        for (size_t i = 0; i < sizeof(data); i++)
        {
            printf("%02X ", data[i]);
        }
        
        /** Write report to the device, must include length as last param. **/
        bool result = hid_write(device, data, 9);
        if (!result)
        {
            printf("[HJ322Driver] - Device Error: %ls\n", hid_error(device));
            hid_close(device);
            hid_exit();
            
            return DeviceError;
        }
        
        /** Read response from device, must pass in response length **/
        response = hid_read_timeout(device, data, sizeof(data), kTimeout);
        
        if(response == 0)
        {
            hid_close(device);
            hid_exit();
            
            return TimedOut;
        }
        
        if (response == -1)
        {
            hid_close(device);
            hid_exit();
            
            return DeviceError;
        }
        
        printf("\n");
        printf("\n[HJ322Driver] - Response Size: %i \n", response);
        
        for (size_t i = 0; i < sizeof(data); i++) {
            printf("%02X ", data[i]);
        }
        
        if (data[2] == 0xFF)
        {
            printf("[HJ322Driver] - Device Error data[2] == 0xFF Error: %ls\n", hid_error(device));
            hid_close(device);
            hid_exit();
            
            return DeviceError;
        }
        
        if (data[7] != 0x00 ||
            data[8] != 0x02 ||
            data[9] != 0x00 ||
            data[10]!= 0x95)
        {
            printf("[HJ322Driver] - Unknown Model Error: %ls\n", hid_error(device));
            hid_close(device);
            hid_exit();
            
            return UnkownModel;
        }
        
        /** Add Bytes to the buffer array **/
        memcpy(buffer + buffer_length, data + 7, 16);
        buffer_length += 16;
    }
    
    /** Set Up Setting Index Report **/
    if (true)
    {
        printf("\n[HJ322Driver] - Reading Settings Index");
        
        data[0] = 0x02;
        data[1] = 0x08;
        data[2] = 0x01;
        data[3] = 0x00;
        data[4] = 0x00;
        data[5] = 0xC0;
        data[6] = 0x30;
        data[7] = 0x00;
        data[8] = 0xF9;
        
        printf("[HJ322Driver] - Reading Settings Index Bytes to write: \n ");
        for (size_t i = 0; i < sizeof(data); i++) {
            printf("%02X ", data[i]);
        }
        
        /** Send Setting Index **/
        bool result = hid_write(device, data, sizeof(data));
        
        if (!result)
        {
            printf("[HJ322Driver] - Deivce error result from write failed, Error: %ls\n", hid_error(device));
            hid_close(device);
            hid_exit();
            
            return DeviceError;
        }
        
        /** Read Settings Index Report **/
        response = hid_read_timeout(device, data, sizeof(data), kTimeout);
        
        if (response == 0)
        {
            hid_close(device);
            hid_exit();
            
            return TimedOut;
        }
        
        if (response == -1)
        {
            hid_close(device);
            hid_exit();
            
            return DeviceError;
        }
        
        if (data[2] == 0xFF) {
            printf("[HJ322Driver] - Device Error on setting index read - Error: %ls\n", hid_error(device));
            hid_close(device);
            hid_exit();
            
            return DeviceError;
        }
        
        /** Add setting index bytes to the buffer **/
        memcpy(buffer + buffer_length, data + 7, 48);
        buffer_length += 48;
        //memcpy(measuredDataPointerBlock, data + 7, 9);
    }
    
    for (int address = 0x0140; address < 0x0400; address += 44)
    {
        printf("\n[HJ322Driver] - Reading daily data 0x%04x \n", address);
        
        data[0] = 0x02; //ReportID
        data[1] = 0x08;
        data[2] = 0x01;
        data[3] = 0x00;
        data[4] = ((address >> 8) & 0xff);
        data[5] = (address & 0xFF);
        data[6] = 0x2C;
        data[7] = 0x00;
        data[8] = (data[1] ^ data[2] ^ data[3] ^ data[4] ^ data[5] ^ data[6] ^ data[7]);
        
        printf("\n[HJ322Driver] - Bytes to Write for reading data: \n");
        for (size_t i = 0; i < sizeof(data); i++) {
            printf("%02X ", data[i]);
        }
        
        /** Send report to the device **/
        bool result = hid_write(device, data, sizeof(data));
        if (!result) {
            printf("[HJ322Driver] - Devce Error result from write failed");
            printf("[HJ322Driver] - Error: %ls\n", hid_error(device));
            hid_close(device);
            hid_exit();
            
            return DeviceError;
        }
        
        /** Read Response Report **/
        response = hid_read_timeout(device, data, sizeof(data), kTimeout);
        if (response == -1) {
            hid_close(device);
            hid_exit();
            
            return TimedOut;
        }
        
        printf("\n");
        printf("\n[HJ322Driver] - Read Data Response size: %i\n", response);
        for (size_t i = 0; i < sizeof(data); i++) {
            printf("%02X ", data[i]);
        }
        
        if (data[2] == 0xFF) {
            printf("[HJ322Driver] - Read Data Device Error");
            hid_close(device);
            hid_exit();
            
            return DeviceError;
        }
        
        memcpy(buffer + buffer_length, data + 7, 44);
        buffer_length += 44;
    }
    NSData* dataToSend = [NSData dataWithBytes:(const void*)buffer length:sizeof(unsigned char)*size];
    NSLog(@"\n\nNSData object :\n %@", dataToSend);
    
    /* Set deviceData property to our encoded buffer
     * and log out data as encoded string
     */
    self.deviceData = [GWUtilities base64forData:dataToSend];
    NSLog(@"\n \n[HJ322UDriver] - Driver property encoded buffer \n %@\n\n", self.deviceData);
    
    
    return Success;
}


- (enum Status)closeDevice:(BOOL)success user:(int)user{
    unsigned char data[64];
    int response;
    
    if (success)
    {
        printf("[HJ322Driver] - Writing setting index Block0");
        
        for (int s = 0; s < sizeof(data); s++)
        {
            data[s] = 0;
        }
        
        data[0] = 0x02;
        data[1] = 0x10;
        data[2] = 0x01;
        data[3] = 0xC0;
        data[4] = 0x01;
        data[5] = 0x00;
        data[6] = 0x08;
        data[7] = measuredDataPointerBlock[0];
        data[8] = measuredDataPointerBlock[1];
        data[9] = measuredDataPointerBlock[2];
        data[10] = measuredDataPointerBlock[3];
        data[11] = 0x01;
        data[12] = 0x01;
        data[13] = measuredDataPointerBlock[6];
        data[14] = measuredDataPointerBlock[7];
        data[15] = 0x00;
        data[16] = (data[1] ^ data[2] ^ data[3] ^ data[4] ^ data[5] ^ data[6] ^
                    data[7] ^ data[8] ^ data[9] ^ data[10] ^ data[11] ^ data[12] ^
                    data[13] ^ data[14] ^ data[15]);
        
        /** Log out the report **/
        printf("\n[HJ322Driver] - Bytes to write for closing device setting index: \n]");
        for (size_t i = 0; i < sizeof(data); i++) {
            printf("%02X ", data[i]);
        }
        
        /** Send The Report to the Device **/
        bool result = hid_write(device, data, sizeof(data));
        if (!result)
        {
            printf("[HJ322Driver] - Device Error results from settings index block0 write failed");
            printf("Error %ls\n", hid_error(device));
            hid_close(device);
            hid_exit();
            
            return DeviceError;
        }
        
        /** Handle the Response **/
        response = hid_read_timeout(device, data, sizeof(data), kTimeout);
        if (response < 0 )
        {
            NSLog(@"\n[HJ322Driver] - Close Decice Setting Error");
            hid_close(device);
            hid_exit();
            
            return DeviceError;
        }
        
        if (data[2] == 0xFF)
        {
            NSLog(@"[HJ322Driver] - Device Error");
            hid_close(device);
            hid_exit();
            
            return DeviceError;
        }
    }
    
    /** Setup Access End Command **/
    if (true)
    {
        NSLog(@"[HJ322Driver] - Sending access end command");
        
        if (success)
        {
            data[0] = 0x02;
            data[1] = 0x08;
            data[2] = 0x0F;
            data[3] = 0x00;
            data[4] = 0x00;
            data[5] = 0x00;
            data[6] = 0x00;
            data[7] = 0x00;
            data[8] = 0x07;
        } else {
            data[0] = 0x02;
            data[1] = 0x08;
            data[2] = 0x0F;
            data[3] = 0x0F;
            data[4] = 0x0F;
            data[5] = 0x0F;
            data[6] = 0x00;
            data[7] = 0x00;
            data[8] = 0x08;
        }
        
        NSLog(@"[HJ322Driver] - Bytes to write:");
        for (size_t i = 0; i < sizeof(data); i++) {
            printf("%02X ", data[i]);
        }
        
        /** Write The End Command To Device **/
        bool result = hid_write(device, data, sizeof(data));
        if (!result) {
            NSLog(@"[HJ322Driver] - Device Error Writing Access End Command");
            hid_close(device);
            hid_exit();
            
            return DeviceError;
        }
        
        response = hid_read_timeout(device, data, sizeof(data), kTimeout);
        if (response < 0)
        {
            hid_close(device);
            hid_exit();
            
            return TimedOut;
        }
        
        if (data[2] == 0xFF)
        {
            NSLog(@"\n[HJ322Driver] - Device error in Access End Command \n");
            hid_close(device);
            hid_exit();
            
            return DeviceError;
        }
        NSLog(@"[HJ322Rdiver] - Closing Device");
    }
    hid_close(device);
    hid_exit();
    
    return Success;
}

@end
