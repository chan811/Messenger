//Name: Chanly Ly
//Id: 011039168


#include <unistd.h>
#include <stdio.h>
#include <sys/socket.h>
#include <stdlib.h>
#include <netinet/in.h>
#include <wiringPi.h>
#include <softPwm.h>
#include <string.h>

#define PORT 8080

typedef struct  //define the huffcode struct
{
    char letter;
    int code[12];
    int size;
} huffcode;

extern int read_huffman(FILE * fptr, huffcode hcode[]);
extern void decoder(unsigned int e_message, huffcode hcode[], int *c_char, char message[]);
extern void led(int bit);

int main(int argc, char *argv[])
{
    FILE *fptr;             //create a file pointer
    unsigned int code;      //holds the int packet that will be decoded
    int current_char = 0;   //holds the number of chars that were decoded
    int valread = 0;        //holds the flag returned by read()
    int message_length = 0; //holds the length of the message
    char message[10000];    //array used to store decoded message
    huffcode hcode[29];     //array made of huffcode used to store huffman code

  //if no file name arguments in main then open deck.dat to read the huffman code
    if (argc == 1){
        fptr = fopen("huffman.dat", "r");
    }
    else   //else open the string file name given as an argument to main
    {
        fptr = fopen(argv[1], "r");
    }

    //call read_huffman() to read the huffman code from the file and store huffman code into hcode array of structs
    read_huffman(fptr, hcode);

    fclose(fptr);               //close "huffman.dat"

    //socket(Comms for IPv4 - add 6 at end of AF_INET for IPv6, defines if TCP or UCP, defines using internet protocol)
    int sockfp = socket(AF_INET, SOCK_STREAM, 0); //int sockfp contains identifier to socket


    //bind to address
    struct sockaddr_in address;
    address.sin_family = AF_INET; //defines com protocol, must match first arguement of
    address.sin_addr.s_addr = INADDR_ANY; //receive anything
    address.sin_port = htons(PORT);
    bind(sockfp, (struct sockaddr*) &address, sizeof(address));

    //listen
    listen(sockfp, 3); //listen to socket, and 3 is how many people to listen to/size of queue
    //accept connection
    int addrlen = sizeof(address);

    //accept(sockfp, address, address length)
    int new_socket = accept(sockfp, (struct sockaddr*) &address, (socklen_t*) &addrlen);

    while(valread == 0) //keep trying to read until something is read
    {
        //read() returns flag for if value received
        valread = read(new_socket, &code, sizeof(code)); //read the code being sent
    }

    //keep reading codes until the sentinal value is sent
    while(code != 999999999)
    {
        valread = 0; //reset valread to 0

        decoder(code, hcode, &current_char, message); //decode the codes being sent over

        while(valread == 0) //keep trying to read until something is read
        {
            //read() returns flag for if value received
            valread = read(new_socket, &code, sizeof(code)); //read the code being sent
        }

    }

    message_length = strlen(message); //get the length of the decoded message

    for (int i = 0; i < message_length; i++) //loop through message[]
    {
        printf("%c", message[i]); //print the message
    }

    close(sockfp); //close the socket

    return 0;
}
