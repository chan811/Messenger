//Name: Chanly Ly
//Id: 011039168


#include <unistd.h>
#include <stdio.h>
#include <sys/socket.h>
#include <stdlib.h>
#include <netinet/in.h>

#define PORT 8080

typedef struct //define the huffcode struct
{
    char letter;
    int code[12];
    int size;
} huffcode;

extern int read_huffman(FILE * fptr, huffcode hcode[]);
extern int read_message(FILE * fptr, char message[]);
extern int encode(char message[], huffcode hcode[]);

int main(int argc, char *argv[])
{
    FILE *fptr;                 //create a file pointer
    huffcode hcode[29];         //array made of huffcode used to store huffman code
    char message[10000];        //array used to store message from file to encode and send over to recipient
    int code = 999999999;       //sentinal value to send to receiver to tell them that all the int packets are sent

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

    //open the message to encode and send to recipient
    fptr = fopen("message.txt", "r");

    //read the message and store the message into the char array message[10000]
    read_message(fptr, message);
    fclose(fptr);              //close message.txt

    //set up socket
    int sockfp = socket(AF_INET, SOCK_STREAM, 0);
    struct sockaddr_in address;
    struct sockaddr_in server_address;
    server_address.sin_family = AF_INET;
    server_address.sin_port = htons(PORT);
    inet_pton(AF_INET, "127.0.1.1", &server_address.sin_addr);

    //connect
    connect(sockfp, (struct sockaddr*) &server_address, sizeof(server_address));


    encode(message, hcode); //call encode() to encode the message and send it to the receiver

    write(sockfp, &code, sizeof(code)); //send the sentinal value to the receiver



    close(sockfp); //close socket
    return 0;
}
