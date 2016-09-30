/*---------------------------------------------------------------------------
  --      hello_world.c                                                    --
  --      Christine Chen                                                   --
  --      Fall 2013
  --
  --   --
  --      Updated Spring 2015
  --
  --  Yi Liang
  --
  --   --
  --      For use with ECE 385 Experiment 9                                --
  --      UIUC ECE Department                                              --
  ---------------------------------------------------------------------------*/


#include <stdio.h>
#include <stdlib.h>

#define to_hw_data ((volatile char*) 0x00000070) // actual address here
#define to_hw_sig ((volatile char*) 0x00000060) // actual address here
//#define to_sw_port ((char*) 0x00000050) // actual address here
#define to_sw_sig ((char*) 0x00000040) // actual address here


int main()
{
*to_hw_sig = 0;
//hw hold
//package information
//|7|6|5|4|3|2|1|0|
//
//|7|6|5|4|3|x|x|x|  x-9,8th y-8th
//
//| x    6-0  |y|
//
//| y    7-0
//|

//(1,0,0)
while(1){

    //32 hw input loop


    //char hw_input[96];
/*    for(int i = 0 ; i<96; ++i){
        hw_input[i] = *to_sw_port;

    }*/
    for(int i = 0 ; i<32; ++i){ //32 sw output loop
    int i =0;

    //while(*to_sw_sig != 2){
                        printf("Top");

        *to_hw_sig = 1;
        *to_hw_data = 8;
        while(*to_sw_sig != 1) {        if(*to_sw_sig == 2) break;}//Still in reset state
                        printf("Checkpoint 1\n");
        *to_hw_sig = 2;
        while(*to_sw_sig != 0) {    	if(*to_sw_sig == 2) break;}; //Still in read state
                        printf("Checkpoint 2\n"); 

        *to_hw_sig = 1;
        *to_hw_data = 5;
        while(*to_sw_sig != 1) {    	if(*to_sw_sig == 2) break;} //Still in ACK state
                        printf("Checkpoint 3\n");
        *to_hw_sig = 2;
        while(*to_sw_sig != 0) {    	if(*to_sw_sig == 2) break;} // Still in read state
                        printf("Checkpoint 4\n"); 

        *to_hw_sig = 1;
        *to_hw_data = 3;     //
        while(*to_sw_sig != 1) {    	if(*to_sw_sig == 2) break;}
                        printf("Checkpoint 5\n");
        *to_hw_sig = 2;
        while(*to_sw_sig != 0) {    	if(*to_sw_sig == 2) break;} // Still in read state
                        printf("Checkpoint 6\n");
          

        //i++;
                        printf("%d Bottom\n",i); 

          
          //to_hw_sig =;//signal end of outputing  
          while();

    }

    printf("Outside for32\n");

    *to_hw_sig = 0; //tell hardware done 32 loops
    while(to_hw_sig == 0); //wait for drawing

  }
    /*
    //(0,320,240)
    *to_hw_data = 0x04;
    *to_hw_data = 0x80;
    *to_hw_data = 0xf0;
    //(2,640-8,480-8)
    *to_hw_data = 0x15;
    *to_hw_data = 0x78;
    *to_hw_data = 0xd8;
    */
    // char sprite_id;
    // uint x;
    // uint y;

    // //test 2
    // sprite_id = 0;
    // x = 320;
    // y = 240;
    // *to_hw_data = (sprite_id <<3)| (x>>5)
    // while(to_sw_sig != 1) ;
    // *to_hw_data = ((x<<1)&0xfe| (y>>8)
    // while(to_sw_sig != 1) ;
    // *to_hw_data = y & 0xff;
    // while(to_sw_sig != 1) ;

    // //test 3

    // sprite_id = 0x02;
    // x = 640-16;
    // y = 480-16;
    // *to_hw_data = (sprite_id <<3)| (x>>5);
    // while(to_sw_sig != 1) ;
    // *to_hw_data = ((x<<1)&0xfe| (y>>8);
    // while(to_sw_sig != 1) ;
    // *to_hw_data = y & 0xff;
    // while(to_sw_sig != 1) ;



  //back to hw
}

}
