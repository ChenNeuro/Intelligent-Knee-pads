import serial
import time

# 配置串口
port = '/dev/cu.usbserial-2130'  # 替换为你的 Arduino 对应的串口号
baudrate = 9600
output_file = 'mpu6050_with_temp_data.csv'

# 打开串口
ser = serial.Serial(port, baudrate, timeout=1)
time.sleep(2)  # 等待串口稳定

# 创建并打开文件
with open(output_file, 'w') as file:
    file.write('ax,ay,az,gx,gy,gz,temperature\n')  # 写入表头

    try:
        while True:
            line = ser.readline().decode('utf-8').strip()  # 读取并解码数据
            if line:  # 如果接收到数据
                print(line)
                file.write(line + '\n')  # 写入文件
    except KeyboardInterrupt:
        print("\n数据记录完成，文件已保存。")

# 关闭串口
ser.close()