//
//  HJ720ITDriver.m
//  Omron Bi-LINK Gateway
//
//  Created by S.Stratis on 12/18/14.
//  Copyright (c) 2014 Justin Helmick. All rights reserved.
//

#import "HJ720ITDriver.h"
#include <CoreFoundation/CoreFoundation.h>
#include <string.h>
#include "hidapi.h"
#include "cencode.h"
#include "cdecode.h"
#import "GWUtilities.h"

@implementation HJ720ITDriver

#pragma mark - Constants


static const UInt32 kProductID  = 0x0028;
static const UInt32 kVendorID   = 0x0590;
static const int    kTimeout    = 1000;
hid_device *device;

- (enum Status)getData:(char *)encodedBuffer user:(int)user
{
    int status;
    unsigned char data[64];
    size_t buffer_length = 0;
    NSUInteger size = 1000;
    unsigned char buffer[size];
    int count = 0;
    
    status = hid_init();
    
    /** Handles Device Search & Matching **/
    struct hid_device_info *devs, *cur_dev;
    devs = hid_enumerate(kVendorID, kProductID);
    cur_dev = devs;
    hid_free_enumeration(devs);
    
    /** Open Matched Device **/
    device = hid_open(kVendorID, kProductID, NULL);
    if (device == NULL) {
        NSLog(@"[HJ720ITDriver] - Device not found\n");
        ShutdownDevice(device);
        
        return DeviceNotFound;
    }
    
    /** Set the Pedometer Mode **/
    if(true)
    {
        NSLog(@"[HJ720ITDriver] - Setting Pedometer Mode");
        unsigned char tempReport[] = { 0x0, (0x0102 & 0xff00) >> 8, (0x0102 & 0x00ff)};
        status = hid_send_feature_report(device, tempReport, 8);
        if(status == -1){
            NSLog(@"[HJ720ITDriver] - Error Setting pedometer mode.");
            return -3;
        }
    }
    
    /** Write/Read the setup report **/
    if (true)
    {
        NSLog(@"\n\n[HJ720ITDriver] - Sending Setup Command");
        
        data[0] = 0x00; // ReportID
        data[1] = 0x07;
        data[2] = 0x00;
        data[3] = 0x00;
        data[4] = 0x00;
        data[5] = 0x00;
        data[6] = 0x00;
        data[7] = 0x00;
        data[8] = 0x00;
        
        printf("\n[HJ720ITDriver] - Bytes to Write ");
        for (size_t i = 0; i < 9; i++) {
            printf("%02X ", data[i]);
        }
        
        /** Write Report To The Device, Must Include Length As Last Param. **/
        int result = hid_write(device, data, 9);
        if (result == -1) {
            printf("[HJ720ITDriver] - Error sending Setup command: %ls\n", hid_error(device));
            ShutdownDevice(device);
            
            return DeviceError;
        }
        
        data[0] = 0x00;
        data[1] = 0x05;
        data[2] = 0x00;
        data[3] = 0x00;
        data[4] = 0x00;
        data[5] = 0x00;
        data[6] = 0x00;
        
        printf("\n[HJ720ITDriver] - Bytes to Write ");
        for (size_t i = 0; i < 9; i++) {
            printf("%02X ", data[i]);
        }
        
        int report = hid_write(device, data, 9);
        if (report == -1) {
            printf("[HJ720ITDriver] - Setup Device Write Error: %ls\n", hid_error(device));
            ShutdownDevice(device);
            
            return DeviceError;
        }
        
        if (!ReadReport(data, 2)) {
            printf("[HJ720ITDriver] - Setup Device Read Error: %ls\n", hid_error(device));
            ShutdownDevice();
            
            return DeviceError;
        }
    }
    
    /** Write/Read GetVersion Command **/
    if (true)
    {
        
        NSLog(@"\n\nSending GetVersion Command");
        
        data[0] = 0x00;
        data[1] = 0x05;
        data[2] = 'V';
        data[3] = 'E';
        data[4] = 'R';
        data[5] = '0';
        data[6] = '0';
        
        printf("\n[HJ720ITDriver] - Bytes to Write \n");
        for (size_t i = 0; i < 9; i++) {
            printf("%02X ", data[i]);
        }
        
        /** Send the Report to the device **/
        int result = hid_write(device, data, 9);
        if (result == -1) {
            printf("\n[HJ720ITDriver] - get version wrtie Error: %ls\n", hid_error(device));
            ShutdownDevice();
            
            return DeviceError;
        }
        
        /** Read the response from the device **/
        if (!ReadReport(data, 15)) {
            printf("[HJ720ITDriver] - Get Version Read Error: %ls\n", hid_error(device));
            ShutdownDevice();
            
            return DeviceError;
        }

        if (data[3] != 'H' ||
            data[4] != 'J' ||
            data[5] != '-' ||
            data[6] != '7' ||
            data[7] != '2' ||
            data[8] != '0' ||
            data[9] !='I' ||
            data[10] !='T')
        {
            printf("\n[HJ720ITDriver] - Bytes read \n");
            for (size_t i = 0; i < sizeof(data); i++) {
                printf("%02X ", data[i]);
            }
            
            printf("[HJ720ITDriver] - Device Version is incorrect, Error: %ls\n", hid_error(device));
            ShutdownDevice();
            
            return UnkownModel;
        }
        
        /* Add response data to buffer */
        memcpy(buffer + buffer_length, data, 15);
        buffer_length += 15;    }

    /** Write/Read Get Profile Command **/
    if (true)
    {
        NSLog(@"\n\nSending GetProfile Command");
        
        data[0] = 0x00;
        data[1] = 0x05;
        data[2] = 'P';
        data[3] = 'R';
        data[4] = 'F';
        data[5] = '0';
        data[6] = '0';
        
        printf("\n[HJ720ITDriver] - Bytes to Write \n");
        for (size_t i = 0; i < 9; i++) {
            printf("%02X ", data[i]);
        }
        
        /** Send report to the device. **/
        int result = hid_write(device, data, 9);
        if (result == -1) {
            printf("[HJ720ITDriver] -GetProfile Write error Error: %ls\n", hid_error(device));
            hid_close(device);
            hid_exit();
            
            return DeviceError;
        }

        /** Read the response from the device **/
        if (!ReadReport(data, 14)) {
            printf("[HJ720ITDriver] - Get Profile Read Error: %ls\n", hid_error(device));
            ShutdownDevice();
            
            return DeviceError;
        }

        /* Add data to buffer, response is the size of the data */
        memcpy(buffer + buffer_length, data, 14);
        buffer_length += 14;
    }
    
    /** Write/Read Data Count Command **/
    if (true)
    {
        NSLog(@"\n\nSend the GetDataCount Command");
        
        data[0] = 0x00;
        data[1] = 0x05;
        data[2] = 'C';
        data[3] = 'N';
        data[4] = 'T';
        data[5] = '0';
        data[6] = '0';
        
        printf("[HJ720Driver] - Bytes to write: \n ");
        for (size_t i = 0; i < 9; i++) {
            printf("%02X ", data[i]);
        }
        
        /** Write the report to the device **/
        bool result = hid_write(device, data, 9);
        if (!result) {
            NSLog(@"[HJ720Driver] - Device Error Result From Write Failed");
            printf("[HJ720Driver] - Error: %ls\n", hid_error(device));
            hid_close(device);
            hid_exit();
            
            return DeviceError;
        }
        
        if (!ReadReport(data, 8)) {
            printf("[HJ720ITDriver] - GetDataCount Read Error: %ls\n", hid_error(device));
            ShutdownDevice();
            
            return DeviceError;
        }
        
        /** Add data to buffer **/
        memcpy(buffer + buffer_length, data, 8);
        buffer_length += 8;
        
        count = data[4];
    }
    
    /** Send GetMeasurementData Report **/
    for (int i = 0; i < count; i++)
    {
        printf("\n\n[HJ720ITDriver] - Sending GetMeasurementData Command: %i", i);
        
        data[0] = 0x00; // ReportID
        data[1] = 0x07;
        data[2] = 'M';
        data[3] = 'E';
        data[4] = 'S';
        data[5] = 0x00;
        data[6] = 0x00;
        data[7] = i;
        data[8] = i;
        
        printf("\n[HJ720ITDriver] - Bytes to Write for reading data: \n");
        for (size_t i = 0; i < 9; i++) {
            printf("%02X ", data[i]);
        }
        
        bool result = hid_write(device, data, 9);
        if (!result) {
            printf("[HJ720ITDriver] - Devce Error result from write failed");
            printf("[HJ720ITDriver] - Error: %ls\n", hid_error(device));
            hid_close(device);
            hid_exit();
            
            return DeviceError;
        }
    
        if (!ReadReport(data, 20)) {
            printf("[HJ720ITDriver] - Setup Device Read Error: %ls\n", hid_error(device));
            ShutdownDevice();
            
            return DeviceError;
        }
        
        memcpy(buffer + buffer_length, data, 20);
        buffer_length += 20;
    }
    
    NSData* dataToSend = [NSData dataWithBytes:(const void*)buffer length:sizeof(unsigned char)*size];
    NSLog(@"\n\nNSData object :\n %@", dataToSend);
    
    /* Set deviceData property to our encoded buffer
     * and log out data as encoded string
     */
    self.deviceData = [GWUtilities base64forData:dataToSend];
    NSLog(@"\n \n[HJ720ITDriver] - Driver property encoded buffer \n %@\n\n", self.deviceData);
    
    return Success;
}

- (enum Status)closeDevice:(BOOL)success user:(int)user
{
    unsigned char data[64];
    unsigned char buffer[70];
    int response = 0;
    
    NSLog(@"\n\n[HJ720ITDriver] - Sending End Command");
    
    if (success)
    {
        data[0] = 0x00;
        data[1] = 0x05;
        data[2] = 'E';
        data[3] = 'N';
        data[4] = 'D';
        data[5] = 0xFF;
        data[6] = 0xFF;
        
        /* Log out the report */
        printf("\n[HJ720ITDriver] - Bytes to write for close device setting index: \n");
        for (size_t i = 0; i < sizeof(data); i++) {
            printf("%02X ", data[i]);
        }
        
        /* Send report to the device */
        bool result = hid_write(device, data, sizeof(data));
        if (!result) {
            printf("\n[HEM7130XDriver] - Device Error result from settings index block0 write failed");
            printf("Device Close Error: %ls\n", hid_error(device));
            hid_close(device);
            hid_exit();
            
            return DeviceError;
        }
        
        /* Handle the response */
        response = ReadResponse((unsigned char *)buffer, 25, 0);
        if (response < 0)
        {
            NSLog(@"\n[HEM7130XDriver] - close device setting index response error");
            hid_close(device);
            hid_exit();
            
            return DeviceError;
        }
        NSLog(@"\n\n[HJ720ITDriver] - Closing Device");
    }
    
    ShutdownDevice();
    
    return Success;
}

# pragma mark - Private Functions 


void ShutdownDevice(){
    hid_close(device);
    hid_exit();
}


int ReadResponse(unsigned char *buffer, int bufferSize, int lengthAvailable) {
    int error = 0;
    int bufferOffset = 0;
    int chunkCount = 0;
    unsigned char inputBuffer[8];
    
    if (lengthAvailable == 1) {
        chunkCount = 3;
    }
    if (lengthAvailable == 2) {
        chunkCount = 6;
    }
    if (lengthAvailable == 3) {
        chunkCount = 4;
    }
    
    do {
        error = hid_read_timeout(device, inputBuffer, 8, 500);
        if (error == -1) {
            break;
        }
        
        printf("\n[HJ720ITDriver] Bytes Read ");
        for (size_t i = 0; i < sizeof(inputBuffer); i++) {
            printf("%02X ", inputBuffer[i]);
        }
        
        memcpy(buffer + bufferOffset, inputBuffer, error);
        bufferOffset += error;
        
        /* Decrement the count */
        chunkCount --;
        if ((lengthAvailable != 0) && (chunkCount == 0))
            break;
        
    } while ((error == 8) && (bufferOffset < bufferSize));
    
    if (error == -1) {
        NSLog(@"[HJ720ITDriver] ReadResponse: Device Communication error.");
        return DeviceError;
    } else {
        return Success;
    }
    
}


bool ReadReport(unsigned char *response, int length) {
    int totalBytesRead = 0;
    int bufferOffset = 0;
    unsigned char inputBuffer[8];
    
    while (totalBytesRead < length) {
        
        int report = hid_read(device, inputBuffer, sizeof(inputBuffer));
        if (report == -1) {
            printf("[HJ720ITDriver] - Read Report failed");
            return -1;
        }
        
        printf("\n[HJ720ITDriver] Bytes Read ");
        for (size_t i = 0; i < 8; i++) {
            printf("%02X ", inputBuffer[i]);
        }
        
        totalBytesRead += inputBuffer[0];
        
        memcpy(response + bufferOffset, inputBuffer+1, inputBuffer[0]);
        bufferOffset += inputBuffer[0];
        
        if (totalBytesRead >= 2 && response[0] != 'O') {
            return false;
        }
    }
    return true;
}



@end
