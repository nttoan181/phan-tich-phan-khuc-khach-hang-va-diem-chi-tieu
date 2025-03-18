# 🚀 Phân tích phân khúc khách hàng và dự đoán điểm chi tiêu

## 📌 Giới thiệu
Đây là dự án được thực hiện trong khuôn khổ môn học **Dữ liệu lớn** tại **Trường Đại học Đại Nam**, với đề tài **Phân tích phân khúc khách hàng và dự đoán điểm chi tiêu**. Dự án sử dụng dữ liệu từ **Kaggle** và áp dụng các công cụ như **R, Spark**, và các mô hình **học máy** để phân tích hành vi tiêu dùng của khách hàng.

## 👤 Thành viên nhóm
- 🧑‍💻 Nguyễn Đức Duy  
- 🧑‍💻 Nguyễn Minh Đức  
- 🧑‍💻 Nguyễn Tất Toàn  
- 🧑‍💻 Nguyễn Tiến Dũng  

## 🛠️ Công nghệ sử dụng
- **Ngôn ngữ lập trình**: R  
- **Công cụ xử lý dữ liệu lớn**: Apache Spark  
- **Thư viện chính**: tidyverse, sparklyr, caret, ggplot2  
- **Mô hình phân tích**: RFM (Recency, Frequency, Monetary), Hồi quy tuyến tính  

## 🎯 Mục tiêu dự án
- Phân tích và phân khúc khách hàng dựa trên mô hình RFM.
- Dự đoán điểm chi tiêu của khách hàng dựa trên dữ liệu lịch sử.
- Tối ưu hóa chiến lược tiếp thị và cải thiện trải nghiệm khách hàng.

## 📂 Dữ liệu
- **Nguồn dữ liệu**: Kaggle
- **Số lượng quan sát**: 143,505 giao dịch
- **Biến số**: `InvoiceNo`, `StockCode`, `Description`, `Quantity`, `InvoiceDate`, `UnitPrice`, `CustomerID`, `Country`, `TotalPrice`

## 🛤️ Quy trình thực hiện
### 1️⃣ Tiền xử lý dữ liệu
- 🧹 Làm sạch dữ liệu, loại bỏ các giá trị bị thiếu  
- 🔄 Chuyển đổi dữ liệu và tạo các biến mới như `TotalPrice`  
- ⚡ Kết nối và xử lý dữ liệu trên Apache Spark thông qua `sparklyr`

### 2️⃣ Phân tích phân khúc khách hàng
- 🧐 Áp dụng mô hình **RFM** để phân loại khách hàng  
- 📊 Trực quan hóa dữ liệu bằng **ggplot2**  

### 3️⃣ Dự đoán điểm chi tiêu
- 🔍 Xây dựng mô hình **hồi quy tuyến tính**  
- 📈 Đánh giá hiệu suất mô hình bằng **RMSE, MAE và R²**  

## ✅ Kết quả đạt được
- 🎯 **Phân khúc khách hàng** thành các nhóm: **VIP, Trung thành, Tiềm năng, Vãng lai**
- 🔥 **Dự đoán xu hướng chi tiêu** với độ chính xác tương đối
- 📈 Ứng dụng thực tiễn trong việc **tối ưu hóa chiến lược kinh doanh và tiếp thị**

## 🛠️ Cách chạy chương trình
### Cài đặt các thư viện cần thiết trong R:
```r
install.packages(c("tidyverse", "sparklyr", "caret", "ggplot2"))
```
### Kết nối với Apache Spark:
```r
library(sparklyr)
sc <- spark_connect(master = "local")
```
### Chạy các bước xử lý và phân tích dữ liệu từ file `PT Phân Khúc Khách Hàng.R`
### Chạy các bước dự đoán và đánh giá mô hình từ file `Dự đoán điểm chi tiêu.R`

## 📚 Tài liệu tham khảo
- [Kaggle](https://www.kaggle.com)
- [Apache Spark](https://spark.apache.org/)
- [Tidyverse](https://www.tidyverse.org/)

## 📧 Liên hệ
- **Email**: nguyenducduy2612@icloud.com  
- **Website**: [Khoa Công nghệ Thông tin - Đại học Đại Nam](https://dainam.edu.vn/vi/khoa-cong-nghe-thong-tin)  
