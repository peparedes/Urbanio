#include "MLX90621.h"

MLX90621 sensor;

void setup(){ 
  Serial.begin(115200);
  //Serial.println("trying to initialize sensor...");
  sensor.initialise (32); // start the thermo cam with 8 frames per second
  //Serial.println("sensor initialized!");
}

void loop(){
  //sensor.measure(); //get new readings from the sensor
  char cmd;
  byte *tx;
  float tempAtXY=0;
  tx=(byte *)&tempAtXY;
  cmd=Serial.read();
  if(cmd=='M')
    sensor.measure();
  if(cmd>=0&&cmd<64)
  {
          tempAtXY= sensor.getTemperature(cmd); // extract the temperature at position x/y
          Serial.write(tx[0]);
          Serial.write(tx[1]);
          Serial.write(tx[2]);
          Serial.write(tx[3]);
          Serial.write('E');
  }
};

