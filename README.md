# Deploy-Scale-MeUp

โปรเจกต์นี้ใช้ AWS ในการ Deploy ระบบที่มีความสามารถในการขยายขนาดอัตโนมัติ โดยใช้ ECR, EC2,และ Auto Scaling Groups + Dynamic scaling policy ในการทำ Step Scaling เพิ่มลดขนาดของ Instance โดยอัตโนมัติ

```shell
npm install
npm run dev
```

## สารบัญ
- [Contributing](#contributing)
- [Architect](#architect)
- [CI/CD Template](#cicd-template)
- [Deployment](#deployment)
- [Load test](#load-test)
- [Auto-scaling](#auto-scaling)



## Contributing

- นางสาวอรุณฉัตร  บุญยัง 6652300109
- นางสาวดวงกมล   พูลเกษม 6652300222
- นายเฉลิมพล     บรรณารรักษ์ 6652300371
- นายคมกฤษณ์   ตังตติยภัทร์  6652300931

##  Architect
####  ภาพที่ 1: Architect Diagram แสดงการทำงานระหว่าง GitHub Actions ไป AWS โดยมีการระบุบริการต่างๆที่เลือกใช้
ภาพนี้แสดง Architect Diagram ที่ใช้ cloud-native บน AWS โดยใช้ CI/CD จาก GitHub ส่งการ deploy ไปที่ AWS ECR และใช้การสเกลอัตโนมัติด้วย Auto Scaling Group และ Load Balancer รองรับโหลดเทสผ่าน K6 โดยใช้ MongoDB Cloud เป็นฐานข้อมูลจากภายนอก.
<img width="1040" height="720" alt="Scalemeup_Workflow" src="https://github.com/user-attachments/assets/d6db87db-b173-4e3a-9694-68578bcc8f15" />


##  CI/CD Template
####  ภาพที่ 2: GitHub Actions Workflow สำหรับการ Deploy ไปยัง AWS ECR
ภาพนี้แสดง **GitHub Actions workflow YML file** ซึ่งกำหนดขั้นตอนในการสร้าง CI/CD pipeline เพื่อทำการ deploy Docker image ไปยัง **AWS ECR** โดย workflow จะทำงานเมื่อมีการ push ไปที่ `main` หรือ `dev` branches และประกอบไปด้วยขั้นตอนการเช็คเอาท์ repository, การตั้งค่าคุณสมบัติของ AWS, การ build, การ tag, และการ push Docker image ไปยัง ECR
![GitHub Actions Workflow สำหรับการ Deploy ไปยัง AWS ECR](https://github.com/ArunChat-BoonYang/Peair/blob/main/image/cicd%20template.png?raw=true)

#### ภาพที่ 3: รายการภาพใน AWS Elastic Container Registry (ECR)
ภาพนี้แสดงหน้า **Amazon ECR** ที่แสดงภาพรายการ Docker ที่ถูกเก็บไว้ใน Amazon ECR พร้อมแสดงแท็กของ Docker image (เช่น `latest`) และเวลาที่อัปโหลดภาพแต่ละอัน ภาพแต่ละอันจะมี URI และ Digest ที่ไม่ซ้ำกันซึ่งใช้ระบุเวอร์ชันของแต่ละ Docker image
![enter image description here](https://github.com/ArunChat-BoonYang/Peair/blob/main/image/cicd%20template%20%E0%B8%82%E0%B8%B2%E0%B8%A7.png?raw=true)

## Deployment
#### ภาพ 4: บันทึกการ Deploy ไปยัง AWS ECS
ภาพนี้แสดง **บันทึกการทำงานใน GitHub Actions** สำหรับการ Deploy แอปพลิเคชันไปยัง **AWS ECS** โดยมีขั้นตอนต่าง ๆ รวมถึงการตั้งค่าคุณสมบัติ AWS, การสร้างและส่ง Docker image ไปยัง Amazon ECR และเสร็จสิ้นกระบวนการ deploy
![enter image description here](https://github.com/ArunChat-BoonYang/Peair/blob/main/image/deploy1.png?raw=true)


## Load test
#### ภาพ 5: หน้าเว็บที่ใช้ในการทดสอบโหลด
ภาพนี้แสดง หน้าเว็บที่ใช้ในการทดสอบโหลด โดยเป็นหน้าเว็บไซต์ที่ใช้อัพโหลดภาพรองรับการ CRUD ผ่าน Mongo DB Cloud โดยลิงก์ที่ใช้ทดสอบหน้าเว็บนี้คือ http://scalemeup-node-alb-609231817.ap-southeast-1.elb.amazonaws.com เป็นลิงก์ที่สร้างจาก Application Load Balancer บน AWS

<img width="1901" height="964" alt="image" src="https://github.com/user-attachments/assets/048fd721-3af7-4990-ba07-be7c56acf141" />

#### ภาพ 6: การตั้งค่าการทดสอบโหลด API ด้วย K6
ภาพนี้แสดงถึง **K6 script สำหรับการทดสอบโหลด** ซึ่งกำหนดขั้นตอนต่าง ๆ ในการปรับขนาดการรับส่งข้อมูล (traffic scaling) โดยเริ่มต้นจากการส่งคำขอที่ 20 RPS (คำขอต่อวินาที) และเพิ่มขึ้นจนถึง 150 RPS ผ่านหลาย ๆ ขั้นตอนของการทดสอบ โดยมีการจำลองโหลดที่มีความคงที่ โดยมีการกำหนด **กรอบเวลาในการหยุดระบบ** (graceful stop) เพื่อให้มั่นใจว่าการหยุดระบบเป็นไปอย่างราบรื่น
![enter image description here](https://github.com/ArunChat-BoonYang/Peair/blob/main/image/L01.jpg?raw=true)

#### ภาพ 7: ฟังก์ชัน HTTP Request ของ K6
โค้ดในภาพนี้มาจาก **K6 script สำหรับการทดสอบโหลด** โดยแสดงวิธีการส่งคำขอ HTTP ไปยัง URL ที่กำหนด พร้อมการเพิ่มพารามิเตอร์ `cache-busting` เพื่อหลีกเลี่ยงการเก็บแคชในระหว่างการทดสอบ และใช้ฟังก์ชัน `check` เพื่อตรวจสอบว่าการตอบสนองของคำขออยู่ในช่วงสถานะ 200 ถึง 400 (แสดงว่าการขอสำเร็จ) และตั้งเวลา timeout ไว้ที่ 30 วินาที
![https://github.com/ArunChat-BoonYang/Peair/blob/main/image/L02.jpg?raw=true](https://github.com/ArunChat-BoonYang/Peair/blob/main/image/L02.jpg?raw=true)

#### ภาพ 8: การดำเนินการของ K6 Test Script
ภาพนี้แสดง **การดำเนินการของ K6 load test** ในเทอร์มินัล โดยใช้คำสั่งที่ระบุ environment variables สำหรับ URL พื้นฐานและเส้นทาง API การทดสอบนี้รันทั้งหมด 118,743 คำขอ และแสดงผลการทดสอบที่รวมทั้งจำนวนคำขอที่สำเร็จและล้มเหลว
![enter image description here](https://github.com/ArunChat-BoonYang/Peair/blob/main/image/Bew1.jpg?raw=true)

#### ภาพ 9: สรุปผลการทดสอบ K6
ภาพนี้แสดง **สรุปผลการทดสอบ K6** ที่แสดงถึงสถิติการทดสอบต่าง ๆ เช่น จำนวนคำขอทั้งหมดที่สำเร็จและล้มเหลว ระยะเวลาการตอบสนอง และข้อมูลเกี่ยวกับ HTTP response โดยแสดงผลว่า 99.98% ของคำขอสำเร็จ
![https://github.com/ArunChat-BoonYang/Peair/blob/main/image/Bew2.jpg?raw=true](https://github.com/ArunChat-BoonYang/Peair/blob/main/image/Bew2.jpg?raw=true)

#### ภาพ 10: K6 ทดสอบโหลดที่กำลังดำเนินการ**
ภาพนี้แสดงการ **ดำเนินการทดสอบโหลดด้วย K6** ที่รันในเทอร์มินัล โดยกำหนดให้ทดสอบกับจำนวนผู้ใช้เสมือน (VUs) สูงสุด 100 คนในระยะเวลา 24 นาที ข้อมูลนี้แสดงการทำงานแบบ real-time ของการทดสอบ และแสดงสถิติเกี่ยวกับการดำเนินการและจำนวนผู้ใช้เสมือนที่กำลังทดสอบ
![https://github.com/ArunChat-BoonYang/Peair/blob/main/image/Bew3.jpg?raw=true](https://github.com/ArunChat-BoonYang/Peair/blob/main/image/Bew3.jpg?raw=true)


## Auto-scaling
### 1.Scaling Up
#### ภาพ 11: กราฟการใช้งาน CPU ของ AWS EC2
ภาพนี้แสดง **กราฟการใช้งาน CPU** ของ **AWS EC2 instance** ที่แสดงการเพิ่มขึ้นของการใช้งาน CPU เมื่อมีการทดสอบโหลด ระบบเริ่มแสดงให้เห็นถึงการใช้งาน CPU ที่สูงขึ้นตามปริมาณการรับส่งข้อมูล
![enter image description here](https://github.com/ArunChat-BoonYang/Peair/blob/main/image/Scal%20up.png?raw=true)

### 2.Scaling Down
#### ภาพ 12: กราฟการลดการใช้งาน CPU หลังจากการปรับขนาดลง
ภาพนี้แสดงการ **ลดการใช้งาน CPU** หลังจากที่มีการปรับลดจำนวนผู้ใช้เสมือน (VUs) การใช้งาน CPU ลดลงเมื่อปริมาณการทดสอบลดลง แสดงถึงการปรับตัวของระบบเมื่อมีการลดปริมาณการรับส่งข้อมูล
![enter image description here](https://github.com/ArunChat-BoonYang/Peair/blob/main/image/scale%20down.png?raw=true)

#### ภาพ 13: log การ Auto-scaling up และ down
ภาพนี้แสดง log การ Auto-scaling up และ down โดยดูได้จากเมนู Auto Scaling groups บน Amazon EC2
<img width="1269" height="272" alt="image" src="https://github.com/user-attachments/assets/48ad6558-31cc-4679-8c4c-8d6aa904160b" />
