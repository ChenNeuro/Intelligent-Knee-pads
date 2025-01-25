#include <Wire.h>
#include <MPU6050.h>

// 初始化 MPU6050
MPU6050 mpu;

// 存储传感器数据
int16_t ax_raw, ay_raw, az_raw;  // 原始加速度数据
int16_t gx_raw, gy_raw, gz_raw;  // 原始陀螺仪数据
float ax, ay, az;                // 转换后的加速度，单位 g
float gx, gy, gz;                // 转换后的角速度，单位 °/s
int16_t temp_raw;                // 原始温度数据
float temperature;               // 转换后的温度数据

void setup() {
  Serial.begin(9600); // 初始化串口通信
  Wire.begin();       // 初始化 I2C

  Serial.println("Initializing MPU6050...");
  mpu.initialize();   // 初始化 MPU6050

  if (!mpu.testConnection()) {
    Serial.println("MPU6050 connection failed!");
    while (1); // 停止程序
  }
  Serial.println("MPU6050 connected.");
  mpu.setFullScaleAccelRange(MPU6050_ACCEL_FS_4); // 将加速度量程改为 ±4g
  mpu.setFullScaleGyroRange(MPU6050_GYRO_FS_500); // 将陀螺仪量程改为 ±500°/s
}

void loop() {
  // 从 MPU6050 获取加速度、陀螺仪和温度数据
  mpu.getMotion6(&ax_raw, &ay_raw, &az_raw, &gx_raw, &gy_raw, &gz_raw);
  temp_raw = mpu.getTemperature();  // 读取原始温度数据

  // 转换加速度为 g，量程 ±2g
  ax = ax_raw / 16384.0;
  ay = ay_raw / 16384.0;
  az = az_raw / 16384.0;

  // 转换角速度为 °/s，量程 ±250°/s
  gx = gx_raw / 131.0;
  gy = gy_raw / 131.0;
  gz = gz_raw / 131.0;

  // 将原始温度数据转换为摄氏度
  // 转换公式：Temperature in °C = (temp_raw / 340.0) + 36.53
  temperature = (temp_raw / 340.0) + 36.53;

  // 将数据通过串口发送
  
  Serial.print(ax); Serial.print(", ");
  Serial.print(ay); Serial.print(", ");
  Serial.print(az); Serial.print(", ");
  Serial.print(gx); Serial.print(", ");
  Serial.print(gy); Serial.print(", ");
  Serial.print(gz); Serial.print(", ");
  Serial.print(temperature); Serial.println(" °C");

  delay(100); // 延迟 100 毫秒
}