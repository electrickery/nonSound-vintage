/* 
 * File:   dfiProcess.h
 * Author: fjkraan
 *
 * Created on February 10, 2012, 7:36 PM
 */

#ifndef DFIPROCESS_H
#define	DFIPROCESS_H

#ifdef	__cplusplus
extern "C" {
#endif

#ifdef	__cplusplus
}
#endif

#endif	/* DFIPROCESS_H */



/* Note: out_level values are used in usage message and on command line */
#define OUT_QUIET 0
#define OUT_SUMMARY 1
#define OUT_TSUMMARY 2
#define OUT_ERRORS 3
#define OUT_IDS 4
#define OUT_HEX 5
#define OUT_RAW 6
#define OUT_SAMPLES 7

/* Window used to undo RX02 MFM transform */
#if 1
#define WINDOW 4   /* change aligned 1000 -> 0101 */
#else
#define WINDOW 12  /* change aligned x01000100010 -> x00101010100 */
#endif

/* Suppress FM address mark detection for a few bit times after each
   data CRC is seen.  Helps prevent seening bogus marks in write
   splices. */
#define WRITE_SPLICE 32


/*
3  trackHi - track high byte
4  trackLo - track low byte
5  headHi  - head high byte
6  headLo  - head low byte
7  sectHi  - sector high byte
8  sectLo  - sector low byte
9  nbyte3  - number of bytes high byte
A  nbyte2  - number of bytes mid-high byte
B  nbyte1  - number of bytes mid-low byte
C  nbyte0  - number of bytes low byte 
 */

struct trackHeader {
    unsigned short track;
    unsigned short head;
    unsigned short sector;
    unsigned int trackSize;
};

#define HISTSIZE 512;

typedef struct  {
    int histSize;
    int hist[512];
} histoGraph_t;

void openImage(char *dImage);
int checkImageHeader();
int isOdd(int value);
unsigned int processTrackHeader(unsigned int pos);
//void initHistArray(histoGraph_t *hist)
//unsigned int processTrack(unsigned int pos, int silent);
//void printHist(histoGraph_t *hist, int printedTresHoldFactor);
//int main(int argc, char** argv);
void initHistArray(histoGraph_t *hist);
void printHist(histoGraph_t *hist, int printedTresHoldFactor);

/* Decoding routines Copyright (C) 2000 Timothy Mann */

void process_bit(int bit);

void process_sample(int sample);

int change_enc(int curenc, int newenc);

void msg(int level, const char *fmt, ...);

int secsize(int sizecode, int encoding);

int mfm_valid_clock(unsigned long long accum);

void check_missing_dam(int dmk_awaiting_dam);

/* Accelerator table to compute the CRC eight bits at a time */
unsigned short const crc16_table[256] = {
  0x0000, 0x1021, 0x2042, 0x3063, 0x4084, 0x50A5, 0x60C6, 0x70E7,
  0x8108, 0x9129, 0xA14A, 0xB16B, 0xC18C, 0xD1AD, 0xE1CE, 0xF1EF,
  0x1231, 0x0210, 0x3273, 0x2252, 0x52B5, 0x4294, 0x72F7, 0x62D6,
  0x9339, 0x8318, 0xB37B, 0xA35A, 0xD3BD, 0xC39C, 0xF3FF, 0xE3DE,
  0x2462, 0x3443, 0x0420, 0x1401, 0x64E6, 0x74C7, 0x44A4, 0x5485,
  0xA56A, 0xB54B, 0x8528, 0x9509, 0xE5EE, 0xF5CF, 0xC5AC, 0xD58D,
  0x3653, 0x2672, 0x1611, 0x0630, 0x76D7, 0x66F6, 0x5695, 0x46B4,
  0xB75B, 0xA77A, 0x9719, 0x8738, 0xF7DF, 0xE7FE, 0xD79D, 0xC7BC,
  0x48C4, 0x58E5, 0x6886, 0x78A7, 0x0840, 0x1861, 0x2802, 0x3823,
  0xC9CC, 0xD9ED, 0xE98E, 0xF9AF, 0x8948, 0x9969, 0xA90A, 0xB92B,
  0x5AF5, 0x4AD4, 0x7AB7, 0x6A96, 0x1A71, 0x0A50, 0x3A33, 0x2A12,
  0xDBFD, 0xCBDC, 0xFBBF, 0xEB9E, 0x9B79, 0x8B58, 0xBB3B, 0xAB1A,
  0x6CA6, 0x7C87, 0x4CE4, 0x5CC5, 0x2C22, 0x3C03, 0x0C60, 0x1C41,
  0xEDAE, 0xFD8F, 0xCDEC, 0xDDCD, 0xAD2A, 0xBD0B, 0x8D68, 0x9D49,
  0x7E97, 0x6EB6, 0x5ED5, 0x4EF4, 0x3E13, 0x2E32, 0x1E51, 0x0E70,
  0xFF9F, 0xEFBE, 0xDFDD, 0xCFFC, 0xBF1B, 0xAF3A, 0x9F59, 0x8F78,
  0x9188, 0x81A9, 0xB1CA, 0xA1EB, 0xD10C, 0xC12D, 0xF14E, 0xE16F,
  0x1080, 0x00A1, 0x30C2, 0x20E3, 0x5004, 0x4025, 0x7046, 0x6067,
  0x83B9, 0x9398, 0xA3FB, 0xB3DA, 0xC33D, 0xD31C, 0xE37F, 0xF35E,
  0x02B1, 0x1290, 0x22F3, 0x32D2, 0x4235, 0x5214, 0x6277, 0x7256,
  0xB5EA, 0xA5CB, 0x95A8, 0x8589, 0xF56E, 0xE54F, 0xD52C, 0xC50D,
  0x34E2, 0x24C3, 0x14A0, 0x0481, 0x7466, 0x6447, 0x5424, 0x4405,
  0xA7DB, 0xB7FA, 0x8799, 0x97B8, 0xE75F, 0xF77E, 0xC71D, 0xD73C,
  0x26D3, 0x36F2, 0x0691, 0x16B0, 0x6657, 0x7676, 0x4615, 0x5634,
  0xD94C, 0xC96D, 0xF90E, 0xE92F, 0x99C8, 0x89E9, 0xB98A, 0xA9AB,
  0x5844, 0x4865, 0x7806, 0x6827, 0x18C0, 0x08E1, 0x3882, 0x28A3,
  0xCB7D, 0xDB5C, 0xEB3F, 0xFB1E, 0x8BF9, 0x9BD8, 0xABBB, 0xBB9A,
  0x4A75, 0x5A54, 0x6A37, 0x7A16, 0x0AF1, 0x1AD0, 0x2AB3, 0x3A92,
  0xFD2E, 0xED0F, 0xDD6C, 0xCD4D, 0xBDAA, 0xAD8B, 0x9DE8, 0x8DC9,
  0x7C26, 0x6C07, 0x5C64, 0x4C45, 0x3CA2, 0x2C83, 0x1CE0, 0x0CC1,
  0xEF1F, 0xFF3E, 0xCF5D, 0xDF7C, 0xAF9B, 0xBFBA, 0x8FD9, 0x9FF8,
  0x6E17, 0x7E36, 0x4E55, 0x5E74, 0x2E93, 0x3EB2, 0x0ED1, 0x1EF0
};

/* Fast way, using table */
#define CALC_CRC1b(crc, c) (((crc) << 8) ^ crc16_table[((crc) >> 8) ^ (c)])

#ifndef calc_crc1
#define calc_crc1 CALC_CRC1b
#endif

/* Constants and globals for decoding */
#define MIXED 0
#define FM 1
#define MFM 2
#define RX02 3
#define N_ENCS 4

#define HISTSIZE 512;

#define MAXSECTORSIZE 1024

typedef struct  {
    int sectorSize;
    unsigned char sectorData[1024];
    int idam;
    int sector;
    int head;
    int track;
    int number;
    int idam_crc1;
    int idam_crc2;
    int dam;
    int data_crc1;
    int data_crc2;
    int encoding;
} sector_t;

#define MAXTRACKSECTORS 30

typedef struct {
    int hardwareTrack;
    int hardwareSide;
    int sectorOrder[30];
    sector_t sector[30];
    int indexMark;
} track_t;

#define JV1_IMG 0
#define JV3_IMG 1
#define DMK_IMG 2
#define IMD_IMG 3
#define D88_IMG 4

typedef struct {
    int skipTracks;
    int out_level;
    int out_file_level;
    int uencoding;
    char *imageFile;
    int imageType;
    FILE *fileHandle;
} userParameters_t ;